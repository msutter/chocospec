function Invoke-HashInterpolation {
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    # Specifies the location of the generated nupkg file
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
    [hashtable]$Hash,

    # Specifies the location of the generated nupkg file
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true )]
    [array]$ExcludeKeys = @(),

    # Specifies the location of the generated nupkg file
    [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true )]
    [array]$ExcludeVars = @('args')

  )

  Process {

    $Result = @{}

    # Add variables to local scope
    foreach ($Key in $Hash.Keys) {
      if (!$ExcludeVars.Contains($key)) {
        New-Variable -Name $Key -Value $Hash.$Key
      }
    }

    # Force Interpolation of yaml values form local scope
    foreach ($Key in $Hash.Keys ) {
      if (!$ExcludeKeys.Contains($key)) {
        if ($Hash.$Key -is [string]) {
          Write-Verbose "${Key} is a string"
          $Result.Add($Key, $ExecutionContext.InvokeCommand.ExpandString($Hash.$Key))
        }

        if ($Hash.$Key -is [array]) {
          Write-Verbose "${Key} is an array"
          $Result.Add($Key, (Invoke-ArrayInterpolation $Hash.$Key))
        }

        if ($Hash.$Key -is [hashtable]) {
          Write-Verbose "${Key} is an hashtable"
          $Result.Add($Key, (Invoke-HashInterpolation $Hash.$Key))
        }
      }
    }

    Return $Result
  }

}

function Invoke-ArrayInterpolation {
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    # Specifies the location of the generated nupkg file
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
    [array]$Array
  )

  Process {

    $Result = @()

    # Force Interpolation of yaml values form local scope
    foreach ($Item in $Array ) {

        if ($Item -is [string]) {
          Write-Verbose "${Item} is a string"
          $Result += $ExecutionContext.InvokeCommand.ExpandString($Item)
        }

        if ($Item -is [array]) {
          Write-Verbose "${Item} is an array"
          $Result += Invoke-ArrayInterpolation $Item
        }

        if ($Item -is [hashtable]) {
          Write-Verbose "${Item} is an hashtable"
          $Result += Invoke-HashInterpolation $Item
        }

    }

    Return $Result
  }

}
