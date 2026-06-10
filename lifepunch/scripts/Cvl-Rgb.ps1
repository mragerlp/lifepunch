# CVL RGB integration diagnostics — additive mixing, not a group nickname.

function Get-CvlRgbDiagnostics {
    param(
        $Vengeance,
        $Cornerman,
        $Lifepunchnet,
        [bool]$CvlReady = $false,
        [bool]$SecurityPass = $true
    )

    $rLit = $false
    $gLit = $false
    $bLit = $false

    if ($Vengeance) {
        $rLit = -not $Vengeance.dirty -and ($Vengeance.behind -eq 0)
    }
    if ($Cornerman) {
        $gLit = [bool]$Cornerman.relayCmd -and [bool]$Cornerman.relayStarter
    }
    if ($Lifepunchnet) {
        $bLit = [bool]$Lifepunchnet.whisperOk -and [bool]$Lifepunchnet.sessionHubOk
    }

    $yellow = $rLit -and $gLit
    $cyan = $gLit -and $bLit
    $magenta = $bLit -and $rLit
    $white = $rLit -and $gLit -and $bLit -and $CvlReady -and $SecurityPass
    $black = (-not $rLit -and -not $gLit -and -not $bLit) -or (-not $SecurityPass)

    $state = 'partial-rgb'
    $detail = 'primaries mixing - not white yet'
    if ($black -and -not $white) { $state = 'black'; $detail = 'no trustworthy signal' }
    elseif ($white) { $state = 'white'; $detail = 'R+G+B full - universal go candidate' }
    elseif ($yellow -and -not $cyan) { $state = 'yellow'; $detail = 'R+G voice desk path' }
    elseif ($cyan -and -not $magenta) { $state = 'cyan'; $detail = 'G+B worker-to-host path' }
    elseif ($magenta -and -not $yellow) { $state = 'magenta'; $detail = 'B+R host-to-desk path' }

    return [pscustomobject]@{
        redLit    = $rLit
        greenLit  = $gLit
        blueLit   = $bLit
        yellow    = $yellow
        cyan      = $cyan
        magenta   = $magenta
        white     = $white
        black     = $black
        state     = $state
        detail    = $detail
        rainbow   = 'not-yet'
    }
}

function Write-CvlRgbReport {
    param($Rgb)
    Write-Host '  RGB INTEGRATION (additive)' -ForegroundColor DarkMagenta
    Write-Host ("    R (VENGEANCE)   {0}" -f $(if ($Rgb.redLit) { 'LIT' } else { 'dim/off' })) -ForegroundColor $(if ($Rgb.redLit) { 'Red' } else { 'DarkGray' })
    Write-Host ("    G (Cornerman)   {0}" -f $(if ($Rgb.greenLit) { 'LIT' } else { 'dim/off' })) -ForegroundColor $(if ($Rgb.greenLit) { 'Green' } else { 'DarkGray' })
    Write-Host ("    B (lifepunchnet) {0}" -f $(if ($Rgb.blueLit) { 'LIT' } else { 'dim/off' })) -ForegroundColor $(if ($Rgb.blueLit) { 'Blue' } else { 'DarkGray' })
    Write-Host ("    mix: yellow={0} cyan={1} magenta={2}" -f $Rgb.yellow, $Rgb.cyan, $Rgb.magenta) -ForegroundColor Gray
    Write-Host ("    integration: {0} - {1}" -f $Rgb.state, $Rgb.detail) -ForegroundColor $(if ($Rgb.white) { 'White' } elseif ($Rgb.black) { 'DarkGray' } else { 'Yellow' })
    Write-Host '    rainbow: not yet - standard RGB phase' -ForegroundColor DarkGray
}
