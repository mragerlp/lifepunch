param(
    [Parameter(Mandatory = $true)]
    [string]$Addon,

    [switch]$OpenFolder
)

$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'config\addons.json'
$UploadRoot = Join-Path $Root '.dxrp-publish\upload'

function Copy-PublishItems {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        return
    }

    $SourceRoot = (Resolve-Path -LiteralPath $Source).Path
    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Force |
        Where-Object {
            $Relative = $_.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
            $RelativeParts = $Relative -split '[\\/]'

            # Dev-only helpers never ship: *TestBots.cs, *DevGive.cs, *DevSpawn.cs, or anything
            # under a `_dev/` folder, stays out of the publish staging. Keep this in sync with
            # the dev-only files tracked in lifepunch/addons/docs/TECH_DEBT.md.
            $_.Name -notin @('.gitkeep', 'desktop.ini', 'Thumbs.db', 'material-map.json') `
                -and $_.Extension -ne '.md' `
                -and $RelativeParts -notcontains 'docs' `
                -and $RelativeParts -notcontains '_dev' `
                -and $_.Name -notmatch '(TestBots|DevGive|DevSpawn)'
        } |
        ForEach-Object {
            $Relative = $_.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
            $Target = Join-Path $Destination $Relative
            $TargetParent = Split-Path -Parent $Target

            if (-not (Test-Path -LiteralPath $TargetParent -PathType Container)) {
                New-Item -ItemType Directory -Force -Path $TargetParent | Out-Null
            }

            Copy-Item -LiteralPath $_.FullName -Destination $Target -Force

            if ($_.Extension -eq '.fbx') {
                Clear-SensitiveBinaryStrings -Path $Target
            }
        }
}

function Clear-SensitiveBinaryStrings {
    param(
        [string]$Path
    )

    $Encoding = [System.Text.Encoding]::GetEncoding(28591)
    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    $Text = $Encoding.GetString($Bytes)

    # Strip any embedded local "<drive>:\Users\<name>\..." path (e.g. baked-in texture
    # references from the source artist's machine). The match is bounded by a control char
    # or quote so it only consumes the printable path string. We keep the trailing basename
    # and left-pad with spaces so the byte length is preserved (binary FBX string properties
    # are length-prefixed, so the byte count must not change).
    $SensitivePathPatterns = @(
        '[A-Za-z]:[\\/]Users[\\/][ -~]*?(?=[\x00-\x1f"])'
    )

    foreach ($Pattern in $SensitivePathPatterns) {
        $Text = [System.Text.RegularExpressions.Regex]::Replace($Text, $Pattern, {
            param($Match)

            $Value = $Match.Value
            $BaseName = ($Value -split '[\\/]')[-1]
            if ([string]::IsNullOrWhiteSpace($BaseName)) {
                $BaseName = 'asset'
            }

            if ($BaseName.Length -ge $Value.Length) {
                return $BaseName.Substring(0, $Value.Length)
            }

            return (' ' * ($Value.Length - $BaseName.Length)) + $BaseName
        })
    }

    [System.IO.File]::WriteAllBytes($Path, $Encoding.GetBytes($Text))
}

& (Join-Path $PSScriptRoot 'validate-layout.ps1')

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$Package = @($Manifest.addons) | Where-Object { $_.ident -eq $Addon } | Select-Object -First 1

if ($null -eq $Package) {
    $Known = (@($Manifest.addons) | ForEach-Object { $_.ident }) -join ', '
    throw "Unknown addon '$Addon'. Known addons: $Known"
}

if (Test-Path -LiteralPath $UploadRoot) {
    Remove-Item -LiteralPath $UploadRoot -Recurse -Force
}

$Org = [string]$Manifest.org
$PublishIdent = if ($Package.packageSlug) { [string]$Package.packageSlug } else { [string]$Package.ident }
$AssetsStage = Join-Path $UploadRoot "Assets\addons\$Org\$PublishIdent"
$CodeStage = Join-Path $UploadRoot "Code\Addons\$Org\$PublishIdent"

if ($Package.hasAssets) {
    $AssetsSource = Join-Path $Root "Assets\addons\$Org\$($Package.ident)"
    New-Item -ItemType Directory -Force -Path $AssetsStage | Out-Null
    Copy-PublishItems -Source $AssetsSource -Destination $AssetsStage
}

if ($Package.hasCode) {
    $CodeSource = Join-Path $Root "Code\Addons\$Org\$($Package.ident)"
    New-Item -ItemType Directory -Force -Path $CodeStage | Out-Null
    Copy-PublishItems -Source $CodeSource -Destination $CodeStage

    # code-only packages that depend on shared LifePunch UI helpers in the parent
    # lifepunch/ folder must vend those files into the publish folder — the dedicated
    # server only mounts Code/Addons/lifepunch/<ident>/, not the parent root.
    $SharedCodeBundle = @{
        adminmenu = @(
            'LifePunchUiScale.cs',
            'LifePunchUiScrollPolicy.cs',
            'LifePunchSourceMark.cs',
            'LifePunchUiFooter.razor',
            'LifePunchUiFooter.razor.scss'
        )
    }

    if ($SharedCodeBundle.ContainsKey($Package.ident)) {
        $SharedRoot = Join-Path $Root "Code\Addons\$Org"
        foreach ($SharedFile in $SharedCodeBundle[$Package.ident]) {
            $SharedSource = Join-Path $SharedRoot $SharedFile
            if (-not (Test-Path -LiteralPath $SharedSource -PathType Leaf)) {
                throw "Publish bundle missing shared file for $($Package.ident): $SharedFile (expected $SharedSource)"
            }

            Copy-Item -LiteralPath $SharedSource -Destination (Join-Path $CodeStage $SharedFile) -Force
        }

        $StaffMenuScss = Join-Path $CodeStage 'StaffMenu.razor.scss'
        if (Test-Path -LiteralPath $StaffMenuScss -PathType Leaf) {
            $Scss = Get-Content -LiteralPath $StaffMenuScss -Raw
            $Patched = $Scss -replace '@import "\.\./LifePunchUiFooter\.razor\.scss";', '@import "./LifePunchUiFooter.razor.scss";'
            if ($Patched -ne $Scss) {
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($StaffMenuScss, $Patched, $utf8NoBom)
            }
        }

        # Dedicated server log shows lifepunch.dxrpadminmenu — mirror bundle for legacy mount name.
        $legacyMounts = @('dxrpadminmenu')
        foreach ($legacy in $legacyMounts) {
            if ($legacy -eq $PublishIdent) { continue }
            $legacyStage = Join-Path $UploadRoot "Code\Addons\$Org\$legacy"
            if (Test-Path -LiteralPath $legacyStage) {
                Remove-Item -LiteralPath $legacyStage -Recurse -Force
            }
            New-Item -ItemType Directory -Force -Path $legacyStage | Out-Null
            Get-ChildItem -LiteralPath $CodeStage -File | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $legacyStage $_.Name) -Force
            }
        }

        $requiredShipFiles = @(
            'StaffMenu.razor',
            'StaffMenuHost.cs',
            'LifePunchUiScale.cs',
            'LifePunchUiScrollPolicy.cs',
            'LifePunchUiFooter.razor',
            'LifePunchSourceMark.cs'
        )
        $shipFiles = @(Get-ChildItem -LiteralPath $CodeStage -File)
        $missing = @($requiredShipFiles | Where-Object {
            -not (Test-Path -LiteralPath (Join-Path $CodeStage $_))
        })
        if ($shipFiles.Count -lt 11 -or $missing.Count -gt 0) {
            throw @"
ULX publish gate FAILED: expected >= 11 code files in $CodeStage, got $($shipFiles.Count).
Missing: $($missing -join ', ')
Do not upload this revision to the portal.
"@
        }

        $codeBytes = ($shipFiles | Measure-Object -Property Length -Sum).Sum
        $verify = [ordered]@{
            schemaVersion = 1
            packageSlug = $PublishIdent
            repoIdent = $Package.ident
            codeMount = "Code/Addons/$Org/$PublishIdent"
            legacyMounts = $legacyMounts
            fileCount = $shipFiles.Count
            totalBytes = $codeBytes
            files = @($shipFiles | ForEach-Object { $_.Name } | Sort-Object)
            portalUpload = "Upload every file inside: Code/Addons/$Org/$PublishIdent/ (not adminmenu/, not repo root)"
            minDownloadBytesHint = 85000
        }
        $verify | ConvertTo-Json -Depth 4 |
            Set-Content -LiteralPath (Join-Path $Root '.dxrp-publish\ulx-publish-verify.json') -Encoding UTF8

        Write-Host "ULX publish gate OK: $($shipFiles.Count) files, $codeBytes bytes -> $PublishIdent" -ForegroundColor Green
    }
}

$ContentRows = @(@($Package.contents) | ForEach-Object {
    [ordered]@{
        slug = $_.slug
        name = $_.name
        label = $_.label
        type = $_.type
        primaryReference = $_.primaryReference
        secondaryReference = $_.secondaryReference
        worldModelPath = $_.worldModelPath
        iconPath = $_.iconPath
        grouping = $_.grouping
        implementationStatus = $_.implementationStatus
    }
})

$Readme = @"
DXRP publish staging for $Org.$($Package.ident)
=============================================

Generated from:
  $Root

Upload root:
  $UploadRoot

Package:
  Title:      $($Package.title)
  Kind:       $($Package.kind)
  HasAssets:  $($Package.hasAssets)
  HasCode:    $($Package.hasCode)

Expected DXRP paths:
  Assets/addons/$Org/$PublishIdent/
  Code/Addons/$Org/$PublishIdent/

Content rows:
$(
    if ($ContentRows.Count -eq 0) {
        '  (none declared)'
    } else {
        ($ContentRows | ForEach-Object {
            @"
  - $($_.label) [$($_.slug)]
    Name:               $($_.name)
    Type:               $($_.type)
    Primary Reference:  $($_.primaryReference)
    Secondary Reference: $($_.secondaryReference)
    World Model Path:   $($_.worldModelPath)
    Icon Path:          $($_.iconPath)
    Grouping:           $($_.grouping)
"@
        }) -join "`r`n"
    }
)

Do not move files into upload-assets or upload-code. Keep the Assets and Code roots intact.
"@

$StagingRoot = Join-Path $Root '.dxrp-publish'
New-Item -ItemType Directory -Force -Path $StagingRoot | Out-Null
Set-Content -LiteralPath (Join-Path $StagingRoot 'README.txt') -Value $Readme -Encoding UTF8

$PackageExport = [ordered]@{
    schemaVersion = 1
    package = [ordered]@{
        org = $Org
        ident = $Package.ident
        title = $Package.title
        kind = $Package.kind
        dxrpAddonId = $Package.dxrpAddonId
        hasAssets = [bool]$Package.hasAssets
        hasCode = [bool]$Package.hasCode
    }
    contentRows = $ContentRows
}

$PackageExport |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath (Join-Path $StagingRoot "package-$($Package.ident).json") -Encoding UTF8

Write-Host "Prepared DXRP publish staging for $Org.$PublishIdent (repo ident: $($Package.ident))" -ForegroundColor Green
Write-Host "Upload root: $UploadRoot"

if ($OpenFolder) {
    Invoke-Item $UploadRoot
}
