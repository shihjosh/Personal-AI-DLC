# Personal-AI-DLC

Personal Team 的 **AI-DLC（AI-Driven Development Lifecycle）協作交付團隊**：在 Claude Code 中以 **PM agent 統籌 BA／設計師／開發者／審查者／QA**，從需求到交付逐階段進行，每個階段由人員核准。

> **人員定方向、PM 統籌、Agent 協作。**

**要開始使用？看 [`INSTALL.md`](INSTALL.md)。**

## 團隊架構

```mermaid
flowchart TB
    USER["人員<br/>訂定目標，並與 PM 檢視進度"] <--> PM["PM agent（主 session）<br/>指導並協調 Agent；追蹤問題解決與交付"]

    PM -->|PM 分派工作並協調團隊| BA["BA<br/>需求與驗收標準"]
    PM --> DES["設計師<br/>使用者流程與方案設計"]
    PM --> DEV["開發者<br/>程式碼與自動化測試"]
    PM --> REV["審查者（唯讀）<br/>程式碼、安全與品質審查"]
    PM --> QA["QA<br/>驗收測試與修正驗證"]

    subgraph FEEDBACK["Agent 間問題回饋（一律經 PM 轉送，每條最多 3 輪）"]
        direction LR
        F1A["審查者"] -->|審查發現 → 程式修正| F1B["開發者"]
        F2A["QA"] -->|測試失敗 → 修正與重測| F2B["開發者"]
        F3A["開發者"] -->|提問 → 釐清或調整| F3B["BA／設計師"]
    end

    BA ~~~ FEEDBACK
    DES ~~~ FEEDBACK
    DEV ~~~ FEEDBACK
    REV ~~~ FEEDBACK
    QA ~~~ FEEDBACK

    classDef person fill:#fef3c7,stroke:#d97706,color:#78350f
    classDef pm fill:#ede9fe,stroke:#7c3aed,color:#4c1d95
    classDef role fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef fb fill:#f9fafb,stroke:#6b7280,color:#374151
    class USER person
    class PM pm
    class BA,DES,DEV,REV,QA role
    class F1A,F1B,F2A,F2B,F3A,F3B fb
```

| 角色 | 負責 | 實作 |
| --- | --- | --- |
| **人員** | 訂定目標，並與 PM 檢視進度；回答問題、核准每個階段 | 只和 PM 對話；問「進度」時 PM 回報目前階段、進行中的迴圈、未解問題與你下一步要做的事 |
| **PM agent** | 指導並協調 Agent；追蹤問題解決與交付 | 主 session（`claude --agent pm`）；一次派一個角色並等待回報；未解問題記在 `team-log.md`，交付前確認沒有未解的 blocking 問題 |
| **BA** | 需求與驗收標準 | 需求分析、使用者故事、非功能需求 |
| **設計師** | 使用者流程與方案設計 | 逆向工程、應用程式設計、單元拆分、功能／非功能／基礎設施設計 |
| **開發者** | 程式碼與自動化測試 | 程式碼產生（先核准計畫）、依回饋修正 |
| **審查者** | 程式碼、安全與品質審查 | **唯讀**（工具強制）；逐條檢查 Personal Team 規範 |
| **QA** | 驗收測試與修正驗證 | 建置與測試、逐條對照驗收標準、修正後重測 |

**Agent 間問題回饋**：subagent 之間無法直接對話，三條回饋一律經 PM 轉送，每條最多 3 輪，超過由人員決定。

| 迴圈 | 觸發 | 處理 |
| --- | --- | --- |
| 審查者 → 開發者 | 審查發現 blocking 問題 | 開發者修正後再審查 |
| QA → 開發者 | 測試失敗 | 開發者修正後 QA 重測，並確認沒有回歸 |
| 開發者 → BA／設計師 | 需求或設計不清楚 | BA／設計師釐清或調整；改變已核准內容時先請人員核准 |

## 工作流程

PM 依 AI-DLC 的階段推進，把每個階段派給負責角色。實線框一定執行；虛線框由 PM 依需求複雜度決定（小需求會略過使用者故事與設計）。✋ 表示完成後**停下等人員核准**。

```mermaid
flowchart TD
    START(["人員訂定目標<br/>claude --agent pm，輸入需求"]) --> WD

    subgraph INCEPTION["🔵 構思階段（Inception）：決定做什麼、為什麼做"]
        WD["工作區偵測 · PM"]
        RE["逆向工程 · 設計師 ✋<br/>僅既有專案"]
        RA["需求分析 · BA ✋<br/>需求與驗收標準"]
        US["使用者故事 · BA ✋"]
        WP["流程規劃 · PM ✋<br/>決定要執行哪些階段"]
        AD["應用程式設計 · 設計師 ✋"]
        UG["單元拆分 · 設計師 ✋"]
        WD --> RE --> RA --> US --> WP --> AD --> UG
    end

    subgraph CONSTRUCTION["🟢 建構階段（Construction）：每個單元重複一次"]
        FD["功能設計 · 設計師 ✋<br/>使用者流程與方案設計"]
        NR["非功能需求 · BA ✋"]
        ND["非功能設計 · 設計師 ✋"]
        ID["基礎設施設計 · 設計師 ✋"]
        CG["程式碼產生 · 開發者 ✋<br/>先核准計畫，再寫程式碼與自動化測試"]
        CR["程式碼審查 · 審查者<br/>程式碼、安全與品質"]
        FD --> NR --> ND --> ID --> CG --> CR
        CR -.->|審查發現 → 程式修正| CG
    end

    UG --> FD
    CR -->|無 blocking| BT["建置與測試 · QA ✋<br/>驗收測試與修正驗證"]
    BT -.->|測試失敗 → 修正與重測| CG
    BT --> DONE(["交付：PM 確認無未解問題<br/>人員核准後 commit／PR"])

    classDef pm fill:#ede9fe,stroke:#7c3aed,color:#4c1d95
    classDef always fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef cond fill:#f9fafb,stroke:#6b7280,stroke-dasharray:4 3,color:#374151
    class WD,WP pm
    class RA,CG,CR,BT always
    class RE,US,AD,UG,FD,NR,ND,ID cond
```

### 每個階段的互動方式

```mermaid
sequenceDiagram
    actor U as 人員
    participant P as PM agent
    participant R as 負責角色（BA／設計師／開發者／審查者／QA）
    participant D as aidlc-docs/

    P->>R: 派工（階段、前置產物、修改要求）
    R->>D: 寫入產出或問題檔
    R-->>P: 回報 STATUS／ITEMS
    P->>D: 更新 aidlc-state.md、audit.md、team-log.md
    opt 角色需要人員回答
        P-->>U: 請你在問題檔 [Answer]: 作答
        U->>P: 「完成」
        P->>R: 再派回同一角色
    end
    P-->>U: 說明結果，停下等核准
    alt 要求修改
        U->>P: 說明要改的地方
        P->>R: 轉送修改要求
    else 核准
        U->>P: 「繼續」
        P->>P: 記錄核准，派下一階段的角色
    end
    opt 隨時
        U->>P: 「進度？」
        P-->>U: 目前階段、進行中的迴圈、未解問題、你要做的事
    end
```

## 系統架構

```mermaid
flowchart TB
    subgraph TEAM["Personal-AI-DLC（範本 repo）"]
        TPL["template/agent-team/.claude<br/>agents/（PM + 5 角色）· aidlc-team/protocol.md"]
        RULES_LIB["template/skill/.claude/skills/aidlc-v1<br/>團隊的規則庫：SKILL.md · rule-details/ · Personal Team 規範"]
        GATE["template/skill/.claude/settings.json<br/>權限關卡"]
    end

    subgraph DEV["開發者電腦（Windows / Ubuntu）"]
        USER(("人員"))
        subgraph CC["Claude Code（claude --agent pm）"]
            PM["PM agent"]
            ROLES["BA · 設計師 · 開發者 · 審查者 · QA<br/>（subagents）"]
        end
        subgraph PROJ["專案 repo"]
            DOTCLAUDE[".claude/<br/>agents · aidlc-team · skills · settings.json"]
            CODE["程式碼與測試"]
            DOCS["aidlc-docs/<br/>需求 · 設計 · aidlc-state.md · audit.md · team-log.md"]
        end
    end

    subgraph GH["GitHub"]
        PR["Pull Request<br/>程式碼 + aidlc-docs 一起 review"]
        GHA["GitHub Actions<br/>建置 · 測試 · cdk deploy"]
    end
    AWS[("AWS")]

    TPL & RULES_LIB & GATE -->|apply-template.sh| DOTCLAUDE
    DOTCLAUDE -->|載入角色、協定與規則| CC
    USER <-->|目標、核准、檢視進度| PM
    PM -->|派工與轉送回饋| ROLES
    ROLES -->|開發者寫入| CODE
    ROLES -->|各角色寫產出| DOCS
    PM -->|記錄| DOCS
    PROJ -->|git push| PR
    PR -->|review 後 merge| GHA
    GHA -->|OIDC 短期憑證| AWS
```

- **團隊定義**：`template/agent-team/.claude/` 的 6 個 agent 與共用協定 `protocol.md`
- **規則庫**：各角色依 `template/skill/.claude/skills/aidlc-v1/` 的 AI-DLC 階段規則工作（上游 awslabs/aidlc-workflows v1.0.1 + Personal Team 本地規則）
- **交付**：程式碼與 `aidlc-docs/` 一起進 PR review；部署只由 GitHub Actions 透過 OIDC 執行，開發者電腦不放可部署的 AWS 憑證

## Personal Team 規則（所有角色適用）

| 規則 | 效果 |
| --- | --- |
| 繁體中文 | 對話與 `aidlc-docs/` 文件一律繁體中文；流程用的標記（`[Answer]:`、檔名、`aidlc-state.md` 欄位）維持原樣 |
| 擴充預設啟用 | Security、Resiliency、Property-Based Testing 預設啟用、不提問；不需要時對 PM 說「關閉 Resiliency」等；不適用的規則標示 N/A |
| Personal Team 規範（PTEAM-01～07） | 部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性與成本變更標示（含 `cdk diff`）、自動化測試、EAC_Wiki 唯讀；違反即為 blocking，審查者逐條檢查 |
| 權限關卡 | `.claude/settings.json` 讓寫入程式碼類檔案（`.js`、`.ts`、`.json`、`.py`、`.yml` 等）前一定跳出確認，即使開了「允許所有編輯」也一樣 |

## 安裝與啟動

**安裝、重新安裝、更新與使用方式見 [`INSTALL.md`](INSTALL.md)**（Windows／Ubuntu 分開說明）。

啟動（在專案目錄）：

```powershell
$env:CLAUDE_CODE_FORK_SUBAGENT = "0"; claude --agent pm
```

## 修改團隊（維護者）

```
開 branch → 修改 template/ → 實測 → 開 PR → review → merge 到 main → 通知各專案更新
```

1. 從最新的 `main` 開 branch：`git switch main && git pull && git switch -c feat/<描述>`
2. 修改：
   - 角色：`template/agent-team/.claude/agents/*.md`；共用規則：`template/agent-team/.claude/aidlc-team/protocol.md`
   - 規則庫：`template/skill/.claude/skills/aidlc-v1/`。`rule-details/` 上游檔案不改；客製寫在 `SKILL.md` 開頭或 `rule-details/extensions/personal-team/`，並記錄在 `UPSTREAM.md`
   - subagent 不會自動載入 `SKILL.md` 開頭的本地規則，改了本地規則時要同步更新 `protocol.md`
3. 在拋棄式目錄套用後用 `claude --agent pm` 跑一次小需求，確認派工順序、回饋迴圈與核准停點
4. 開 PR（標題與內文用繁體中文），merge 到 `main`
5. **PR merge 後，同一個 branch 再 push 的 commit 不會進 `main`**，要另開新的 PR

## 目前狀態

| 項目 | 狀態 |
| --- | --- |
| 協作交付團隊（PM + 5 角色） | ✅ 對齊架構圖；hello.js 端到端實測通過：PM → BA → PM → 開發者（計畫、核准後實作）→ 審查者 → QA，四個核准停點、`team-log.md` 與未解問題表皆正常 |
| 回饋迴圈（審查者／QA → 開發者、開發者 → BA／設計師） | ⏳ 實測時審查與測試一次通過，迴圈尚未實際觸發，待用較複雜的需求驗證 |
| 規則庫（v1.0.1 + Personal Team 本地規則） | ✅ 繁體中文、Personal Team 規範、權限關卡皆已實測 |
| 擴充預設啟用（Security、Resiliency、PBT） | ✅ 實測：三者記為「Personal Team 預設」啟用、不產生問題檔；hello.js 不適用的規則（例如 Resiliency）標示 N/A，不算 blocking |

## 限制

- 只有「審查者唯讀」與「PM 只能派這 5 個角色」由工具強制；其餘檔案所有權與核准 gate 靠 prompt 遵守，再以權限關卡補強程式碼寫入
- 權限關卡只涵蓋檔案編輯工具；Bash 指令寫檔不在規則內（Bash 指令本身會詢問）。`bypassPermissions` 模式下關卡無效，不要使用
- 每次交接都會重新讀取資料，token 用量高於單一 agent
- PM 沒有查詢時間的工具，`team-log.md` 的時間戳記為模型估計值，僅供排序參考

## 目錄結構

```
Personal-AI-DLC/
├── template/
│   ├── README.md                       範本說明
│   ├── agent-team/.claude/             協作交付團隊：agents/（PM + 5 角色）、aidlc-team/protocol.md
│   └── skill/.claude/                  規則庫：skills/aidlc-v1/（SKILL.md、rule-details/、UPSTREAM.md）、settings.json（權限關卡）
├── scripts/
│   └── apply-template.sh               把團隊套用到專案
├── INSTALL.md                          安裝、重新安裝與使用方式
└── AGENTS.md / CLAUDE.md               AI agent 在此 repo 的工作規則
```

## Branch 規則

- `main`：只放確定採用的內容
- `trial/*`：試用專用；試用產生的 `aidlc-docs/`、根目錄 `.claude/` **不 merge 進 `main`**，試用結束刪除 branch 即可

## 慣例

- 文件、commit message 描述、PR 標題與內文使用**繁體中文**；技術名詞與識別字維持原文
- `EAC_Wiki` 一律唯讀（詳見 [`AGENTS.md`](AGENTS.md)）
- 不在本機放可部署的 AWS 憑證；部署只走 CI + OIDC

## 維護者

- [josh-giant](https://github.com/josh-giant)

## 參考

- [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows)：AI-DLC 官方實作（規則庫來源：v1.0.1）
- [AI-DLC Method Definition Paper](https://prod.d13rzhkk8cj2z0.amplifyapp.com/)：AI-DLC 方法論白皮書
- [`template/README.md`](template/README.md)：範本細節（角色工具、Personal Team 本地規則、權限關卡）
- [`UPSTREAM.md`](template/skill/.claude/skills/aidlc-v1/UPSTREAM.md)：規則庫的上游版本、授權與本地修改
