$url = $opts['url'];

$curl = curl_init();

set_curl_proxy($curl);
curl_setopt($curl, CURLOPT_URL, $url );
curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST"); 
curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($obj));

$ret = curl_exec($curl);
$code = curl_getinfo($curl, CURLINFO_HTTP_CODE);

var_dump("Response from JSM: " . $ret); //FIXME: proper debugging

if($code != 200) {
    var_dump("Error when sending post request to JSM. Response code: " . $code); //FIXME: proper debugging
    return false;
}

return true;
