<#
.SYNOPSIS
  Windows toast notification for LifePunch ops events.

.EXAMPLE
  . .\Send-LifePunchToast.ps1; Send-LifePunchToast -Title 'CVL' -Message 'MCP down'
#>
function Send-LifePunchToast {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Title,
        [Parameter(Mandatory)]
        [string] $Message,
        [ValidateSet('default', 'warning', 'error')]
        [string] $Tone = 'default',
        [switch] $AllowNonVengeance
    )

    if (-not $AllowNonVengeance) {
        $opsHelper = Join-Path $PSScriptRoot 'LifePunch-OpsNode.ps1'
        if (Test-Path -LiteralPath $opsHelper) {
            . $opsHelper
            if (-not (Test-IsVengeanceWorkstation)) { return $false }
        }
        else {
            $hn = $env:COMPUTERNAME.ToUpperInvariant()
            if ($hn -notlike '*VENGEANCE*') { return $false }
        }
    }

    $safeTitle = [System.Security.SecurityElement]::Escape($Title)
    $safeMsg = [System.Security.SecurityElement]::Escape($Message)
    if (-not $safeTitle) { $safeTitle = 'LifePunch' }
    if (-not $safeMsg) { $safeMsg = $Message }

    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

        $appId = 'LifePunch.CVL'
        $xml = @"
<toast duration="long">
  <visual>
    <binding template="ToastGeneric">
      <text>$safeTitle</text>
      <text>$safeMsg</text>
    </binding>
  </visual>
  <audio src="ms-winsoundevent:Notification.$($Tone)" />
</toast>
"@
        $doc = New-Object Windows.Data.Xml.Dom.XmlDocument
        $doc.LoadXml($xml)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($doc)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
        return $true
    }
    catch {
        Write-Host "[TOAST] $Title - $Message" -ForegroundColor Yellow
        return $false
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Send-LifePunchToast @PSBoundParameters
}
