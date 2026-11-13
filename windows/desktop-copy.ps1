function Copy-LabToDesktop {
    param(
        [Parameter(Mandatory = $true)][string]$SourceRoot,
        [Parameter(Mandatory = $true)][string]$Desktop
    )

    $source = (Resolve-Path -LiteralPath $SourceRoot -ErrorAction Stop).ProviderPath
    if (-not (Test-Path -LiteralPath (Join-Path $source 'run.sh') -PathType Leaf)) {
        throw 'The source folder does not contain run.sh. Extract the complete repository first.'
    }
    if ([string]::IsNullOrWhiteSpace($Desktop)) {
        throw 'Windows did not return a Desktop folder.'
    }
    New-Item -ItemType Directory -Path $Desktop -Force -ErrorAction Stop | Out-Null
    $desktopPath = (Resolve-Path -LiteralPath $Desktop).ProviderPath

    # Reuse a project that is already directly on the Desktop.
    if ($source -ieq $desktopPath -or (Split-Path -Parent $source) -ieq $desktopPath) {
        return $source
    }

    $destination = Join-Path $desktopPath 'gta-vi-apk'
    if (Test-Path -LiteralPath $destination) {
        # Keep existing Desktop copies and any student edits intact.
        $suffix = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 6)
        $destination = Join-Path $desktopPath ('gta-vi-apk-' + $suffix)
    }
    New-Item -ItemType Directory -Path $destination -ErrorAction Stop | Out-Null
    Get-ChildItem -LiteralPath $source -Force -ErrorAction Stop |
        Where-Object { $_.Name -notin @('.git', 'build', 'addressbook.txt', '.DS_Store') } |
        ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse -Force -ErrorAction Stop
        }
    return $destination
}
