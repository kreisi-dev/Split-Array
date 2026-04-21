# Split-Array

A PowerShell function that splits an array into evenly distributed sub-arrays (chunks).

## Installation

Dot-source the script in your session or profile:

```powershell
. ./Split-Array.ps1
```

## Usage

### Split by chunk size (`-ChunkSize`)

Specifies the maximum number of elements per chunk. Each chunk has exactly that
size — except the last one, which may be smaller if the count does not divide evenly.

```powershell
Split-Array -InputObject 1..9 -ChunkSize 3
# Returns: (1,2,3), (4,5,6), (7,8,9)

Split-Array -InputObject 1..10 -ChunkSize 3
# Returns: (1,2,3), (4,5,6), (7,8,9), (10)  ← last chunk smaller
```

### Split into N chunks (`-MaxChunk`)

Specifies the desired number of chunks. Elements are distributed as evenly as possible.

```powershell
Split-Array -InputObject 1..10 -MaxChunk 3
# Returns: (1,2,3,4), (5,6,7), (8,9,10)
```

### Iterating over chunks

```powershell
$chunks = Split-Array -InputObject 1..7 -MaxChunk 3
foreach ($chunk in $chunks) {
    $chunk -join ', '
}
# Output:
# 1, 2, 3
# 4, 5
# 6, 7
```

## Parameters

| Parameter | Type | Description |
|---|---|---|
| `InputObject` | `Object` | Array or elements to split. Accepts pipeline input. |
| `ChunkSize` | `Int` | Maximum number of elements per chunk. |
| `MaxChunk` | `Int` | Desired number of output chunks. |

`-ChunkSize` and `-MaxChunk` are mutually exclusive.

## Edge Cases

| Scenario | Behavior |
|---|---|
| `ChunkSize >= Count` | Returns one chunk containing all elements |
| `MaxChunk = 1` | Returns one chunk containing all elements |
| `Count <= MaxChunk` | Returns one chunk per element |
| Empty input | Returns one empty chunk |

## Verbose Output

Add `-Verbose` to any call to trace the splitting logic — useful for debugging or understanding how elements are distributed.

```powershell
Split-Array -InputObject 1..10 -MaxChunk 4 -Verbose
```
```
VERBOSE: Input count: 10
VERBOSE: Mode: MaxChunk
VERBOSE: MaxChunk: 4
VERBOSE: Base size: 2
VERBOSE: Remainder: 2
VERBOSE: Chunks created: 4
VERBOSE: Chunk sizes: 3, 3, 2, 2
```

```powershell
1..7 | Split-Array -MaxChunk 3 -Verbose
```
```
VERBOSE: Input count: 7
VERBOSE: Mode: MaxChunk
VERBOSE: MaxChunk: 3
VERBOSE: Base size: 2
VERBOSE: Remainder: 1
VERBOSE: Chunks created: 3
VERBOSE: Chunk sizes: 3, 2, 2
```

## Tests

Tests are written with [Pester](https://pester.dev) v5.

```powershell
Invoke-Pester ./Split-Array.Tests.ps1
```

## License

[MIT](LICENSE)
