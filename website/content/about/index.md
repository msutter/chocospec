+++
title = "About Chocospec"
weight = 1
icon = "<b>1. </b>"
+++

Chocospec extends the ability to build a chocolatey package based on a spec file called the chocospec file. The features are inspired from the RPM spec format.

## Overview

Chocolatey is a bootstrapper that uses PowerShell scripts and the NuGet packaging format to install apps for you. Chocolatey extends the Nuget/Nuspec concept to bring applications down at the system level by using additional PowerShell scripts.

Every chocolatey package needs some metadata so it can specify, under other things, its dependencies. Chocolatey packages usually uses the nuspec format, used by a developer-centric package manager called NuGet. A .nuspec file is a manifest that uses XML to describe how to build the package. For information about the nuspec format, see [Nuspec Reference](http://docs.nuget.org/create/nuspec-reference).

At the heart of the chocolatey package building process is the chocospec file. It governs how a package is configured, what files will be installed, where they’ll be installed, and what system-level activity needs to take place before and after a package is installed.

## Features

  * On common yaml file to define the package
  * Splitting packages in multiple parts to avoid upload size limits
  * Hooks to execute powershell scripts before and after the installation
