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

.EXAMPLE
    ./scripts/package.ps1 -RevitYear 2027 -Version 1.2.3
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet(2025, 2026, 2027)][int]$RevitYear,
    [Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
    [string]$Configuration = 'Release',
    [string]$OutDir = 'artifacts'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

$targets = @{
    2025 = @{ Dynamo = '3.0'; Engine = '3.0.4.7905';  Tfm = 'net8.0-windows'  }
    2026 = @{ Dynamo = '3.6'; Engine = '3.6.2.11575'; Tfm = 'net8.0-windows'  }
    2027 = @{ Dynamo = '4.0'; Engine = '4.0.2.3870';  Tfm = 'net10.0-windows' }
}
$target = $targets[$RevitYear]

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
Set-Content (Join-Path $stage 'pkg.json') -Value $pkg -Encoding utf8

$zip = Join-Path $outPath "archi-lab.net_${Version}_Revit${RevitYear}_Dynamo$($target.Dynamo).zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
Remove-Item $stage -Recurse -Force

$size = [math]::Round((Get-Item $zip).Length / 1MB, 2)
Write-Host "Packaged Revit $RevitYear (Dynamo $($target.Dynamo)) -> $zip [$size MB]"
