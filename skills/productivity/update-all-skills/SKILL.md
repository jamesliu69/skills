---
name: update-all-skills
description: "一鍵檢查並升級全系統所有 AI 代理的技能庫 (Skills)、外掛 (Plugins)、MCP 服務與 CLI 工具。當使用者說「更新技能」、「更新所有 AI」、「update all skills」或要求同步最新版本時使用。"
disable-model-invocation: true
---
## 輸出語言

除非使用者明確要求其他語言，否則所有回覆、文件、規格、報告、摘要、說明文字與產出內容都必須使用正體中文，並優先使用臺灣常用語。程式碼識別字、API 名稱、CLI 指令、檔案路徑、類別名稱、套件名稱、協定名稱及必要技術專有名詞保留原文。

# Update All Skills & AI Tools

當使用者要求更新所有技能、外掛或 AI 工具時，直接執行本技能隨附的一鍵自動化腳本：

```powershell
pwsh -NoProfile -File "D:\Repo\Matt\skills\skills\productivity\update-all-skills\scripts\update-all.ps1"
```

## 自動化涵蓋範疇

1. **Skills 倉儲同步**：從上游 `upstream/main` 抓取 Matt Pocock 最新技能，合併至本地 `zh-tw-localization` 分支，保留臺灣正體中文本地化並推送至個人遠端。
2. **全域技能分發**：將全套技能（含此技能）同步部署至全機 63 個 AI 代理環境（含 `~/.agents/skills`、`~/.claude/skills`、`~/.gemini/skills`、`~/.codex/skills`、`~/.cursor/skills`、`~/.copilot/skills` 等）。
3. **Python AI 工具升級**：透過 `uv tool upgrade --all` 更新 Headroom AI、MemPalace、Graphifyy、Specify CLI、Aider 等。
4. **npm 全域 AI 工具升級**：更新 `@openai/codex`、`@google/gemini-cli`、`oh-my-codex`、`@colbymchenry/codegraph` 等。
5. **Git 外掛與市場同步**：同步 Claude Code ponytail / thedotmack 市場、Copilot superpowers、VS Code awesome-copilot 與 MemPalace。
6. **IDE 擴充套件更新**：呼叫 `code --update-extensions` 檢查並更新 VS Code 擴充功能。