function Invoke-Exec
{
    [CmdletBinding()]
    param (
      [Parameter(Position=0, Mandatory=1)]
      [string]$Command,
      [Parameter(Position=1, Mandatory=0)]
      [string]$Arguments = ''
    )
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.WorkingDirectory = Get-Location
    $pinfo.FileName = $Command
    $pinfo.Arguments = $Arguments
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $null = $p.Start()
    $null = $p.WaitForExit()

    $result = New-Object psobject -Property @{
      exitcode = $p.ExitCode
      stdout = $p.StandardOutput.ReadToEnd()
      stderr = $p.StandardError.ReadToEnd()
    }

    if ($result.exitcode -ne 0) {
      if (![string]::IsNullOrEmpty($result.stderr)) {
        throw $result.stderr
      } elseif (![string]::IsNullOrEmpty($result.stdout)) {
        throw $result.stdout
      } else {
        throw "Command $Command $Arguments failed with no output !"
      }
    }

    return $result
}