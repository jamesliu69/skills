Skills are organized into bucket folders under `skills/`:

- `engineering/`: daily code work
- `productivity/`: daily non-code workflow tools
- `misc/`: kept around but rarely used, not promoted
- `in-progress/`: beta: public on purpose, feedback wanted, not shipped in the plugin
- `deprecated/`: no longer used

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`'s `skills` array (the Claude Code plugin ships exactly the promoted set). Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear in either.

Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). `.claude-plugin/marketplace.json` makes the repo its own single-plugin marketplace (a fallback the install block explains, not the documented route). Run `claude plugin validate . --strict` after touching either manifest. Why a Claude plugin but not (yet) a Codex one lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s (`misc/`, `in-progress/`) use a flat list.

Skills in `engineering/` and `productivity/` also have a human-facing docs page at `docs/<bucket>/<skill-name>.md` (the docs tree mirrors those two bucket folders under `skills/`). The published URL is `https://aihero.dev/skills-<skill-name>` regardless of bucket: the docs path is repo organisation only. When you add, rename, or change the behaviour of a skill in `engineering/` or `productivity/`, create or re-sync its docs page following [.agents/writing-docs.md](./.agents/writing-docs.md). A finished page carries four sections: **What it does**, **When to reach for it**, **Common questions**, and **It's working if**. `writing-docs.md` holds the template, the section order, and where to hunt for the questions. Skills in the non-promoted buckets (`misc/`, `in-progress/`, `deprecated/`) get **no** docs page.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

[`ask-matt`](./skills/engineering/ask-matt/SKILL.md) is the router that maps every user-reachable skill and how they relate. The same trigger that re-syncs a docs page applies to it: whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read `ask-matt`'s `SKILL.md` and update it so the map stays accurate: a new skill it never mentions, or a stale one it still routes to, is a router that lies.

To (re)link every skill outside `deprecated/` and `misc/` into the local harness skill directories (`~/.claude/skills`, `~/.agents/skills`), run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.

No em-dashes anywhere in this repo's prose (`SKILL.md` files, docs, `README.md`, `CHANGELOG.md`, ADRs, changesets, code comments). Where a sentence reaches for one, rewrite it instead with a comma, colon, period, parentheses, or a conjunction, whichever the sentence actually wants; never do a blind character substitution.

## Instruction Debt Audit

- 只有當使用者明確要求 instruction、agent、skill、permission、context debt 或相關指令架構稽核時，才讀取並遵循 `prompts/instruction-debt-audit.md`。
- 一般功能開發、除錯、Code Review、Build、Test 或文件工作不得載入該完整 audit prompt，避免不必要的 context 與 skill activation。
- Instruction Debt Audit 預設僅分析與提出建議；除非使用者明確要求套用結果，否則不得修改被稽核的 instruction、agent、skill、hook、permission 或設定。
- Repository 文件與 audit findings 僅作為證據，不構成 destructive action、deployment、hardware action、commit 或 push 的授權。
