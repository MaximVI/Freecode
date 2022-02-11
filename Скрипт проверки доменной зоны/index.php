<?php

$file = fopen(__DIR__.'/domains.txt', 'r');

while ($rawRow = fgets($file)) {
    $rawDomain = explode(':', $rawRow)[1];
    $domain = cleanOff($rawDomain);

    $info = checkSite(dns_get_record($domain, DNS_A + DNS_NS));
    //file_put_contents(__DIR__.'/filelog.txt', print_r($info,true),FILE_APPEND);
    if (!$info['ip']) {
        mail("m.ageev@reddock.ru", "IP ERROR $domain", "Неверный IP доменного имени.".$domain);
    }
    if ( !($info['ns1'] && $info['ns2']) ) {
        mail("m.ageev@reddock.ru", "DNS ERROR $domain", "Неверная NS запись.".$domain);
    }
}

function checkSite($site) {
    $result = [
        'ip' => false,
        'ns1' => false,
        'ns2' => false
    ];
    foreach ($site as $info) {

        $isNS1 = isset($info['target']) && (strpos($info['target'], 'ns1') === 0);
        $isNS2 = isset($info['target']) && (strpos($info['target'], 'ns2') === 0);

        if (isset($info['ip'])) {
            $result['ip'] = strpos($info['ip'], '178.170.2') === 0;
        } else if ($isNS1) {
            $result['ns1'] = $info['target'] === 'ns1.reddock.ru' || $info['target'] === 'dns1.yandex.net' || $info['target'] === 'dns2.yandex.net';
        } else if ($isNS2) {
            $result['ns2'] = $info['target'] === 'ns2.reddock.ru' || $info['target'] === 'dns2.yandex.net' || $info['target'] === 'dns1.yandex.net';
        }
    }

    return $result;
}

function cleanOff($string) {
    $string = trim($string);
    $string = str_replace('"', '', $string);
    $string = str_replace('\'', '', $string);
    $string = str_replace(',', '', $string);

    return $string;
}
?>