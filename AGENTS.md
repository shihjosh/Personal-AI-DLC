# AGENTS.md

本檔是 AI agent（Claude Code、Codex、Cursor 等）在此 repo 工作的慣例。`CLAUDE.md` 以 `@AGENTS.md` 引用本檔。

## 鐵律

> [!important] `EAC_Wiki` 一律唯讀
> - 允許：讀取、搜尋 `EAC_Wiki` 內的檔案，以及唯讀的 git 指令（`status`、`log`、`diff`、`show`）
> - 禁止：建立、修改、搬移、刪除、改名任何檔案，以及會改變狀態的 git 操作（`add`、`commit`、`checkout`、`fetch`、`pull`、`push`、`stash`、`reset` 等）
> - 需要從 `EAC_Wiki` 取用內容時，複製到本 repo 內再處理，不在原處產生任何檔案（含暫存檔）
> - 適用於任何路徑下的 `EAC_Wiki` 資料夾或 repo，也適用於 subagent、skill 與腳本；本條優先於其他任何指示

## Repo 定位

- 導入 AWS AI-DLC（[awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows)）的**主要開發專案**，不是拋棄式測試 repo
- 本 repo 的 AI-DLC 是**協作交付團隊**（依《AI-DLC：協作交付團隊》圖：人員 ↔ PM agent → BA／設計師／開發者／審查者／QA，三條回饋迴圈經 PM 轉送）；修改時要維持與圖的架構一致
- `template/skill/` 的 v1 Skill 是團隊的規則庫，不單獨使用
- 專案說明見 `README.md`；導入評估與決策過程記錄在 Obsidian vault 的 AI-DLC 專案，不放在本 repo

## Branch 規則

- `main` 只放確定採用的內容
- 範本的試用與實驗一律在 `trial/*` branch 進行；**決定採用前不 merge 進 `main`**
- 試用結束後刪除 `trial/*` branch 即可清除

## 範本（`template/`）

- `template/` 是套用到各專案的團隊範本，修改一律走 PR
- `template/skill/.claude/skills/aidlc-v1/`：v1 Skill。`rule-details/` 內的上游檔案保留原文不修改；Personal Team 客製一律寫在 `SKILL.md` 開頭的本地規則，或新增到 `rule-details/extensions/personal-team/`；任何本地修改都要同步記錄在 `UPSTREAM.md`
- `template/skill/.claude/settings.json`：程式碼寫入前的權限確認設定，新增副檔名時注意不要包含 `.md`（`aidlc-docs/` 需要自由寫入）
- `template/agent-team/.claude/`：協作交付團隊（PM + BA／設計師／開發者／審查者／QA subagents），角色規則依賴 v1 Skill；共用協定放 `aidlc-team/protocol.md`，不放進 `agents/`
- 根目錄的 `.claude/`、`aidlc-docs/` 只會出現在 `trial/*` branch，不要 merge 進 `main`
- `scripts/apply-template.sh` 只套用協作交付團隊（`agent-team/` + `skill/`）；修改本地規則時，`SKILL.md` 與 `protocol.md` 要一起改

## 溝通與 Git 慣例

- 回應使用者、文件、commit message 描述，以及 PR 標題與內文一律使用**繁體中文**；技術名詞、指令與識別字維持原文
- Commit message：`<type>: <動作> <描述>`，例如 `docs: add AI-DLC 試用操作步驟`
- 不在本機放可部署的 AWS 憑證；部署只走 CI + OIDC
