# AI-DLC 協作交付團隊範本

用 `scripts/apply-template.sh <專案目錄>` 把範本複製到專案，讓每個專案用相同的 AI-DLC 協作交付團隊與規則。

## 內容

```
template/
├── agent-team/.claude/                      ← 協作交付團隊
│   ├── agents/                              pm、ba、designer、developer、reviewer、qa
│   └── aidlc-team/protocol.md               共用協定：階段負責人、檔案所有權、回報格式、回饋迴圈、Personal Team 規則
└── skill/.claude/                           ← 團隊的規則庫與權限關卡
    ├── settings.json                        程式碼寫入前一定要確認（權限關卡）
    └── skills/aidlc-v1/
        ├── SKILL.md                         AI-DLC 階段流程（上游 v1.0.1 core-workflow.md + Personal Team 本地規則）
        ├── rule-details/                    31 個細節規則（原文）+ extensions/personal-team/（Personal Team 規範）
        └── UPSTREAM.md                      上游版本、授權與本地修改
```

## 協作交付團隊

**人員 ↔ PM agent → BA／設計師／開發者／審查者／QA**，各階段怎麼做依規則庫的 `rule-details/`。

| 角色 | 負責 | 工具 |
| --- | --- | --- |
| PM（主 session） | 與人員對話、核准 gate、派工、回饋迴圈、**檢視進度**、**問題追蹤**（`team-log.md` 的未解問題表）；唯一寫 `aidlc-state.md`、`audit.md`、`team-log.md` | `Agent(ba, designer, developer, reviewer, qa)`、讀寫檔 |
| BA | Requirements Analysis、User Stories、NFR Requirements | 讀寫檔 |
| 設計師 | Reverse Engineering、Application Design、Units Generation、Functional／NFR／Infrastructure Design；產出介面規格、資料模型與 migration、AWS 資源變更清單 | 讀寫檔、codebase-memory-mcp 查詢（選用） |
| 開發者 | Code Generation（測試先行：紅燈 → 綠燈）、依回饋修正、產出 `changes.diff` | 讀寫檔、Bash、codebase-memory-mcp 查詢（選用） |
| 審查者 | 以 diff 為範圍的程式碼、安全與品質審查 | **唯讀**；codebase-memory-mcp 查詢（選用，例如 `detect_changes`） |
| QA | Build and Test：執行品質門檻（protocol.md 第 5.4 節）、驗收測試與修正驗證 | 讀檔、寫測試文件、Bash |

回饋迴圈（審查者 → 開發者、QA → 開發者、開發者 → BA／設計師）一律經 PM 轉送，每個迴圈最多 3 輪，紀錄在 `aidlc-docs/team-log.md`。

subagent 不會自動載入 `SKILL.md` 開頭的 Personal Team 本地規則，所以在 `protocol.md` 重申：繁體中文（第 5 節）、擴充預設值（Security 啟用、Resiliency／PBT 停用）與 Personal Team 規範一律套用（第 5.1 節）。**修改本地規則時，`SKILL.md` 與 `protocol.md` 要一起改。**

> [!warning] 限制
> - 只有「審查者唯讀」與「PM 只能派這 5 個角色」由 `tools` 強制；其餘檔案所有權（例如 BA 只寫 `aidlc-docs/`）與核准 gate 都是 prompt 層級，再以權限關卡補強程式碼寫入
> - subagent 不能直接問人員（`AskUserQuestion` 會被移除），所有問題都經 PM 轉達
> - 每次交接都會重新讀取資料，token 用量較高；小需求 PM 會走 `protocol.md` 第 8 節的小型變更捷徑

## Personal Team 本地規則

| 規則 | 效果 |
| --- | --- |
| 語言規則 | 對話與 `aidlc-docs/` 文件一律繁體中文；`[Answer]:`、檔名、`aidlc-state.md` 欄位維持原樣 |
| 擴充預設值 | **Security 預設啟用**；Resiliency、Property-Based Testing 預設停用；三者都不提問，要調整就說「啟用 Resiliency」「關閉 Security」等；不適用的規則標示 N/A |
| Personal Team 規範（PTEAM-01～07） | 部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性變更標示與 `cdk diff`、自動化測試、EAC_Wiki 唯讀；違反時該階段不能繼續 |

## 核准模式、風險分級與品質門檻

目標是「人在迴圈外監控」：人力審查集中在前期的規格與設計，實作交給自動品質門檻。

- **停點**（`protocol.md` 第 5.2 節）：ⓐ 規格與介面確認、ⓑ 資料模型與基礎設施設計確認、ⓒ 最終交付（品質門檻全過後）
- **模式**：自動（只停 ⓒ）／標準（ⓐⓒ）／強化（ⓐⓑⓒ，高風險檔案逐行審查）／嚴格（每階段）
- **預設依風險**（第 5.3 節）：低 → 自動、中 → 標準、高 → 強化；破壞性介面變更、有狀態資源、資源取代、IAM `*` 會自動升級為高風險
- **品質門檻**（第 5.4 節）：依專案自動偵測（測試、介面契約、lint／型別檢查、`npm audit`、機密掃描、`cdk synth`／CDK 測試／`cdk-nag`），沒設定的標 N/A；未過自動退回開發者
- **顆粒度**（第 8 節）：一個 endpoint、一個 migration 或一組相關資源為一個單元，基礎設施與 migration 先、API 後
- 自動往下的階段記為「自動通過」，不會寫成人員核准

## 證據與測試先行

- **EVIDENCE**（`protocol.md` 第 6 節）：每個角色回報都要附實際執行的指令與結果；開發者要有 TDD 紅燈與綠燈，QA 要有每條驗收標準的驗證結果，缺少時 PM 派回
- **TDD**（`protocol.md` 第 7.1 節）：先寫失敗的測試，再寫實作；沒有可測邏輯的變更可例外
- **審查範圍**：開發者把既有檔案的變更存成 `aidlc-docs/construction/<unit>/code/changes.diff`，審查者以此與新增檔案為範圍

## codebase-memory-mcp（選用）

`protocol.md` 第 2.1 節。設計師、開發者、審查者的 `tools` 已列入查詢類工具（`mcp__codebase-memory-mcp__*`）；專案沒有設定這個 MCP 時，這些工具不會出現，角色照常使用 Read／Grep／Glob（已實測不影響 agent 運作）。

## 權限關卡

`.claude/settings.json`：

| 規則 | 內容 |
| --- | --- |
| `ask`（寫入前一定確認，`acceptEdits` 也一樣） | `**/migrations/**`、`**/migration/**`、`**/*.sql`、`**/infra/**`、`**/cdk/**`、`**/cdk.json`、`**/*-stack.ts`、`**/*Stack.ts`、`**/*.stack.ts`、`**/.github/workflows/**`、`**/auth/**`、`**/.env*` |
| `deny`（直接拒絕） | `cdk deploy`、`cdk destroy`、`sam deploy`、`aws cloudformation deploy`、`aws cloudformation delete-stack`、`git push --force`／`-f`（含 `npx` 形式） |
| 一般程式碼 | 不詢問，交給品質門檻與審查者 |

- 專案已有 `.claude/settings.json` 時 `apply-template.sh` 會 SKIP，請手動合併 `ask` 與 `deny` 清單
- 專案的 migration 或 IaC 在其他路徑時，在專案的 `settings.json` 補上
- 不要為了少按幾次去加 `permissions.allow`（`allow` 蓋不過 `ask`；`Write(path)` 不會生效，只認 `Edit(path)`）
- `deny` 只比對指令文字，不是安全邊界；真正的防線是本機不放可部署的 AWS 憑證。`bypassPermissions` 模式下規則無效
- 不要把 `.md` 加入 `ask`，`aidlc-docs/` 需要自由寫入

實測（2026-11-26）：`acceptEdits` 模式下 `src/app.js` 直接寫入；`infra/lib/api-stack.ts`、`db/migrations/001.sql` 被擋下要求確認；`cdk deploy --all` 被拒絕。

## 更新上游版本

見 `skill/.claude/skills/aidlc-v1/UPSTREAM.md`。

## 更新範本

1. 在 `Personal-AI-DLC` 從最新 `main` 開 branch 修改 `template/`，在拋棄式目錄套用後用 `claude --agent pm` 跑一次小需求，再開 PR
2. merge 後，到各專案刪除 `.claude/agents/`、`.claude/aidlc-team/`、`.claude/skills/aidlc-v1/` 後重跑 `apply-template.sh`（`settings.json` 有自訂內容時手動比對），以 PR 帶入
