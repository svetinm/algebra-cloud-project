using namespace System.Net

param($Request, $TriggerMetadata)

Write-Host "HelloFunc triggered."

$name = $Request.Query.name
if (-not $name) {
    $name = "Algebra Student"
}

$body = @"
<!DOCTYPE html>
<html lang="hr">
<head>
  <meta charset="UTF-8"/>
  <title>Algebra Cloud Project – Function App</title>
  <style>
    body { font-family: Arial, sans-serif; background: #107c10; color: white;
           display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    .box { text-align: center; background: rgba(255,255,255,0.1);
           padding: 40px 60px; border-radius: 12px; }
    h1 { font-size: 2.5rem; margin-bottom: 10px; }
    p  { font-size: 1.2rem; opacity: 0.9; }
  </style>
</head>
<body>
  <div class="box">
    <h1>⚡ Azure Function App</h1>
    <p>Hello, $name!</p>
    <p>Algebra Bernays University</p>
    <p>Student: Svetin Matijaš</p>
    <p>Deployed via Azure Function App</p>
  </div>
</body>
</html>
"@

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $body
    Headers    = @{ "Content-Type" = "text/html" }
})
