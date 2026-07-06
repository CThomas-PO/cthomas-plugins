# bump.ps1 — set the plugin version in both manifests, show proof, stage the files.
# Usage:  .\bump.ps1 0.6.0
param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

# Must look like semver: X.Y.Z
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "ERROR: '$Version' is not a valid version. Use the form 0.6.0" -ForegroundColor Red
    exit 1
}

# Run from the repo root (where this script lives)
Set-Location $PSScriptRoot

$pluginFile      = "plugins\job-search-copilot\.claude-plugin\plugin.json"
$marketplaceFile = ".claude-plugin\marketplace.json"

foreach ($f in @($pluginFile, $marketplaceFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "ERROR: can't find $f — are you in the repo root?" -ForegroundColor Red
        exit 1
    }
}

# --- plugin.json ---
$plugin = Get-Content $pluginFile -Raw | ConvertFrom-Json
$oldPlugin = $plugin.version
$plugin.version = $Version
$plugin | ConvertTo-Json -Depth 10 | Set-Content $pluginFile -Encoding UTF8

# --- marketplace.json (only the plugin entry; metadata.version is left alone) ---
$marketplace = Get-Content $marketplaceFile -Raw | ConvertFrom-Json
$entry = $marketplace.plugins | Where-Object { $_.name -eq "job-search-copilot" }
if (-not $entry) {
    Write-Host "ERROR: no 'job-search-copilot' entry found in marketplace.json" -ForegroundColor Red
    exit 1
}
$oldMarketplace = $entry.version
$entry.version = $Version
$marketplace | ConvertTo-Json -Depth 10 | Set-Content $marketplaceFile -Encoding UTF8

# --- proof ---
Write-Host ""
Write-Host "plugin.json       : $oldPlugin -> $Version" -ForegroundColor Green
Write-Host "marketplace.json  : $oldMarketplace -> $Version" -ForegroundColor Green

if ($oldPlugin -eq $Version -and $oldMarketplace -eq $Version) {
    Write-Host "NOTE: both files already said $Version — nothing changed." -ForegroundColor Yellow
}

# --- stage ---
git add $pluginFile $marketplaceFile
Write-Host ""
Write-Host "Both files staged. Reminder: add a changelog line to README.md, then:" -ForegroundColor Cyan
Write-Host "  git add README.md"
Write-Host "  git commit -m `"bump to $Version`""
Write-Host "  git push"
