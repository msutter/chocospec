function Start-64bitSession {
    <#
    .SYNOPSIS

    Starts a 64 bit Powershell Session

    .DESCRIPTION

    Starts a 64 bit Powershell Session

    #>
    [CmdletBinding()]
    Param
    (

    )

    if ($pshome -like "*syswow64*") {

      write-warning "Restarting script under 64 bit powershell"

      # relaunch this script under 64 bit shell
      # if you want powershell 2.0, add -version 2 *before* -file parameter
      & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
        (join-path $psscriptroot $myinvocation.mycommand) @args

      # exit 32 bit script
      exit
    }

}