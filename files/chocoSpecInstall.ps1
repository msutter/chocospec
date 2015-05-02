#------- INSTALLATION -------#
try {

  # Set the location of the package on disk
  $PackagePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

  # Import chocolateyPkgHelpers Module
  Import-Module -force -verbose -Name c:\powershell\chocohelpers\chocohelpers.psm1

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

  #------- EXECUTE BEFORE-INSTALL SCRIPT WHEN PRESENT ---------#
  $BeforeInstallPath = "${ToolsPath}\chocolateyBeforeInstall.ps1"
  if (Test-Path -Path "${BeforeInstallPath}") {
    Write-Verbose "Executing ${BeforeInstallPath}"
    & "${BeforeInstallPath}"
  }

  #------- INSTALLATION SETUP (Only files deployement here ) ---------#
  Install-ChocoPkgFiles

  #------- EXECUTE AFTER-INSTALL SCRIPT ---------#
  $AfterInstallPath = "${ToolsPath}\chocolateyAfterInstall.ps1"
  if (Test-Path -Path "${AfterInstallPath}") {
    Write-Verbose "Executing ${AfterInstallPath}"
    & "${AfterInstallPath}"
  } else {
    # Default install of exe, msi, etc...
    Install-ChocoPkgInstallers
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $PackageId
} catch {
  Write-ChocolateyFailure $PackageId $($_.Exception.Message)
  throw
}
