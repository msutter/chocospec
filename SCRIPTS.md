# Script

The powershell scripts used to control the build process are among the most varied and interesting parts of the chocospec file.
Chocospec files also contain scripts that perform a variety of tasks whenever the package is installed or erased.

The start of each script is denoted by a keyword. For example, the `build` keyword marks the start of the script executed when building the software to be packaged. the contents of each script section are copied into a file and executed as a script. Anything that can be done in a powershell script can be done by chocospec.

Let's start by looking at the scripts used during the build process.

## Build-time Scripts

The scripts that Chocospec uses during the building of a package follow the steps known to every software developer:

* Unpacking the sources.
* Building the software.
* Installing the software.
* Cleaning up.

Although each of the scripts perform a specific function in the build process, they share a common environment.
For detailed information about the environment varaibles, see VARIABLES.md.

All of these environment variables are set for your use, to make it easier to write scripts that will do the right thing even if the build environment changes.

Let's look at the scripts in the order they are executed.

### The `prep` Script

The `prep` script is the first script executed during a build. Just prior to passing control over to the `prep` script's contents, chocobuild changes directory into chocobuild's sources area, which, is accessible with the `$SourcesPath` variable.

At that point, it is the responsibility of the `prep` script to:

* Create the top-level build directory.
* Unpack the original sources into the build directory.
* Perform any other actions required to get the sources in a ready-to-build state.

The two first items on this list are common to the vast majority of all software being packaged. Because of this, chocobuild has a `Invoke-AutoPrep` function that greatly simplify these routine functions.

The last item on the list can include creating directories or anything else required to get the sources in a ready-to-build state. As a result, a `prep` script can range from one line invoking a single `Invoke-AutoPrep` function, to many lines of tricky powershell programming.

If the prep key is not specified in the chocospec file, a default `prep` script will still be run.
It's default is to invoke the `Invoke-AutoPrep` function.

CAUTION: if you write your own `prep` script, the `Invoke-AutoPrep` function will NOT be executed. You'll have to include this function in your `prep` script.

Example chocospec entry:
```yaml
  prep: |
    Write-Verbose 'I am a useless custom prep script'
    Write-Verbose 'because this function call is the default'
    Invoke-AutoPrep
```

This example is would override the default action of the prep script, with exactly the same action as default.
In other word, it's a total useless example, just here to show the syntax.

### The `build` Script

The `build` script picks up where the `prep` script left off. Once the `prep` script has gotten everything ready for the build, the `build` script is usually invoking msbuild, maybe a configuration script, and little else.

Like `prep` before it, the `build` script has the same assortment of environment variables to draw on. Also, like `prep`, `build` changes directory into the software's top-level build directory usually called <name>-<version>.

Unlike `prep`, there are no functions available for use in the `build` script. The reason is simple: Either the commands required to build the software are simple (such as a single msbuild command), or they are so unique that a macro wouldn't make it easier to write the script.

If the `build` key is not specified in the chocospec file, no default `build` script will be run.

Example build entry:
```yaml
  build: |
    # Nuget dependencies
    $NugetCommand = 'C:\nuget.exe'
    $NugetArgs = 'restore'
    $NugetProcess = Invoke-Exec $NugetCommand $NugetArgs
    Write-Verbose "$($NugetProcess.stdout)"

    # MsBuild
    $MsBuildCommand = 'C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe'
    $MsBuildArgs = 'MyApp.csproj'
    $MsBuildProcess = Invoke-Exec $MsBuildCommand $MsBuildArgs
    Write-Verbose "$($MsBuildProcess.stdout)"

    # Update version release with commit count
    $CommitCount   = Get-CommitCount "${GitRepoPath}"
    $SpecVersion   = $version -as [Version]
    $CustomVersion = '{0}.{1}.{2}.{3}' -f $SpecVersion.Major, $SpecVersion.Minor, $SpecVersion.Build, $CommitCount
    Update-Nuspec -Path $NuspecPath -version $CustomVersion
```

### The `install` Script

The environment in which the `install` script executes is identical to the other scripts. Like the other scripts, the `install` script's working directory is set to the software's top-level directory.

As the name implies, it is this script's responsibility to do whatever is necessary to actually install the newly built software. In most cases, this means a few commands to read the files underneath the build directory `$PackageBuildPath` and writes to the files directory underneath the build root directory `$PackageBuildRootFilesPath`.

The files that are written are the files that are supposed to be installed when the binary package is installed by an end-user.
Beware of the weird terminology: The build root directory is not the same as the build directory.

### The `clean` Script

The `clean` script, as the name implies, is used to clean up the software's build directory tree. Chocobuild normally does this for you, but in certain cases you'll want to include a `clean` script.

As usual, the `clean` script has the same set of environment variables as the other scripts we've covered here. Since a `clean` script is normally used when the package is built in a build root, the `$PackageBuildPath` environment variable is particularly useful. In many cases, a simple

```powershell
Remove-Item -Recurse -Force $PackageBuildPath
```

will clean the build area.

## Install/Uninstall-time Scripts

The other type of scripts that are present in the chocospec file are those that are only executed when the package is either installed or erased.
There are six scripts, each one meant to be executed at different times during the life of a package:

* Before installation (chocolateyBeforeInstall).
* After installation (chocolateyAfterInstall).
* Before uninstallation (chocolateyBeforeUninstall).
* After uninstallation (chocolateyAfterUninstall).

Unlike the build-time scripts, there is little in the way of environment variables for these scripts. The only environment variable available is `$Prefix` which defines the installation prefix for the files to install.

What is normally done during these scripts? The exact tasks may vary, but in general, the tasks are any that need to be performed at these points in the package's existence. One very common task is to manage the prefix location in which the files are installed. But that's not the only use for these scripts. It's even possible to use the scripts to perform tests to ensure the package install/erasure should proceed.

Since each of these scripts will be executing on whatever system installs the package, it's necessary to choose the script's choice of tools carefully. Unless you're sure a given program is going to be available on all the systems that could possibly install your package, you should not use it in these scripts.

### The `chocolateyBeforeInstall` Script

The `chocolateyBeforeInstall` script executes just before the package is to be installed.
Quite often, `chocolateyBeforeInstall` scripts are used to create the prefix location in which the files are installed.

If a package uses a `chocolateyBeforeInstall` script to perform some function, quite often it will include a `chocolateyAfterUninstall` script that performs the inverse of the `chocolateyBeforeInstall` script, after the package removal.

### The `chocolateyAfterInstall` Script

The `chocolateyAfterInstall` script executes after the package has been installed. One of the most popular reasons a `chocolateyAfterInstall` script is needed is to add some binaries to the PATH. Of course, other functions can be performed in a `chocolateyAfterInstall` script. For example, a Registry key or an environment variable could be set.

If a package uses a `chocolateyAfterInstall` script to perform some function, quite often it will include a `chocolateyBeforeUninstall` script that performs the inverse of the `chocolateyAfterInstall` script, before the package removal.

### The `chocolateyBeforeUninstall` Script

If there's a time when your package needs to have one last look around before the user erases it, the place to do it is in the `chocolateyBeforeUninstall` script. Anything that a package needs to do immediately prior to chocolatey taking any action to erase the package, can be done here.

### The `chocolateyAfterUninstall` Script

The `chocolateyAfterUninstall` script executes after the package has been removed. It is the last chance for a package to clean up after itself.
Quite often, `chocolateyAfterUninstall` scripts are used to remove the prefix location.
