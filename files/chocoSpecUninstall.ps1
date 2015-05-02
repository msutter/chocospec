#------- UNINSTALLATION -------#
try {

  # Set the location of the package on disk
  $PackagePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

  # Import chocolateyPkgHelpers Module
  Import-Module -Name chocoHelpers

  # Load Package variables (datas)
  $ChocoData = Import-ChocoHelpersVariables -PackagePath "${PackagePath}"
  foreach ($Var in $ChocoData.Keys) {
      Write-Verbose "Importing variable $($ChocoData.$Var) in the local scope"

      # Pathes with spaces workaround
      if ($ChocoData.$Var -is [system.string]) {
          New-Variable -Name $Var -Value "$($ChocoData.$Var)"
      } else {
          New-Variable -Name $Var -Value $ChocoData.$Var
      }
  }

  #------- BEFORE UNINSTALL SCRIPT ---------#
  $BeforeUninstallPath = "${ToolsPath}\chocolateyBeforeUninstall.ps1"
  if (Test-Path -Path "${BeforeUninstallPath}") {
    Write-Verbose "Executing ${BeforeUninstallPath}"
    & "${BeforeUninstallPath}"
  } else {
    # Default uninstall of exe, msi, etc...
    Uninstall-ChocoPkgUninstallers
  }

  #------- UNINSTALLATION SETUP ---------#
  Uninstall-ChocoPkgFiles

  #------- AFTER UNINSTALL SCRIPT ---------#
  $AfterUninstallPath = "${ToolsPath}\chocolateyAfterUninstall.ps1"
  if (Test-Path -Path "${AfterUninstallPath}") {
    Write-Verbose "Executing ${AfterUninstallPath}"
    & "${AfterUninstallPath}"
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $PackageId
} catch {
  Write-ChocolateyFailure $PackageId $($_.Exception.Message)
  throw
}
