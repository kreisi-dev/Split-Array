function Add-PadToLastChunk {
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Chunks,

        [Parameter(Mandatory = $false)]
        [object]$PadValue
    )

    $targetSize = $Chunks[0].Count
    $last       = $Chunks[$Chunks.Count - 1]

    Write-Verbose "Pad value: '$PadValue'"

    if ($last.Count -ge $targetSize) {
        Write-Verbose "Last chunk already full — no padding needed."
        return ,$Chunks
    }

    $padded = [object[]]::new($targetSize)
    [Array]::Copy($last, $padded, $last.Count)
    for ($j = $last.Count; $j -lt $targetSize; $j++) { $padded[$j] = $PadValue }

    Write-Verbose "Last chunk padded from $($last.Count) to $targetSize elements."

    # Return a copy instead of mutating the caller's array
    $result = $Chunks.Clone()
    $result[$result.Count - 1] = $padded
    return ,$result
}
