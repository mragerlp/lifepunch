<#
.SYNOPSIS
  Insert or upgrade LifePunch post-download compile hotfix in on-box dxrp-server.cs (idempotent).
#>
[CmdletBinding()]
param(
    [string] $InstallRoot
)

$ErrorActionPreference = 'Stop'

if (-not $InstallRoot) { throw 'InstallRoot required' }

$launcher = Join-Path $InstallRoot 'dxrp-server.cs'
if (-not (Test-Path -LiteralPath $launcher)) {
    Write-Host "  skip hook, no dxrp-server.cs in $InstallRoot" -ForegroundColor DarkGray
    return
}

$runCompileHotfixesMethod = @'
    static void RunCompileHotfixes()
    {
        try
        {
            var root = Directory.GetCurrentDirectory();
            Console.ForegroundColor = ConsoleColor.DarkGray;
            Console.WriteLine("  Applying compile hotfixes...");
            Console.ResetColor();

            var pickpocket = Path.Combine(root, "dxrp", "game", "Code", "Addons", "pikpak", "pickpocket", "PickpocketService.cs");
            if (File.Exists(pickpocket))
            {
                var text = File.ReadAllText(pickpocket);
                const string bad = "if ( !current.IsValid() || !string.Equals( current.Identifier, Identifier, StringComparison.OrdinalIgnoreCase ) )";
                const string good = "if ( !current.IsValid() )";
                if (text.Contains(bad))
                {
                    File.WriteAllText(pickpocket, text.Replace(bad, good));
                    Console.WriteLine("  patched pikpak.pickpocket Equipment.Identifier");
                }
                else if (text.Contains(good))
                {
                    Console.WriteLine("  skip pikpak.pickpocket (already patched)");
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine("  warn pikpak.pickpocket (pattern missing, portal revision may have changed)");
                    Console.ResetColor();
                }
            }
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("  WARN compile hotfix: " + ex.Message);
            Console.ResetColor();
        }
    }

'@

function Get-ClosingBraceIndex {
    param(
        [string] $Text,
        [int] $OpenBraceIndex
    )
    $depth = 0
    for ($i = $OpenBraceIndex; $i -lt $Text.Length; $i++) {
        switch ($Text[$i]) {
            '{' { $depth++; break }
            '}' {
                $depth--
                if ($depth -eq 0) { return $i }
                break
            }
        }
    }
    throw 'Unbalanced braces in dxrp-server.cs'
}

function Remove-RunCompileHotfixesMethods {
    param([string] $Text)

    $signature = '(?ms)\r?\n\s*static void RunCompileHotfixes\(\)\s*\{'
    while ($Text -match $signature) {
        $match = [regex]::Match($Text, $signature)
        $openBrace = $Text.IndexOf('{', $match.Index)
        $closeBrace = Get-ClosingBraceIndex -Text $Text -OpenBraceIndex $openBrace
        $end = $closeBrace + 1
        if ($end -lt $Text.Length -and $Text[$end] -eq "`r") { $end++ }
        if ($end -lt $Text.Length -and $Text[$end] -eq "`n") { $end++ }
        $Text = $Text.Remove($match.Index, $end - $match.Index)
    }

    # Orphan tail left by older non-greedy regex upgrades.
    $orphan = '(?ms)\r?\n\s*else if \(text\.Contains\(good\)\)\s*\{.*?\n\s*\}\s*\n\s*\}\s*\n\s*catch \(Exception ex\)\s*\{.*?\n\s*\}\s*\n\s*\}\s*\n(?=\s*static void ClearDir)'
    return [regex]::Replace($Text, $orphan, "`n")
}

$text = Get-Content -LiteralPath $launcher -Raw
$text = Remove-RunCompileHotfixesMethods -Text $text

$callAnchor = '            Ok("All addons ready.");'
$callInsert = @'
            Ok("All addons ready.");

            // lifepunch: patch portal addons for staging API drift before sbox-server compile
            RunCompileHotfixes();
'@

if ($text.Contains('RunCompileHotfixes();')) {
    # Call already present — only refresh method body.
}
elseif ($text.Contains($callAnchor)) {
    $text = $text.Replace($callAnchor, $callInsert)
}
else {
    throw "dxrp-server.cs call anchor not found in $InstallRoot"
}

$methodAnchor = '    static void ClearDir(string path)'
if (-not $text.Contains($methodAnchor)) {
    throw "dxrp-server.cs method anchor not found in $InstallRoot"
}

$newText = $text.Replace($methodAnchor, $runCompileHotfixesMethod + $methodAnchor)
Set-Content -LiteralPath $launcher -Value $newText -NoNewline
Write-Host "  installed dxrp-server.cs hotfix hook -> $InstallRoot" -ForegroundColor Green
