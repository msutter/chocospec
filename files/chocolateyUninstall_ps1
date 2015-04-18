#------- UNINSTALLATION -------#
try {

  # Set the location of the package on disk
  $PackagePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

  # Include chocolateyPkgHelpers Module
  Import-Module -Name chocolateyPkgHelpers

  # Load Package Datas
  $ChocoPkgData = Get-ChocoPkgData -PackagePath $PackagePath

  #------- BEFORE UNINSTALL SCRIPT ---------#
  $BeforeUninstallPath = "$($ChocoPkgData.ToolsPath)\chocolateyBeforeUninstall.ps1"
  if (Test-Path -Path "${BeforeUninstallPath}") {
    Write-Verbose "Executing ${BeforeUninstallPath}"
    & "${BeforeUninstallPath}"
  }

  #------- UNINSTALLATION SETUP ---------#
  Uninstall-ChocoPkgUninstallers $ChocoPkgData
  Uninstall-ChocoPkgFiles $ChocoPkgData

  #------- AFTER UNINSTALL SCRIPT ---------#
  $AfterUninstallPath = "$($ChocoPkgData.ToolsPath)\chocolateyAfterUninstall.ps1"
  if (Test-Path -Path "${AfterUninstallPath}") {
    Write-Verbose "Executing ${AfterUninstallPath}"
    & "${AfterUninstallPath}"
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $ChocoPkgData.PackageId
} catch {
  Write-ChocolateyFailure $ChocoPkgData.PackageId $($_.Exception.Message)
  throw
}
