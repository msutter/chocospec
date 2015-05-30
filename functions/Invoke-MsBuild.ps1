function Invoke-MsBuild
{
    param
    (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $SourceCodePath = (Get-Location),

        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $SolutionFile,

        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Configuration = "Debug",

        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Boolean] $AutoLaunchBuildLog = $false,

        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Switch] $MsBuildHelp,

        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Switch] $CleanFirst,

        [ValidateNotNullOrEmpty()]
        [string] $BuildLogFile,

        [ValidateNotNullOrEmpty()]
        [string] $BuildLogOutputPath = (Get-Location)
    )

    process
    {
        # Local Variables
        $MsBuild = "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe";
    }

}