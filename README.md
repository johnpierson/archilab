# archilab

[![Build](https://github.com/ksobon/archilab/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/ksobon/archilab/actions/workflows/build.yml)

This is the official Repository for archi-lab.net Dynamo Package.

## Supported versions

| Revit | DynamoRevit | DynamoCore | Target framework |
|-------|-------------|------------|------------------|
| 2027  | 27.0        | 4.0        | net10.0-windows  |
| 2026  | 3.6         | 3.6        | net8.0-windows   |
| 2025  | 3.2         | 3.2        | net8.0-windows   |

The two Dynamo columns differ from Revit 2027 onward, where DynamoRevit
switched to year-based versioning. DynamoRevit is the one that matters for
deployment: it names the `%AppData%\Dynamo\Dynamo Revit\<version>\packages`
folder. DynamoCore is what the `DynamoVisualProgramming.*` packages track and
what `pkg.json`'s `engine_version` refers to.

Revit 2024 and earlier are no longer supported. The last release supporting
them is on the commit history prior to this change.

## Building

Requires the [.NET 10 SDK](https://dotnet.microsoft.com/download) (it builds
the net8.0 targets too) and Visual Studio 2022 or later for the IDE.

```bash
dotnet build archilabUI2027/archilabUI2027.csproj -c Release
```

Each version's UI project references its core project, so building the UI
project builds both. Build `archilab.sln` from Visual Studio to build every
Revit version at once — note that `dotnet build` does not reliably handle the
shared projects (`.shproj`) the solution contains, so command-line builds
should target an individual project.

A successful local build deploys straight into
`%AppData%\Dynamo\Dynamo Revit\<dynamo-version>\packages\archi-lab.net`, so
the package is immediately available the next time Dynamo starts. Set
`CI=true` to skip that step.

### Project layout

Shared source lives in two shared projects and is compiled into every Revit
version:

- `archilabSharedProject` — zero-touch nodes (`archilab<year>.dll`)
- `archilabUISharedProject` — NodeModel/UI nodes (`archilabUI<year>.dll`)

Where the Revit API differs between versions, code is guarded with cumulative
symbols such as `REVIT2026_OR_GREATER`, which each version project defines for
every release it satisfies. Adding a new Revit version means copying a project
pair and defining its symbols — existing guarded code does not need to change
unless that version introduces a new API break.

## Releasing

Push a tag and CI builds all three Revit versions, stamps each assembly, and
attaches one Dynamo package zip per version to a GitHub release. Uploading
those zips to the Dynamo Package Manager is still done by hand; it has no
publish API.

### Version scheme

    <major>.<YYDDD>.<YY>        frozen major . build date . target Revit

    2027.26216.25   built 2026 day 216 (Aug 4), for Revit 2025
    2027.26216.26                                for Revit 2026
    2027.26216.27                                for Revit 2027

Nothing has to be hand-incremented: the middle segment is the build date, so
ordering falls out of the calendar, and the trailing Revit year keeps a single
day's three packages distinct and ascending.

The major is frozen at 2027 on purpose. All three Revit versions publish under
the one `archi-lab.net` package name, and the Package Manager rejects a
version that moves backwards — so if the major were the target Revit year,
shipping a Revit 2025 fix after a 2027 release would be refused. A constant
major removes that problem entirely; it only has to stay at or above the last
published major.

The date is `YYDDD` rather than `YYMMDD` because this same string is the
assembly version, whose components are 16-bit: `26216` fits, `260804` does
not. It stays monotonic and unambiguous through 2065.

Two releases on the same day would collide. Pass an explicit date to
`package.ps1 -Date`, or use the release workflow's date input, to stamp a
different day.

### How one package serves three Revit versions

All three publish under the single `archi-lab.net` name. Each published
version carries its own `engine_version` — the minimum Dynamo it requires —
and Dynamo offers a user the newest version their engine satisfies:

| Version | engine_version | Offered to |
|---------|----------------|------------|
| `2027.26216.25` | 3.2.1.5366 | Revit 2025 and newer |
| `2027.26216.26` | 3.6.1.9895 | Revit 2026 and newer |
| `2027.26216.27` | 4.0.2.3852 | Revit 2027 |

A Revit 2025 user is only compatible with the first, so that is what they get.
A Revit 2027 user is compatible with all three and takes the newest. This
works because the trailing Revit year rises in step with the engine
requirement, so "newest compatible" and "right build for my Revit" are always
the same version. Publish a round in 2025 → 2026 → 2027 order.

Note that `engine_version` is the exact Dynamo the package was built against,
so a Revit version whose Dynamo predates it will not be offered the update —
worth checking against the oldest Dynamo servicing each Revit release if wider
reach matters more than binding to the newest API.

# Support

<p align="center">
  <img width="600" src="https://i2.wp.com/archi-lab.net/wp-content/uploads/2019/04/patreon_archilab.jpg">
</p>

This repo and the package is maintained and supported by Konrad K Sobon. Konrad has a lot of things to look after, so if you like what you see here, like to keep the archi-lab.net package maintained and getting better, please consider supporting Konrad on Patreon: https://www.patreon.com/archilab 
