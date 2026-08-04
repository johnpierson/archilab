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

Push a tag naming the build number — `v13` — and CI builds all three Revit
versions, stamps each assembly, and attaches one Dynamo package zip per
version to a GitHub release. Uploading those zips to the Dynamo Package
Manager is still done by hand; it has no publish API.

### Version scheme

    <LineMajor>.<LineMinor>.<Build><YY>

    2027.400.1325   2027 line, Dynamo 4.0, build 13, for Revit '25
    2027.400.1326                                    for Revit '26
    2027.400.1327                                    for Revit '27

`LineMajor`/`LineMinor` are the current release line — the newest supported
Revit year and its DynamoCore version — and are shared by every package in a
round. They live in `scripts/version.ps1` and are bumped when support for a
newer Revit is added.

The trailing two digits are the Revit version a given package targets. Every
Revit version publishes under the one `archi-lab.net` package name, and the
Package Manager rejects a version that moves backwards, so the target Revit
year cannot be the major: publishing `2027.x` and later shipping a `2025.x`
fix would be refused. Encoding it in the last two digits instead keeps a round
ascending as it publishes 2025 → 2026 → 2027, and the next round's higher
build number clears the whole previous round.

# Support

<p align="center">
  <img width="600" src="https://i2.wp.com/archi-lab.net/wp-content/uploads/2019/04/patreon_archilab.jpg">
</p>

This repo and the package is maintained and supported by Konrad K Sobon. Konrad has a lot of things to look after, so if you like what you see here, like to keep the archi-lab.net package maintained and getting better, please consider supporting Konrad on Patreon: https://www.patreon.com/archilab 
