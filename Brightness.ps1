$timeout = 60
$elapsed = 0
# Start-Sleep 120
while ($elapsed -lt $timeout) {
    $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue
    if ($monitors) { break }
    Start-Sleep 1
    $elapsed++
}
if (-not $monitors) {
    Write-Host 'No monitors detected. Exiting script.'
    exit
}
$Host.UI.RawUI.WindowTitle = 'Brightness Adjuster'
$H = Get-Host
$Win = $H.UI.RawUI.WindowSize
$Win.Height = 10
$Win.Width = 35
$H.UI.RawUI.Set_WindowSize($Win)

$url = 'https://api.weather.com/v3/aggcommon/v3-wx-observations-current;v3-wx-forecast-daily-15day;v3-wx-forecast-hourly-12hour?format=json&geocode=33.3,22.28&units=m&language=tr-tr&apiKey=71f92ea9dd2f4790b92ea9dd2f779061'
$data = Invoke-RestMethod -Uri $url -Method Get

$temprture = $data.'v3-wx-forecast-hourly-12hour'.temperatureFeelsLike
$cldcover = $data.'v3-wx-forecast-hourly-12hour'.cloudCover[0]
$hava = $data.'v3-wx-forecast-hourly-12hour'.wxPhraseLong[0]
$tempout = $temprture[0..5] -join ', '
$cldcover
$ESC = [char]27
$dateTime = Get-Date -Format 'd-MMM...HH:mm:ss'


$Hour = (Get-Date).Hour
if ( $hour -le 7) {
    $contrastLevel = 35
    $brighnessLevel = $hour
}
elseif ($Hour -lt 18 -and $hour -gt 7) {
    $brighnessLevel = [Math]::Min(98, [Math]::Round((24 - $Hour) * 4))
    if ($cldcover) {
        $brighnessLevel = [Math]::Min(98, [Math]::Round((24 - $Hour) * 4 - $cldcover / 3))
    }
    $contrastLevel = 35

}
else {
    $contrastLevel = 50
    $brighnessLevel = [Math]::Min(98, [Math]::Round((24 - $Hour) ))
}
$brighnessLevel


D:\Programlar\ClickMonitor.exe b $brighnessLevel
D:\Programlar\ClickMonitor.exe c $contrastLevel

Write-Host ('=' * 34)
Write-Host '='(' ' * 30)'='
Write-Host "=        $ESC[0;93m$dateTime       ="
Write-Host '='(' ' * 30)'='
Write-Host "=        $ESC[1;94m$tempout      ="
Write-Host '='(' ' * 30)'='
Write-Host "=        $ESC[1;92m*$hava                     ="
Write-Host '='(' ' * 30)'='
Write-Host ("=     $ESC[1;32mbrightness set to $brighnessLevel%      =")
Write-Host '='(' ' * 30)'='
Write-Host ('=' * 34)

Start-Sleep -Seconds 10
# Stop-Process -Name cmd.exe
