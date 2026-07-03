<#
.SYNOPSIS
  Rebuild vm_ak47.prefab — single v_ak47 renderer + camera bone (drops M4 invisible master hack).

.EXAMPLE
  powershell -File Rebuild-Ak47ViewmodelPrefab.ps1
#>
[CmdletBinding()]
param(
    [switch] $DxrpOnly,
    [switch] $IncludeArms
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoPrefab = Join-Path $Here '..\Assets\addons\lifepunch\ak47\equipment\vm_ak47\vm_ak47.prefab'
$DxrpPrefab = 'D:\Steam\steamapps\common\sbox\dxrp\game\Assets\addons\lifepunch\ak47\equipment\vm_ak47\vm_ak47.prefab'
$M4Template = 'D:\Steam\steamapps\common\sbox\dxrp\game\Assets\gameplay\equipment\weapons\m4a1\vm_m4a1.prefab'

if (-not (Test-Path -LiteralPath $M4Template)) {
    throw "Missing M4 template: $M4Template"
}

$text = [IO.File]::ReadAllText($M4Template)
$text = $text.Replace('"Name": "vm_m4a1"', '"Name": "vm_ak47"')
$text = $text.Replace(
    '"Model": "models/weapons/sbox_assault_m4a1/v_m4a1.vmdl"',
    '"Model": "addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/v_ak47.vmdl"'
)
$text = [regex]::Replace(
    $text,
    '(addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/v_ak47\.vmdl",[\s\S]*?"UseAnimGraph": )true',
    '${1}false',
    1
)
if (-not $IncludeArms) {
    $text = [regex]::Replace($text, '("__guid": "f46fd200-29f1-4c4f-8f26-4e993ed5cec4",[\s\S]*?"__enabled": )true', '${1}false', 1)
}

$minimalChildren = @'
    "Children": [
      {
        "__guid": "f7e627b3-5e09-46e2-9788-73703e999b75",
        "__version": 1,
        "Flags": 4,
        "Name": "camera",
        "Position": "0,0,0",
        "Rotation": "0,0,0,1",
        "Scale": "1,1,1",
        "Tags": "",
        "Enabled": true,
        "NetworkMode": 2,
        "NetworkInterpolation": true,
        "NetworkOrphaned": 0,
        "OwnerTransfer": 1,
        "Components": [],
        "Children": []
      },
      {
        "__guid": "17537c4e-23c1-45b8-9429-f950b345213d",
        "__version": 1,
        "Flags": 4,
        "Name": "muzzle",
        "Position": "20.07571,0,7.212921",
        "Rotation": "0,0,0,1",
        "Scale": "1,1,1",
        "Tags": "",
        "Enabled": true,
        "NetworkMode": 2,
        "NetworkInterpolation": true,
        "NetworkOrphaned": 0,
        "OwnerTransfer": 1,
        "Components": [],
        "Children": []
      },
      {
        "__guid": "60019c0b-5443-4e23-9154-37648ba90882",
        "__version": 1,
        "Flags": 4,
        "Name": "ejectionport",
        "Position": "1.774985,-0.4210945,7.672482",
        "Rotation": "0,0,0,1",
        "Scale": "1,1,1",
        "Tags": "",
        "Enabled": true,
        "NetworkMode": 2,
        "NetworkInterpolation": true,
        "NetworkOrphaned": 0,
        "OwnerTransfer": 1,
        "Components": [],
        "Children": []
      }
    ],
'@

$text = [regex]::Replace(
    $text,
    '(?s)    "Children": \[.*?\r?\n    \],',
    $minimalChildren.TrimEnd(),
    1
)

$text = $text.Replace(
    @"
  "__references": [
    "facepunch.v_first_person_arms_human#205798",
    "facepunch.v_m4a1#152506"
  ],
"@,
    @"
  "__references": [
    "facepunch.v_first_person_arms_human#205798"
  ],
"@
)

$targets = @()
if (-not $DxrpOnly) { $targets += $RepoPrefab }
$targets += $DxrpPrefab

foreach ($path in $targets) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($path, $text, $utf8)
    Write-Host "OK $path" -ForegroundColor Green
}

Write-Host 'vm_ak47 rebuilt: v_ak47 master, no M4 hack, minimal bone children.' -ForegroundColor Cyan
