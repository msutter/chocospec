function Invoke-ChocoBuildInstall {
<#
.SYNOPSIS

.DESCRIPTION
Script commands to "install" the program.
The commands should copy the files from the BUILD directory %{_builddir} into the buildroot directory, %{buildroot}.
See the %install section below for more.

.EXAMPLE

#>

  $install = ?
  $PackageBuildPath = ?

  $InstallScriptFileName = 'chocolateyinstall.ps1'
  $InstallScriptFilePath = Join-Path $PackageBuildPath $InstallScriptFileName

  if ($install) {

    Write-Verbose 'Executing install:'
    Write-Verbose "$($install)"
    "$($install)" | Out-File -filepath $InstallScriptFilePath

  } else {

    Write-Verbose 'Executing default install'
    "`$null = Copy-Item -Force -Recurse -Exclude .git `"`${PackageSourcesPath}\*`" `"`${PackageRootPath}`"" | Out-File -filepath $InstallScriptFilePath
    Write-Verbose (Get-Content $InstallScriptFilePath)

  }

  Write-Verbose "InstallScriptFilePath: ${InstallScriptFilePath}"
  $null = & "${InstallScriptFilePath}"



}