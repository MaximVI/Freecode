<?php
define('CURRENT_IP', '178.170.2');
define('ADMIN_MAIL', 'm.ageev@reddock.ru');


$fileWithDomains = fopen(__DIR__.'/domains.txt', 'r');
checkDomainInfo($fileWithDomains);


function checkDomainInfo($domainsInfo) {
    while ($fileRow = fgets($domainsInfo)) {
        $domain = getDomainFromRow($fileRow);
        $domainRecords = getDomainRecords( dns_get_record($domain, DNS_A + DNS_NS) );

        sendMailIfNotCorrect($domainRecords, $domain);
        //file_put_contents(DIR.'/filelog.txt', print_r($info,true),FILE_APPEND);
    }
}

function getDomainFromRow($fileRow) {
    $domain = explode(':', $fileRow)[1];
    return cleanOff($domain);
}


function getDomainRecords($site) {
    $result = [
        'ip' => false,
        'ns1' => false,
        'ns2' => false
    ];
    
    echo '<pre>';
    
    print_r($site);
    echo '</pre>';

    foreach ($site as $siteInfo) {
        $siteInfo['ip'] = isset($siteInfo['ip']) ? $siteInfo['ip'] : '';
        $siteInfo['target'] = isset($siteInfo['target']) ? $siteInfo['target'] : '';

        $result['ip'] = $result['ip'] ?? checkDomainIp($siteInfo['ip']);
        $resultNS = checkDomainTarget($siteInfo['target']);
        $result = array_merge($result, $resultNS);
    }
echo '<pre>';
    
    print_r($result);
    echo '</pre>';
    return $result;
}

function sendMailIfNotCorrect($domainRecords, $domain) {
    if (!$domainRecords['ip']) {
        mail(ADMIN_MAIL, "IP ERROR $domain", "Неверный IP доменного имени. $domain");

        if ( !($domainRecords['ns1'] && $domainRecords['ns2']) ) {
            mail(ADMIN_MAIL, "DNS ERROR $domain", "Неверная NS запись. $domain");
        }
    }
}

function checkDomainIp($ip) {
    return findStringInStart($ip, CURRENT_IP);
}

function checkDomainTarget($target) {
    $allowedNS = [
        'ns1' => [
            'ns1.reddock.ru',
            'dns1.yandex.net',
            'dns2.yandex.net',
        ],
        'ns2' => [
            'ns2.reddock.ru',
            'dns1.yandex.net',
            'dns2.yandex.net',
        ]
    ];
    $result = [];

    foreach($allowedNS as $nsKey => $allowed) {
        if( findStringInStart($target, $nsKey) ) {
            $result[ $nsKey ] = in_array($target, $allowed);
        }
    }
    
    return $result;
}

function cleanOff($string) {
    $cleanedSimbols = [
        '"',
        '\'',
        ',',
    ];
    $string = trim($string);
    $string = str_replace($cleanedSimbols, '', $string);

    return $string;
}

function findStringInStart($currentString, $needString) {
    return strpos($currentString, $needString) === 0;
}
?>