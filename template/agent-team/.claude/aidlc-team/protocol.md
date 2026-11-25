# AI-DLC 協作交付團隊：共用協定

所有角色（PM、BA、設計師、開發者、審查者、QA）**開始工作前必讀**本檔。
流程與各階段細節以 AI-DLC v1 Skill 為準，本檔只規定「誰做、怎麼交接」。

## 1. 團隊結構

```
人員（使用者）  <──>  PM（主 session，claude --agent pm）
                         │ 派工、轉送回饋、記錄
      ┌──────────┬───────┼──────────┬──────────┐
      BA        設計師   開發者     審查者      QA
```

- **只有 PM 和使用者對話**。其他角色是 subagent，不能等待使用者回答
- 角色之間**不直接溝通**，所有回饋都回報給 PM，由 PM 轉派
- 需要使用者回答時：角色寫好問題檔（`[Answer]:` 格式），回報 `STATUS: needs-user-input`，由 PM 請使用者作答後再派回同一角色

## 2. 規則檔位置

v1 Skill 的規則目錄（依序找到第一個存在的）：

1. `.claude/skills/aidlc-v1/`（專案內）
2. `~/.claude/skills/aidlc-v1/`（使用者層級）

以下簡稱 `<rules>` = 上述目錄下的 `rule-details/`，`<skill>` = 上述目錄下的 `SKILL.md`。

每個角色都要讀：

- `<rules>/common/content-validation.md`（建立任何檔案前）
- `<rules>/common/question-format-guide.md`（要提問時）
- `<rules>/common/terminology.md`
- `<rules>/extensions/personal-team/team-standards/personal-team-standards.md`（Personal Team 規範，一律適用）
- `<skill>` 中與自己負責階段相關的段落（各階段的執行條件與步驟）

已啟用的 extensions（見 `aidlc-docs/aidlc-state.md` 的 `## Extension Configuration`）對所有角色都是硬性規則。

## 3. 階段負責人

| 階段（v1） | 負責角色 | 規則檔 |
| --- | --- | --- |
| Workspace Detection | PM | `inception/workspace-detection.md` |
| Reverse Engineering | 設計師 | `inception/reverse-engineering.md` |
| Requirements Analysis | BA | `inception/requirements-analysis.md` |
| User Stories | BA | `inception/user-stories.md` |
| Workflow Planning | PM | `inception/workflow-planning.md` |
| Application Design | 設計師 | `inception/application-design.md` |
| Units Generation | 設計師 | `inception/units-generation.md` |
| Functional Design | 設計師 | `construction/functional-design.md` |
| NFR Requirements | BA | `construction/nfr-requirements.md` |
| NFR Design | 設計師 | `construction/nfr-design.md` |
| Infrastructure Design | 設計師 | `construction/infrastructure-design.md` |
| Code Generation | 開發者 | `construction/code-generation.md` |
| 程式碼審查（本團隊新增） | 審查者 | 已啟用的 `extensions/`、本檔第 6 節 |
| Build and Test | QA | `construction/build-and-test.md` |
| Operations | PM（目前為 placeholder） | `operations/operations.md` |

## 4. 檔案所有權

| 檔案 | 誰可以寫 |
| --- | --- |
| `aidlc-docs/aidlc-state.md` | **只有 PM** |
| `aidlc-docs/audit.md` | **只有 PM** |
| `aidlc-docs/team-log.md`（派工與回饋紀錄） | **只有 PM** |
| 自己負責階段的 `aidlc-docs/` 產物 | 該階段負責角色 |
| 應用程式碼與測試（`aidlc-docs/` 以外） | **只有開發者** |
| 審查者 | 不寫任何檔案，只回報 |

- 角色只能讀別人的產物，不能修改；要改就回報給 PM，由 PM 派給負責人
- 以上為 prompt 層級規則；只有審查者的唯讀是由 `tools` 強制

## 5. 語言規則（同 v1 Skill，subagent 不會自動載入 Skill，故在此重申）

- 對話與 `aidlc-docs/` 下新產生的文件一律使用**繁體中文**（台灣用語）
- 規則檔中的英文訊息範本翻成繁體中文，固定選項可在括號附原文
- **保持原樣不翻譯**：`[Answer]:` 標記、選項字母（`A)`、`B)`、`X)`）、核取方塊（`[ ]`、`[x]`）、檔名與目錄名、`aidlc-state.md` 的欄位與階段名稱、程式碼與識別字
- 問題檔最後的「Other」選項寫成：`X) 其他（請在下方 [Answer]: 後說明）`

## 5.1 擴充預設值（同 v1 Skill 本地規則，subagent 不會自動載入 Skill，故在此重申）

- Security、Resiliency、Property-Based Testing 擴充**一律預設啟用，不在問題檔中詢問**；只有使用者明確要求關閉（由 PM 轉達）時才停用
- 已啟用擴充的完整規則檔，各角色在自己負責的階段都要讀取並遵守：`<rules>/extensions/security/baseline/security-baseline.md`、`<rules>/extensions/resiliency/baseline/resiliency-baseline.md`、`<rules>/extensions/testing/property-based/property-based-testing.md`；不適用的規則標示 N/A
- **Personal Team 規範（PTEAM-01～07）一律啟用**：部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性與成本變更標示（含 `cdk diff`）、自動化測試、EAC_Wiki 唯讀
- 違反適用的擴充規則或 PTEAM 規則即為 blocking finding；完成回報時在 SUMMARY 或 ITEMS 附「擴充與 Personal Team 規範檢查」（符合／不符合／N/A）

## 6. 回報格式（每個角色結束時最後輸出，PM 依此決定下一步）

```text
## 回報
- ROLE: <ba|designer|developer|reviewer|qa>
- STAGE: <階段名稱（英文，同 aidlc-state.md）>
- STATUS: <done | needs-user-input | question-for-ba | question-for-designer | changes-requested | tests-failed | blocked>
- ARTIFACTS:
  - <建立或修改的檔案路徑>
- SUMMARY: <三行以內的繁體中文摘要>
- ITEMS:
  - <問題清單、審查發現或失敗測試；每項一行，含檔案路徑:行號與嚴重度（blocking / non-blocking）>
```

- `needs-user-input`：問題檔路徑列在 ARTIFACTS
- `changes-requested`（審查者）：ITEMS 只要有一項 `blocking` 就要回這個狀態
- `tests-failed`（QA）：ITEMS 列出失敗的測試、重現指令與錯誤摘要
- `question-for-*`（開發者）：ITEMS 列出要釐清的問題

## 7. 回饋迴圈（由 PM 執行）

| 迴圈 | 觸發 | PM 動作 |
| --- | --- | --- |
| 審查者 → 開發者 | `changes-requested` | 把 blocking 項目派給開發者修正，修完再派審查者 |
| QA → 開發者 | `tests-failed` | 把失敗清單派給開發者修正，修完再派 QA 重測 |
| 開發者 → BA / 設計師 | `question-for-ba` / `question-for-designer` | 派給對應角色釐清或調整；涉及需求或設計變更時先請使用者核准 |

- 同一迴圈最多 **3 輪**；第 3 輪仍未通過，PM 停下並請使用者決定
- 每一輪都記到 `aidlc-docs/team-log.md`

## 8. 小型變更捷徑

需求明確、只動 1–2 個檔案、沒有架構或資料變更時（例如 hello.js），PM 可以：

- 略過 User Stories、Application Design、Units Generation、NFR、Infrastructure Design
- 仍保留：Requirements Analysis（BA，可為精簡版）→ Code Generation（開發者）→ 審查者 → QA
- 在 Workflow Planning 明列略過的階段與理由，由使用者核准
