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
| 設計師 | Reverse Engineering、Application Design、Units Generation、Functional／NFR／Infrastructure Design | 讀寫檔 |
| 開發者 | Code Generation（含自動化測試）、依回饋修正 | 讀寫檔、Bash |
| 審查者 | 程式碼、安全與品質審查 | **唯讀** |
| QA | Build and Test、驗收測試與修正驗證 | 讀檔、寫測試文件、Bash |

回饋迴圈（審查者 → 開發者、QA → 開發者、開發者 → BA／設計師）一律經 PM 轉送，每個迴圈最多 3 輪，紀錄在 `aidlc-docs/team-log.md`。

subagent 不會自動載入 `SKILL.md` 開頭的 Personal Team 本地規則，所以在 `protocol.md` 重申：繁體中文（第 5 節）、擴充預設啟用與 Personal Team 規範一律套用（第 5.1 節）。**修改本地規則時，`SKILL.md` 與 `protocol.md` 要一起改。**

> [!warning] 限制
> - 只有「審查者唯讀」與「PM 只能派這 5 個角色」由 `tools` 強制；其餘檔案所有權（例如 BA 只寫 `aidlc-docs/`）與核准 gate 都是 prompt 層級，再以權限關卡補強程式碼寫入
> - subagent 不能直接問人員（`AskUserQuestion` 會被移除），所有問題都經 PM 轉達
> - 每次交接都會重新讀取資料，token 用量較高；小需求 PM 會走 `protocol.md` 第 8 節的小型變更捷徑

## Personal Team 本地規則

| 規則 | 效果 |
| --- | --- |
| 語言規則 | 對話與 `aidlc-docs/` 文件一律繁體中文；`[Answer]:`、檔名、`aidlc-state.md` 欄位維持原樣 |
| 擴充預設值 | Security、Resiliency、Property-Based Testing **預設啟用、不提問**；不需要時說「關閉 Resiliency」等；不適用的規則標示 N/A |
| Personal Team 規範（PTEAM-01～07） | 部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性變更標示與 `cdk diff`、自動化測試、EAC_Wiki 唯讀；違反時該階段不能繼續 |

## 權限關卡

`.claude/settings.json` 用 Claude Code 的 `permissions.ask`，讓寫入 `.js`、`.ts`、`.json`、`.py`、`.yml` 等程式碼類檔案前**一定跳出確認**，即使選了「允許本次所有編輯」或 `acceptEdits` 模式也一樣（`bypassPermissions` 模式除外，不要使用）；`aidlc-docs/` 的 `.md` 文件不受影響。

- 專案已有 `.claude/settings.json` 時 `apply-template.sh` 會 SKIP，請手動把 `permissions.ask` 清單合併進去
- 跳出提示按「允許」即可；不要為了少按幾次去加 `permissions.allow`（`allow` 蓋不過 `ask`，且 `Write(path)` 規則不會生效，只認 `Edit(path)`）
- 只涵蓋檔案編輯工具；Bash 指令寫檔（例如 `echo > file`）不在規則內，Bash 指令本身會詢問，執行前請看清楚
- 新增副檔名時不要加入 `.md`，`aidlc-docs/` 需要自由寫入

實測（2026-11-25）：`acceptEdits` 模式下一路回覆「核准並繼續」，`aidlc-docs/` 正常寫入，寫 `hello.js` 時被擋下 5 次，模型沒有改用 shell 繞過。

## 更新上游版本

見 `skill/.claude/skills/aidlc-v1/UPSTREAM.md`。

## 更新範本

1. 在 `Personal-AI-DLC` 從最新 `main` 開 branch 修改 `template/`，在拋棄式目錄套用後用 `claude --agent pm` 跑一次小需求，再開 PR
2. merge 後，到各專案刪除 `.claude/agents/`、`.claude/aidlc-team/`、`.claude/skills/aidlc-v1/` 後重跑 `apply-template.sh`（`settings.json` 有自訂內容時手動比對），以 PR 帶入
