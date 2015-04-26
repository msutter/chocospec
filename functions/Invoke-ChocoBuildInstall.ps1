function Invoke-ChocoBuildInstall {
<#
.SYNOPSIS

.DESCRIPTION
Script commands to "install" the program.
The commands should copy the files from the BUILD directory %{_builddir} into the buildroot directory, %{buildroot}.
See the %install section below for more.

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $false)]
    [switch] $D
  )

  if (!$D) {
    $null = Remove-Item -Force -Recurse $PackageBuildRootFilesPath
  }

  # Deploy the content to root path
  $null = New-Item -Force -ItemType Directory $PackageBuildRootFilesPath
  $null = Copy-Item -Force -Recurse "${PackageBuildPath}\*" "${PackageBuildRootFilesPath}"


}


