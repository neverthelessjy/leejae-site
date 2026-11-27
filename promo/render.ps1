# 홍보물 HTML을 PDF/PNG로 뽑는다. 사용법: .\render.ps1 <html경로> pdf|png [가로] [세로] [배율]
param([string]$Html, [string]$Mode = "pdf", [int]$W = 1080, [int]$H = 1350, [double]$Scale = 1)
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$full = (Resolve-Path $Html).Path
$url = "file:///" + ($full -replace '\\', '/')
$out = [IO.Path]::ChangeExtension($full, $Mode)
$prof = Join-Path $env:TEMP ("edge-render-" + [guid]::NewGuid())
if (Test-Path $out) { Remove-Item $out }
$common = @("--headless=new", "--disable-gpu", "--user-data-dir=$prof", "--virtual-time-budget=10000", "--hide-scrollbars")
if ($Mode -eq "pdf") {
  $p = Start-Process $edge -ArgumentList ($common + @("--no-pdf-header-footer", "--print-to-pdf=`"$out`"", $url)) -Wait -PassThru
} else {
  $p = Start-Process $edge -ArgumentList ($common + @("--force-device-scale-factor=$Scale", "--window-size=$W,$H", "--screenshot=`"$out`"", $url)) -Wait -PassThru
}
Remove-Item -Recurse -Force $prof -ErrorAction SilentlyContinue
Get-Item $out | Select-Object Name, Length, LastWriteTime
