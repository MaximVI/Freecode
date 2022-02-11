<?php
//print_r (checkSite(dns_get_record('1int.ru', DNS_A + DNS_NS))); die();

$arResult = array(); 

$file = fopen(__DIR__.'/domain_new.txt', 'r');
while ($rawRow = fgets($file)) {
    $rawDomain = explode(':', $rawRow)[1];
    $domain = cleanOff($rawDomain);

    $arRecords = @dns_get_record($domain, DNS_A + DNS_NS);
    if($arRecords) {
        $info = checkSite($arRecords);
        //file_put_contents(DIR.'/filelog.txt', print_r($info,true),FILE_APPEND);
        if (!$info['ip']) {
            $arResult[] = "IP доменного имени отличается".$domain;
        }
        if ( !($info['ns1'] && $info['ns2']) ) {
            $arResult[] = "Ресурсная запись доменной зоны неверная ".$domain;
        }
    }
    else{
        $arResult[] = "не удалось проверить домен, возможно он не существует ".$domain;
    }
}


mail("m.ageev@reddock.ru", "Check result", $arResult ? implode("\n", $arResult) : "Все хорошо");


function checkSite($site) {
    $result = [
        'ip' => false,
        'ns1' => false,
        'ns2' => false
    ];
    
    foreach ($site as $info) {
        $isNS1 = isset($info['target']) && (strpos($info['target'], 'ns1') === 0);
        $isNS2 = isset($info['target']) && (strpos($info['target'], 'ns2') === 0);

        $result = array(
            'ip' => isset($info['ip']) ? strpos($info['ip'], '178.170.2') === 0 : $result['ip'],
            'ns1' => $isNS1 ? $info['target'] === 'ns1.reddock.ru' || $info['target'] === 'dns1.yandex.net' || $info['target'] === 'dns2.yandex.net': $result['ns1'], 
            'ns2' => $isNS2 ? $info['target'] === 'ns2.reddock.ru' || $info['target'] === 'dns2.yandex.net' || $info['target'] === 'dns1.yandex.net': $result['ns2'],
        );
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
