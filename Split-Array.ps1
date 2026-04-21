function Split-Array {
<#
.SYNOPSIS
    Splits an array into evenly distributed sub-arrays (chunks).

.DESCRIPTION
    Split-Array accepts an array — either as a direct argument or from the pipeline —
    and returns a list of sub-arrays.

    Two modes are available:

      -ChunkSize  Specifies the maximum number of elements per chunk.
                  The last chunk may be smaller if the total count does not divide evenly.

      -MaxChunk   Specifies the desired number of chunks.
                  Elements are distributed as evenly as possible; any remainder
                  is spread across the first chunks (one extra element each).

.PARAMETER InputObject
    The array or individual elements to split.
    Accepts pipeline input.

.PARAMETER ChunkSize
    Maximum number of elements per chunk (ParameterSet: BySize).
    Must be greater than 0.
    If ChunkSize >= element count, a single chunk containing all elements is returned.

.PARAMETER MaxChunk
    Desired number of output chunks (ParameterSet: ByMaxChunk).
    Must be greater than 0.
    If MaxChunk = 1, a single chunk is always returned.
    If element count <= MaxChunk, each element is returned in its own chunk.

.INPUTS
    System.Object
    Individual elements or arrays can be passed via the pipeline.

.OUTPUTS
    System.Object[][]
    An array of arrays. Each element of the outer array is one chunk.

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3

    Returns four chunks: (1,2,3), (4,5,6), (7,8,9), (10).

.EXAMPLE
    1..10 | Split-Array -ChunkSize 4

    Pipeline variant. Returns three chunks: (1,2,3,4), (5,6,7,8), (9,10).

.EXAMPLE
    Split-Array -InputObject 1..10 -MaxChunk 3

    Returns three evenly distributed chunks: (1,2,3,4), (5,6,7), (8,9,10).

.EXAMPLE
    $chunks = Split-Array -InputObject 1..7 -MaxChunk 3
    $chunks | ForEach-Object { $_ -join ',' }

    Processes each chunk individually. Output: "1,2,3" / "4,5" / "6,7"

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3 -Verbose

    Runs with verbose output. Shows the active mode, input count, number of chunks
    created, and the size of each chunk:

      VERBOSE: Input count: 10
      VERBOSE: Mode: ChunkSize
      VERBOSE: ChunkSize: 3
      VERBOSE: Chunks created: 4
      VERBOSE: Chunk sizes: 3, 3, 3, 1

.EXAMPLE
    1..7 | Split-Array -MaxChunk 3 -Verbose

    Verbose output for MaxChunk mode. Shows the base size and how the remainder
    is distributed across the first chunks:

      VERBOSE: Input count: 7
      VERBOSE: Mode: MaxChunk
      VERBOSE: MaxChunk: 3
      VERBOSE: Base size: 2
      VERBOSE: Remainder: 1
      VERBOSE: Chunks created: 3
      VERBOSE: Chunk sizes: 3, 2, 2

.NOTES
    The function always returns an array of arrays, even when the result contains
    only a single chunk. This ensures a consistent return type that can always
    be iterated without type-checking the output.

    Use -Verbose to trace the splitting logic: input count, active mode, chunk
    distribution, and final chunk sizes are all reported.
#>
    [CmdletBinding(DefaultParameterSetName = 'BySize')]
    param(
        # Allow pipeline input
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [object]$InputObject,

        # Mode 1: ChunkSize
        [Parameter(ParameterSetName = 'BySize')]
        [int]$ChunkSize,

        # Mode 2: MaxChunk
        [Parameter(ParameterSetName = 'ByMaxChunk')]
        [int]$MaxChunk
    )

    begin {
        # Buffer for pipeline input
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($null -ne $InputObject) {
            if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
                foreach ($item in $InputObject) { $buffer.Add($item) }
            } else {
                $buffer.Add($InputObject)
            }
        }
    }

    end {

        $Array = $buffer.ToArray()
        $Count = $Array.Count

        Write-Verbose "Input count: $Count"

        if ($Count -eq 0) {
            Write-Verbose "Input empty — returning empty array."
            $chunks = @(,@())
            return ,$chunks
        }

        #
        # MODE: ChunkSize
        #
        if ($PSCmdlet.ParameterSetName -eq 'BySize') {

            Write-Verbose "Mode: ChunkSize"
            Write-Verbose "ChunkSize: $ChunkSize"

            if ($ChunkSize -le 0) { throw "ChunkSize must be greater than zero." }

            # If ChunkSize >= Count, return one chunk
            if ($ChunkSize -ge $Count) {
                Write-Verbose "ChunkSize >= count, returning a single chunk."
                Write-Verbose "Chunk sizes: $Count"
                $chunks = @(,$Array)
                return ,$chunks
            }

            # Normal splitting
            $chunks = @()

            for ($i = 0; $i -lt $Count; $i += $ChunkSize) {
                $end = [Math]::Min($i + $ChunkSize - 1, $Count - 1)
                $chunk = $Array[$i..$end]
                $chunks += ,$chunk
            }

            Write-Verbose "Chunks created: $($chunks.Count)"
            Write-Verbose "Chunk sizes: $(( $chunks | ForEach-Object { $_.Count }) -join ', ')"

            return ,$chunks
        }

        #
        # MODE: MaxChunk
        #
        if ($PSCmdlet.ParameterSetName -eq 'ByMaxChunk') {

            Write-Verbose "Mode: MaxChunk"
            Write-Verbose "MaxChunk: $MaxChunk"

            if ($MaxChunk -le 0) { throw "MaxChunk must be greater than zero." }

            # MaxChunk = 1 → ALWAYS return a single chunk
            if ($MaxChunk -eq 1) {
                Write-Verbose "MaxChunk = 1 → Returning a single chunk."
                Write-Verbose "Chunk sizes: $Count"
                $chunks = @(,$Array)
                return ,$chunks
            }

            # If array smaller than MaxChunk → return single-item chunks
            if ($Count -le $MaxChunk) {
                Write-Verbose "Count <= MaxChunk → Returning $Count single-item chunks."
                $chunks = @()
                foreach ($item in $Array) { $chunks += ,@($item) }
                return ,$chunks
            }

            # Even distribution with remainder
            $BaseSize  = [Math]::Floor($Count / $MaxChunk)
            $Remainder = $Count % $MaxChunk

            Write-Verbose "Base size: $BaseSize"
            Write-Verbose "Remainder: $Remainder"

            $chunks = @()
            $index = 0

            for ($i = 1; $i -le $MaxChunk; $i++) {

                $size = $BaseSize
                if ($Remainder -gt 0) {
                    $size++
                    $Remainder--
                }

                $chunk = $Array[$index..($index + $size - 1)]
                $index += $size

                $chunks += ,$chunk
            }

            Write-Verbose "Chunks created: $MaxChunk"
            Write-Verbose "Chunk sizes: $(( $chunks | ForEach-Object { $_.Count }) -join ', ')"

            return ,$chunks
        }
    }
}
