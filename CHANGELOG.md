# Changelog

Personal-AI-DLC 的版本紀錄。版本號存在 `template/agent-team/.claude/aidlc-team/VERSION`，套用範本時會一併複製到專案的 `.claude/aidlc-team/VERSION`。

## 版本規則（SemVer）

| 變更 | 版本 | 例子 |
| --- | --- | --- |
| **MAJOR**：已套用的專案需要調整才能繼續使用 | `2.0.0` | 角色或停點結構改變、`aidlc-state.md` 格式不相容、移除規則 |
| **MINOR**：新增或改變行為，舊專案重新套用即可 | `1.1.0` | 新增規則、門檻、角色能力；調整預設值 |
| **PATCH**：不改變行為 | `1.0.1` | 錯字、說明文字、文件 |

每個修改 `template/` 的 PR 都要：更新 `VERSION`、在本檔最上方新增版本段落。合併後建立 git tag（`v<版本>`）。

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
