---
name: resolving-merge-conflicts
description: "當需要解決進行中的 git merge 或 rebase 衝突時使用。"
---
## 輸出語言

除非使用者明確要求其他語言，否則所有回覆、文件、規格、報告、摘要、說明文字與產出內容都必須使用正體中文，並優先使用臺灣常用語。程式碼識別字、API 名稱、CLI 指令、檔案路徑、類別名稱、套件名稱、協定名稱及必要技術專有名詞保留原文。

1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`.

4. Discover the project's **automated checks** and run them, typically typecheck, then tests, then format. Fix anything the merge broke.

5. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue the rebase process until all commits are rebased.
