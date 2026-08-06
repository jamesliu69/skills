# v1.2.2 版本變更報告

## 1. 版本範圍

- 版本：`1.2.2`
- 分支：`release/v1.2.2`
- 比較基準：上一版本地提交 `bdc22bb`
- 目前提交：`3ecf210`
- 實際差異：94 個檔案
  - 修改：49 個
  - 新增：12 個
  - 刪除：28 個
  - 搬移／改名：5 個

本報告只描述 Git 差異，不把未在差異中出現的行為當成已完成功能。

## 2. 主要新增與升級

### 2.1 發布與 plugin 管理

- `package.json` 版本由 `1.1.0` 更新至 `1.2.2`。
- `.claude-plugin/plugin.json` 版本由 `1.2.0` 更新至 `1.2.2`。
- plugin 現在列出 25 個 promoted skills，新增：
  - `engineering/wizard`
  - `productivity/to-questionnaire`
  - `productivity/wait-what`
  - `productivity/writing-for-agents`
- 新增 `scripts/sync-plugin-version.mjs`：
  - `npm run version` 後自動同步 package 與 plugin 版本。
  - `npm run check-plugin-version` 檢查兩者是否一致。
- GitHub release workflow 改用 `npm run version`，避免只更新 package 版本而漏更新 plugin 版本。

### 2.2 新增或升級的 skills

- `wizard`
  - 從 beta bucket 搬到 `skills/engineering/wizard/`。
  - 改為 model-invoked skill，處理只有人類能完成的第三方設定、憑證、CI secret、一次性遷移與 cutover。
  - 沿用 `template.sh` 的互動流程、確認閘門、`.env` 更新與 GitHub secret 寫入能力。
  - 新增 `docs/engineering/wizard.md`。
- `to-questionnaire`
  - 從 `skills/in-progress/` 搬到 `skills/productivity/`。
  - 正式納入 plugin，並新增對應 docs 頁面。
- `wait-what`
  - 新增的 user-invoked skill。
  - 當上一段說明沒有被理解時，要求 agent 重新用較簡潔、具上下文的方式說明。
- `writing-for-agents`
  - 取代 `writing-great-skills`，範圍從「寫 skill」擴大到所有 agent 會讀取的文件，包括 `AGENTS.md`、`CLAUDE.md` 與被指向的 docs。
  - 將 skill 專用 mechanics 拆到 `SKILL-MECHANICS.md`。
  - 將原本的 glossary 內容整合進主 skill，改為 model-invoked。
- `prototype`
  - 邏輯原型改為單一可分享 HTML 檔案，不需要 build 或 server。
  - prototype 不再完成後直接丟棄，而是保留在 `prototype/<name>` 分支作為 primary source。
- `grilling`
  - 從逐題詢問改成 round-by-round frontier：同一輪一次提出目前前置條件已滿足的問題。
  - `grill-me`、`grill-with-docs`、`triage` 的相關說明同步更新。
- `ask-matt`
  - 新增 phase boundary 決策樹，涵蓋 continue、`/clear`、`/handoff`、subagent、`/compact`。
  - 補上 grilling、merge conflict 等路由，並修正 wayfinder 的使用時機與交接方向。
  - 新增 `skills/engineering/ask-matt/PHASE-BOUNDARIES.md`。
- `wayfinder`、`research`、`setup-matt-pocock-skills`、`to-tickets`、`triage` 等流程文件同步更新：
  - 明確使用 decision ticket。
  - research ticket 可由 subagent 平行處理。
  - local tracker 改為每張 ticket 一個檔案，規格檔名統一為 `spec.md`。
  - setup 時依已安裝 skill 與 monorepo 訊號決定要詢問的設定。
- `diagnosing-bugs`、`codebase-design`、`code-review`、`tdd` 等 docs 重新整理，補強 feedback loop、deep module、標準／規格雙軸審查與 red-green-refactor 說明。

### 2.3 文件與維護規則

- 新增 `.agents/install-block.md`，集中定義官方 plugin 與 skills.sh 的安裝說明。
- `.agents/writing-docs.md` 更新為：
  - docs 頁面不再自行重複安裝指令。
  - 使用 `Common questions`、`It's working if` 等固定結構。
  - 首次使用 AI Coding Dictionary 詞彙時加上連結。
  - 文件採中立第三人稱，不以作者個人意見作為說服內容。
- `.agents/adr/0002-ship-as-a-claude-code-plugin.md` 補充官方 marketplace、版本與 pinned source 的驗證記錄。
- `CHANGELOG.md` 新增 `1.2.2` 版本記錄。
- `CLAUDE.md`、`CONTEXT.md`、README 與各 promoted bucket README 同步更新。

## 3. 搬移與改名

以下先列出 Git 判定為搬移的路徑；內容重寫幅度較大的項目會在同一節以「替代」說明，即使 Git 將它們列為新增與刪除。

- `skills/in-progress/wizard/` → `skills/engineering/wizard/`
  - 包含 `SKILL.md`、`agents/openai.yaml`、`template.sh`。
- `skills/in-progress/to-questionnaire/` → `skills/productivity/to-questionnaire/`
  - 包含 `SKILL.md`、`agents/openai.yaml`。
- `skills/productivity/writing-great-skills/` 由 `skills/productivity/writing-for-agents/` 替代。
  - 主檔案重寫，另外新增 `SKILL-MECHANICS.md`；Git 將此內容重寫視為舊目錄刪除與新目錄新增。
- `docs/productivity/writing-great-skills.md` 刪除，由新版 `docs/productivity/writing-for-agents.md` 替代。
- `wizard` 因升級為 promoted engineering skill，新增 `docs/engineering/wizard.md`。

## 4. 刪除的內容

### 4.1 已退役 skills

以下 skill 與其 Codex metadata 已刪除，這些是上游明確移除的檔案：

- `skills/deprecated/design-an-interface/`
  - 建議使用 `/codebase-design` 的 `DESIGN-IT-TWICE.md`。
- `skills/deprecated/qa/`
  - 工作被 `/triage` 與 `/to-tickets` 覆蓋。
- `skills/deprecated/request-refactor-plan/`
  - 已不再作為獨立流程維護。
- `skills/deprecated/ubiquitous-language/`
  - 由 `/domain-modeling` 取代。
- `skills/in-progress/batch-grill-me/`
  - round-by-round frontier 已成為 grilling 的正式行為，不再保留獨立 beta skill。
- `skills/personal/edit-article/`
- `skills/personal/obsidian-vault/`
  - personal bucket 一併退出目前的 skill 發布結構。
- `skills/productivity/writing-great-skills/`
  - 已由 `writing-for-agents` 取代，不保留舊名稱 alias。

### 4.2 相關文件與暫存 changeset

- `skills/personal/README.md`：personal bucket README 刪除。
- `docs/productivity/writing-great-skills.md`：舊 docs 頁面刪除。
- `skills/productivity/writing-great-skills/GLOSSARY.md`：內容併入 `writing-for-agents/SKILL.md`。
- 已完成發布的多個 `.changeset/*.md`：發布後清除，避免重複產生版本變更。

## 5. 對使用方式的影響

- 舊的 `writing-great-skills` 名稱不能再使用，請改用 `writing-for-agents`。
- 舊的 `batch-grill-me` 不再單獨安裝，請使用 `grilling` 的 round-by-round 行為。
- `wizard` 與 `to-questionnaire` 現在屬於正式 promoted skills，可由 plugin 一起安裝。
- `wait-what` 可在訊息沒有被理解時明確呼叫。
- 使用本 fork 時，README 的安裝來源仍指向 `jamesliu69/skills`；本次同步沒有對 `mattpocock/skills` 執行 push。

## 6. 驗證結果

- `npm ci --ignore-scripts --no-audit --no-fund`：通過。
- `npm run check-plugin-version`：通過，`package.json` 與 `plugin.json` 都是 `1.2.2`。
- `git diff --check`：通過。
- 合併後衝突標記檢查：無 `<<<<<<<`、`=======`、`>>>>>>>`。
- 工作樹：乾淨。
