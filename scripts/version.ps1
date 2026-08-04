# Single source of truth for what each Revit version targets, and for the
# package version scheme. Dot-sourced by package.ps1 and the release workflow.

# Dynamo      - the DynamoRevit version. Names the packages folder under
#               %AppData%\Dynamo\Dynamo Revit\<version>\packages.
# Engine      - the DynamoCore version. What pkg.json's engine_version means,
#               and what the DynamoVisualProgramming.* packages track.
#
# DynamoRevit and DynamoCore were the same number until Revit 2027, where
# DynamoRevit switched to year-based versioning (27.0) while DynamoCore
# continued as 4.0.
$ArchilabTargets = @{
    2025 = @{ Dynamo = '3.2';  Engine = '3.2.1.5366'; Tfm = 'net8.0-windows'  }
    2026 = @{ Dynamo = '3.6';  Engine = '3.6.1.9895'; Tfm = 'net8.0-windows'  }
    2027 = @{ Dynamo = '27.0'; Engine = '4.0.2.3852'; Tfm = 'net10.0-windows' }
}

# The current release line: the newest supported Revit year, and the DynamoCore
# major/minor it ships with, with the dot dropped (4.0 -> 400).
#
# This is deliberately ONE line shared by every Revit version in a release
# round, rather than per-Revit values. The Dynamo Package Manager will not
# accept a version that moves backwards, and all Revit versions publish under
# the single archi-lab.net package name. If the major encoded the target Revit
# year, then publishing 2027.x and later shipping a 2025.x fix would move the
# major backwards and be rejected.
#
# Bump these when adding support for a newer Revit.
$ArchilabLineMajor = 2027
$ArchilabLineMinor = '400'

function Get-ArchilabVersion {
    <#
    .SYNOPSIS
        Builds the archi-lab.net package version for a Revit version.

    .DESCRIPTION
        Format: <LineMajor>.<LineMinor>.<Build><YY>

            2027.400.1325  =  2027 line, Dynamo 4.0, build 13, for Revit '25
            2027.400.1326  =  same round, same build, for Revit '26
            2027.400.1327  =  same round, same build, for Revit '27

        The trailing two digits are the Revit version this package targets, and
        are what keep the three packages built from one round distinct. Because
        they ascend with the Revit year, publishing a round in 2025 -> 2026 ->
        2027 order always moves the version forwards, and the next round's
        higher build number clears every version of the previous round.

        This matches the established scheme, where e.g. 2023.213.1722 was the
        Revit 2022 build published under the 2023 line.
    #>
    param(
        [Parameter(Mandatory)][ValidateSet(2025, 2026, 2027)][int]$RevitYear,
        [Parameter(Mandatory)][ValidateRange(1, 99)][int]$Build
    )

    "{0}.{1}.{2}{3:D2}" -f $ArchilabLineMajor, $ArchilabLineMinor, $Build, ($RevitYear % 100)
}
