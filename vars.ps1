# 1. Namespace'leri Tanımla (Kısayol oluşturur)
using namespace System.Drawing
using namespace System.Drawing.Drawing2D
using namespace System.Windows.Forms

# 2. Assembly'leri Yükle (Kütüphaneyi sisteme tanıtır)
# OPTIMIZED: Suppress redundant loading attempts
$null = @(
    (Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue)
    (Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue)
)
# Set-Location $PSScriptRoot

#  ------------- Runtime --------------
$stopWatch = [System.Diagnostics.Stopwatch]::StartNew() # Zaman ölçümü için
$stopWatch.Start()
Write-Host "`n"+(Get-Date).ToString('        HH:mm        d  dddd')+"`n" -ForegroundColor Cyan

# Artık[Graphics] yerine sadece [Graphics] diyebilirsiniz.
$screen = [Screen]::PrimaryScreen
$Width = $screen.Bounds.Width
$Height = $screen.Bounds.Height
$Width2 = $Height * 2.65
#  elips yarıçapları
$mainRy = $Width * 0.19
$mainRx = $mainRy * 0.38

# merkez koordinatları
$c1 = $width * 0.5
$c2 = $height * 0.5

# birimler 3-5-8-13-21-(34-55)
$unt = [Math]::Round($height / 34)
# Dosya yollarını belirleyin
# $sourcePath = 'bg.png'
# $sourcePath = 'C:\Users\Admin\Documents\wallpprAssets\w3.png'
# $sourcePath = 'C:\Users\Admin\Documents\wallpprAssets\w2.png'
$outputPath = 'wallpaper.png'

# Orijinal resmi yükle
# $srcImage = [Bitmap]::FromFile($sourcePath)

# Yeni boyutları hesapla (2 katı)
# $newWidth = $srcImage.Width
# $newHeight = $srcImage.Height

# Yeni boş bir bitmap oluştur
$png = [Bitmap]::new($Width, $Height)
# $png.SetResolution($srcImage.HorizontalResolution, $srcImage.VerticalResolution)

# Grafik nesnesini hazırla
$gfx = [Graphics]::FromImage($png)


# --- EN YÜKSEK KALİTE AYARLARI ---
$gfx.InterpolationMode = [InterpolationMode]::HighQualityBicubic
$gfx.SmoothingMode = [SmoothingMode]::HighQuality
$gfx.PixelOffsetMode = [PixelOffsetMode]::HighQuality
$gfx.CompositingQuality = [CompositingQuality]::HighQuality
$gfx.CompositingMode = [Drawing2D.CompositingMode]::SourceOver
$gfx.TextRenderingHint = [Text.TextRenderingHint]::ClearTypeGridFit

# Kenar hatalarını (ghosting) önlemek için WrapMode ayarı (Opsiyonel ama önerilir)
# OPTIMIZED: Removed unused $attributes object - not needed for current workflow


# Resmi çiz (Büyütme burada gerçekleşiyor)
$destRect = [Rectangle]::new(0, 0, $Width, $Height)
# $gfx.Clear([Color]::FromArgb(255, 18, 24, 30)) # Arka plan rengini siyah yap
$gfx.Clear([Color]::FromArgb(255, 12,16,18))
# $gfx.DrawImage([Image]::FromFile('.\Temp\bulut.png'), 0, 0, $Width, $Height)

# $destRect = [Rectangle]::new(0, 160, $Width, $Height-20)
# $gfx.FillRectangle($grydrk, [Rectangle]::new(0, 160, $Width, $Height-20))
# $gfx.DrawImage($srcImage, 0, 0, $Width, $Height)
# $png.GetPixel(240,540)





# ----------------------------- Background Logic -----------------------------
# background colors #layers
# OPTIMIZED: Removed unused $bx object
$flrc = [Color]::FromArgb(100, 50, 50, 50)
$flrb = [SolidBrush]::New($flrc)
$flrb2 = [SolidBrush]::New([Color]::FromArgb(70, 30, 30, 30))
$flrb1 = [SolidBrush]::New([Color]::FromArgb(50, 50, 50, 50))

# Font
$font = [Font]::New('Segoe UI Variable Text', 10, [FontStyle]::Bold)
$font2 = [Font]::New('Calibri', 11, [FontStyle]::Bold)
$fontin = [Font]::New('Segoe UI Variable Text', 9, [FontStyle]::Bold)
$fontBig = [Font]::New('Calibri', $unt * 0.7, [FontStyle]::Bold) # Büyük yazı
$fontMid = [Font]::New('Segoe UI Variable Text', $unt * 0.4, [FontStyle]::Bold)
$fontSmall = [Font]::New('Calibri', $unt * 0.35, [FontStyle]::Bold) # Küçük detaylar
$fontSmaller = [Font]::New('Calibri', [int]($unt * 0.3), [FontStyle]::Bold)

$fontgf = [Font]::New('Segoe UI Variable Text', 8, [FontStyle]::Bold)
$fontmc = [Font]::New('Comic Sans MS', 11, [FontStyle]::Bold)

$fgeorgia14 = [Font]::New('Georgia', 12, [FontStyle]::Bold)
$fgeorgia9 = [Font]::New('Georgia', 9, [FontStyle]::Bold)
# font format alignment
$format = [StringFormat]::New()
$format.Alignment = [StringAlignment]::Center
$format.LineAlignment = [StringAlignment]::Center
# $format.Trimming = [StringTrimming]::EllipsisWord
$format.FormatFlags = [StringFormatFlags]::NoWrap



# font colors
$whte = [SolidBrush]::New([Color]::FromArgb(255, 192, 192, 192))
$gryl = [SolidBrush]::New([Color]::FromArgb(255, 156, 156, 156))
$gryla = [SolidBrush]::New([Color]::FromArgb(155, 56, 56, 56))
$gryd = [SolidBrush]::New([Color]::FromArgb(255, 106, 106, 106))
$grydrk = [SolidBrush]::New([Color]::FromArgb(255, 54, 54, 54))
$grydrkb = [SolidBrush]::New([Color]::FromArgb(55, 54, 54, 54))



# renkler f26419 f6ae2d 758e4f 86bbd8 33658a 137 84 53 31
$ornge = [SolidBrush]::New([Color]::FromArgb(255, 203, 156, 18 ))
$gren = [SolidBrush]::New([Color]::FromArgb(255, 26, 203, 26))
$pink = [SolidBrush]::New([Color]::FromArgb(255, 192, 80, 77 ))
$tquaz = [SolidBrush]::New([Color]::FromArgb(255, 22, 156, 156 ))
$pinko = [SolidBrush]::New([Color]::FromArgb(255, 98, 114, 203 ))
$ornge2 = [SolidBrush]::New([Color]::FromArgb(155, 203, 156, 18 ))
$tquaz2 = [SolidBrush]::New([Color]::FromArgb(155, 22, 156, 156 ))
$steal = [SolidBrush]::New([Color]::FromArgb(150, 18, 18, 18))

# $font.Sizeinpoints
$colorStart = [Color]::FromArgb(100, 0, 0, 0) # Koyu gri / siyah (şeffaf)
$colorEnd = [Color]::FromArgb(0, 100, 100, 100 )   # Mavimsi gri
$colorStart2 = [Color]::FromArgb(200, 0, 0, 0 ) # Koyu gri / siyah (şeffaf)
$colorEnd2 = [Color]::FromArgb(0, 200, 200, 200 )   # Mavimsi gri
$colorStart3 = [Color]::FromArgb(250, 0, 0, 0 ) # Koyu gri / siyah (şeffaf)
$colorEnd3 = [Color]::FromArgb(0, 250, 250, 250 )   # Mavimsi gri
$colorStartR = [Color]::FromArgb(50, 0, 0, 0 ) # Koyu gri / siyah (şeffaf)
$colorEndR = [Color]::FromArgb(0, 50, 50, 50 )   # Mavimsi gri
$colorStartR2 = [Color]::FromArgb(20, 0, 0, 0 ) # Koyu gri / siyah (şeffaf)
$colorEndR2 = [Color]::FromArgb(0, 20, 20, 20 )   # Mavimsi gri
# 80 = More transparent
# 80 = More transparent
# $colorEnd = [Color]::FromArgb(120, 20, 20, 25)   # 120 = Slightly darker edge
$glowBrush = [SolidBrush]::New([Color]::FromArgb(100, 0, 0, 0)) # Semi-transparent black
$glowBrush2 = [SolidBrush]::New([Color]::FromArgb(150, 0, 0, 0))
$glowBrush22 = [SolidBrush]::New([Color]::FromArgb(225, 0, 0, 0))
$glowBrushR = [SolidBrush]::New([Color]::FromArgb(50, 0, 0, 0))
$glowBrushR2 = [SolidBrush]::New([Color]::FromArgb(25, 0, 0, 0))


# $rnd = [System.Random]::new()

# for ($i = 0; $i -lt 3; $i++) {
#     $gfx.DrawLine($grydrk, 0, $i * $Height *0.38, $Width, $i * $Height *0.38)
#     $gfx.DrawLine($grydrk, $i * $Width * 0.38, 0, $i * $Width * 0.38, $Height)
# }
#
$ia = [Imaging.ImageAttributes]::new()
$cm = [Imaging.ColorMatrix]::new()
$cm.Matrix33 = 0.5  # 0.0 = tam şeffaf, 1.0 = tam opak
$ia.SetColorMatrix($cm)


$flrpen = [Pen]::New($gren, 1)


# 'Turkish Super Lig'      = 4339 https://www.thesportsdb.com/api/v1/json/123/lookuptable.php?l=4339
# 'English Premier League' = 4328 https://www.thesportsdb.com/api/v1/json/123/eventsnext.php?id=133804
# 'La Liga'                = 4335 https://www.thesportsdb.com/api/v1/json/123/eventsnextleague.php?id=4339
# 'Serie A'                = 4332 https://www.thesportsdb.com/api/v1/json/123/eventsday.php?d=2026-01-31&s=Soccer&l=Turkish%20Super%20Lig
# 'Bundesliga'             = 4331 # 'Ligue 1'= 4334 ,4570: "EFL Cup",
# gs:133804 133807 'UEFA Champions League:4480', 'Turkish Cup'


function Get-Hue($r, $g, $b) {
    $r = $r / 255.0; $g = $g / 255.0; $b = $b / 255.0
    $max = [Math]::Max($r, [Math]::Max($g, $b))
    $min = [Math]::Min($r, [Math]::Min($g, $b))
    # if ($max -eq $min) { $min -= 1 }  # gri/siyah/beyaz
    $delta = $max - $min

    if ($delta -eq 0) { $h = 0; $v = $r; $s = 0.1 }
    else {
        if ($max -eq $r) { $h = 60 * ((($g - $b) / $delta) % 6) }
        elseif ($max -eq $g) { $h = 60 * ((($b - $r) / $delta) + 2) }
        else { $h = 60 * ((($r - $g) / $delta) + 4) }

        if ($h -lt 0) { $h += 360 }

        $s = if ($max -eq 0) { 0 } else { $delta / $max }  # saturation
        $v = $max  # value (parlaklık)
    }
    return [PSCustomObject]@{ H = $h; S = $s; V = $v }
}


function ColorTemp {
    param ([int]$sc,
        $alfa = 115)
    # sıcaklığa göre renk
    if ($sc -le 11) {
        $gr = $sc * 23
        $br = 255
        $rd = 55 - $sc * 5
    }
    elseif ($sc -le 22) {
        $gr = 255
        $rd = 0
        $br = (22 - $sc) * 23
    }
    elseif ($sc -le 33) {
        $gr = 244
        $rd = ($sc - 22) * 23
        $br = 0
    }
    else {
        $rd = 244
        $gr = (44 - $sc) * 17
        $br = 0
    }
    # Write-Host "ColorTemp: $sc => R=$rd, G=$gr, B=$br"
    $gr = [math]::Max(128, [math]::Min(255, $gr))
    $rd = [math]::Max(1, [math]::Min(255, $rd))
    $colortemp = [Color]::FromArgb( $alfa, $rd, $gr, $br)
    $brushtemp = [SolidBrush]::new($colortemp)

    return $brushtemp

}


function Contrst {
    param (
        $colorx,
        $alfa = 192
    )
    $r = $colorx.R
    $g = $colorx.G
    $b = $colorx.B

    #     $b = [math]::min(255, $b * 1.4)
    $Luma = [int](0.21 * $r + 0.72 * $g + 0.07 * $b)
    $Luma2 = [int](0.3 * $r + 0.59 * $g + 0.11 * $b)
    if ($luma -gt 128) {
        $colorx = [SolidBrush]::New([Color]::FromArgb(255, [int]$r * 0.1, [int]$g * 0.1, [int]$b * 0.1))
    }
    else {
        $colorx = [SolidBrush]::New([Color]::FromArgb($alfa, 255 - $r * 0.35, 255 - $g * 0.35, 255 - $b * 0.35))
    }
    # Write-Host "Renk: [R=$([int]$r), G=$([int]$g), B=$([int]$b)]  Luma=$Luma Luma2=$Luma2  return: $($colorx.color)"

    return $colorx
}





function Get-PreciseTextWidth {
    param([string]$text, [Font]$font)

    if ([string]::IsNullOrWhiteSpace($text)) { return 0 }

    $format = [StringFormat]::GenericTypographic
    $range = [CharacterRange]::new(0, $text.Length)
    $format.SetMeasurableCharacterRanges(@($range))

    $rect = [RectangleF]::new(0, 0, 5000, 100)
    $regions = $gfx.MeasureCharacterRanges($text, $font, $rect, $format)
    $bounds = $regions[0].GetBounds($gfx)

    # Bölgeleri dispose etmek bellek yönetimi için iyidir
    $regions | ForEach-Object { $_.Dispose() }

    return $bounds
}


function Get-VectorAngle {
    param (
        [PointF]$P1,
        [PointF]$P2
    )

    # Vektör bileşenlerini hesapla
    $dx = $P2.X - $P1.X
    $dy = $P2.Y - $P1.Y

    # Radyan cinsinden açıyı bul
    $radians = [Math]::Atan2($dy, $dx)

    # Dereceye çevir
    $degrees = $radians * (180 / [Math]::PI)

    # Eğer 0-360 arası pozitif sonuç istersen:
    if ($degrees -lt 0) { $degrees += 360 }
    # Write-Host $degrees $p1
    return $degrees
}


#----------------------------------------------------------------------------#
#                                                                            #
#                    1 point perspective boxes                               #
#                                                                            #
# ---------------------------------------------------------------------------#

function circlec {
    param (
        $r = $mainRx,         # çember-elips yarıçapı , distance far from center of circle
        [int]$dg = 175,       # saat yönünün tersine 0-360, normal x-y ekseni dereceleri
        $text = $wthrHourly,  # data array [i,j]
        $mode = 'xxx',        # make colored text
        $hozntl = $true,      # right-left , 1 point perspective about x axis
        $fontcrcl = $fontin,  # change font
        $grdr = $true,        # add gradiant rectangle background
        $clrd = $true,        # add colored border lines
        $c1 = $c1,            # center x
        $c2 = $c2             # center y
    )
    # Write-Output "`n------------------$dbg------------------`n"

    $clr = $gryl
    [int]$ln = $text.getlength(0)
    [int]$clmn = $text.getlength(1)
    $sz = @(0)
    $wth = 0
    $measuredH = @()

    # $r = [math]::Pow(([math]::Pow($c1 - $ax, 2) + [math]::Pow($c2 - $ay, 2)), 0.5)
    $sn = [math]::sin([math]::PI * $dg / 180)
    $csn = [math]::cos([math]::PI * $dg / 180)

    $ax = ($c1 + $r * $csn)
    $ay = ($c2 - $r * $sn)

    # ---------------height and width of  boxes------------------
    if ($hozntl) {

        if ($c1 -gt $ax) {
            #'--------------------left---------------------'
            $currentFs = @(12)
            for ($i = 0; $i -lt $clmn; $i++) {
                $sz += 0
                $currentFs[$i] -= 2 / $clmn
                $currentFs += $currentFs[$i]
                # $fontcrcl = [Font]::New('Calibri', $currentFs[$i], [FontStyle]::Bold)
                $measuredH += 0
                #..................................
                for ($j = 0; $j -lt $ln; $j++) {
                    $cellText = $text[$j, $i]
                    $measuredWidth = $gfx.MeasureString($cellText, $fontcrcl).Width
                    $measuredHeight = $gfx.MeasureString($cellText, $fontcrcl).Height
                    $measuredH[$i] += $measuredHeight * 1.1
                    if ($measuredWidth -gt 5) {
                        if ($measuredWidth -gt $sz[$i + 1]) {
                            $sz[$i + 1] = $measuredWidth
                            # Write-Output "sol $i`:$j, $celltext => $($sz[$i + 1]) ,             $measuredHeight,            $($currentfs[$i])"
                        }
                        else { $measuredWidth = 0 }
                    }
                }
                $sz[$i + 1] += $sz[$i]
                #..................................
            }
            #'----------------------------------------------------'

        }
        else {
            #'--------------------right---------------------'
            $currentFs = @(8)
            for ($i = 0; $i -lt $clmn; $i++) {
                $sz += 0
                $currentFs[$i] += 2 / $clmn
                $currentFs += $currentFs[$i]
                # $fontcrcl = [Font]::New('Calibri', $currentFs[$i], [FontStyle]::Bold)
                $measuredH += 0

                for ($j = 0; $j -lt $ln; $j++) {
                    $cellText = $text[$j, $i]
                    $measuredWidth = $gfx.MeasureString($cellText, $fontcrcl).Width
                    $measuredHeight = $gfx.MeasureString($cellText, $fontcrcl).Height
                    $measuredH[$i] += $measuredHeight * 1.1
                    if ($measuredWidth -gt 5) {
                        if ($measuredWidth -gt $sz[$i + 1]) {
                            $sz[$i + 1] = $measuredWidth
                            # Write-Output "sağ $i`:$j, $celltext => $($sz[$i + 1]) ,         $measuredHeight,           $($currentfs[$i])"
                        }
                        else { $measuredWidth = 0 }
                    }
                }
                #..................................
                $sz[$i + 1] += $sz[$i] + 8
            }
            #'---------------------------------------'-----------
        }

        #'----------4 corner points of  boxes-----------
        # $wth = $sz[-1] + 12 * $($clmn - 1)
        $wth = $sz[-1]  # 150
        $hght = $measuredH[0]  # 150
        if ($ax -lt $c1) {
            $wth *= -1
        }
        $r2 = $r + $wth   # 600+150*0.85+150*0.53= 600+127.5+79.5=807
        # $wth = $r2 - $r

        # $r2 = $r + $wth # 430+150=580
        $ax2 = $c1 + ($ax - $c1) * $r2 / $r  # 1000+(627-1000)*1.35
        $ay2 = $c2 + ($ay - $c2) * ($r2 / $r)

        if ($csn -lt 0) { $hght *= -1 }
        $dg -= 360 * $hght / (2 * [math]::PI * $r)

        $sn = [math]::sin([math]::PI * $dg / 180)
        $csn = [math]::cos([math]::PI * $dg / 180)

        $bx = $c1 + $r * $csn
        $by = $c2 - $r * $sn
        $bx2 = $c1 + ($bx - $c1) * $r2 / $r
        $by2 = $c2 + ($by - $c2) * $r2 / $r
        # Write-Output "$wth $hght $r2 $($r2 / $r) : $ax $ay $ax2 $ay2 $bx $by $bx2 $by2"
    }
    else {
        # $fontcrcl.name
        Write-Output "`n.........$mode paralelkenarı............`n"

        $currentFs = @(11)
        for ($i = 0; $i -lt $clmn; $i++) {
            $currentFs += 11
            $sz += 0
            # $fontcrcl = [Font]::New('Calibri', 11, [FontStyle]::Bold)
            # $sz[$i + 1] += $sz[$i] + 12
            #..................................
            for ($j = 0; $j -lt $ln; $j++) {
                $cellText = $text[$j, $i]

                $measuredWidth = (Get-PreciseTextWidth $cellText $fontcrcl).Width
                $measuredHeight = (Get-PreciseTextWidth $cellText $fontcrcl).Height

                if ($measuredWidth -gt 5) {
                    if ($measuredWidth -gt $sz[$i + 1]) {
                        $sz[$i + 1] = $measuredWidth
                        # Write-Output "$i`:$j, $celltext => $($sz[$i + 1]) ,             $($measuredHeight),            $($currentfs[$i])"
                    }
                    else { $measuredWidth = 0 }
                }
                # $sz[$i + 1]
            }
            $sz[$i + 1] += $sz[$i] + 22

        }
        $wth = $sz[-1]
        $hght = ($measuredHeight + 5) * $ln + 10
        # if ($ay -lt $c2) {
        #     $hght *= -1
        # }
        $r2 = $r + $hght
        $bx = $ax + 20
        $by = $ay + $hght

        $ax2 = $ax + $wth
        $bx2 = $bx + $wth

        $ay2 = $ay - 5
        $by2 = $by + 5
        # Write-Output "$wth $hght $ax $ay $ax2 $ay2 $bx $by $bx2 $by2"
    }
    #---------------colored borders----------
    if ($clrd) {
        $trcolor = [Color]::FromArgb(22, 12, 16, 18)
        $pen = [Pen]::new(($trcolor), 3)
        # $gfx.FillEllipse([SolidBrush]::new($trcolor), ($c1 - $r), ($c2 - $r), $r * 2, $r * 2 )
        # $gfx.DrawEllipse($pen, ($c1 - $r), ($c2 - $r), $r * 2, $r * 2)
        $gfx.DrawLine($gren, $ax - 1, $ay, $ax2, $ay2)
        $gfx.DrawLine($pink, $bx - 1, $by, $bx2, $by2)
        # Write-Host $bx $by $bx2 $by2
        $gfx.DrawLine($pinko, $ax - 1, $ay, $bx - 1, $by)
        $gfx.DrawLine($ornge, $ax2, $ay2, $bx2, $by2)
    }
    # gradyant background of box
    if ($grdr) {
        # 1. Köşe noktalarını tanımla (Dörtgenin perspektif hali)
        $p1 = [PointF]::new($ax, $ay)
        $p2 = [PointF]::new($ax2, $ay2)
        $p3 = [PointF]::new($bx2, $by2)
        $p4 = [PointF]::new($bx, $by)
        $points = [PointF[]]@($p1, $p2, $p3, $p4)
        $rectBound = [RectangleF]::new($ax, $ay, $wth, $hght)

        # $brush = [LinearGradientBrush]::new($rectBound, $colorStart3, $colorEnd3, 0.0)
        # $gfx.FillPolygon($brush, $points)
        # $brush = [LinearGradientBrush]::new($rectBound, $colorStart3, $colorEnd3, 90.0)
        # $gfx.FillPolygon($brush, $points)
        # $brush = [LinearGradientBrush]::new($rectBound, $colorStart2, $colorEnd, 0.0)
        # $gfx.FillPolygon($brush, $points)
        # $brush = [LinearGradientBrush]::new($rectBound, $colorStart, $colorEnd2, 180.0)
        # $gfx.FillPolygon($brush, $points)

        $gfx.FillPolygon($glowBrush2, $points)
    }
    $tmx = (Get-Date).addminutes(0).ToString('HH:mm')



    #------------------------------------------------
    for ($i = 0; $i -lt $ln; $i++) {

        if ($mode -eq 'ligr') {
            $played = [math]::max(1, $tble[$i].intPlayed)
            $teamPoints = $tble[$i].intPoints
            $teamPointr = $teamPoints / $played
            $frk = if ($teamPointr -gt 0) { $maxrt - $teamPointr } else { 1 }
            # Write-Host "$frk, $maxrt, $teamPointr"
            if ($frk -lt 0.2) {
                $grn = 85 * $teamPointr
                $red = 90
                $blu = 90
                # $blu = [System.Math]::Min(255, [System.Math]::Max(0, (192-$grn*0.65-$red*0.25)*10))
            }
            elseif ($frk -lt 0.4) {
                $grn = 80 * $teamPointr
                $red = $grn
                $blu = $grn
            }
            else {
                $grn = 65 * $teamPointr
                $red = 110 * $teamPointr
                $blu = 120 * $teamPointr

            }
            $grn = [math]::Max(1, [math]::Min(255, $grn))
            $red = [math]::Max(1, [math]::Min(255, $red))
            $blu = [math]::Max(1, [math]::Min(255, $blu))
            $tbclr = [color]::FromArgb(255, $red, $grn, $blu)
            $clr = [SolidBrush]::new($tbclr)
            # Write-Output "$teampointr $frk $tbclr"
            $clr = if (($teamPoints / $played -gt 2.1)) { $gren } elseif (($teamPoints / $played -ge 2)) { $ornge } elseif (($teamPoints / $played -ge 1.8)) { $gryl } else { $grydrk }
        }
        if ($mode -eq 'snews') { if (($i % 2) ) { $clr = $ornge }else { $clr = $gren } }
        if ($mode -eq 'mtchs') {
            if (($text[$i, 0] -lt ((Get-Date).addhours(-2).ToString('HH:mm')))) { $clr = $pink }elseif (($text[$i, 0]) -lt ($tmx)) { $clr = $ornge }else { $clr = $gryl }
            $tmpclr = $clr
        }
        if ($mode -eq 'wthrdly') { if ($null -ne $qPh30[2 * $i] ) { $clr = $pink }else { $clr = $gryl } }

        # Mevcut satırın sol ve sağ koordinatlarını hesapla*******************
        $curYLeft = ($by - $ay) * ($i) / $ln + $ay
        $curYRight = ($by2 - $ay2) * ($i) / $ln + $ay2
        $curXLeft = ($bx - $ax) * ($i) / $ln + $ax
        $curXRight = ($bx2 - $ax2) * ($i) / $ln + $ax2

        # Satırın eğim açısını bul********************************************
        $p1 = [PointF]::new( $curXLeft, $curYLeft)
        $p2 = [PointF]::new($curXRight , $curYRight)
        $angl = Get-VectorAngle -P1 $p1 -P2 $p2
        # $angl
        # Transformasyonları uygula ******************************************
        $state = $gfx.Save()
        $gfx.TranslateTransform($curXLeft, $curYLeft)
        $gfx.RotateTransform($angl)



        #------------------------   drawing datas    --------------------------

        for ($j = 0; $j -lt $clmn; $j++) {
            $cellText = $text[$i, $j]
            # write-Output "$i`:$j, $celltext => $($sz[$j + 1]) ,             $($measuredHeight),            $($currentfs[$j])"
            if ($mode -eq 'mtchs') {
                if (($text[$i, ($j % 4) ] -in $tims) -and ($text[$i, (($j + 2) % 4)] -in $tims) ) { $clr = $gren }else { $clr = $tmpclr }
            }
            if ($null -ne $cellText) {

                $fontcrcl = [Font]::New($fontcrcl.Name, $currentFs[$j], [FontStyle]::Bold)

                # Add this for a subtle "Glow/Shadow" effect
                # $gfx.DrawString($cellText, $fontcrcl, $glowBrush2, $sz[$j] + 1, 6)
                # $gfx.DrawString($cellText, $fontcrcl, $glowBrush, $sz[$j] + 2, 7) # Shadow offset by 1px
                $gfx.DrawString($cellText, $fontcrcl, $glowBrush22, $sz[$j] + 1, 3)

                $gfx.DrawString($cellText, $fontcrcl, $clr, $sz[$j], 2)          # Main text
            }
        }
        $gfx.Restore($state)
    }
}



function boxes {
    param (
        [int]$x,
        [int]$y,
        [int]$w,
        [int]$h
    )
    # $gfx.FillRectangle($bx, $x  , $y , $w - 1 , $h - 1)
    #
    $hh = [math]::Round($h / 25)
    $ttt = [math]::min(24, [int](240 / $hh))
    $gcl = $ttt + 24
    for ($i = 0; $i -lt $hh; $i++) {
        $gryd2 = [SolidBrush]::New([Color]::FromArgb(35, $gcl, $gcl, $gcl))
        # Write-Host "$i $x $y $h $gcl $($gryd2.Color)"
        $gfx.FillRectangle($gryd2, $x, $y + $i * 25, $w, 25)
        if ($i % 2 -eq 0) {
            $gcl -= 12
        }
        else {
            $gcl += 24
        }

    }
    # Write-Host "$x $y $($gryd2.Color)"
    $gryd2.Dispose()
}



#----------------------------------------------------------------------------#
#                                                                            #
#                 arc len for t radian (old)                                 #
# $radian = $degree * ([Math]::PI / 180)                                   #
# [Math]::Cos($radian)                                                      #
# ---------------------------------------------------------------------------#
# çemberin x=y 30 derecesi, elipsin x!=y 49-19 arasına denk gelir,
# eşit açılar için her radyan için (0.5=360/720, steps=720) aralıklkarla çevre uzunluğunu hesaplıyoruz,
# 0:0 , 45/360:262, 90/360:415.... 360/360:1660
# tabloda olmayan radyan 30.7/360 olursa, (30.5/360-31/360 ) arasında olduğu için orantı ile aradaki radyanı buluyoruz =30.7/360
# bu fonksiyonlrla yeni tablo oluşturuyoruz.

#from 90 to -270 degrees: arctable={hour=3:degree=90:x-y axis=0.....0:0:90.....9:270:180..6:180:270.....3:90:360}
# poweshell x-y axis hor (3,6,9,12,3) ~= world x-y axis = hour x-y axis +90

# arclen =elipsin 2000 adımlık toplam uzunluğu, oldt=0..2*pi arası radian değerleri
function Build-EllipseArcTable($a, $b, $steps = 360) {
    # saat yönünün tersi, saat 3ten geriye doğru 360 derece: <== x-y  cos-sin ekseni
    $table = @()
    $arclen = 0

    $px = $a
    $py = 0

    for ($i = 0; $i -le $steps; $i++) {
        # if i=(0..1) =>oldt=(0..2*pi) =>hour=(3..6..9..12 -3)
        $oldT = 2 * [math]::PI * $i / $steps
        # x= newRx, y= newRy
        $x = $a * [math]::cos($oldT)
        $y = $b * [math]::sin($oldT)

        $seg = [math]::Sqrt(($x - $px) * ($x - $px) + ($y - $py) * ($y - $py))
        $arcLen += $seg

        $table += [pscustomobject]@{
            oldT   = $oldT
            arclen = $arcLen
        }
        # if ($i % 60 -eq 0) { Write-Host "bi: $i=$([math]::round($oldT*180/[math]::PI)) , $([math]::round($seg)) ::  $([math]::round($x)) $([math]::round($y))  :: $([math]::round($arclen))" }

        $px = $x
        $py = $y
    }


    return $table
}

# ------------get old radian for arc len----------------------

# if arclen pie>30/360 (30.586/360); find radian between radians(30-31) else dont change radian.
function Get-EllipseAngle($table, $arcLen_hour) {
    for ($i = 1; $i -le $table.Count; $i++) {
        if ($table[$i].arclen -ge $arcLen_hour) {
            $l1 = $table[$i - 1].arclen
            $l2 = $table[$i].arclen

            $oldT1 = $table[$i - 1].oldT
            $oldT2 = $table[$i].oldT

            $f = ($arcLen_hour - $l1) / ($l2 - $l1)

            return $oldT1 + ($oldT2 - $oldT1) * $f
        }
    }

    return $table[-1].oldT
}


$arcTable = Build-EllipseArcTable ($mainRx*1) ($mainRy*1)
$totalLen = $arcTable[-1].arclen
$ellipsePoints = @()
# $arcTable[720].oldT*180/[math]::PI
# $rd=Get-EllipseAngle $arcTable ($totalLen/12)
# $rd * (180 / [Math]::PI)
# $totalLen
$offset = 1.24

$hr = $now.Hour
$mn = $now.Minute
$offsetpnts = @()

$nowi = $hr * 4
$nowd = $nowi + [int]($mn / 15)
$nowdf = ($nowi + ($mn / 15))

for ($i = 0; $i -le 48; $i++) {
    # starts in [now_hour*4 +(now_min/4)] : 48 slices for 12 hours, 1 slice=15 minutes

    $newi = $i
    $arcLen = (7.5 * $totalLen * $newi / 360)

    $oldT = Get-EllipseAngle $arcTable $arcLen
    $oldTdg = $oldT * 180 / [math]::PI

    $newRx = $mainRx * [math]::cos($oldT)
    $newRy = $mainRy * [math]::sin($oldT)

    $NewT = [math]::Atan2($newRy, $newRx)
    $NewTdg = $NewT * 180 / [math]::PI
    if ($NewTdg -lt 0) { $NewTdg += 360}
    # Write-Host $NewTdg

    $newRlen = [math]::Sqrt($newRx * $newRx + $newRy * $newRy)

    $offsetx = $c1 + $newRx * $offset
    $offsety = $c2 + $newRy * $offset

    $offsetpnts += [pscustomobject]@{
        x = $offsetx
        y = $offsety
    }

    # if ($i%4 -eq 0) {
    #     $gfx.DrawLine($pink, $c1, $c2, $offsetx , $offsety)
    # }
    # else {
    #     $gfx.DrawLine($grydrk, $c1, $c2, $offsetx , $offsety)
    # }
    # if ($i % 4 -eq 0) { Write-Host "$i   $($i*7.5)=$([math]::round($oldTdg))=$([math]::round($NewTdg))    :::[$([math]::round($newRx)) $([math]::round($newRy)) ]      $([math]::round($newRlen))" }

    # if ($newi % 4 -eq 0) {
    #     # $gfx.DrawString("$i    $([math]::round($oldTdg))   $([math]::round($NewTdg))             $([math]::round($newRx))   $([math]::round($newRy))       $([math]::round($newRlen))", $font, $whte, [PointF]::new($c1 + $newRx, $c2 + $newRy))
    #     $gfx.DrawString("$i ... $([math]::round($oldTdg)) - $([math]::round($NewTdg))", $font, $whte, [PointF]::new($offsetx, $offsety))
    # }

    $ellipsePoints += [pscustomobject]@{
        oldT    = $oldT
        newT    = $newT
        newRx   = $newRx
        newRy   = $newRy
        newRlen = $newRlen
        offsetx = $offsetx
        offsety = $offsety
    }
}



# boxes ($unt * 16 ) ($unt * 0 ) ($unt * 6 ) ($unt * 8-25)

# 'Nottingham Fo' 82x15,5   ; "20:45" 32x15,5 ; 1 letter width=8

# $fonttest = $fontgf
# $text = '2 - 1'
# # # (Get-PreciseTextWidth $text $fonttest).Height
# $gfx.MeasureString($text, $fonttest).Height
# # (Get-PreciseTextWidth $text $fonttest).width
# $gfx.MeasureString($text, $fonttest).Width

# Write-Host "vars importing..."
# Start-Sleep -Seconds 2
