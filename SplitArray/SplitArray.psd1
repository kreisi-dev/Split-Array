@{
    # Script module associated with this manifest.
    RootModule           = 'SplitArray.psm1'

    # Version of this module.
    ModuleVersion        = '1.0.3'

    # Supported PSEditions.
    CompatiblePSEditions = @('Desktop', 'Core')

    # Unique ID for this module.
    GUID                 = 'ce2cea65-0255-43c0-81a0-4b179a30b321'

    # Author of this module.
    Author               = 'Rene Kreisbeck'

    # Copyright statement.
    Copyright            = '(c) Rene Kreisbeck. All rights reserved.'

    # Description of the functionality provided by this module.
    Description          = 'Splits an array into sub-arrays (chunks) with a configurable distribution strategy (Greedy/Even), optional padding, and pipeline support.'

    # Minimum version of the PowerShell engine required.
    PowerShellVersion    = '5.1'

    # Functions exported from this module.
    FunctionsToExport    = @('Split-Array')

    # Cmdlets exported from this module.
    CmdletsToExport      = @()

    # Variables exported from this module.
    VariablesToExport    = @()

    # Aliases exported from this module.
    AliasesToExport      = @()

    # Private data, e.g. for the PowerShell Gallery.
    PrivateData          = @{
        PSData = @{
            Tags         = @('Array', 'Chunk', 'Split', 'Partition', 'Utility', 'Batch')
            LicenseUri   = 'https://github.com/kreisi-dev/Split-Array/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/kreisi-dev/Split-Array'
            ReleaseNotes = @'
1.0.3
- Tooling only: dev dependencies are declared in requirements.psd1 (PSDepend)
  and dev tasks (lint, test) are driven by Invoke-Build, locally and in CI.
- No functional changes.

1.0.2
- Infrastructure only: releases are now driven by version tags (with tests and a
  tag/version check before publishing), CI lints more strictly, and the README
  carries the Gallery version badge.
- No functional changes.

1.0.1
- Documentation only: installation instructions now point to the PowerShell Gallery.
- No functional changes.

1.0.0
- Initial release.
- Split-Array: splits an array into chunks by -ChunkSize (elements per chunk) or -MaxChunk (number of chunks).
- -Distribution parameter (Greedy/Even) controls how the remainder is spread across chunks.
- -Pad parameter fills the last chunk up to full size with a given value.
- Pipeline support.
- Empty input yields one empty chunk (by design).
'@
        }
    }
}
