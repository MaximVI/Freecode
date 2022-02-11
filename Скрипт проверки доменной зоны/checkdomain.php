<?
$info = checkSite(dns_get_record($domain, DNS_A + DNS_NS));

if (!$info['ip']) {
    // неверный IP
}
if ( !($info['ns1'] && $info['ns2']) ) {
    // неверные NS записи
}

function checkSite(array $site): array {
    $result = [
        'ip' => false,
        'ns1' => false,
        'ns2' => false
    ];
    foreach ($site as $info) {

        $isNS1 = isset($info['target']) && (strpos($info['target'], 'ns1') === 0);
        $isNS2 = isset($info['target']) && (strpos($info['target'], 'ns2') === 0);

        if (isset($info['ip'])) {
            $result['ip'] = strpos($ip, '178.170') === 0;
        } else if ($isNS1) {
            $result['ns1'] = $info['target'] === 'ns1.reddock.ru';
        } else if ($isNS2) {
            $result['ns2'] = $info['target'] === 'ns2.reddock.ru';
        }
    }

    return $result;
}
?>