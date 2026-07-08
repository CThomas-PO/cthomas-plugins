# bump.ps1 - set the plugin version in both manifests, show proof, stage the files.
# Usage:  .\bump.ps1 0.6.0                                  (defaults to job-search-copilot)
#         .\bump.ps1 0.6.0 -Plugin user-persona-generator
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$Plugin = "job-search-copilot"
)

$ErrorActionPreference = "Stop"

# Must look like semver: X.Y.Z
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "ERROR: '$Version' is not a valid version. Use the form 0.6.0" -ForegroundColor Red
    exit 1
}

# Run from the repo root (where this script lives)
Set-Location $PSScriptRoot

if (-not (Test-Path "plugins\$Plugin")) {
    Write-Host "ERROR: no such plugin 'plugins\$Plugin'. Available:" -ForegroundColor Red
    Get-ChildItem "plugins" -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
    exit 1
}

$pluginFile      = "plugins\$Plugin\.claude-plugin\plugin.json"
$marketplaceFile = ".claude-plugin\marketplace.json"

foreach ($f in @($pluginFile, $marketplaceFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "ERROR: can't find $f - are you in the repo root?" -ForegroundColor Red
        exit 1
    }
}

# Replace the first "version": "..." field found at or after $Anchor in $Text (or the
# first one in the file if $Anchor is empty). A targeted text replace, not a JSON
# parse/re-serialize round trip, so original formatting, key order, and encoding survive untouched.
function Set-VersionField {
    param([string]$Text, [string]$Anchor, [string]$NewVersion)

    $searchFrom = 0
    if ($Anchor) {
        $searchFrom = $Text.IndexOf($Anchor)
        if ($searchFrom -lt 0) {
            throw "couldn't find anchor '$Anchor'"
        }
    }
    $match = [regex]::Match($Text.Substring($searchFrom), '"version":\s*"(\d+\.\d+\.\d+)"')
    if (-not $match.Success) {
        throw "couldn't find a version field"
    }
    $oldVersion = $match.Groups[1].Value
    $absoluteIndex = $searchFrom + $match.Index
    $newText = $Text.Substring(0, $absoluteIndex) + $match.Value.Replace($oldVersion, $NewVersion) + $Text.Substring($absoluteIndex + $match.Length)
    return @{ Text = $newText; OldVersion = $oldVersion }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# --- plugin.json ---
$result = Set-VersionField -Text (Get-Content $pluginFile -Raw) -Anchor "" -NewVersion $Version
$oldPlugin = $result.OldVersion
[System.IO.File]::WriteAllText((Resolve-Path $pluginFile), $result.Text, $utf8NoBom)

# --- marketplace.json (only this plugin's entry; metadata.version is left alone) ---
$result = Set-VersionField -Text (Get-Content $marketplaceFile -Raw) -Anchor "`"$Plugin`"" -NewVersion $Version
$oldMarketplace = $result.OldVersion
[System.IO.File]::WriteAllText((Resolve-Path $marketplaceFile), $result.Text, $utf8NoBom)

# --- proof ---
Write-Host ""
Write-Host "plugin.json       : $oldPlugin -> $Version" -ForegroundColor Green
Write-Host "marketplace.json  : $oldMarketplace -> $Version" -ForegroundColor Green

if ($oldPlugin -eq $Version -and $oldMarketplace -eq $Version) {
    Write-Host "NOTE: both files already said $Version - nothing changed." -ForegroundColor Yellow
}

# --- stage ---
git add $pluginFile $marketplaceFile
Write-Host ""
Write-Host "Both files staged. Reminder: add a changelog line to README.md, then:" -ForegroundColor Cyan
Write-Host "  git add README.md"
Write-Host "  git commit -m `"bump to $Version`""
Write-Host "  git push"
