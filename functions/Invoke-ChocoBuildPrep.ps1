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

  $DefaultPrep = 

}


The "%autosetup" command unpacks a source package. Switches include:

-n name : If the Source tarball unpacks into a directory whose name is not the RPM name,
this switch can be used to specify the correct directory name.
For example, if the tarball unpacks into the directory FOO, use "%autosetup -n FOO".

-c name : If the Source tarball unpacks into multiple directories instead of a single directory,
this switch can be used to create a directory named name and then unpack into it.

