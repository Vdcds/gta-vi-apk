$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'windows/desktop-copy.ps1')

function Assert-Lab($Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

# Parse with the same Windows PowerShell engine used by WINDOWS-START.cmd.
Get-ChildItem -LiteralPath $root -Filter '*.ps1' -Recurse | ForEach-Object {
    $parseErrors = $null
    $tokens = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $_.FullName, [ref]$tokens, [ref]$parseErrors
    ) | Out-Null
    Assert-Lab ($parseErrors.Count -eq 0) "PowerShell syntax failed: $($_.FullName): $parseErrors"
}

$work = Join-Path ([IO.Path]::GetTempPath()) ('oslab-copy-' + [guid]::NewGuid().ToString('N'))
try {
    $desktop = Join-Path $work 'OneDrive - College/Desktop'
    $first = Copy-LabToDesktop -SourceRoot $root -Desktop $desktop
    Assert-Lab ($first -eq (Join-Path $desktop 'gta-vi-apk')) 'Wrong initial Desktop destination.'
    foreach ($file in @('run.sh', 'windows/start.ps1', 'windows/menu.sh',
                       '.vscode/tasks.json', 'common/sync.h', 'samples/bankers.in',
                       'cheats/00-WINDOWS-START.txt', 'cheats/08-DISK-SCHEDULING.txt')) {
        Assert-Lab (Test-Path -LiteralPath (Join-Path $first $file)) "Copy is missing $file"
    }
    foreach ($excluded in @('.git', 'build', 'addressbook.txt')) {
        Assert-Lab (-not (Test-Path -LiteralPath (Join-Path $first $excluded))) "Copied $excluded"
    }
    $originals = @(Get-ChildItem -LiteralPath (Join-Path $first 'originals') -File)
    Assert-Lab ($originals.Count -eq 8) 'Copy does not have all eight originals.'
    foreach ($file in $originals) {
        $sourceHash = (Get-FileHash -LiteralPath (Join-Path (Join-Path $root 'originals') $file.Name)).Hash
        Assert-Lab ((Get-FileHash -LiteralPath $file.FullName).Hash -eq $sourceHash) 'Original content changed.'
    }

    $readme = Join-Path $first 'README.md'
    Set-Content -LiteralPath $readme -Value 'My Desktop edits'
    $second = Copy-LabToDesktop -SourceRoot $root -Desktop $desktop
    Assert-Lab ($first -ne $second) 'A repeated copy overwrote the existing project.'
    Assert-Lab ((Get-Content -LiteralPath $readme -Raw).Trim() -eq 'My Desktop edits') 'Desktop edits were lost.'
    Assert-Lab ((Get-FileHash -LiteralPath (Join-Path $second 'README.md')).Hash -eq
                (Get-FileHash -LiteralPath (Join-Path $root 'README.md')).Hash) 'Second copy is incomplete.'
    $reused = Copy-LabToDesktop -SourceRoot $first -Desktop $desktop
    Assert-Lab ($reused -eq $first) 'A project already on the Desktop should be reused.'
    Write-Host 'PASS Desktop copy: spaces, OneDrive-style path, source files, original bytes, repeat copies, and existing edits.'
    Write-Host 'PASS PowerShell syntax. Full VS Code + WSL launch requires a configured Windows desktop.'
} finally {
    if (Test-Path -LiteralPath $work) {
        Remove-Item -LiteralPath $work -Recurse -Force
    }
}
