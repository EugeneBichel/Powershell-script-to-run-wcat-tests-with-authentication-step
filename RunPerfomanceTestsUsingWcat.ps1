$body = @{
    Login = "anylogin";
    Password = "anypasswod"
}

$url = "{host}{app}/auth/login"

$response = Invoke-RestMethod -Method Post -Uri $url -Body (ConvertTo-Json $body) -Header @{"Content-Type"="application/json"}

Write-Host "token: " $esponse.Token

$token = $response.Token
$IpAddress = "{ip address}";

$scenarioName = '"WCAT Script"';
$transactionId = '"requests"';
$requestId = '"1000"';
$url = '"/IdentifiApi/auth/validate"';
$postData = '"{\"Token\":\"' + $token + '\", \"IpAddress\":\"' + $IpAddress + '\"}"';
$connectionHeader='"Connection"';
$connectionValue = '"keep-alive"';
$acceptHeader='"Accept"';
$acceptValue = '"application/json"';
$ContentTypeHeader='"Content-Type"';
$ContentTypeValue = '"application/json"';

$HostHeader='"Host"';
$HostValue = '"{target_host}"';

$OriginHeader='"Origin"';
$OriginValue = '"http://localhost"';

$AcceptEncodingHeader='"Accept-Encoding"';
$AcceptEncodingValue = '"gzip, deflate"';

$AcceptLanguageHeader='"Accept-Language"';
$AcceptLanguageValue = '"en-US,en;q=0.8,be;q=0.6,ru;q=0.4"';


$scenario = "scenario
{
  name    = $scenarioName;
  warmup      = 30;
  duration    = 120;
  cooldown    = 10;

  default
  {
    version = HTTP11;
  }

  transaction                        
  {                                  
    id = $transactionId;
    weight = 1;
    
    request
    {
      id = $requestId;
      url = $url;
      secure = true;

      verb = POST;
      postdata = $postData;
      addheader
      {
        name=$HostHeader;
        value=$HostValue;
      }
      addheader
      {
        name=$connectionHeader;
        value=$connectionValue;
      }
      addheader
      {
        name=$acceptHeader;
        value=$acceptValue;
      }
      addheader
      {
        name=$OriginHeader;
        value=$OriginValue;
      }
      addheader
      {
        name=$ContentTypeHeader;
        value=$ContentTypeValue;
      }
      addheader
      {
        name=$AcceptEncodingHeader;
        value=$AcceptEncodingValue;
      }
      addheader
      {
        name=$AcceptLanguageHeader;
        value=$AcceptLanguageValue;
      }
    }
  }
}";

Write-Host $scenario

$scenario | Out-File -Encoding ASCII "script.wcat"

$server = '"{target_host}"';

$settings = "settings
{
	server = $server;
	virtualclients  = 1000;
    clients     = 1;
}";

Write-Host $settings

$settings | Out-File -Encoding ASCII "wcat\psSettings.ubr"

wcat.wsf -terminate -run -clients localhost -t psScript.wcat -f psSettings.ubr -x