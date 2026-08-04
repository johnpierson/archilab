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

function Get-ArchilabVersion {
    <#
    .SYNOPSIS
        Builds the archi-lab.net package version for a Revit version.

    .DESCRIPTION
        Format: <year>.<day of year>.<target Revit YY>

            2026.216.25  =  built 2026 day 216 (Aug 4), for Revit 2025
            2026.216.26  =  same build, for Revit 2026
            2026.216.27  =  same build, for Revit 2027

        Every segment moves forwards on its own: the calendar year, then the
        day within it, then the Revit year within a single day's round. The
        Dynamo Package Manager refuses a version that moves backwards, and all
        three Revit versions publish under the one archi-lab.net package name,
        so that property is what makes a shared name workable -- and it holds
        without anyone having to remember to increment anything.

        Each component is also a legal assembly version part (16-bit): the year
        is well under 65534, the day of year never exceeds 366.

        The day is not zero-padded, so that the string matches how .NET renders
        the same value as an assembly version (2026.5.26, not 2026.005.26).
    #>
    param(
        [Parameter(Mandatory)][ValidateSet(2025, 2026, 2027)][int]$RevitYear,
        [datetime]$Date = (Get-Date)
    )

    "{0}.{1}.{2:D2}" -f $Date.Year, $Date.DayOfYear, ($RevitYear % 100)
}
