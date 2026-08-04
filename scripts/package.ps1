<#
.SYNOPSIS
    Stages a built archilab version as a Dynamo package and zips it.

.DESCRIPTION
    Copies from the archilabUI<year> output directory, which is a superset of
    the core project's output (CopyLocalLockFileAssemblies plus the
    ProjectReference), into the pkg.json / bin / extra layout Dynamo expects.

    Assemblies are chosen by allowlist, never by exclusion: the build output
    also contains RevitAPI.dll, RevitAPIUI.dll, AdWindows.dll and the whole
    Dynamo assembly set, none of which may ship in a package.

.PARAMETER Date
    Build date the version is stamped from; defaults to today. Override it
    only to reproduce an earlier release. See Get-ArchilabVersion in
    version.ps1 for the format.

.EXAMPLE
    ./scripts/package.ps1 -RevitYear 2027
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet(2025, 2026, 2027)][int]$RevitYear,
    [datetime]$Date = (Get-Date),
    [string]$Configuration = 'Release',
    [string]$OutDir = 'dist'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'version.ps1')

$target = $ArchilabTargets[$RevitYear]
$Version = Get-ArchilabVersion -RevitYear $RevitYear -Date $Date

$src = Join-Path $root "archilabUI$RevitYear\bin\$Configuration\$($target.Tfm)"
if (-not (Test-Path $src)) {
    throw "Build output not found: $src. Build archilabUI$RevitYear in $Configuration first."
}

# Ship these. A missing one is a packaging bug, so fail rather than ship a
# package that loads with pieces silently absent.
$required = @(
    "archilab$RevitYear"
    "archilabUI$RevitYear"
    'ClosedXML'
    'CommunityToolkit.Mvvm'
    'DocumentFormat.OpenXml'
    'EPPlus'
    'ExcelNumberFormat'
    'FastMember.Signed'
    'HtmlAgilityPack'
    'itextsharp'
    'LumenWorks.Framework.IO'
    'Microsoft.Xaml.Behaviors'
    'RestSharp'
    'WeCantSpell.Hunspell'
    'Xceed.Wpf.Toolkit'
)

# Inbox on net8/net10, so normally absent from the output. Ship them only if
# the build actually produced them.
$optional = @(
    'System.Buffers'
    'System.Drawing.Common'
    'System.IO.Packaging'
    'System.Memory'
    'System.Numerics.Vectors'
    'System.Runtime.CompilerServices.Unsafe'
)

$outPath = Join-Path $root $OutDir
$stage = Join-Path $outPath "stage-$RevitYear"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Join-Path $stage 'bin'), (Join-Path $stage 'extra') | Out-Null

$binDir = Join-Path $stage 'bin'

foreach ($name in $required) {
    Copy-Item (Join-Path $src "$name.dll") $binDir
}

$skipped = @()
foreach ($name in $optional) {
    $dll = Join-Path $src "$name.dll"
    if (Test-Path $dll) { Copy-Item $dll $binDir } else { $skipped += $name }
}
if ($skipped) { Write-Host "  note: not in build output, skipped: $($skipped -join ', ')" }

# XML docs drive Dynamo's node tooltips; the customization file maps
# namespaces to library categories. Both must sit alongside the assemblies.
foreach ($name in @("archilab$RevitYear", "archilabUI$RevitYear")) {
    $xml = Join-Path $src "$name.xml"
    if (Test-Path $xml) { Copy-Item $xml $binDir }
}
Copy-Item (Join-Path $src "archilab${RevitYear}_DynamoCustomization.xml") $binDir

# Hunspell dictionaries for the spell-check nodes.
Copy-Item (Join-Path $src 'en_US.aff'), (Join-Path $src 'en_US.dic') (Join-Path $stage 'extra')

$assemblyVersion = "$Version.0"
$pkg = Get-Content (Join-Path $PSScriptRoot 'pkg.template.json') -Raw
$pkg = $pkg -replace '\{\{VERSION\}\}', $Version `
            -replace '\{\{YEAR\}\}', $RevitYear `
            -replace '\{\{ENGINE_VERSION\}\}', $target.Engine `
            -replace '\{\{ASSEMBLY_VERSION\}\}', $assemblyVersion

# Every package published carries this license, so make sure the claim is
# actually backed by a LICENSE file in the repository.
$license = ($pkg | ConvertFrom-Json).license
if (-not $license) {
    Write-Warning "pkg.template.json has no license set; every published package will claim none."
} elseif (-not (Test-Path (Join-Path $root 'LICENSE'))) {
    Write-Warning "pkg.template.json claims the $license license but the repository has no LICENSE file."
}

# WriteAllText with an explicit BOM-less encoder: Set-Content -Encoding utf8
# emits a BOM under Windows PowerShell 5.1, which trips strict JSON parsers.
[System.IO.File]::WriteAllText(
    (Join-Path $stage 'pkg.json'), $pkg, (New-Object System.Text.UTF8Encoding($false)))

$zip = Join-Path $outPath "archi-lab.net_${Version}_Revit${RevitYear}_Dynamo$($target.Dynamo).zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
Remove-Item $stage -Recurse -Force

$size = [math]::Round((Get-Item $zip).Length / 1MB, 2)
Write-Host "Packaged Revit $RevitYear (Dynamo $($target.Dynamo)) -> $zip [$size MB]"

