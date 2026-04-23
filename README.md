# Split-Array

A PowerShell function that splits an array into sub-arrays (chunks) with configurable distribution.

## Installation

Dot-source the script in your session or profile:

```powershell
. ./Split-Array.ps1
```

## Usage

### Split by chunk size (`-ChunkSize`)

Specifies the maximum number of elements per chunk. Default distribution: **Greedy**.

```powershell
Split-Array -InputObject 1..10 -ChunkSize 3
# Greedy (default): (1,2,3), (4,5,6), (7,8,9), (10)

Split-Array -InputObject 1..10 -ChunkSize 3 -Distribution Even
# Even: (1,2,3), (4,5,6), (7,8), (9,10)
```

### Split into N chunks (`-MaxChunk`)

Specifies the desired number of chunks. Default distribution: **Even**.

```powershell
Split-Array -InputObject 1..10 -MaxChunk 4
# Even (default): (1,2,3), (4,5,6), (7,8), (9,10)

Split-Array -InputObject 1..10 -MaxChunk 4 -Distribution Greedy
# Greedy: (1,2,3), (4,5,6), (7,8,9), (10)
```

### Distribution strategies

| Strategy | Behavior | Default for |
|---|---|---|
| `Greedy` | Fill each chunk to maximum; last chunk absorbs the remainder | `-ChunkSize` |
| `Even` | Spread the remainder one element at a time across the first chunks | `-MaxChunk` |

With the same input `1..10` and 4 chunks:

| Strategy | Chunks | Sizes |
|---|---|---|
| `Greedy` | `(1,2,3)`, `(4,5,6)`, `(7,8,9)`, `(10)` | 3, 3, 3, 1 |
| `Even` | `(1,2,3)`, `(4,5,6)`, `(7,8)`, `(9,10)` | 3, 3, 2, 2 |

Both strategies produce identical results when the element count divides evenly.

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
| `Distribution` | `String` | `Greedy` or `Even`. Controls how the remainder is placed. |

`-ChunkSize` and `-MaxChunk` are mutually exclusive.

## Edge Cases

| Scenario | Behavior |
|---|---|
| `ChunkSize >= Count` | Returns one chunk containing all elements |
| `MaxChunk = 1` | Returns one chunk containing all elements |
| `Count <= MaxChunk` | Returns one chunk per element |
| Empty input | Returns one empty chunk |

## Verbose Output

Add `-Verbose` to any call to trace the splitting logic.

```powershell
Split-Array -InputObject 1..10 -MaxChunk 4 -Verbose
```
```
VERBOSE: Input count: 10
VERBOSE: Mode: MaxChunk
VERBOSE: MaxChunk: 4
VERBOSE: Distribution: Even
VERBOSE: Base size: 2
VERBOSE: Remainder: 2
VERBOSE: Chunks created: 4
VERBOSE: Chunk sizes: 3, 3, 2, 2
```

```powershell
Split-Array -InputObject 1..10 -MaxChunk 4 -Distribution Greedy -Verbose
```
```
VERBOSE: Input count: 10
VERBOSE: Mode: MaxChunk
VERBOSE: MaxChunk: 4
VERBOSE: Distribution: Greedy
VERBOSE: Base size: 3
VERBOSE: Chunks created: 4
VERBOSE: Chunk sizes: 3, 3, 3, 1
```

## Tests

Tests are written with [Pester](https://pester.dev) v5.

```powershell
Invoke-Pester ./Split-Array.Tests.ps1
```

## License

[MIT](LICENSE)
