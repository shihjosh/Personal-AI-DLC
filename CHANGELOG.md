# Changelog

Personal-AI-DLC 的版本紀錄。版本號存在 `template/agent-team/.claude/aidlc-team/VERSION`，套用範本時會一併複製到專案的 `.claude/aidlc-team/VERSION`。

## 版本規則（SemVer）

| 變更 | 版本 | 例子 |
| --- | --- | --- |
| **MAJOR**：已套用的專案需要調整才能繼續使用 | `2.0.0` | 角色或停點結構改變、`aidlc-state.md` 格式不相容、移除規則 |
| **MINOR**：新增或改變行為，舊專案重新套用即可 | `1.1.0` | 新增規則、門檻、角色能力；調整預設值 |
| **PATCH**：不改變行為 | `1.0.1` | 錯字、說明文字、文件 |

每個修改 `template/` 的 PR 都要：更新 `VERSION`、在本檔最上方新增版本段落。合併後建立 git tag（`v<版本>`）。

## [1.2.0] - 2026-11-26

依 Anthropic「Don't Build Agents, Build Skills」的做法：知識放進可組合、可重用的 Skill，重複性工作交給腳本。舊專案依 `INSTALL.md` 重新安裝（要刪除的範本檔案清單已更新）；`settings.json` 不會被覆蓋，沒有自訂過就先刪除再套用，有自訂就手動合併 `allow`／`ask`／`deny`。

### 規範改為獨立的 Skill

- `personal-team-standards`（PTEAM-01～07）、`backend-api-standards`（BE-01～08）、`frontend-standards`（FE-01～08）、`aws-cdk-standards`（CDK-01～08）從 `aidlc-v1/rule-details/extensions/personal-team/` 搬出，成為各自的 Skill，附 `description`
- 平常直接用 Claude Code 開發（不經 PM）時，也會依描述自動載入對應規範
- 團隊角色（BA／設計師／開發者／審查者／QA）以 `skills: personal-team-standards` 預先載入；技術模組規範依偵測結果讀取

### 腳本

- 新增 `quality-gates` Skill：
  - `scripts/detect-modules.sh`：偵測後端 API／前端（Vue 2／3、Vuex／Pinia、Vite、vue-tsc）／AWS CDK，支援 monorepo 與 Python 後端
  - `scripts/run-quality-gates.sh`：依專案設定執行 test、lint、typecheck、build、vue-tsc／tsc、npm audit、cdk synth、gitleaks，輸出 PASS／FAIL／N/A 結果表；FAIL 時 exit 1；不安裝套件、不修改檔案、不部署
- PM 以腳本偵測技術模組（PM 新增 `Bash` 工具）；QA 先執行門檻腳本，再補腳本沒涵蓋的項目
- `settings.json` 新增 `allow`：`detect-modules.sh`、`run-quality-gates.sh` 兩支腳本（`.claude/skills/...` 與 `~/.claude/skills/...` 兩種寫法）以及 `date` 免確認；`deny` 補上不帶參數的 `cdk destroy`、`npx cdk deploy`、`npx cdk destroy`、`sam deploy`；需先在專案接受信任對話框才生效（`INSTALL.md` 已補說明）
- `team-log.md` 時間戳記改用 `date -u` 取得實際時間，不再由模型估計

## [1.1.0] - 2026-11-26

依技術領域模組化，支援前端、後端、AWS CDK 任意組合的專案（含 monorepo）。舊專案重新套用即可。

### 技術模組

- 新增 `rule-details/extensions/personal-team/` 下的三個模組，PM 在 Workspace Detection 依專案自動偵測啟用（monorepo 依子目錄），專案 `AGENTS.md` 聲明優先：
  - 後端 API（BE-01～08）：輸入驗證、安全的錯誤回應、授權與 IDOR、介面向後相容、參數化查詢與分頁、migration 可回滾、外部呼叫 timeout、API 整合測試
  - 前端 Vue 2／Vue 3（FE-01～08）：XSS（`v-html`）、前端變數無機密與 token 處理、依 API 契約串接、載入／錯誤／空狀態、路由守衛、無障礙、不新增 Vue 2 專屬依賴、元件測試；沿用各子專案既有寫法（Vuex／Pinia、Options／Composition API）
  - AWS CDK（CDK-01～08）：有狀態資源 `RETAIN`、logical ID 穩定、最小權限、安全群組、加密與存取記錄、環境不寫死、assertions 測試、cdk-nag suppression 需理由
- 偵測結果記錄在 `aidlc-state.md` 的 `## Tech Modules`；可對 PM 說「這個專案沒有前端」「這是 Vue 3 專案」調整

### 流程

- 風險分級新增前端欄（低：文案、樣式；中：新頁面、API 串接；高：登入與權限流程、路由守衛、付款、全域狀態、Vue 2 → 3 遷移）；跨模組時取最高等級
- 品質門檻新增前端：`build` 必須成功，有設定時跑元件測試與 e2e；Vue 3 + TypeScript 用 `vue-tsc --noEmit`
- 單元順序：CDK 資源 → DB migration → 後端 API → 前端；同一單元不同時改後端與前端
- 設計師產出前端的畫面流程、元件拆分、狀態管理與 API 串接；審查者依模組規則 ID 判定

## [1.0.0] - 2026-11-26

第一個正式版本：依《AI-DLC：協作交付團隊》圖建立的協作交付團隊，規則庫為 [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) v1.0.1。

### 團隊

- PM（主 session，`claude --agent pm`）統籌 BA／設計師／開發者／審查者／QA；審查者唯讀；三條回饋迴圈經 PM 轉送、最多 3 輪
- PM 提供檢視進度與問題追蹤（`team-log.md` 的未解問題表）
- `scripts/apply-template.sh` 與 `INSTALL.md`（Windows Git Bash／PowerShell、Ubuntu）
- 操作提示詞速查表 `.claude/aidlc-team/prompts.md`：可以對 PM 說的話與可調整的設定；問 PM「有哪些指令」會列出

### 規則庫（v1.0.1 + Personal Team 本地規則）

- 對話與 `aidlc-docs/` 文件一律繁體中文
- 擴充預設值：Security 啟用；Resiliency、Property-Based Testing 停用；三者都不提問
- Personal Team 規範 PTEAM-01～07：部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性與成本變更標示、自動化測試、EAC_Wiki 唯讀

### 人在迴圈外監控

- 依風險的核准模式：低 → 自動（只停最終交付）、中 → 標準（規格與介面、最終交付）、高 → 強化（再加資料模型與基礎設施設計）；也可指定嚴格
- 自動品質門檻：依專案偵測測試、介面契約、lint／型別檢查、`npm audit`、機密掃描、`cdk synth`／CDK 測試／`cdk-nag`；全過才送到人員面前
- 任務顆粒度：一個單元只做一件事，基礎設施與 migration 先、API 後
- 完成證據（EVIDENCE）、測試先行（TDD）、以 diff 為範圍的審查清單
- 選用 codebase-memory-mcp 查詢工具

### 權限關卡（`.claude/settings.json`）

- `ask`：只擋高風險路徑（migration、SQL、IaC、workflow、auth、`.env`）
- `deny`：本機部署（`cdk deploy`／`destroy`、`sam deploy`、`aws cloudformation deploy`／`delete-stack`）與強制推送
