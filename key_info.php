<?
/*
Usage:
	get client info as array
	https://aspro.ru/support/key_info.php?key=S12-NA-IFFZATWRGB3B7MNQ

	get client info as json
	https://aspro.ru/support/key_info.php?type=json&key=S12-NA-IFFZATWRGB3B7MNQ
*/

error_reporting(E_ERROR | E_PARSE);
header('Content-Type: text/html; charset=utf-8');

$arResult = array();

$key = isset($_REQUEST['key']) ? htmlspecialchars(trim($_REQUEST['key'])) : '';
if(strlen($key)){
	$arResult = getBXKeyInfo($key);
}

$type = isset($_REQUEST['type']) ? htmlspecialchars(trim($_REQUEST['type'])) : '';
if(!in_array($type, array('array', 'json'))){
	$type = 'array';
}

if($type === 'json'){
	echo json_encode($arResult);
}
else{
	echo '<pre>';print_r($arResult);echo '</pre>';
}

function getBXKeyInfo($licenseKey){
	$result = $errstr = '';
	$errno = false;
	$arInfo = array();

	if(strlen($licenseKey)){
		if($fp = fsockopen('www.bitrixsoft.com', 80, $errno, $errstr, 120)){
			$out = "POST /bitrix/updates/us_updater_list.php HTTP/1.0\r\nUser-Agent: BitrixSMUpdater\r\nAccept: */*\r\nHost: www.bitrixsoft.com\r\nAccept-Language: en\r\nContent-type: application/x-www-form-urlencoded\r\nContent-length: 1356\r\n\r\nLICENSE_KEY=".md5($licenseKey)."&lang=ru&SUPD_VER=17.0.7&VERSION=17.0.9&TYPENC=E&SUPD_STS=1&SUPD_URS=0&SUPD_DBS=MYSQL&XE=N&CLIENT_SITE=test&CHHB=test&CSAB=127.0.0.1&SUID=14c864bd810b2ab273e558aa9c175f0b&CANGZIP=N&CLIENT_PHPVER=7.0.8&stable=Y&NGINX=Y&rerere=Y&bitm_main=17.0.9&bitm_abtest=17.0.0&bitm_advertising=17.0.0&bitm_b24connector=17.0.1&bitm_bitrixcloud=17.0.0&bitm_bizproc=17.5.1&bitm_bizprocdesigner=17.0.2&bitm_blog=17.5.2&bitm_calendar=17.5.1&bitm_catalog=17.0.9&bitm_clouds=17.0.0&bitm_cluster=17.0.0&bitm_compression=16.0.0&bitm_conversion=17.0.2&bitm_currency=17.0.3&bitm_eshopapp=16.5.0&bitm_fileman=17.5.0&bitm_form=17.0.1&bitm_forum=17.5.1&bitm_highloadblock=17.0.2&bitm_iblock=17.0.9&bitm_idea=17.5.0&bitm_im=17.1.4&bitm_ldap=17.0.0&bitm_learning=17.5.0&bitm_lists=17.0.6&bitm_mail=17.0.5&bitm_mobileapp=17.0.1&bitm_perfmon=17.0.0&bitm_photogallery=17.0.2&bitm_pull=17.1.0&bitm_report=16.5.1&bitm_sale=17.0.24&bitm_scale=17.0.0&bitm_search=17.0.1&bitm_security=17.0.1&bitm_sender=17.1.2&bitm_seo=17.0.6&bitm_socialnetwork=17.5.5&bitm_socialservices=17.1.4&bitm_statistic=17.0.0&bitm_storeassist=16.0.1&bitm_subscribe=17.0.0&bitm_support=16.0.0&bitm_translate=15.0.0&bitm_vote=17.5.0&bitm_webservice=17.0.0&bitm_wiki=16.0.3&bitm_workflow=17.0.0&bitl_en=&bitl_ru=&SUPD_SRS=0&SUPD_CMP=N&SALE_15=Y&spd=&utf=N&dbv=5.5.50&NS=Y&KDS=Y\r\n";

			fputs($fp, $out);

			$bChunked = false;
			while(!feof($fp)){
				$line = fgets($fp, 4096);
				if($line != "\r\n"){
					if(preg_match("/Transfer-Encoding: +chunked/i", $line)){
						$bChunked = true;
					}
				}
				else{
					break;
				}
			}

			if($bChunked){
				$maxLineSize = 4096;
				$_652347730 = 0;
				$line = fgets($fp, $maxLineSize);
				$line = strtolower($line);
				$inHex = '';
				$i = 0;
				while($i< strlen($line) && in_array($line[$i], array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"))){
					$inHex .= $line[$i];
					$i++;
				}
				$_556910786 = hexdec($inHex);
				while($_556910786 > 0){
					$_672916534 = 0;
					$_1983953956 = (($_556910786 > $maxLineSize) ? $maxLineSize : $_556910786);
					while($_1983953956 > (822-2*411) && $line = fread($fp, $_1983953956)){
						$result .= $line;
						$_672916534 += strlen($line);
						$_1763014943 = $_556910786 - $_672916534;
						$_1983953956 = (($_1763014943 > $maxLineSize) ? $maxLineSize: $_1763014943);
					}
					$_652347730 += $_556910786;
					$line = fgets($fp, $maxLineSize);
					$line = fgets($fp, $maxLineSize);
					$line = strtolower($line);
					$inHex = '';
					$i = 0;
					while($i < strlen($line) && in_array($line[$i], array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"))){
						$inHex .= $line[$i];
						$i++;
					}
					$_556910786 = hexdec($inHex);
				}
			}
			else{
				while($line = fread($fp, 4096)){
					$result .= $line;
				}
			}

			fclose($fp);
		}
	}

	if($result){
		if(preg_match_all('@([A-Z\d_]*)=\"([^"]*)"@', $result, $arMatch)){
			if($arMatch && $arMatch[0]){
				foreach($arMatch[0] as $i => $match){
					$k = $arMatch[1][$i];
					$v = $arMatch[2][$i];
					$arInfo[iconv('cp1251', 'utf-8', $k)] = iconv('cp1251', 'utf-8', $v);
				}

				if(in_array($arInfo['ENC_TYPE'], array('E', 'F', 'D'))){
					$arInfo['DEMO'] = $arInfo['ENC_TYPE'] === 'D' ? 'Y' : 'N';
				}
			}
		}
	}

	//file_put_contents($_SERVER['DOCUMENT_ROOT'].'/key_info.txt', $result, FILE_APPEND);
	return $arResult = array('info' => $arInfo, 'key' => $licenseKey, 'errstr' => $errstr, 'errno' => $errno);
}
?>
