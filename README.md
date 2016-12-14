# ChocoBuild

Every chocolatey package needs some metadata so it can specify, under other things, its
dependencies. Chocolatey packages usually uses the nuspec format, used by a developer-centric
package manager called NuGet. A .nuspec file is a manifest that uses XML to describe how to
build the package. For information about the nuspec format, see [Nuspec Reference](http://docs.nuget.org/create/nuspec-reference).

Chocolatey is a bootstrapper that uses PowerShell scripts and the NuGet packaging format to
install apps for you. Chocolatey extends the Nuget/Nuspec concept to bring applications down
at the system level by using additional PowerShell scripts.

Chocobuild extends the ability to build a chocolatey package based on a spec file called the chocospec file.
The features are inspired from the RPM spec format.

## Chocospec

At the heart of the chocolatey package building process is the chocospec file. It governs how a package is configured, what files will be installed and where they’ll be installed, and what system-level activity needs to take place before and after a package is installed.

## Chocospec Format

A Chocospec file should be named `<package_name>.chocospec.yaml`. It's written in the [YAML](http://www.yaml.org/) language.

The fields can be ordered in 3 main Groups:
 - Nuspec specific fields
 - Build time specific fields
 - Install time specific fields

## At the top level are a series of Nuspec specific fields.
###The currently supported ones are

### id
Required for every package.
The ID defines what the package will actually be called.
The ID will be included in the package package filename.

### version
Required for every package.
The version line should be set to the version of the software being packaged.
The version will also be included in the package filename.

### description
Required for every package.
It is used to provide a more detailed description of the packaged software than the summary line.

### authors
Required for every package.
A list of authors of the package code.

# owners
Optional.
A list of package creators.

# summary
Optional.
It is used to provide a short description of the packaged software.

# owners
Optional.
A list of the package creators

# language
Optional.
The locale ID for the package, such as en-us.

# projectUrl
Optional.
A URL for the home page of the package.

# iconUrl
Optional.
A URL for the image to use as the icon for the package

# licenseUrl
Optional.
A link to the license that the package is under.

# copyright
Optional.
Copyright details for the package.

# requireLicenseAcceptance
Optional.
A Boolean value that specifies whether the client needs to ensure that the package license (described by licenseUrl)
is accepted before the package is installed.

# tags
Optional.
A list of tags and keywords that describe the package.
This information is used to help make sure users can find the package using searches.

# dependencies
The list of dependencies for the package.
Can be omitted if your package has no dependencies.

## You can then specify build time specific fields. The currently supported ones are:

# sources
Optional.
Can be omitted if your package has no sources.
A list of key/value pairs, commonly called a “hash” or a “dictionary”.

## Example

A simple but complete Chocospec looks something
like the following:

```yaml
title: Git

# Version (3 digits)
version: 1.9.5

authors:
  - Johannes Schindelin
  - msysgit Committers

owners:
  - Johannes Schindelin

projectUrl: http://msysgit.github.io/

requireLicenseAcceptance: false

summary: Git (for Windows) - Fast Version Control

description: |
  Git (for Windows) - Git is a powerful distributed Source Code Management tool.
  If you just want to use Git to do your version control in Windows,
  you will need to download Git for Windows, run the installer, and you are ready to start.
  Note: Git for Windows is a project run by volunteers, so if you want it to improve, volunteer!

tags:
  - sc-git_all
  - git
  - vcs
  - dvcs
  - version
  - control
  - msysgit
  - admin

sources:
  - type: file
    url: https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20150319/Git-1.9.5-preview20150319.exe

installers:
  - file: 'Git-1.9.5-preview20150319.exe'
    args:
      - '/VERYSILENT'
      - '/NORESTART'
      - '/NOCANCEL'
      - '/SP-'
      - '/CLOSEAPPLICATIONS'
      - '/RESTARTAPPLICATIONS'
      - '/NOICONS'
      - '/COMPONENTS="assoc,assoc_sh"'
      - '/LOG'

uninstallers:
  - file: 'C:\Program Files (x86)\Git\unins000.exe'
    args:
      - '/VERYSILENT'
      - 'REMOVE=ALL'
      - '/qn'
      - '/norestart'
```

## Name

Every package needs a name.  It's how other packages will refer to yours,
and how it will appear to the world, should you publish it.

Try to pick a name that is clear, terse, and not already in use.
A quick search of packages on [chocolatey.org](https://chocolatey.org/packages)
to make sure that nothing else is using your name is recommended.

## Version

Every package has a version. A version number is required.

Versioning is necessary for reusing code while letting it evolve quickly. A
version number is three numbers separated by dots, like `0.1.32`. It can also
optionally have a build (`.20150319`).

Each time you publish your package, you will publish it at a specific version.
Once that's been done, consider it hermetically sealed: you can't touch it
anymore. To make more changes, you'll need a new version.

When you select a version, follow [semantic versioning](http://semver.org/spec/v2.0.0-rc.1.html).

[semantic versioning]: http://semver.org/spec/v2.0.0-rc.1.html

## Description

Every package has a description. This should be relatively short and
should tell users what they might want to know about your package.

Think of the description as the sales pitch for your package. Users will see it
when they [browse for packages](https://chocolatey.org/packages).
It should be simple plain text: no markdown or HTML.

## Authors

You're encouraged to use these fields to describe the author(s) of your package
and provide contact information. `authors` should be used with a YAML list.

```yaml
authors:
  - Johannes Schindelin
  - msysgit Committers
```

## ProjectUrl

Some packages may have a site that hosts documentation separate from the main
homepage. If your package has that, you can also add a `ProjectUrl:` field
with that URL. If provided, a link to it will be shown on your package's page.

## Dependencies

In this section you list each package that your package needs in order to work.

A package can indicate which versions of its dependencies it supports, but there
is also another implicit dependency all packages have: the the chocolateyHelpers.
Since the this powershell library evolves over time, a package may only work with certain
versions of it.

# PowerShell Variables

The following is a list of most of the accessible variables which can be
used in an embeded powershell script.

## Path Variables
**ScriptsPath**

**SpecsPath**

**SourcesPath**

**BuildPath**

**BuildRootPath**

**NupkgsPath**

**PartsPath**

**PackageScriptsPath**

**PackageBuildPath**

**PackageBuildRootPath**

**PackageBuildRootToolsPath**

**PackageBuildRootFilesPath**

**PackagePartsPath**
