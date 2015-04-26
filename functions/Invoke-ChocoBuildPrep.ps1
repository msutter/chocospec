function Invoke-ChocoBuildPrep {
<#
.SYNOPSIS

.DESCRIPTION
Script commands to "prepare" the program (e.g. to uncompress it) so that it will be ready for building.
Typically this is just "%autosetup"; a common variation is "%autosetup -n NAME" if the source file unpacks into NAME.
See the %prep section below for more.

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true)]
    [string] $MapName
  )


}
