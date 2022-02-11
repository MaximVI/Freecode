<?
ini_set('memory_limit', '3200M');

$fileSource = $_SERVER['DOCUMENT_ROOT'].'/transfer.sql';
$fileDestination = $_SERVER['DOCUMENT_ROOT'].'/transfer_.sql';

@unlink($fileDestination);
if(file_exists($fileSource)){
	$chunk = '';

	$hSource = @fopen($fileSource, 'r');
	while(($buffer = fgets($hSource, 4096)) !== false){
        if(($p = strpos($buffer, ';')) !== false){
        	$part0 = substr($buffer, 0, $p + 1);
        	$part1 = substr($buffer, $p + 1);
        	$chunk .= $part0;

        	if(strpos($chunk, 'FULLTEXT') !== false){
        		if(preg_match_all('@ENGINE=([^\s]*)@i', $chunk, $arMatches)){
        		    if($arMatches[1][0] === 'InnoDB'){
        		        $chunk = str_replace($arMatches[1][0], 'MyISAM', $chunk);
        		    }
        		}
        	}

        	@file_put_contents($fileDestination, $chunk, FILE_APPEND);
        	$chunk = $part1;
        }
        else{
        	$chunk .= $buffer;
        }
    }

    @file_put_contents($fileDestination, $chunk, FILE_APPEND);
}

echo 'FINISH HIM';
?>
