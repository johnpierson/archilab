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

# Frozen. The Dynamo Package Manager refuses a version that moves backwards,
# and every Revit version publishes under the single archi-lab.net package
# name, so the major cannot encode anything that varies per release -- a
# target Revit year in the major would make a 2025 fix unpublishable after a
# 2027 release. Holding it constant removes that whole class of problem. It
# only has to stay at or above the last published major (2025.300.1225).
$ArchilabVersionMajor = 2027

function Get-ArchilabVersion {
    <#
    .SYNOPSIS
        Builds the archi-lab.net package version for a Revit version.

    .DESCRIPTION
        Format: <Major>.<YYDDD>.<YY>   frozen major . date . target Revit

            2027.26216.25  =  built 2026 day 216 (Aug 4), for Revit '25
            2027.26216.26  =  same build, for Revit '26
            2027.26216.27  =  same build, for Revit '27

        The middle segment is the build date as a two-digit year followed by
        the day of year. Ordering therefore comes from the date rather than a
        counter anyone has to remember to increment, and the trailing Revit
        year keeps a single day's three packages distinct and ascending.

        The date is YYDDD rather than YYMMDD because this string is also the
        assembly version, whose components are 16-bit: 26216 fits, 260804 does
        not. The encoding stays monotonic and unambiguous through 2065.
    #>
    param(
        [Parameter(Mandatory)][ValidateSet(2025, 2026, 2027)][int]$RevitYear,
        [datetime]$Date = (Get-Date)
    )

    $stamp = '{0:D2}{1:D3}' -f ($Date.Year % 100), $Date.DayOfYear
    "{0}.{1}.{2:D2}" -f $ArchilabVersionMajor, $stamp, ($RevitYear % 100)
}
