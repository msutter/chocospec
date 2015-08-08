function New-ChocoBuildScript {
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true)]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$PackageScriptsPath,

    [Parameter(Mandatory = $false)]
    [string]$Content
  )

  # CamelCase the Type
  $TextInfo      = (Get-Culture).TextInfo
  $CamelCaseType = $TextInfo.ToTitleCase($Type.ToLower())

  # Get the default scripts path
  $MyModulePath       = Split-Path -Parent $PSScriptRoot
  $DefaultScriptsPath = "${MyModulePath}/files/defaults"

  # Generate filename and path
  $ScriptFileName        = "chocoBuild${CamelCaseType}.ps1"
  $DefaultScriptFilePath = Join-Path $DefaultScriptsPath $ScriptFileName
  $ScriptFilePath        = Join-Path $PackageScriptsPath $ScriptFileName

  if ($Content) {
    "$($Content)" | Out-File -filepath $ScriptFilePath
  } else {
    #$null = Copy-Item $DefaultScriptFilePath $ScriptFilePath
    $null = Robocopy "${DefaultScriptsPath}" "${PackageScriptsPath}" $ScriptFileName
  }

  Return $ScriptFilePath

}