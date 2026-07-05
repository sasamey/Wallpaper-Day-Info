Add-Type -AssemblyName System.Drawing

# Dosya yollarını belirleyin
$sourcePath = 'vag.png'
$outputPath = 'output_upscaled.png'

# Orijinal resmi yükle
$srcImage = [System.Drawing.Image]::FromFile($sourcePath)

# Yeni boyutları hesapla (2 katı)
$newWidth = 1920 #$srcImage.Width
$newHeight = $srcImage.Height*1920 / $srcImage.Width

# Yeni boş bir bitmap oluştur
$destBitmap = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$destBitmap.SetResolution($srcImage.HorizontalResolution, $srcImage.VerticalResolution)


# Grafik nesnesini hazırla
$gfx = [System.Drawing.Graphics]::FromImage($destBitmap)

# --- EN YÜKSEK KALİTE AYARLARI ---
$gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gfx.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

# Kenar hatalarını (ghosting) önlemek için WrapMode ayarı (Opsiyonel ama önerilir)
$attributes = New-Object System.Drawing.Imaging.ImageAttributes
$attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)

# Resmi çiz (Büyütme burada gerçekleşiyor)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $newWidth, $newHeight)
$gfx.DrawImage($srcImage, $destRect, 0, 0, $srcImage.Width, $srcImage.Height, [System.Drawing.GraphicsUnit]::Pixel, $attributes)

# Kaynakları serbest bırak ve kaydet
$destBitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$gfx.Dispose()
$srcImage.Dispose()
$destBitmap.Dispose()

Write-Host 'R'