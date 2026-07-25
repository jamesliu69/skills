---
name: implement
description: "根據規格或一組 tickets 實作工作項目。"
disable-model-invocation: true
---
## 輸出語言

除非使用者明確要求其他語言，否則所有回覆、文件、規格、報告、摘要、說明文字與產出內容都必須使用正體中文，並優先使用臺灣常用語。程式碼識別字、API 名稱、CLI 指令、檔案路徑、類別名稱、套件名稱、協定名稱及必要技術專有名詞保留原文。

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
