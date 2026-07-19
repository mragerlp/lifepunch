$f = 'D:\Steam\steamapps\common\sbox\logs\sbox-dev.log'
$hits = Select-String -Path $f -Pattern 'Compile of|error CS|playerhub|PlayerHub' | Select-Object -Last 12
foreach ($h in $hits) { "{0}: {1}" -f $h.LineNumber, $h.Line.Substring(0, [Math]::Min(180, $h.Line.Length)) }
if (-not $hits) { "nothing" }
