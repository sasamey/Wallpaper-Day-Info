# Write-Host 'vars importing 2... ...'
# Start-Sleep -Seconds 2
Set-Location -Path $PSScriptRoot
. '.\vars.ps1'
Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

if (Test-Path 'bgr.png') {
    # Convert the relative path into a full, absolute path for .NET
    $bgrPath = Convert-Path '.\bgr.png'
    Write-Host $bgrPath

    $gfx.DrawImage([Image]::FromFile($bgrPath), 0, 0, 1920, 1080)
}
# Force terminating errors and prepare error log
# $ErrorActionPreference = 'Stop'
# $LogPath = Join-Path $PSScriptRoot 'TxtToWallpaper_error.log'
# try {
# Write-Host 'vars imported............'
# Start-Sleep -Seconds 1

# Create a simple placeholder PNG when an expected icon is missing
function New-PlaceholderImage {
    param(
        [string]$Path,
        [int]$Width = 64,
        [int]$Height = 64,
        [string]$Text = '?'
    )
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }

    $bmp = New-Object System.Drawing.Bitmap $Width, $Height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.Clear([System.Drawing.Color]::FromArgb(255, 240, 240, 240))
        $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 200, 200)), 2
        $g.DrawRectangle($pen, 0, 0, $Width - 1, $Height - 1)
        $fontSize = [Math]::Max(8, [int]([Math]::Min($Width, $Height) / 3))
        $font = New-Object System.Drawing.Font 'Arial', $fontSize, [System.Drawing.FontStyle]::Bold
        $brush = New-Object System.Drawing.SolidBrush [System.Drawing.Color]::FromArgb(80, 80, 80)
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $rectf = New-Object System.Drawing.RectangleF 0, 0, $Width, $Height
        $g.DrawString($Text, $font, $brush, $rectf, $sf)
        $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $g.Dispose()
        $bmp.Dispose()
        if ($pen) { $pen.Dispose() }
        if ($font) { $font.Dispose() }
        if ($brush) { $brush.Dispose() }
    }
}


#----------------------------------------------------------------
#                                                                #
#                            Run or test                         #
#                                                                #
# ---------------------------------------------------------------


$runMinute = (Get-Date).minute
$runn = $false
if ((($runMinute -lt 36) -and ($runMinute -gt 34)) -or (($runMinute -lt 6) -and ($runMinute -gt 4))) {
    if (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet) {
        $runn = $true
        Write-Output 'Live mode: Veriler APIden çekiliyor...'
    }
    else {
        $runn = $false
        Write-Output 'Test modeee: No internet'
    }
}

# $runn = $true
# $runn = $false



#----------------------------------------------------------------------------
#                     Weather Data and Atmosphere Logic
#
#---------------------------------------------------------------------------

$weatherTxtPath = 'weather.txt'
if ($runn) {
    # choose your location and language
    $location = '36.629639,29.123722'
    $language = $PSUICulture  #'tr-tr'
    $url = 'https://api.weather.com/v3/aggcommon/v3-wx-observations-current;v3-wx-forecast-daily-15day;v3-wx-forecast-hourly-12hour?format=json&geocode=' + $location + '&units=m&language=' + $language + '&apiKey=71f92ea9dd2f4790b92ea9dd2f779061'
    $data = Invoke-RestMethod -Uri $url -Method Get
    if ($null -ne $data) {
        $data | ConvertTo-Json -Depth 10 | Out-File -FilePath '.\Test\w.json' -Encoding utf8
    }
    else {
        $data = Get-Content '.\Test\w.json' -Raw | ConvertFrom-Json
        Write-Host 'NO internet data for weather....'
    }
}
else {
    $data = Get-Content '.\Test\w.json' -Raw | ConvertFrom-Json
    # Write-Host 'Test modeeee: Weather data'
}


# 12 saatlik..................................................................
$temp12 = $data.'v3-wx-forecast-hourly-12hour'.temperatureFeelsLike
$tm12 = $data.'v3-wx-forecast-hourly-12hour'.validTimeLocal | ForEach-Object { [datetime]$_ }
$hava12 = $data.'v3-wx-forecast-hourly-12hour'.wxPhraseLong
$vTimeL = $data.'v3-wx-forecast-hourly-12hour'.validTimeLocal | ForEach-Object { [datetime]$_ }
$iconcode12 = $data.'v3-wx-forecast-hourly-12hour'.iconcode
$prChnce12 = $data.'v3-wx-forecast-hourly-12hour'.precipChance
# 15 daily...................................................................
$iconcode30 = $data.'v3-wx-forecast-daily-15day'.daypart[0].iconcode
$hava30 = $data.'v3-wx-forecast-daily-15day'.daypart[0].wxPhraseLong
$temp30 = $data.'v3-wx-forecast-daily-15day'.daypart[0].temperature
$dayNight30 = $data.'v3-wx-forecast-daily-15day'.daypart[0].daypartName
$qPh30 = $data.'v3-wx-forecast-daily-15day'.daypart[0].qpf
$nrtv15 = $data.'v3-wx-forecast-daily-15day'.narrative
# şimdi.......................................................................
$sunrise = [datetime]$data.'v3-wx-observations-current'.sunriseTimeLocal
$sunset = [datetime]$data.'v3-wx-observations-current'.sunsetTimeLocal
$tempnow = $data.'v3-wx-observations-current'.temperatureFeelsLike
$iconcode = $data.'v3-wx-observations-current'.iconcode
$havanow = $data.'v3-wx-observations-current'.wxPhraseLong
$lastme = $data.'v3-wx-observations-current'.validTimeLocal
$cloudn = $data.'v3-wx-observations-current'.cloudCover
$cloudh = $data.'v3-wx-observations-current'.cloudCeiling
$windr = $data.'v3-wx-observations-current'.windDirection
$windspd = $data.'v3-wx-observations-current'.windSpeed
#-------------------------------daytime---------------------------------------

$now = (Get-Date).AddMinutes(0)

$dyinfo = $now.ToString('d dddd')

$todayMidnight = $now.Date
$tomorrowMidnight = $todayMidnight.AddDays(1)

$nowM = ($now - $todayMidnight).TotalMinutes
# Write-Host $todayMidnight $tomorrowMidnight $nowM

if (($sunrise.Hour -lt $now.Hour) -and ($sunset.Hour -gt $now.Hour)) {
    "daytime `n"
    # DAYTIME LOGIC
    $daytime = $true
    $rmnclr = $ornge

    $totalDayMinutes = ($sunset - $sunrise).TotalMinutes
    $elapsedMinutes = ($now - $sunrise).TotalMinutes

    # Progress ratio (0.0 to 1.0)
    $dayProgress = ($elapsedMinutes / $totalDayMinutes) % $totalDayMinutes

    # Your specific split-day logic (noon as anchor)
    $noon = $todayMidnight.AddHours(12)
    $morningDuration = ($noon - $sunrise).TotalMinutes % $totalDayMinutes
    $afternoonDuration = ($sunset - $noon).TotalMinutes % $totalDayMinutes

    $passPm = [math]::Min($elapsedMinutes / $morningDuration, 1)
    $passPa = [math]::Max(($elapsedMinutes - $morningDuration) / $afternoonDuration, 0)

    $rmnM = ($sunset - $now).totalMinutes
    $rateday = $morningDuration / $afternoonDuration

}
else {
    "today Midnight`n"
    $rmnclr = $tquaz
    $daytime = $false

    if ($sunrise -lt $now) {
        $nightStart = $sunset
        $nightEnd = $sunrise.AddDays(1)
        $todayMidnight = $now.Date.AddDays(1)

    }
    else {
        $nightStart = $sunset.AddDays(-1)
        $nightEnd = $sunrise
    }

    $totalDayMinutes = ($nightEnd - $nightStart).TotalMinutes
    $elapsedMinutes = ($now - $nightStart).TotalMinutes % $totalDayMinutes
    $dayProgress = $elapsedMinutes / $totalDayMinutes

    $rmnM = ($nightEnd - $now).totalMinutes

    $morningDuration = ($todayMidnight - $nightStart).TotalMinutes % $totalDayMinutes
    $afternoonDuration = ($nightEnd - $todayMidnight).TotalMinutes % $totalDayMinutes
    $rateday = $morningDuration / $afternoonDuration

    # $ratemrng = $morningDuration.TotalMinutes / $totalDayMinutes
    # $rateevng = $afternoonDuration.TotalMinutes / $totalDayMinutes

    $passPm = [math]::Min($elapsedMinutes / $morningDuration, 1)
    $passPa = [math]::Max(($elapsedMinutes - $morningDuration) / $afternoonDuration, 0)
    # Write-Host "$totalDayMinutes, $elapsedMinutes ,$rateday
}


# Write-Host $totalDayMinutes, $elapsedMinutes  , $rateday = $morningDuration / $afternoonDuration


# todo:add temperature picture and show current temp as visual

# $gfx.FillRectangle($steal, 0, 0, 1920, 1080)
# $gfx.FillRectangle($steal, 1615, 0, 365, 1080)

#----------------------------------------------------------------#
#                                                                #
#             sunset-sunrise line and day weather                #
#                                                                #
# ---------------------------------------------------------------#


# ---------sun horizon side vertical arc lines--------------------------------


$sry = New-Object System.Drawing.Pen $grydrk, 3
$sry2 = New-Object System.Drawing.Pen $grydrkb, 1

# keep suncx calculation
$suncx = $mainRy * 1.25

$sunRect = New-Object System.Drawing.Rectangle ([int]($c1 - $suncx * 1)), ([int]($c2 - $suncx * 2.2)), ([int]($suncx * 2)), ([int]($suncx * 4.4))
# $gfx.drawEllipse($sry, $sunRect)

$gfx.DrawArc($sry, $sunRect, 180 - 45 * $rateday, 90 * $rateday * $passPm )
$gfx.DrawArc($sry2, $sunRect, 180 - 45 * $rateday + 90 * $rateday * $passPm, 90 * $rateday - 90 * $rateday * $passPm)
# $gfx.DrawArc($sry2, $sunRect, 180 - 45 * $rateday + 90 * $rateday * $passPm, 360)

$gfx.DrawArc($sry, $sunRect, 320, $passPa * 80)
# $gfx.DrawArc($sry, $sunRect, 320, 360)
$gfx.DrawArc($sry2, $sunRect, 320 + $passPa * 80, 80 - $passPa * 80 )



# -------------------day weather icon and update time-------------------------

$sunAngle = if ($passPm -lt 1) { 180 + 45 * $rateday * (1 - 2 * $passPm) }else { 315 + $passPa * 90 }
$sunRdn = (360 - $sunAngle) * [System.Math]::PI / 180

$sunx = $c1 + $suncx * [System.Math]::Cos($sunRdn)
$snVx = if ($passPm -lt 1) { 50 }else { 50 }
$suny = if ($passPm -lt 1) { $c2 + $mainRy * $rateday * (1 - 2 * $passPm) }else { $c2 - $mainRy * (1 - 2 * $passPa) }

$srect = New-Object System.Drawing.Rectangle ([int]($sunx - 39)), ([int]($suny - 32)), 64, 64
$imgPath = Join-Path $PSScriptRoot ".\Deluxe\$iconcode.png"
if (Test-Path $imgPath) {
    $img = [System.Drawing.Bitmap]::FromFile($imgPath)
}
else {
    New-PlaceholderImage -Path $imgPath -Width 64 -Height 64 -Text $iconcode
    $img = [Bitmap]::FromFile($imgPath)
    Write-Verbose "Created placeholder image: $imgPath"
}
if ($img) {
    $ia = New-Object System.Drawing.Imaging.ImageAttributes
    $cm = New-Object System.Drawing.Imaging.ColorMatrix
    $cm.Matrix33 = 0.25
    $ia.SetColorMatrix($cm)

    try {
        $gfx.DrawImage($img, $srect, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    }
    finally {
        $img.Dispose()
        $ia.Dispose()
    }
}


# $bgday = $png.GetPixel([int]($sunx - $snVx), [int]($suny + 60))
# $bgdyclr = Contrst $bgday
$gfx.DrawString(([datetime]$lastme).ToString('HH:mm'), $font, $whte, $srect.X + 12, $srect.Y + 70)



#----------------------------------------------------------------# grid
#                                                                #
#             cloud cover and wind speed                         #
#                                                                #
# ---------------------------------------------------------------#
# $cloudn = 100

$imgcldPath = if ($prChnce12[0] -lt 50) { Join-Path $PSScriptRoot '.\Deluxe\26.png' } else { Join-Path $PSScriptRoot ".\Deluxe\$iconcode.png" }
if (Test-Path $imgcldPath) {
    $imgcld = [System.Drawing.Bitmap]::FromFile($imgcldPath)
}
else {
    New-PlaceholderImage -Path $imgcldPath -Width 64 -Height 64 -Text $iconcode
    $imgcld = [Bitmap]::FromFile($imgcldPath)
    Write-Verbose "Created placeholder cloud image: $imgcldPath"
}

$rnd = New-Object System.Random
$cloudh = if ($cloudh -eq 'null') { $cloudh = 0 }else { $cloudn }
for ($i = 1; $i -le $cloudn * 0.1; $i++) {
    $cloudxBase = $Width * 0.5 - $cloudn * 10 + $i * 170 - 60
    $cloudx = $rnd.Next([int]($cloudxBase - 30), [int]($cloudxBase + 30))
    $cloudy = $rnd.Next(-$cloudn, $cloudh * 0.01 - $cloudn)

    $rect = New-Object System.Drawing.Rectangle ([int]$cloudx), ([int]$cloudy), ([int]($cloudn * 3)), ([int]($cloudn * 3))
    if ($imgcld) { $gfx.DrawImage($imgcld, $rect) }
}
if ($imgcld) { $imgcld.Dispose(); $imgcld = $null }

#--------------------------------------------------------------------------#
#                          wind arrows                                     #
# ---------- windspd arrows from wind direction and speed near sunrise-sunset pies-------------------------
# OPTIMIZED: Reuse pen object instead of creating new one each iteration
$windpen = New-Object System.Drawing.Pen $tquaz, 1
try {
    for ($i = - $windspd * 0.25; $i -lt $windspd * 0.25; $i++) {
        $state = $gfx.Save()
        $gfx.TranslateTransform($c1, $c2)
        $gfx.RotateTransform($windr - 90 + $windspd * 0.1 * $i)
        $windpen.Width = [int]$windspd * 0.1
        # $gfx.drawline($windpen, 450, 0, 0, 0)
        $gfx.drawline($windpen, 450 - $windspd * 4 + [math]::abs($i * 5), 0, 450 + $windspd * 4 + [math]::abs($i * 5), 0)
        $gfx.drawline($windpen, 450 - $windspd * 4 + [math]::abs($i * 5), 0, 450 - $windspd * 4 + [math]::abs($i * 5) + $windspd * 0.5, $windspd * 0.5)
        $gfx.drawline($windpen, 450 - $windspd * 4 + [math]::abs($i * 5), 0, 450 - $windspd * 4 + [math]::abs($i * 5) + $windspd * 0.5, - $windspd * 0.5)
        # Write-Host "$i  $( 450 - $windspd * 4 + [math]::abs($i*3))  $windspd"
        $gfx.Restore($state)
    }
}
finally {
    $windpen.Dispose()
}
#------------------------wind density around clock-----------------------------
$state = $gfx.Save()
$gfx.TranslateTransform($c1, $c2)
$gfx.RotateTransform($windr - 90)
# OPTIMIZED: Reuse Random and Brush objects
$rndm = New-Object System.Random
$glowbrushb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 50, 50, 50))
try {
    for ($i = 30; $i -lt $mainRy * $windspd / 30 ; $i += $windspd) {
        # $d = if ($windr -gt 90) { $i}else { $i }
        $hnext = $rndm.Next(-$c2 / 90 * $windspd, $c2 / 90 * $windspd)
        $gradientRect = New-Object System.Drawing.Rectangle ([int]($i + $suncx * 0.65 - $windspd * 2)), ([int]$hnext), ([int]($rndm.Next($windspd , $windspd * 5))), ([int]($rndm.Next(1, 3)))
        # write-host "$i  $hnext $($gradientRect.Size)  $($glowbrushb.Color)"
        $gfx.FillEllipse($tquaz2, $gradientRect )
    }
}
finally {
    $glowbrushb.Dispose()
}
$gfx.Restore($state)








        #----------------------------------------------------------------------------# clock
        #                                                                            #
        #                       Grid lines   for measuring                           #
        #                                                                            #
        #----------------------------------------------------------------------------#

# $fgt = 60
# $tgf = $fgt * 33
# for ($i = 0; $i -lt $tgf; $i += $fgt * 0.25) {
#     if ($i % $fgt -eq 0) {
#         $gfx.DrawLine([Pen]::new([Color]::FromArgb(155, 125, 125, 5), 1), $i , 0, $i , 1080)
#         $gfx.DrawLine([Pen]::new([Color]::FromArgb(155, 125, 125, 5), 1), 0, $i + 0  , $tgf , $i + 0)
#         if ($i -gt 1020) { $ii = -960 + $i }else { $ii = 960 - $i }
#         $gfx.DrawString("$($ii)", $fontSmaller, $gryl, [PointF]::new($i , 530 ))
#         if ($i -gt 500) { $ii = -540 + $i }else { $ii = 540 - $i }
#         $gfx.DrawString("$($ii)", $fontSmaller, $gryl, [PointF]::new(230 , $i))
#     }
#     else {
#         $gfx.DrawLine([Pen]::new([Color]::FromArgb(85, 105, 125, 5), 1), $i , 0, $i , 1080)
#         $gfx.DrawLine([Pen]::new([Color]::FromArgb(85, 105, 125, 5), 1), 0, $i + 0 , $tgf , $i + 0)
#     }
# }

#----------------------------------------------------------------------------#
#                                                                            #
#              Drawing clock   and   hourly temperature                       #
#                                                                            #
# ---------------------------------------------------------------------------#

# color based on temperature
$bgclr = ColorTemp $tempnow 192
$fontclr = Contrst $bgclr.Color

$imgCache = @{}
$cm = New-Object System.Drawing.Imaging.ColorMatrix
$cm.Matrix33 = 0.5
$ia = New-Object System.Drawing.Imaging.ImageAttributes
$ia.SetColorMatrix($cm)

$gr = 0
$rd = 0
$br = 0

# --------------clock inner fill and circle outline----------

$hvv = 0
# saatin iç dolgusu
# $gradientRect = New-Object System.Drawing.Rectangle ([int]($c1 - $mainRx - $hvv)), ([int]($c2 - $mainRy - $hvv)), ([int]($mainRx * 2 + $hvv * 2)), ([int]($mainRy * 2 + $hvv * 2))
# $gradientBrush = [LinearGradientBrush]::new($gradientRect, $colorStart, $colorEnd, 270)
# $gfx.FillEllipse($glowBrushR, $gradientRect)


$mainRxScaled = $mainRx * 1
# saatin dış outline
# $gradientRect = [Rectangle]::new($c1 - $mainRxScaled * 1.1, $c2 - $mainRy * 1.05, $mainRxScaled * 2.2, $mainRy * 2.1)
# $srhy = [Pen]::new($flrc, 1)
# $gfx.drawEllipse($srhy, $gradientRect)

# $gradientRect = [Rectangle]::new($c1 - $mainRxScaled * 1.0, $c2 - $mainRy * 1.0, $mainRxScaled * 2.0, $mainRy * 2.0)
# $srhy = [Pen]::new($flrc, 1)
# $gfx.drawEllipse($srhy, $gradientRect)


$kts = 2.45
# $gfx.FillEllipse($tquaz2, $c1 - $mainRx * $kts, $c2 - $mainRy * $kts, $mainRx *2* $kts, $mainRy * 2 * $kts)
# $gfx.FillEllipse($ornge2, $c1 - $mainRx, $c2 - $mainRy, $mainRx * 2, $mainRy * 2)

# $bghour = $png.getpixel($c1 + 66, $c2)
# $clrd = Contrst $bghour
$hr = $now.Hour
$mn = $now.Minute
$hvv = 0
$nowi = $hr * 4
$nowd = $nowi + [int]($mn / 15)
$nowdf = ($nowi + ($mn / 15))
for ($i = $nowi; $i -lt $nowi + 48; $i++) {
    # $nowd [0,95]   newi [-12,35] i-nowd=[0,47]   idx=(i-nowd)/4=[0,11]
    # Ensure newi is in range 0..47 (always positive)
    $newi = ($i - 12) % 48
    if ($newi -lt 0) { $newi += 48 }
    $startIdx = $i - $nowi # [0,47]

    $pt = $ellipsePoints[$newi]
    $NewTdg = $pt.newT * 180 / [math]::PI

    $newRlen = $pt.newRlen
    $nrx = $c1 + $pt.newRx
    $nry = $c2 + $pt.newRy
    $ofx = $pt.offsetx
    $ofy = $pt.offsety

    $ptnxt = $ellipsePoints[($newi + 1) % 48]
    $nx2 = $c1 + $ptnxt.newRx
    $ny2 = $c2 + $ptnxt.newRx
    $ofx2 = $ptnxt.offsetx
    $ofy2 = $ptnxt.offsety

    # Write-Host "Hour:$i  $newi, $([math]::round($NewTdg))     :::[$([math]::round($nrx)), $([math]::round($nry))]    $([math]::round($($pt.newRlen)))"

    if ( $startIdx -lt 4 ) {
        #[0,47]$startIdx = 0 = now hour ==> $startIdx = 4 = next hour ... $startIdx = 44 = last hour
        $gfx.DrawLine( (New-Object System.Drawing.Pen $glowBrush2, 13), $ofx, $ofy , $ofx2, $ofy2 )
    }
    # else {
    #     $gfx.DrawLine( (New-Object System.Drawing.Pen $grydrk, 1), $ofx, $ofy , $ofx2, $ofy2)
    # }

    $state = $gfx.Save()
    $gfx.TranslateTransform($c1, $c2)
    $gfx.RotateTransform($NewTdg)

    if (($startIdx % 4) -eq 0) {
        $newRlen *= 0.9
        $idx = [math]::min($startIdx / 4, 11) # [0,11]
        # Write-Host "ooHour:$i  $newi  $idx  $startIdx $([math]::round($NewTdg)) "
        $gfx.DrawString("$([int]($i/4)%24)", $font, $gryd, (New-Object System.Drawing.PointF ($mainRx * 0.78), (-10)))
        # current hour temperature on clock arc + weather phrase in center circle
        if ( $idx -eq 0) {
            $gfx.DrawString($tempnow, $fontMid, $bgclr, (New-Object System.Drawing.PointF ($newRlen), ( - 10)))
            $gfx.DrawString($havanow, $fontgf, $bgclr, (New-Object System.Drawing.PointF (30), (-5)))
        }
        else {
            $idx = [math]::min($startIdx / 4 - 1, 11)
            if ($idx -lt 12) {

                # Write-Host "ooHour:$i  $newi  $idx  $startIdx $([math]::round($NewTdg)) "
                $tempclr = ColorTemp $temp12[$idx] 180
                # $glwclr = Contrst $tempclr.Color 180
                # $gfx.FillEllipse($glwclr, $newRlen + $hvv - 30, -10, 24, 20)
                $gfx.DrawString($temp12[$idx], $fontSmaller, $tempclr, (New-Object System.Drawing.PointF ($newRlen ), (-10)))
            }
            $hava12[$idx] = if ($hava12[$idx].length -gt 17) { $hava12[$idx].Substring(0, 17) } else { $hava12[$idx] }
            $hava12clr = if ($prChnce12[$idx] -ge 50) { $tquaz }else { $gryl }
            if ($idx -lt 9) {
                $gfx.DrawString($hava12[$idx], $fontgf, $hava12clr, (New-Object System.Drawing.PointF (30), (-10)))
                # Write-Host "my i-idx:$i  $newi, $idx, $($temp12[$idx])"
            }
        }
    }
    if ( $i -eq $nowd) {
        # saat çubuğu _ akrep=yelkovan
        $gfx.DrawLine( (New-Object System.Drawing.Pen $grydrkb, 5), 0, 0, $newRlen, -2)
        $nowdgre = $NewTdg
    }
    $gfx.Restore($state)
}


# day in the top clock  ==      28 pazar
$gfx.DrawString($dyinfo, $fontmc, $gryl, $c1 - 35, $Height * 0.27)
#---sunrise-set time in the bottom clock--- 11.11.1111 22:07:54
$bootrec = New-Object System.Drawing.RectangleF ($c1 - 45), ($Height * 0.7), 100, 50
$format.FormatFlags = [StringFormatFlags]::NoWrap
$gfx.DrawString("$($sunrise.ToString('HH:mm'))   $($sunset.ToString('HH:mm')) `n $([int]($rmnM/60))s $([int]($rmnM%60))d", $font, $rmnclr, $bootrec, $format)
# ~~~~~~~~
# $gfx.DrawString($now, $font, $bgdyclr, $c1 - 60, $c2 * 1.8)




# -----------daytime or todayMidnight pie--------------circle in the middle -------------------------------
$rpie = $mainrx * 0.9
$rectpie = [System.Drawing.Rectangle]::new(
    [int]([math]::Round($c1 - $rpie)),
    [int]([math]::Round($c2 - $rpie)),
    [int]([math]::Round($rpie * 2)),
    [int]([math]::Round($rpie * 2))
)
$piecl = if ($daytime) { $ornge2 } else { $tquaz2 }
$pieclr = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(5, $piecl.Color))
$gfx.FillPie($pieclr, $rectpie, $nowdgre, 360 * (1 - $dayProgress))
# $gfx.FillPie($pieclr, $gradientRect, 0, 71)











#----------------------------------------------------------------#
#                                                                #
#           Weekly weather ,icons                #
#                                                                #
# ---------------------------------------------------------------#
# $sry = [Pen]::new($glowBrush, 3)
# $gfx.DrawArc($sry, 960 - 360, 80, 360 * 2, 80 * 2, 185, 170)
$flrc = [Color]::FromArgb(250, 0, 0, 0)
$flrb = New-Object System.Drawing.SolidBrush $flrc
$hv = 2
$hy = $height * 0.85
$hymin=$hy
$topy = $hy
$firsty = $hy
for ($hx = 20; $hx -lt 520; $hx += 100) {
    $cod30 = $iconcode30[$hv]
    $img = $null

    try {
        $imgPath30 = Join-Path $PSScriptRoot ".\Deluxe\$cod30.png"
        if (-not $imgCache.ContainsKey($cod30)) {
            if (Test-Path $imgPath30) {
                $imgCache[$cod30] = [Bitmap]::FromFile($imgPath30)
            }
            else {
                New-PlaceholderImage -Path $imgPath30 -Width 32 -Height 32 -Text $cod30
                $imgCache[$cod30] = [Bitmap]::FromFile($imgPath30)
                Write-Verbose "Created placeholder weekly icon: $imgPath30"
            }
        }
        $img = $imgCache[$cod30]
        # if ($hx -gt 20) {
        $hy -= [System.Math]::Min(($temp30[$hv] - $temp30[$hv - 2]) * 20, 80)
        # }
        if ($hy -lt $topy) { $topy = $hy }
        if ($hx -gt 20) {
            $gfx.DrawLine([Pen]::new($grydrk, 1), $hx - 100 + 42, $firsty + 55, $hx + 42, $hy + 55)
        }
        # Write-Host "Day $($hv): $($temp30[$hv])Â°C,  $firsty y-position: $hy, topy: $topy $($temp30[$hv] - $temp30[$hv - 2])"
        $firsty = $hy
        if ($hymin -gt $hy) { $hymin = $hy }
        # Write-Host "Adjusting y-position for day $hv based on temperature difference: $topy  $($temp30[$hv]) $(-$temp30[$hv] + $temp30[$hv-2])  ($hx $hy)"
        $rect = New-Object System.Drawing.Rectangle ([int]$hx), ([int]($hy - 20)), 32, 32
        $iclr = if ($null -ne $qPh30[$hv] -and $qPh30[$hv] -gt 0) { $pink } else { ColorTemp $temp30[$hv] 55 }

        $gfx.FillRectangle($iclr, $hx - 5, $hy - 32, 85, 65)
        $gfx.DrawString($dayNight30[$hv], $fontgf, $flrb, (New-Object System.Drawing.PointF ($hx + 5), ($hy - 32)))
        if ($img) {
            $gfx.DrawImage($img, $rect, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
        }
        $gfx.DrawString($temp30[$hv], $fontin, $flrb, (New-Object System.Drawing.PointF ($hx + 40), ($hy - 10 )))
        $gfx.DrawString($hava30[$hv][0..12] -join '', $fontgf, $flrb, (New-Object System.Drawing.PointF ($hx - 3), ($hy + 18)))
    }
    finally {
        # Image will be disposed after all usage
    }

    $hv += 2
}

# weather narrative today and night
$gfx.DrawString($nrtv15[0], $font, $gryl, 20, $hymin + 100)



#----------------------------------------------------------------#
#                                                                #
#                       Motivation words                         #
#                                                                #
#---------------------------------------------------------------#

$random = New-Object System.Random
$mtvs = $true
if ($mtvs) {
    $strng = Get-Content '.\motive.txt' -Raw
    $motve = $strng -split '\."' | ForEach-Object { $_.Trim() }

    # $chs1 = $random.Next(0, $motve.Count)
    # $gfx.DrawString(($motve)[52], $font, $gryl, [PointF]::new($unt*2 , 3))


    $chs2 = $random.Next(0, $motve.Count)
    $mtvTxt = $gfx.MeasureString($motve[$chs2], $fontmc)
    $gfx.DrawString($motve[$chs2], $fontmc, $gryl, [PointF]::new($width * 0.5 - $mtvTxt.Width * 0.5, $height * 0.93 - $mtvTxt.Height * 0.5))

    # $chs3 = $random.Next(0, $motve.Count)
    # 6. Motivation Quote Card (Bottom Left)
    # New-LayoutCard -X 0 -Y 990 -Width 500 -Height 50 -Title '' -TitleColor 'ornge' -BorderColor 'ornge'
    # $Mtv = $png.GetPixel(960, 960)
    # # $mtv
    # $clrMtv = Contrst $Mtv



    # $rectMtv = [RectangleF]::new($mtvTxt.Width2 * 0.5, -80, $mtvTxt.Width2, $mtvTxt.Height)
    # $rectMtv = New-Object System.Drawing.RectangleF ($mainrx * 0 - $mtvTxt.Width2), ($mainRy * 1.2 - $mtvTxt.Height * 0.5), $mtvTxt.Width2, $mtvTxt.Height

    # $state = $gfx.Save()
    # $gfx.TranslateTransform($c1, $c2)
    # $gfx.RotateTransform(-3)
    # # $gfx.FillRectangle($glowBrushR, $rectMtv)
    # $format.FormatFlags = [StringFormatFlags]::LineLimit

    # $gfx.DrawString($motve[$chs3], $fontmc, $gryl, $rectMtv, $format)
    # # Write-Host $motve[$chs3] -ForegroundColor Cyan
    # $gfx.Restore($state)
}



#----------------------------------------------------------------#
#                                                                #
#                         sport news data                        #
#                                                                #
#----------------------------------------------------------------#
$xml = New-Object System.Xml.XmlDocument
if ($runn) {
    $url = 'https://www.mynet.com/spor/rss'
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    if ($null -ne $response.Content) {
        $response.Content | Out-File -FilePath '.\Test\spor.xml'
        $xml.LoadXml($response.Content)
    }
    else {
        Write-Host 'No internet for Sport news'
        $xml.LoadXml((Get-Content '.\Test\spor.xml' -Raw))
    }
}
else {
    # Write-Host 'Test modeeeee: Sport news            data'
    $xml.LoadXml((Get-Content '.\Test\spor.xml' -Raw))
}
$items = $xml.SelectNodes('//item')
$ttle = 5
$snews = New-Object 'string[,]' $ttle, 1
$i = 0
$items | Select-Object -First $ttle | ForEach-Object {
    $content = $_.SelectSingleNode('title').InnerText
    #+ "`n"
    # $snews[$i, 0] = if ($content.length -gt 68) { $content.Substring(0, 68) } else { $content }
    $sttls = ($content -split '[?!]' | Select-Object -First 1)
    $sttls2 = ($content -split ' ' | Select-Object -First 9)
    $snews[$i, 0] = if ($sttls.Length -gt 48) { $sttls }else { $sttls2 }
    $i += 1
}
# drawing sport new
$dbg = 'Sport news:                '
# circlec -r ($mainRy * 1.85) -dg 198 -text $snews -hozntl $false -fontcrcl $fontgf -grdr $true -clrd $false -mode 'snews'
$yPos = $height * 0.82
# $Mtv = $png.GetPixel(1590, 890)
# # $mtv
# $clrMtv = Contrst $Mtv

for ($n = 0; $n -lt $snews.GetLength(0); $n++) {
    if ($snews[$n, 0]) {
        if ($n % 2 -eq 0) {
            # $stext = $gfx.MeasureString($snews[$n,0], $font)
            # $rectsport = [RectangleF]::new(90, $yPos + $n * 30, $stext.Width2*0.85, $stext.Height)
            # $gfx.FillRectangle($glowBrushR, $rectsport)
            $gfx.DrawString(($snews[$n, 0]), $font, $ornge2, [PointF]::new($width * 0.78 - $n * 5, $yPos + ($n * 22)))
        }
        else {
            $gfx.DrawString(($snews[$n, 0]), $font, $tquaz2, [PointF]::new($width * 0.78 - $n * 5, $yPos + ($n * 22)))
        }
    }
}




#----------------------------------------------------------------#
#                                                                #
#               League tables puan durumu                        #
#                                                                #
# ---------------------------------------------------------------#
#import data from web and create each table amd teams to show
$ligs = @(4339, 4328, 4335, 4332, 4331, 4334, 4480, 4960, 4429, 4562)
if ($now.Month -lt 6 -or $now.Month -gt 8) {
    $ids = $ligs[0..3]
}
else {
    $ids = @(4429)
}
# $ids = @(4339, 4328, 4335, 4332, 4331, 4334, 4429)
$tims = @()
$bordr = $false
for ($t = 0; $t -lt $ids.Count; $t++) {
    if ($runn) {
        $url = 'https://www.thesportsdb.com/api/v1/json/123/lookuptable.php?l=' + $ids[$t]
        try {
            $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
            if ($response.table) {
                $bordr = $true
                # Write-Output "Lig : $($t+1) - Data is being fetched from the API..."
                [System.IO.File]::WriteAllText(
                    ".\Test\etable$t.json",
                    ($response | ConvertTo-Json -Depth 10),
                    [System.Text.Encoding]::UTF8
                )
                $tble = $response.table
            }
            else {
                throw 'API boş tablo döndürdü'
                $bordr=$false
            }
        }
        catch {
            # Write-Output "Lig : $($t+1) - Hata: $($_.Exception.Message). Veriler from backup çekiliyor..."
            $tble = (Get-Content ".\Test\etable$t.json" -Raw | ConvertFrom-Json).table
        }
    }
    else {
        $tble = (Get-Content ".\Test\etable$t.json" -Raw | ConvertFrom-Json).table
    }

    if ($null -ne $tble) {
        # ✓ Her lig için doğru boyutta Newden occurredr
        $ligr = New-Object 'string[,]' $tble.Count, 3

        for ($i = 0; $i -lt $tble.Count; $i++) {
            $team = $tble[$i]
            $tims += $team.strTeam

            # ✓ Güvenli karakter kesme
            $ligr[$i, 0] = if ($team.strTeam.Length -gt 13) { $team.strTeam.Substring(0, 13) } else { $team.strTeam }

            # ✓ Case-insensitive form dönüşümü
            # if ($team.strForm -eq '') { $team.strForm = '-' }
            if ($tble[0].intPlayed -eq 0) { $tble[0].intPlayed = 1 }

            $ligr[$i, 1] = $team.strForm -replace '(?i)w', '' -replace '(?i)d', '1' -replace '(?i)l', '0'

            $ligr[$i, 2] = $team.intPoints

        }
        $maxrt = $ligr[0, 2] / $tble[0].intPlayed
        $dbg = "$($team.strleague)"
        $tablec = [math]::Min(4, $ids.Length)

        $r = $mainRy * 1.98
        $xx = 150 * 360 / (6.24 * $r)
        if ($t -lt $tablec) {
            circlec -r ($r) -dg ($xx * 0.5 * $tablec - $t * $xx) -text ($ligr) -mode 'ligr' -clrd $bordr
        }
    }
}
$tims += @('Liverpool', 'Tottenham Hotspur')





#----------------------------------------------------------------#
#                                                                #
#               NEXT matches leagues and teams                   #
#

$bgnext = $png.GetPixel($unt * 51, 30)
$nxtclr = Contrst $bgnext
# 4960 türkish cup
# your favorite leauges, next match
function NextLeagueMatch {
    param([int]$LeagueId, [int]$YOffset, [string]$MatchName)
    $testFile = ".\Test\eday$($LeagueId).json"

    if ($runn) {
        $url = "https://www.thesportsdb.com/api/v1/json/123/eventsnextleague.php?id=$LeagueId"
        try {
            $response = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing -ErrorAction Stop

            # ✓ Remove BOM then save
            $cleanJson = $response.Content -replace '^\xEF\xBB\xBF', '' -replace '^\uFEFF', ''
            $cleanJson | Out-File -FilePath $testFile -Encoding UTF8

            $data = $cleanJson | ConvertFrom-Json
            $nxtmatch = $data.events | Select-Object -First 1
        }
        catch {
            Write-Output "Veriler $MatchName için çekilirken hata olu?tu: $($_.Exception.Message)"
            Write-Output 'Switching to Test modeeeee...'
        }
    }
    else {
        # ✓ Also remove BOM from file
        $cleanJson = (Get-Content $testFile -Raw) -replace '^\uFEFF', ''
        $data = $cleanJson | ConvertFrom-Json
        $nxtmatch = $data.events | Select-Object -First 1
    }

    if ($null -ne $nxtmatch) {
        $datime = Get-Date -Date $nxtmatch.strTimestamp
        $eventStr = $datime.AddHours(3).ToString('dd MMM  HH:mm') + '    ' + $nxtmatch.strEvent
        # $gfx.FillRectangle($glowBrushR, $unt * 51, $YOffset, 322, 20)
        $gfx.DrawString($eventStr, $fontSmaller, $nxtclr, (New-Object System.Drawing.PointF ($unt * 51), $YOffset))
    }
}

# New-league match
NextLeagueMatch -LeagueId 4480 -YOffset 10 -MatchName 'Champions League Match'
NextLeagueMatch -LeagueId 4429 -YOffset 30 -MatchName 'FIFA World Cup'
NextLeagueMatch -LeagueId 135985 -YOffset 50 -MatchName 'UEFA Nations League '
NextLeagueMatch 4960 -YOffset 70 -MatchName 'Turkish Cup Match'


# your team and country, next match
function NextTeamMatch {
    param([int]$LeagueId, [int]$YOffset, [string]$MatchName)
    $testFile = ".\Test\nexteam$($LeagueId).json"

    if ($runn) {
        $url = "https://www.thesportsdb.com/api/v1/json/123/eventsnext.php?id=$LeagueId"
        try {
            $response = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing -ErrorAction Stop
            # Write-Output "$MatchName : Data is being fetched from the API..."

            # ✓ Remove BOM then save
            $cleanJson = $response.Content -replace '^\xEF\xBB\xBF', '' -replace '^\uFEFF', ''
            $cleanJson | Out-File -FilePath $testFile -Encoding UTF8

            $data = $cleanJson | ConvertFrom-Json
            $nxtmatch = $data.events | Select-Object -First 1
        }
        catch {
            Write-Output "Veriler $MatchName için çekilirken hata occurred: $($_.Exception.Message)"
            Write-Output 'Test modeeeeena geçiliyor...'
        }
    }
    else {
        # ✓ Also remove BOM from file
        $cleanJson = (Get-Content $testFile -Raw) -replace '^\uFEFF', ''
        $data = $cleanJson | ConvertFrom-Json
        $nxtmatch = $data.events | Select-Object -First 1
    }

    if ($null -ne $nxtmatch) {
        $datime = Get-Date -Date $nxtmatch.strTimestamp
        $eventStr = $datime.AddHours(3).ToString('dd MMM  HH:mm') + '    ' + $nxtmatch.strEvent
        # $gfx.FillRectangle($glowBrushR, $unt * 51, $YOffset, 322, 20)
        $gfx.DrawString($eventStr, $fontSmaller, $nxtclr, (New-Object System.Drawing.PointF ($unt * 51 ), $YOffset))
    }
}

# New-team match
NextTeamMatch -LeagueId 133804 -YOffset 90 -MatchName 'Gs'            #your team code
NextTeamMatch -LeagueId 135985 -YOffset 110 -MatchName 'Milli takım'  #your country code





#----------------------------------------------------------------
#
#                        Today's matches
#        4339, 4328, 4335, 4332, 4331, 4334                                                        #
# ---------------------------------------------------------------

$fontmc = [Font]::New('Segoe UI Variable Text', 10, [FontStyle]::Bold)
$mtchs = @()
# $ligs = @('Turkish Super Lig', 'English Premier League', 'Spanish La Liga', 'Italian Serie A', 'German Bundesliga', 'French Ligue 1', 'Turkish Cup', 'EFL Cup', 'FA Cup', 'UEFA Champions League', 'UEFA Europa League')

$day = (Get-Date).AddDays(0).AddHours(-2).ToString('yyyy-MM-dd')

for ($t = 0; $t -lt $ligs.Count; $t++) {
    if ($runn) {
        $url2 = "https://www.thesportsdb.com/api/v1/json/123/eventsday.php?d=$day&s=Soccer&l=" + $ligs[$t]
        $response2 = Invoke-RestMethod -Uri $url2 -Method Get -UseBasicParsing

        $response2 | ConvertTo-Json | Out-File -FilePath ".\Test\eday$t.json"
        if ($response2.events) {
            $mtchs += $response2.events #| Where-Object { $_.strHomeTeam -in $tims -or $_.strAwayTeam -in $tims }
        }
    }
    else {
        $response2 = Get-Content ".\Test\eday$t.json" -Raw | ConvertFrom-Json
        if ($response2.events) {
            $mtchs += $response2.events
            #| Where-Object { $_.strHomeTeam -in $tims -or $_.strAwayTeam -in $tims }
        }
    }
}
if (($mtchs.Count) -gt 1) {
    $mtchs = $mtchs | Sort-Object -Property { ([datetime]$_.strTimestamp).Hour % 12 }
}

Write-Output "$($mtchs.count) match var...`n"
# $lngth2 = $mtchs | Sort-Object -Property { [string]$_.strEvent.Length } -Descending | Select-Object -First 1
# $evnt = New-Object 'string[,]' ($mtchs.Count), 4
$vy2 = $c2 + $mainRy
$vy = 0
$bttm = $c2 + $mainrY

# for ($i = 1; $i -lt 2; $i++) {
for ($i = 0; $i -lt $mtchs.Count; $i++) {
    $mtch = $mtchs[$i]
    $timhome = if ($mtch.strHomeTeam.length -gt 13) { $mtch.strHomeTeam.Substring(0, 13) }else { $mtch.strHomeTeam }
    $timaway = if ($mtch.strAwayTeam.length -gt 13) { $mtch.strAwayTeam.Substring(0, 13) }else { $mtch.strAwayTeam }
    $intHomeScore = $mtch.intHomeScore
    $intAwayScore = $mtch.intAwayScore
    # for ($j = 0; $j -lt 12; $j++) {
    # $dt = $(Get-Date $mtch.strTimestamp).AddHours(3 + $j)
    $dt = $(Get-Date $mtch.strTimestamp).AddHours(3)
    $tme = $dt.ToString('HH:mm')
    # Compute dgt in 0..47 (always positive)
    $dgt = ((($dt.Hour % 12) * 4) + [int]($dt.Minute / 15) - 12) % 48
    if ($dgt -lt 0) { $dgt += 48 }


    $elpt = $ellipsePoints[$dgt]
    $mx = $c1 + $elpt.newrx
    $my = $c2 + $elpt.newry
    $angt = $elpt.newT * 180 / [math]::PI
    # Write-Host  "$angt $dgt                             mx=$([math]::round($mx)) $([math]::round($my))"

    if ($dgt -ge 12 -and $dgt -le 14) { $mx -= 80 }
    if ($dgt -ge 34 -and $dgt -le 36) { $mx -= 80 }

    # colors
    $mrmn = $now - $dt
    if ($mrmn -gt 0) {
        $mred = 244
        $mgreen = [math]::max(66, [math]::min(225, 244 - $mrmn.TotalMinutes))
        $mblue = 96

    }
    else {

        $mblue = 166
        $mgreen = 160
        $mred = 156
    }

    $mclr = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, $mred, $mgreen, $mblue))
    $mclrh = if ($mtch.strHomeTeam -in $tims) { $gren } else { $gryl }
    $mclra = if ($mtch.strAwayTeam -in $tims) { $gren } else { $gryl }
    # Write-Output "$($mclr.color)"


    $infomtch = if ($intHomeScore -ne $null) { " $tme $timhome   $intHomeScore-$intAwayScore   $timaway" }else { "$timhome  $tme    $timaway" }
    $infomtch = if ($null -ne $intHomeScore) { "$intHomeScore-$intAwayScore" } else { "$tme" }

    if ($mrmn.totalMinutes -le 120) {
        if ($mrmn.TotalMinutes -lt 0) {
            $mhr = [System.Math]::Floor(-$mrmn.TotalHours)
            $mmn = - $mrmn.TotalMinutes % 60
            $mtcmnt = "$([int]$mhr)'$([int]$mmn)"
            # Write-Host $mmn
        }
        else {
            $mtcmnt = "$([System.Math]::min(90, $mrmn.TotalMinutes))'"
        }

    }
    else { $mtcmnt = "$tme" }

    # $awayT = $gfx.MeasureString($infomtch, $fontgf)
    $awayT = $gfx.MeasureString($timaway, $fontgf).Width
    $homeT = $gfx.MeasureString($timhome, $fontgf).Width
    $spaceT = if (($mtch.strAwayTeam -in $tims) -or ($mtch.strHomeTeam -in $tims)) { 10 } else { 5 }

    # $vh = $awayT.Height * 1.35
    $vh = 25
    $rectLen = ($awayT + $homeT + $spaceT + 135) # 5+(35)+5+(home)+(spaceT)+40+(away)+5   +45
    if (($($dt.Hour % 12) -ge 6) -or ($($dt.Hour % 12) -eq 0)) {
        $vy = 0
        # Write-Host $($dt.Hour % 12)
        if ($my -gt ($vy2 - $vh)) {
            $vy2 -= $vh
        }
        else {
            $vy2 = $my
        }
        $gfx.FillRectangle($glowBrushR, $mx - $rectLen, $vy2 - 3, $rectLen - 45, 20)
        $gfx.DrawString( $mtcmnt, $fontgf, $mclr, $mx - $rectLen + 5, $vy2)
        $gfx.DrawString( $timhome, $fontgf, $mclrh, $mx - $rectLen + 45, $vy2)
        $gfx.DrawString( $infomtch, $fontgf, $mclr, $mx - $rectLen + 45 + $homeT + $spaceT, $vy2)
        $gfx.DrawString( $timaway, $fontgf, $mclra, $mx - $rectLen + 85 + $homeT + $spaceT, $vy2)

        # Write-Host "$([math]::round($angt)) $dgt       mx=$([math]::round($mx)) $([math]::round($my))       $([math]::round($vy2))         $timhome $tme`n"
    }
    else {
        $vy2 = $c2 + $mainRy
        if ($my -lt ($vy + $vh)) {
            $vy += $vh
        }
        else {
            $vy = $my
        }
        $mx += 45
        $gfx.FillRectangle($glowBrushR, $mx , $vy - 3, $rectLen - 45, 20 )
        $gfx.DrawString( $mtcmnt, $fontgf, $mclrh, $mx + 5, $vy  )
        $gfx.DrawString( $timhome, $fontgf, $mclrh, $mx + 45 , $vy  )
        $gfx.DrawString( $infomtch, $fontgf, $mclr, $mx + $homeT + $spaceT + 45, $vy  )
        $gfx.DrawString( $timaway, $fontgf, $mclra, $mx + $homeT + $spaceT + 85, $vy  )

        # Write-Host "$([math]::round($angt)) $dgt   mx=$([math]::round($mx)) $([math]::round($my))       $([math]::round($vy))       $timhome $tme`n"
    }


}
# }

# OPTIMIZATION: Clear large match data arrays after use to free memory
$mtchs = $null
$tims = $null
$snews = $null


# ------------------------------------------------------------------
#                  APPLICATION OF LAYOUT CARDS
# ------------------------------------------------------------------

# --------------------- Crypto Module ---------------------
# $cryptoFile = '.\Test\crypto.json'
# if ($runn) {
#     try {
#         $cryptoUrl = 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd'
#         $prices = Invoke-RestMethod -Uri $cryptoUrl -Method Get
#         $prices | ConvertTo-Json | Out-File $cryptoFile
#     }
#     catch {
#         $prices = Get-Content $cryptoFile | ConvertFrom-Json
#     }
# }
# else {
#     $prices = Get-Content $cryptoFile | ConvertFrom-Json
# }
# $btc = 'BTC: $' + $prices.bitcoin.usd
# $eth = 'ETH: $' + $prices.ethereum.usd

# ---------- System Info with Color Triggers ----------
$clrMtv = $gryl
# if ($runn) {
$prcss = (Get-Process).count
$srvs = (Get-CimInstance -ClassName Win32_Service -Filter "State = 'Running'").Count
# }else { $prcss = 'test';$srvs = 'test'}
# $tsks = (Get-ScheduledTask | Where-Object {$_.State -eq 'Ready'}).count

$os = Get-CimInstance -ClassName win32_operatingsystem
$bootime = $os.LastBootUpTime
$cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
$totalRam = $os.TotalVisibleMemorySize
$freeRam = $os.FreePhysicalMemory
if ($totalRam -ne 0) {
    $ramUsagePct = [Math]::Round((($totalRam - $freeRam) / $totalRam) * 100, 1)
}
else {
    $ramUsagePct = 0
}

$cpuBrush = if ($cpuLoad -gt 90) { $pink } else { $clrMtv }

$ramBrush = if ($ramUsagePct -gt 15) { $pink } else { $clrMtv }
$ramfontsize = [Math]::Max(8, [Math]::Min($ramUsagePct * 0.7, 40))
$fontgf = [Font]::New('Segoe UI Variable Text', 8, [FontStyle]::Bold)
# 1. System Info Card (Top Left) New-LayoutCard
# New-LayoutCard -X 20 -Y 50 -Width 260 -Height 160
# $gfx.FillRectangle($gryla, 0, 0, 120, 180)
$bb = $width * 0.7
$cc = $Height * 0
$gfx.DrawString("Boot  ...  $($bootime.ToString('HH:mm'))", $font, $gryl, (New-Object System.Drawing.PointF ($bb + 8), ($cc)))

$gfx.DrawString("CPU $cpuLoad ........... $prcss", $font, $cpuBrush, (New-Object System.Drawing.PointF ($bb), ($cc + 30)))
$gfx.DrawString("Service ........... $srvs", $font, $clrMtv, (New-Object System.Drawing.PointF ($bb), ($cc + 60)))
$gfx.DrawString("Memory ..... %$ramUsagePct", $font, $ramBrush, (New-Object System.Drawing.PointF ($bb), ($cc + 90)))
# $gfx.DrawString($btc, $fontgf, $ornge, [PointF]::new($bb, 180))
# $gfx.DrawString($eth, $fontgf, $tquaz, [PointF]::new($bb, 210))
$startTime = (Get-Date).AddDays(-3)
$seen = @{}

$startTime = (Get-Date).AddDays(-3)
$seen = @{}

$eventDescriptions = @{
    1     = 'log dosya boyutu üst sınıra ulaştı'
    4     = 'log dosya boyutu üst sınıra ulaştı'
    7     = 'Disk: Kötü sektör veya disk okuma/yazma hatası.'
    10    = 'bozuk sürücüler veya hatalı Daycellemeler'
    18    = 'WHEA: İşlemci veya donanım hatası (CPU, RAM, anakart vb.).'
    19    = 'WHEA: Düzeltilmiş donanım hatası.'
    20    = 'WHEA: Düzeltilmemiş donanım hatası.'
    35    = 'Anakart bellenim sorunları '
    41    = 'Kernel-Power: Sistem düzDay kapatılmadan Newden başladı. Elektrik kesintisi, PSU, donma veya mavi ekran olabilir.'
    51    = 'Disk: Diskte G/Ç (I/O) hatası occurred.'
    55    = 'NTFS: Dosya sistemi bozulması tespit edildi.'
    57    = 'NTFS: Dosya sistemi beklenmedik şekilde bozuldu.'

    129   = 'StorAHCI/StorPort: Depolama aygıtı yanıt vermedi, zaman aşımı.'
    142   = 'no WRM start by BITS'
    153   = 'Disk: Gecikmeli disk erişimi veya Newden deneme yapıldı.'

    131   = 'auto driver install'
    161   = 'volmgr: Crash dump occurred'

    524   = 'disk wakeup spin time telemetry'

    1000  = 'Application Error: Bir uygulama çöktü. DLL, bellek veya yazılım hatası olabilir.'
    1001  = 'Windows Error Reporting: Çökme raporu occurredruldu.'
    1074  = 'Planlı Newden başlatma/kapatma. Hangi kullanıcı veya uygulamanın yaptığı kaydedilir.'

    5858  = 'old WMI cant install'
    6008  = 'Beklenmeyen kapanma. Elektrik kesintisi, donma veya zorla kapatma.'
    7000  = 'Service Control Manager: Bir servis başlatılamadı.'
    7001  = 'Service Control Manager: Bağımlı servis başlatılamadı.'
    7031  = 'Service Control Manager: Servis beklenmedik şekilde sonlandı.'
    7034  = 'Service Control Manager: Servis çöktü.'

    10016 = 'arka plan uygulamaları veya hizmetleri için izin/erişim'
}

$eee = Get-WinEvent -FilterHashtable @{
    LogName   = '*'
    Level     = @(1, 2)
    StartTime = $startTime
} |
Sort-Object TimeCreated -Descending |
Where-Object {
    $key = $_.ProviderName

    if (-not $seen.ContainsKey($key)) {
        $seen[$key] = $true
        $true
    }
    else {
        $false
    }
} |
Select-Object -First 3

for ($n = 0; $n -lt $eee.Count; $n++) {
    $event = $eee[$n]
    $timeText = $event.TimeCreated.ToString('dd.MM HH:mm')
    $messageText = '' #($event.Message -replace '\r?\n', ' ').Trim()
    $ProviderN = ($event.ProviderName -split '-')[2]
    $idm = $event.Id


    if ($eventDescriptions.ContainsKey($event.Id)) {
        $messageText = $eventDescriptions[$event.Id]
    }

    $drawText = "${timeText}   : $($ProviderN) $messageText $idm"
    if ($drawText.Length -gt 140) {
        $drawText = $drawText.Substring(0, 140) + '...'
    }
    $etvfont = if ($event.Level -lt 2) { $pink }else { $gryd }
    $gfx.DrawString($drawText, $font, $etvfont, (New-Object System.Drawing.PointF ($width * 0.78), ($Height * 0.75 + $n * 20)))
}







#-------------------------end-------------------------------------------


$stopWatch.Stop()
#  Get the elapsed time as a TimeSpan value.
[TimeSpan]$ts = $stopWatch.Elapsed
[string]$elapsedTime = '{0:0}.{1:00}' -f $ts.Seconds, ($ts.Milliseconds / 10)
Write-Host "RunTime  $elapsedTime seconds" -ForegroundColor Green



# Start-Sleep -Seconds 5


# save
$fullOutputPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot $outputPath))
$outputDir = Split-Path $fullOutputPath -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$tempOutputPath = "$fullOutputPath.tmp"
if (Test-Path $tempOutputPath) {
    Remove-Item $tempOutputPath -Force -ErrorAction SilentlyContinue
}

try {
    $png.Save($tempOutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    if (Test-Path $tempOutputPath) {
        Move-Item -Path $tempOutputPath -Destination $fullOutputPath -Force
    }
}
catch {
    if (Test-Path $tempOutputPath) {
        Remove-Item $tempOutputPath -Force -ErrorAction SilentlyContinue
    }

    $clonedBitmap = [System.Drawing.Bitmap]::new($png)
    try {
        $clonedBitmap.Save($fullOutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $clonedBitmap.Dispose()
    }
}

# Cleanup
# Cleanup resources
@($font, $font2, $fontin, $tquaz, $gryl, $ornge, $pink, $format, $gren, $flrb, $gfx, $png) | ForEach-Object {
    if ($_ -ne $null) { $_.Dispose() }
}

# Cleanup cached images
$imgCache.Values | ForEach-Object {
    if ($_ -ne $null) { $_.Dispose() }
}

$imgCache.Clear()
$imgCache.Clear()
$ia.Dispose()
$ia = $null
# Force garbage collection
# [GC]::Collect()
# [GC]::WaitForPendingFinalizers()
[GC]::Collect()
[GC]::WaitForPendingFinalizers()
Start-Sleep -Milliseconds 300
# PNGâ€™yi Duvar KÃ¢ğıdı Yapma (Anında)
# $code = @'
# using System.Runtime.InteropServices;
# public class Wallpaper {
#   [DllImport("user32.dll", SetLastError = true)]
#   public static extern bool SystemParametersInfo(
#     int uAction, int uParam, string lpvParam, int fuWinIni);
# }
# '@
# Add-Type -Language CSharp $code
if (-not ('Wallpaper' -as [type])) {
    Add-Type @'
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni);
}
'@
}
$pngFullPath = (Get-Item $fullOutputPath).FullName

$result = [Wallpaper]::SystemParametersInfo(20, 0, $pngFullPath, 3)
Write-Host $result
Write-Host ([Runtime.InteropServices.Marshal]::GetLastWin32Error())
# Stop-Transcript
# }
# catch {
# $time = Get-Date -Format o
# $errMsg = "[$time] $($_.Exception.GetType().FullName): $($_.Exception.Message)"
# if ($_.InvocationInfo) { $errMsg += "`nScript: $($_.InvocationInfo.ScriptName) Line: $($_.InvocationInfo.ScriptLineNumber)" }
# if ($_.ScriptStackTrace) { $errMsg += "`nStackTrace:`n$($_.ScriptStackTrace)" }
# $errMsg += "`n----------`n"
# $errMsg | Out-File -FilePath $LogPath -Encoding utf8 -Append
# Write-Host "Hata occurred. Detaylar kaydedildi: $LogPath" -ForegroundColor Red
# }
