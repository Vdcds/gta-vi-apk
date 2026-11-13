param([string]$Distribution = 'Ubuntu')

$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot 'desktop-copy.ps1')
    $source = Split-Path -Parent $PSScriptRoot
    $desktop = [Environment]::GetFolderPath('Desktop')
    $project = Copy-LabToDesktop -SourceRoot $source -Desktop $desktop
    Write-Host "Desktop project: $project"

    $code = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($code) {
        $codePath = $code.Source
    } else {
        $candidates = @(
            (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe'),
            (Join-Path $env:ProgramFiles 'Microsoft VS Code\Code.exe')
        )
        $codePath = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    }
    if (-not $codePath) {
        throw "Install VS Code on Windows with Add to PATH enabled, then retry. Read $project\cheats\00-WINDOWS-START.txt"
    }
    & $codePath --new-window $project (Join-Path $project 'cheats\00-WINDOWS-START.txt')
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw 'VS Code could not open the Desktop copy.'
    }

    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        throw "WSL is missing. Read $project\cheats\00-WINDOWS-START.txt for setup commands."
    }
    # Pass the Desktop path as an argument, never as shell command text.
    # wslpath also handles spaces and OneDrive Desktop paths.
    $linuxPath = & wsl.exe --distribution $Distribution --exec wslpath -a -u $project
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot start WSL distribution '$Distribution'. Read cheats\00-WINDOWS-START.txt, or run WINDOWS-START.cmd -Distribution YourDistroName."
    }
    $linuxPath = ([string]$linuxPath).Trim()
    Write-Host "Opening the run menu in WSL $Distribution..."
    & wsl.exe --distribution $Distribution --cd $linuxPath --exec bash windows/menu.sh
    exit $LASTEXITCODE
} catch {
    Write-Host "`n$($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
