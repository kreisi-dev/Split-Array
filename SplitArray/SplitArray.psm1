# Dot-source every function file under Public/ and Private/, then export only the
# public functions. Adding a new .ps1 to either folder is all it takes to extend the module.

$Public  = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1"  -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue)

foreach ($file in @($Public + $Private)) {
    try {
        . $file.FullName
    } catch {
        Write-Error "Failed to import function $($file.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
