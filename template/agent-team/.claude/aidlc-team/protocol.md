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

以下簡稱 `<rules>` = 上述目錄下的 `rule-details/`，`<skill>` = 上述目錄下的 `SKILL.md`，`<skills>` = 該目錄的上一層（`.claude/skills/` 或 `~/.claude/skills/`）。

Personal Team 規範是獨立的 Skill，放在 `<skills>/` 下：`personal-team-standards`、`backend-api-standards`、`frontend-standards`、`aws-cdk-standards`；工具 Skill `quality-gates` 提供 `scripts/detect-modules.sh` 與 `scripts/run-quality-gates.sh`。

每個角色都要讀：

- `<rules>/common/content-validation.md`（建立任何檔案前）
- `<rules>/common/question-format-guide.md`（要提問時）
- `<rules>/common/terminology.md`
- `personal-team-standards` Skill（PTEAM-01～07，一律適用；BA／設計師／開發者／審查者／QA 已在 `skills:` 預先載入，PM 讀 `<skills>/personal-team-standards/SKILL.md`）
- `<skill>` 中與自己負責階段相關的段落（各階段的執行條件與步驟）

已啟用的 extensions（見 `aidlc-docs/aidlc-state.md` 的 `## Extension Configuration`）對所有角色都是硬性規則。

## 2.1 程式碼查詢工具（選用：codebase-memory-mcp）

專案有設定 [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) 時，角色可用的工具中會出現 `mcp__codebase-memory-mcp__*`。有這些工具就**優先用查詢取代逐檔讀取**，以減少 token；沒有就照常用 Read／Grep／Glob。

| 工具 | 用途 | 主要使用者 |
| --- | --- | --- |
| `index_status`、`check_index_coverage` | 確認專案已建立索引且是最新的；不是最新就改用 Read／Grep，並在 SUMMARY 註明 | 所有角色（使用前先確認） |
| `get_architecture` | 專案概觀：語言、套件、路由、熱點 | 設計師（逆向工程、應用程式設計） |
| `search_graph`、`get_file_outline`、`get_code_snippet` | 找符號、看檔案大綱、讀單一函式 | 設計師、開發者、審查者 |
| `trace_path` | 呼叫者／被呼叫者、資料流 | 設計師、開發者（修改前看影響範圍）、審查者 |
| `detect_changes` | 把 git diff 對應到受影響的符號與影響範圍（blast radius） | 審查者 |

- 只使用查詢類工具；**不呼叫** `index_repository`、`delete_project`、`manage_adr` 等會改變索引的工具（需要重建索引時由 PM 請使用者決定）
- 查詢結果只是線索；要判定 blocking 或修改程式碼前，仍要用 Read 確認實際內容

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
| 程式碼審查（本團隊新增） | 審查者 | `agents/reviewer.md`、已啟用的擴充規則、規範 Skill（第 5.5 節） |
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

- 預設：**Security 啟用**，Resiliency、Property-Based Testing **停用**；三者都**不在問題檔中詢問**，只有使用者明確要求（由 PM 轉達）時才改變
- 依 `aidlc-docs/aidlc-state.md` 的 `## Extension Configuration` 判斷哪些擴充已啟用；已啟用擴充的完整規則檔，各角色在自己負責的階段都要讀取並遵守：
  - Security：`<rules>/extensions/security/baseline/security-baseline.md`
  - Resiliency（啟用時）：`<rules>/extensions/resiliency/baseline/resiliency-baseline.md`
  - Property-Based Testing（啟用時）：`<rules>/extensions/testing/property-based/property-based-testing.md`
- 不適用的規則標示 N/A；停用的擴充不需讀取，也不要在問題檔中提到
- **Personal Team 規範（PTEAM-01～07）一律啟用**：部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性與成本變更標示（含 `cdk diff`）、自動化測試、EAC_Wiki 唯讀
- 違反適用的擴充規則或 PTEAM 規則即為 blocking finding；完成回報時在 SUMMARY 或 ITEMS 附「擴充與 Personal Team 規範檢查」（符合／不符合／N/A）

## 5.2 核准模式（同 v1 Skill 本地規則）

由 PM 執行，其他角色不直接處理核准：

| 模式 | 停下來等人員核准的時機 | 問題檔 |
| --- | --- | --- |
| **自動** | 只有 ⓒ 最終交付 | 有建議答案的題目自動採用並標註「依建議代填（自動模式）」，交付時列出這些假設 |
| **標準** | ⓐ 規格與介面確認、ⓒ 最終交付 | 請人員作答 |
| **強化** | ⓐ 規格與介面確認、ⓑ 資料模型與基礎設施設計確認、ⓒ 最終交付；審查者對高風險檔案逐行審查 | 請人員作答 |
| **嚴格** | 每個階段完成後（上游 v1 原本的做法） | 請人員作答 |

- ⓐ **規格與介面確認**：需求分析完成時。內容包含需求、驗收標準，以及**介面**（API 的路由、HTTP method、request／response schema、錯誤碼、認證方式；或其他對外介面）
- ⓑ **資料模型與基礎設施設計確認**：設計完成時。內容包含資料表、欄位、索引、migration（含 down 與既有資料影響）；AWS 資源的新增／修改／取代／刪除清單、IAM 權限、網路與安全群組、成本變化
- ⓒ **最終交付**：品質門檻（本檔第 5.4 節）**全部通過**後才停下，提供門檻結果、介面對照、資源變更清單與交付摘要；門檻未過時自動退回開發者，不送到人員面前
- 程式碼產生計畫（Code Generation Part 1）只在**嚴格**模式停下；其他模式由開發者產出計畫後直接實作
- **預設「依風險」**：PM 在 Workflow Planning 依風險分級（本檔第 5.3 節）決定——低 → 自動、中 → 標準、高 → 強化；人員可隨時指定，例如「用嚴格模式」「這次用自動模式」

- **任何模式都會停下來**：回饋迴圈第 3 輪仍未通過、角色回報 `blocked`、問題沒有建議答案或答案互相矛盾、需要只有人員知道的資訊、人員要求停下
- 自動進入下一階段**不等於人員核准**：`audit.md` 與 `team-log.md` 記為「自動通過（○○模式）」，不可寫成人員核准
- 切換後從下一個停點起生效；目前模式、風險等級與來源記錄在 `aidlc-state.md` 的 `## Approval Mode`
- 不停下的階段仍要完成所有產物、檢查與 `audit.md` 紀錄，只是不等待回覆

## 5.3 風險分級（PM 在 Workflow Planning 判定）

依變更涉及的技術模組（第 5.5 節）判定；跨多個模組時取**最高**的等級。

| 風險 | 後端 API | 前端（Vue 2／3） | AWS 基礎設施（CDK／IaC） | 其他 |
| --- | --- | --- | --- | --- |
| **低** | 補測試、改 log 或錯誤訊息、不改介面的內部重構、補輸入驗證 | 文案、樣式、不影響邏輯的元件重構、補元件測試 | 加 tag、調整 log 保留天數、新增 CloudWatch alarm、補 CDK 測試 | 文件 |
| **中** | 新增 endpoint、向後相容地加欄位或參數 | 新增頁面或元件、新增 API 串接、表單 | 新增**無狀態**資源（Lambda、ECS service、SQS 等） | 一般功能 |
| **高** | **破壞性介面變更**（移除或改名欄位、改狀態碼或語意）、**DB migration／schema 變更**、認證與授權、金流、大量資料批次處理、刪除資料 | **登入、token 與權限流程**、路由守衛、付款流程、全域狀態（store）結構改動、移除頁面、Vue 2 → 3 遷移或更換建置工具 | **IAM／權限**、安全群組與網路、**有狀態資源**（RDS、DynamoDB、S3、EFS 等）、**會被取代或刪除的資源**、跨 stack export、明顯增加成本 | 專案 `AGENTS.md` 列為高風險的路徑或模組 |

**自動升級為高風險**（任何角色發現就回報 PM，PM 改用強化模式並告知人員）：

- 介面比對出不向後相容的變更
- 改到有狀態資源，或其 `RemovalPolicy` 不是 `RETAIN`／`SNAPSHOT`
- `cdk synth` 前後比對顯示資源的 logical ID 改變（會被取代）
- IAM 出現 `*` 動作或資源（同時是 PTEAM-03 的 blocking）
- 一次變更同時跨多個風險類別

人員可以覆寫風險等級，PM 記錄原判定與覆寫原因。

## 5.4 品質門檻（由 QA 執行，全部通過才進入最終交付）

門檻**依專案自動偵測**，有設定才執行，沒有就標 `N/A（專案未設定）`；不得為了通過而改設定或跳過。QA **先在專案根目錄執行 `bash .claude/skills/quality-gates/scripts/run-quality-gates.sh .`**（或 `~/.claude/skills/...`）（自動涵蓋 test、lint、typecheck、build、vue-tsc／tsc、npm audit、cdk synth、gitleaks），再補腳本沒涵蓋的項目（介面契約、逐條驗收標準、整合測試涵蓋範圍）：

| 門檻 | 偵測方式與指令（範例） |
| --- | --- |
| 單元與整合測試 | `package.json` 的 `test` script（或 `pytest`、`go test` 等專案慣用指令）；後端 API 要有實際打路由的整合測試（例如 Fastify `app.inject()`）涵蓋成功、驗證失敗、未授權、找不到 |
| 介面契約 | 實際回應符合 response schema（沒有多出或缺少欄位）；有 OpenAPI 或路由 schema 時逐一比對 |
| 靜態分析 | `lint` script 或 `eslint` 設定；有 `tsconfig.json` 時 `tsc --noEmit`（或 `typecheck` script）；Vue 3 + TypeScript 用 `vue-tsc --noEmit` |
| 前端（啟用前端模組時） | `build` script 必須成功；有設定時跑元件測試（Vitest／Jest + `@vue/test-utils`）與 e2e（Playwright／Cypress，可於無頭模式執行時）；檢查 FE-01（`v-html`）、FE-02（前端變數無機密） |
| 相依套件弱點 | 有 `package-lock.json` 時 `npm audit --audit-level=high`（其他套件管理工具用對應指令） |
| 機密掃描 | 有安裝 `gitleaks` 時 `gitleaks detect --no-git -s .`；沒安裝時以 Grep 檢查常見金鑰格式並註明 |
| 基礎設施（有 `cdk.json` 時） | 在 `cdk.json` 所在目錄執行 `npx cdk synth`（因需要 AWS 查詢或憑證而失敗時，標 N/A（環境限制）並註明原因，不算 `tests-failed`，不設定憑證）；CDK assertions／snapshot 測試；專案有 `cdk-nag` 時其結果不可有 error |
| 審查 | 審查者沒有未解決的 blocking |

- 任一門檻失敗 → `tests-failed`，自動退回開發者，**不送到人員面前**
- `cdk diff` 需要 AWS 憑證，本機不執行；交付摘要提醒由 CI（OIDC 唯讀角色）在 PR 上執行並由人員檢視（PTEAM-05）

## 5.5 技術模組與規範 Skill（同 v1 Skill 本地規則）

專案可能是前端、後端、AWS CDK 的任意組合（含 monorepo）。PM 在 Workspace Detection 於專案根目錄**執行 `bash .claude/skills/quality-gates/scripts/detect-modules.sh .`**（Skill 裝在使用者層級時改用 `bash ~/.claude/skills/quality-gates/scripts/detect-modules.sh .`；`settings.json` 已允許這兩種寫法免確認）偵測並啟用對應模組，各角色只套用已啟用模組的規範 Skill：

| 模組 | 偵測依據（任一成立即啟用） | 規範 Skill |
| --- | --- | --- |
| 後端 API | `package.json` 依賴 `fastify`、`express`、`@nestjs/core`、`koa`、`hono`；或 Python `fastapi`、`django`、`flask` | `backend-api-standards`（BE-01～08） |
| 前端 | 依賴 `vue`、`react`、`next`、`nuxt`、`svelte`、`@angular/core`；Vue 依 `vue` 版本判定 2 或 3 | `frontend-standards`（FE-01～08） |
| AWS CDK | 有 `cdk.json`，或依賴 `aws-cdk-lib` | `aws-cdk-standards`（CDK-01～08） |

- 專案 `AGENTS.md` 的聲明優先於腳本偵測；使用者可要求增減模組
- 結果記錄在 `aidlc-state.md` 的 `## Tech Modules`
- 每個角色依變更涉及的模組讀取 `<skills>/<規範 Skill>/SKILL.md`；審查者依規則 ID（BE／FE／CDK）判定，違反即為 blocking
- **跨模組的需求**：API 契約是前後端的共同介面，在 ⓐ 規格與介面確認時一起定案；前端依契約串接，審查者檢查前後端是否一致

## 6. 回報格式（每個角色結束時最後輸出，PM 依此決定下一步）

```text
## 回報
- ROLE: <ba|designer|developer|reviewer|qa>
- STAGE: <階段名稱（英文，同 aidlc-state.md）>
- STATUS: <done | needs-user-input | question-for-ba | question-for-designer | changes-requested | tests-failed | blocked>
- ARTIFACTS:
  - <建立或修改的檔案路徑>
- SUMMARY: <三行以內的繁體中文摘要>
- EVIDENCE:
  - <實際執行的指令與結果摘要，例如 `node --test` → 5 pass / 0 fail；或審查範圍、使用的查詢工具>
- ITEMS:
  - <問題清單、審查發現或失敗測試；每項一行，含檔案路徑:行號與嚴重度（blocking / non-blocking）>
```

- `needs-user-input`：問題檔路徑列在 ARTIFACTS
- `changes-requested`（審查者）：ITEMS 只要有一項 `blocking` 就要回這個狀態
- `tests-failed`（QA）：ITEMS 列出失敗的測試、重現指令與錯誤摘要
- `question-for-*`（開發者）：ITEMS 列出要釐清的問題

### EVIDENCE（完成前要有證據）

宣稱完成前必須附上**實際執行過**的證據，不能只寫「已通過」「應該可以」：

| 角色 | EVIDENCE 必須包含 |
| --- | --- |
| 開發者 | TDD 的紅燈與綠燈：先跑新測試失敗的指令與失敗原因，再跑實作後全部測試通過的指令與結果（pass／fail 數）；`git diff` 存檔路徑 |
| QA | 建置與每條驗收標準的驗證指令與結果 |
| 審查者 | 審查範圍（diff 檔、檔案清單）、使用的查詢工具與重點結果 |
| BA／設計師 | 完成的檢查，例如 content-validation、Mermaid 語法驗證；無指令可執行時寫 `N/A（文件產出）` |

- 開發者、QA 回報 `done` 卻沒有實際指令結果時，PM 視為未完成並派回（算一輪回饋）
- 證據中的指令要能讓人員複製重跑


## 7. 回饋迴圈（由 PM 執行）

| 迴圈 | 觸發 | PM 動作 |
| --- | --- | --- |
| 審查者 → 開發者 | `changes-requested` | 把 blocking 項目派給開發者修正，修完再派審查者 |
| QA → 開發者 | `tests-failed` | 把失敗清單派給開發者修正，修完再派 QA 重測 |
| 開發者 → BA / 設計師 | `question-for-ba` / `question-for-designer` | 派給對應角色釐清或調整；涉及需求或設計變更時先請使用者核准 |

- 同一迴圈最多 **3 輪**；第 3 輪仍未通過，PM 停下並請使用者決定
- 每一輪都記到 `aidlc-docs/team-log.md`

## 7.1 測試先行（TDD）

開發者預設採用測試先行：

1. **計畫**：Code Generation 計畫先列出要寫的測試（對應驗收標準），再列實作步驟
2. **紅燈**：先寫測試並執行，確認因「功能尚未實作」而失敗（不是語法錯誤或設定錯誤）
3. **綠燈**：寫最少的實作讓測試通過，再跑全部測試確認沒有回歸
4. **重構**：需要時整理程式碼，測試保持綠燈
5. **修 bug**：先寫能重現 bug 的失敗測試，再修正

- 例外：沒有可測邏輯的變更（純設定、文件、IaC 接線等）可不走紅燈，在計畫中寫明理由；人員也可以說「這次不用 TDD」
- 紅燈與綠燈的指令與結果都要寫進 EVIDENCE

## 8. 任務顆粒度與小型變更

**單元越小，審查越輕鬆。** PM 在 Workflow Planning（必要時經 Units Generation）把工作切成小單元：

- 一個單元只處理一件事：**一個 endpoint、一個 migration，或一個 stack 中一組相關資源**
- 目標每個單元變更約 300 行以內；超過時說明理由或再切分
- 順序：**CDK 資源 → DB migration → 後端 API → 前端**，方便分開回滾；同一單元不要同時改有狀態資源與大量 API 程式碼，也不要同時改後端與前端
- monorepo 依子目錄切分單元，每個單元只動一個子專案
- 每個單元獨立走完 開發者 → 審查者 → QA；最終交付逐單元列出摘要

需求明確、只動 1–2 個檔案、沒有架構或資料變更時（例如 hello.js），PM 可以：

- 略過 User Stories、Application Design、Units Generation、NFR、Infrastructure Design
- 仍保留：Requirements Analysis（BA，可為精簡版）→ Code Generation（開發者）→ 審查者 → QA
- 在 Workflow Planning 明列略過的階段與理由
