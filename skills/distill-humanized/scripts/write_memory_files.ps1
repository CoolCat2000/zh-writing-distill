param(
    [string]$Root = ".",
    [switch]$Stdin,
    [string]$ContentFile,
    [string]$Timestamp
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Error "用法：powershell -ExecutionPolicy Bypass -File scripts\write_memory_files.ps1 -Root <目录> (-Stdin | -ContentFile <文件>) [-Timestamp yyyyMMddHHmmss]"
}

if ($Stdin -and $ContentFile) {
    Show-Usage
}

if (-not $Stdin -and -not $ContentFile) {
    Show-Usage
}

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Error "错误：目标目录不存在或不是目录：$Root"
}

if (-not $Timestamp) {
    $Timestamp = Get-Date -Format "yyyyMMddHHmmss"
}

$RootPath = (Resolve-Path -LiteralPath $Root).Path
$AgentsPath = Join-Path $RootPath "AGENTS.md"
$ClaudePath = Join-Path $RootPath "CLAUDE.md"

if ($Stdin) {
    $Content = [Console]::In.ReadToEnd()
} else {
    if (-not (Test-Path -LiteralPath $ContentFile -PathType Leaf)) {
        Write-Error "错误：内容文件不存在：$ContentFile"
    }
    $Content = Get-Content -LiteralPath $ContentFile -Raw -Encoding UTF8
}

$Content = $Content.TrimEnd() + [Environment]::NewLine
if ([string]::IsNullOrWhiteSpace($Content)) {
    Write-Error "错误：AGENTS.md 内容为空，已停止写入。"
}

function Test-PathOrLink {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        return $true
    }

    $Item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return $null -ne $Item
}

function Get-BackupPath {
    param(
        [string]$Path,
        [string]$Name
    )

    $Candidate = Join-Path $RootPath "$Name.bak_$Timestamp"
    $Index = 1
    while (Test-PathOrLink -Path $Candidate) {
        $Candidate = Join-Path $RootPath "$Name.bak_${Timestamp}_$Index"
        $Index += 1
    }
    return $Candidate
}

function Backup-Existing {
    param(
        [string]$Path,
        [string]$Name
    )

    if (-not (Test-PathOrLink -Path $Path)) {
        return
    }

    $Backup = Get-BackupPath -Path $Path -Name $Name
    Move-Item -LiteralPath $Path -Destination $Backup
    Write-Output "已备份：$Backup"
}

Backup-Existing -Path $AgentsPath -Name "AGENTS.md"
Backup-Existing -Path $ClaudePath -Name "CLAUDE.md"

Set-Content -LiteralPath $AgentsPath -Value $Content -Encoding UTF8 -NoNewline

try {
    New-Item -ItemType SymbolicLink -Path $ClaudePath -Target "AGENTS.md" | Out-Null
} catch {
    Write-Error "错误：创建 CLAUDE.md 软链接失败。请开启 Windows 开发者模式，或使用允许创建符号链接的权限重新运行。原始错误：$($_.Exception.Message)"
}

Write-Output "已写入：$AgentsPath"
Write-Output "已创建软链接：$ClaudePath -> AGENTS.md"
