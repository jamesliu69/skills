#Requires -Version 7
[CmdletBinding()]
param(
    [switch]$Quick
)

$ErrorActionPreference = 'Stop'
$uHome = $env:USERPROFILE
$repoPath = 'D:\Repo\Matt\skills'
$nodeExe = 'C:\nvm4w\nodejs\node.exe'
$npmCli = 'C:\nvm4w\nodejs\node_modules\npm\bin\npm-cli.js'

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "         AI 全系統技能與工具一鍵更新程序               " -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# 1. 同步 Matt Pocock Skills 儲存庫
# -----------------------------------------------------------------------------
Write-Host "[1/6] 檢查並同步本地 Skills 倉儲 (D:\Repo\Matt\skills)..." -ForegroundColor Yellow
if (Test-Path (Join-Path $repoPath '.git')) {
    try {
        git -C $repoPath fetch upstream 2>$null
        $curBranch = (git -C $repoPath rev-parse --abbrev-ref HEAD 2>$null)
        if ($curBranch -eq 'zh-tw-localization') {
            git -C $repoPath merge --no-edit upstream/main 2>$null | Out-Null
            git -C $repoPath branch -f main upstream/main 2>$null | Out-Null
            git -C $repoPath push origin zh-tw-localization main 2>$null | Out-Null
            Write-Host "  -> Skills 倉儲已成功與上游同步，並推送至個人遠端！" -ForegroundColor Green
        }
    } catch {
        Write-Host "  -> 倉儲同步警告: $_" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  -> 找不到 $repoPath，略過倉儲同步步驟。" -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# 2. 部署 Skills 到全系統 63 個 AI 目錄
# -----------------------------------------------------------------------------
Write-Host "`n[2/6] 部署最新 Skills 至全域及所有 AI 代理目錄..." -ForegroundColor Yellow
$sourceSkills = @{}
Get-ChildItem -Path (Join-Path $repoPath 'skills') -Recurse -Filter 'SKILL.md' |
    Where-Object { $_.FullName -notmatch 'node_modules|deprecated' } |
    ForEach-Object { $sourceSkills[$_.Directory.Name] = $_.Directory.FullName }

$allTargets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
Get-ChildItem -Path $uHome -Depth 4 -Filter 'ask-matt' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch 'backup' } |
    ForEach-Object { [void]$allTargets.Add($_.Parent.FullName) }

$primary = @(
    "$uHome\.agents\skills",
    "$uHome\.claude\skills",
    "$uHome\.gemini\skills",
    "$uHome\.codex\skills",
    "$uHome\.copilot\skills",
    "$uHome\.cursor\skills"
)
foreach ($p in $primary) {
    if (Test-Path $p) { [void]$allTargets.Add($p) }
}

$deploySuccess = 0
foreach ($target in ($allTargets | Sort-Object)) {
    if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
    try {
        foreach ($skillName in $sourceSkills.Keys) {
            $src = $sourceSkills[$skillName]
            $dest = Join-Path $target $skillName
            if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
            Copy-Item -Recurse -Force $src $dest
        }
        $deploySuccess++
    } catch {
        Write-Host "  -> 部署失敗 ($target): $_" -ForegroundColor DarkRed
    }
}
Write-Host "  -> 成功部署 $($sourceSkills.Count) 個技能至 $deploySuccess 個 AI 目錄！" -ForegroundColor Green

# -----------------------------------------------------------------------------
# 3. 更新 Python AI 工具 (uv tool)
# -----------------------------------------------------------------------------
Write-Host "`n[3/6] 升級 Python AI 工具 (uv tool: headroom, mempalace, graphifyy, etc.)..." -ForegroundColor Yellow
try {
    $uvOut = uv tool upgrade --all 2>&1 | Where-Object { $_ -match 'Updated|Installed|Upgraded' }
    if ($uvOut) {
        $uvOut | ForEach-Object { Write-Host "  -> $_" -ForegroundColor Green }
    } else {
        Write-Host "  -> 所有 uv tool 已是最新版本。" -ForegroundColor Green
    }
} catch {
    Write-Host "  -> uv tool 升級警告: $_" -ForegroundColor DarkYellow
}

# -----------------------------------------------------------------------------
# 4. 更新全域 npm AI 套件
# -----------------------------------------------------------------------------
Write-Host "`n[4/6] 檢查並更新全域 npm AI 套件..." -ForegroundColor Yellow
if ((Test-Path $nodeExe) -and (Test-Path $npmCli)) {
    $pkgsNvm = @('@openai/codex')
    $pkgsRoaming = @('@google/gemini-cli', 'oh-my-codex', '@colbymchenry/codegraph')

    foreach ($pkg in $pkgsNvm) {
        $cur = try { (& $nodeExe -e "console.log(require('C:/nvm4w/nodejs/node_modules/$pkg/package.json').version)") } catch { '?' }
        $lat = (& $nodeExe $npmCli view $pkg version 2>$null)
        if ($lat -and $cur -ne $lat) {
            Write-Host "  -> 升級 $($pkg)：$cur -> $lat (nvm)..." -ForegroundColor Yellow
            & $nodeExe $npmCli install -g --prefix 'C:\nvm4w\nodejs' "$pkg@latest" 2>&1 | Out-Null
        } else {
            Write-Host "  -> $($pkg) 已是最新 ($cur)" -ForegroundColor DarkGray
        }
    }

    foreach ($pkg in $pkgsRoaming) {
        $roamPath = "$uHome/AppData/Roaming/npm/node_modules/$pkg/package.json".Replace('\', '/')
        $cur = try { (& $nodeExe -e "console.log(require('$roamPath').version)") } catch { '?' }
        $lat = (& $nodeExe $npmCli view $pkg version 2>$null)
        if ($lat -and $cur -ne $lat) {
            Write-Host "  -> 升級 $($pkg)：$cur -> $lat (Roaming)..." -ForegroundColor Yellow
            & $nodeExe $npmCli install -g --prefix "$uHome\AppData\Roaming\npm" "$pkg@latest" 2>&1 | Out-Null
        } else {
            Write-Host "  -> $($pkg) 已是最新 ($cur)" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "  -> 找不到 node/npm，略過 npm 套件檢查。" -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# 5. 更新 Git 外掛與市場
# -----------------------------------------------------------------------------
Write-Host "`n[5/6] 檢查 Git 外掛市場與外掛庫..." -ForegroundColor Yellow
$gitRepos = @(
    @{ Name = 'Copilot superpowers'; Path = "$uHome\.copilot\installed-plugins\superpowers-marketplace\superpowers" },
    @{ Name = 'awesome-copilot'; Path = "$uHome\.vscode\agent-plugins\github.com\github\awesome-copilot" },
    @{ Name = 'MemPalace'; Path = "$uHome\.vscode\agent-plugins\github.com\MemPalace\mempalace" },
    @{ Name = 'Claude ponytail marketplace'; Path = "$uHome\.claude\plugins\marketplaces\ponytail" },
    @{ Name = 'Claude thedotmack marketplace'; Path = "$uHome\.claude\plugins\marketplaces\thedotmack" }
)

foreach ($repo in $gitRepos) {
    if (Test-Path (Join-Path $repo.Path '.git')) {
        $before = (git -C $repo.Path rev-parse --short HEAD 2>$null)
        git -C $repo.Path fetch origin 2>$null
        $branch = (git -C $repo.Path rev-parse --abbrev-ref HEAD 2>$null)
        git -C $repo.Path pull --ff-only origin $branch 2>$null | Out-Null
        $after = (git -C $repo.Path rev-parse --short HEAD 2>$null)
        if ($before -ne $after) {
            Write-Host "  -> $($repo.Name): 更新 $before -> $after" -ForegroundColor Green
        } else {
            Write-Host "  -> $($repo.Name): 已是最新 ($after)" -ForegroundColor DarkGray
        }
    }
}

# -----------------------------------------------------------------------------
# 6. 更新 VS Code 擴充套件
# -----------------------------------------------------------------------------
Write-Host "`n[6/6] 檢查 VS Code 擴充套件更新..." -ForegroundColor Yellow
try {
    $codeOut = code --update-extensions 2>&1 | Where-Object { $_ -match '\S' } | Select-Object -Last 2
    Write-Host "  -> $($codeOut -join ' ')" -ForegroundColor Green
} catch {
    Write-Host "  -> 略過 (code CLI 未安裝或不在 PATH)" -ForegroundColor DarkGray
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "           所有 AI 技能與工具更新完成！                 " -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Cyan