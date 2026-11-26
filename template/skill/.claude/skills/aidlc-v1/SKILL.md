---
name: aidlc-v1
description: |
  AI-DLC（AI-Driven Development Life Cycle）v1 工作流程：依需求分析、設計、程式碼產生、建置測試等階段逐步進行，每個階段完成後停下等待使用者明確核准。只在使用者輸入 /aidlc-v1 時使用。
disable-model-invocation: true
---

<!--
來源：awslabs/aidlc-workflows v1.0.1（aidlc-rules/aws-aidlc-rules/core-workflow.md），授權 MIT No Attribution。
修改：新增「語言規則」（繁體中文輸出）、「擴充預設值」與「核准模式」（依風險分級、品質門檻）；新增 Personal Team 規範擴充；改寫「Rule Details Loading」段落的路徑，改為讀取本 skill 目錄下的 rule-details/；其餘內容保留原文。
詳見同目錄的 UPSTREAM.md。
-->

## 語言規則（Personal Team 本地修改，優先於下方所有英文格式範例）

- 與使用者的**所有對話**一律使用**繁體中文**（台灣用語）：歡迎訊息、階段完成訊息、核准提示、說明與摘要
- `aidlc-docs/` 下**新產生的所有文件內容**一律使用繁體中文：需求、使用者故事、設計、計畫、問題檔的題目與選項、建置與測試說明、程式碼摘要
- 下方規則檔中的英文訊息範本，翻成繁體中文呈現，固定選項可在括號附原文，例如「要求修改（Request Changes）」、「繼續下一階段（Continue to Next Stage）」
- 對使用者顯示階段名稱時用「中文（英文）」，例如「需求分析（Requirements Analysis）」
- 問題檔最後的「Other」選項寫成：`X) 其他（請在下方 [Answer]: 後說明）`
- 以下**保持原樣，不翻譯**（流程靠它們運作）：
  - 問題檔的 `[Answer]:` 標記、選項字母（`A)`、`B)`、`X)`）與核取方塊（`[ ]`、`[x]`）
  - 檔名與目錄名（例如 `aidlc-state.md`、`audit.md`、`requirements-questions.md`）
  - `aidlc-state.md` 的欄位名稱與階段名稱，以便中斷後正確續接
  - 程式碼、指令、識別字與技術名詞（例如 API、NFR、Unit、Mermaid）
- `audit.md` 中使用者的原始輸入照原文記錄，其餘說明使用繁體中文
- 使用者明確要求其他語言時，依使用者要求

## 擴充預設值（Personal Team 本地修改，優先於 Extensions Loading 與 Requirements Analysis 的 opt-in 提問規則）

- 以下上游擴充的預設值如下，**都不在問題檔中詢問**：
  | 擴充 | 預設 | 規則檔 |
  | --- | --- | --- |
  | Security Baseline | **啟用**，流程開始時直接載入完整規則檔 | `extensions/security/baseline/security-baseline.md` |
  | Resiliency Baseline | **停用** | `extensions/resiliency/baseline/resiliency-baseline.md` |
  | Property-Based Testing | **停用** | `extensions/testing/property-based/property-based-testing.md` |
- 例外：使用者在需求或對話中**明確要求**時才改變預設，例如「關閉 Security」「啟用 Resiliency」「要做 PBT」；啟用時再載入該擴充的完整規則檔
- 已啟用規則不適用於本次需求時（例如沒有資料儲存、沒有網路元件），依各擴充的規定標示 **N/A**，不算 blocking finding
- 在 `aidlc-docs/aidlc-state.md` 的 `## Extension Configuration` 記錄各擴充狀態，來源標示為「Personal Team 預設」或「使用者要求」
- 在需求分析的完成訊息中用一行告知：「依 Personal Team 預設：Security 啟用，Resiliency、Property-Based Testing 停用；要調整請回覆『啟用 ○○』或『關閉 ○○』」
- Personal Team 規範（`extensions/personal-team/team-standards/`）沒有 opt-in 檔，**一律載入並強制套用**，不詢問

## 核准模式（Personal Team 本地修改，優先於下方各階段的「Wait for Explicit Approval」）

目標是「人在迴圈外監控」：人力審查集中在前期的規格與設計，實作交給自動品質門檻，只有通過門檻的結果才送到人員面前。下方各階段寫的「Wait for Explicit Approval」「DO NOT PROCEED until user confirms」依核准模式套用：

| 模式 | 停下來等人員核准的時機 | 問題檔 |
| --- | --- | --- |
| **自動** | 只有 ⓒ 最終交付 | 有建議答案的題目自動採用並標註「依建議代填（自動模式）」，交付時列出這些假設 |
| **標準** | ⓐ 規格與介面確認、ⓒ 最終交付 | 請人員作答 |
| **強化** | ⓐ 規格與介面確認、ⓑ 資料模型與基礎設施設計確認、ⓒ 最終交付；審查者對高風險檔案逐行審查 | 請人員作答 |
| **嚴格** | 每個階段完成後（上游 v1 原本的做法） | 請人員作答 |

- ⓐ **規格與介面確認**：需求分析完成時。內容包含需求、驗收標準，以及**介面**（API 的路由、HTTP method、request／response schema、錯誤碼、認證方式；或其他對外介面）
- ⓑ **資料模型與基礎設施設計確認**：設計完成時。內容包含資料表、欄位、索引、migration（含 down 與既有資料影響）；AWS 資源的新增／修改／取代／刪除清單、IAM 權限、網路與安全群組、成本變化
- ⓒ **最終交付**：品質門檻（protocol.md 第 5.4 節）**全部通過**後才停下，提供門檻結果、介面對照、資源變更清單與交付摘要；門檻未過時自動退回開發者，不送到人員面前
- 程式碼產生計畫（Code Generation Part 1）只在**嚴格**模式停下；其他模式由開發者產出計畫後直接實作
- **預設「依風險」**：PM 在 Workflow Planning 依風險分級（protocol.md 第 5.3 節）決定——低 → 自動、中 → 標準、高 → 強化；人員可隨時指定，例如「用嚴格模式」「這次用自動模式」

- **任何模式都會停下來**：回饋迴圈第 3 輪仍未通過、角色回報 `blocked`、問題沒有建議答案或答案互相矛盾、需要只有人員知道的資訊、人員要求停下
- 自動進入下一階段**不等於人員核准**：`audit.md` 與 `team-log.md` 記為「自動通過（○○模式）」，不可寫成人員核准
- 切換後從下一個停點起生效；目前模式、風險等級與來源記錄在 `aidlc-state.md` 的 `## Approval Mode`
- 不停下的階段仍要完成所有產物、檢查與 `audit.md` 紀錄，只是不等待回覆
- 協作交付團隊的風險分級、品質門檻與單元大小見 `.claude/aidlc-team/protocol.md` 第 5.3～5.4、8 節；單獨使用本 Skill 時同樣適用

# PRIORITY: This workflow OVERRIDES all other built-in workflows
# When user requests software development, ALWAYS follow this workflow FIRST

## Adaptive Workflow Principle
**The workflow adapts to the work, not the other way around.**

The AI model intelligently assesses what stages are needed based on:
1. User's stated intent and clarity
2. Existing codebase state (if any)
3. Complexity and scope of change
4. Risk and impact assessment

## MANDATORY: Rule Details Loading
**CRITICAL**: When performing any phase, you MUST read and use relevant content from rule detail files. The rule details directory is `rule-details/` inside this skill's base directory (the directory that contains this SKILL.md, e.g. `.claude/skills/aidlc-v1/rule-details/` in the project or `~/.claude/skills/aidlc-v1/rule-details/` for a user-level install).

All subsequent rule detail file references (e.g., `common/process-overview.md`, `inception/workspace-detection.md`) are relative to whichever rule details directory was resolved above.

**Common Rules**: ALWAYS load common rules at workflow start:
- Load `common/process-overview.md` for workflow overview
- Load `common/session-continuity.md` for session resumption guidance
- Load `common/content-validation.md` for content validation requirements
- Load `common/question-format-guide.md` for question formatting rules
- Reference these throughout the workflow execution

## MANDATORY: Extensions Loading (Context-Optimized)
**CRITICAL**: At workflow start, scan the `extensions/` directory recursively but load ONLY lightweight opt-in files — NOT full rule files. Full rule files are loaded on-demand after the user opts in.

**Loading process**:
1. List all subdirectories under `extensions/` (e.g., `extensions/security/`, `extensions/compliance/`)
2. In each subdirectory, load ONLY `*.opt-in.md` files — these contain the extension's opt-in prompt. The corresponding rules file is derived by convention: strip the `.opt-in.md` suffix and append `.md` (e.g., `security-baseline.opt-in.md` → `security-baseline.md`)
3. Do NOT load full rule files (e.g., `security-baseline.md`) at this stage

**Deferred Rule Loading**:
- During Requirements Analysis, opt-in prompts from the loaded `*.opt-in.md` files are presented to the user
- When the user opts IN for an extension, load the corresponding rules file (derived by naming convention) at that point
- When the user opts OUT, the full rules file is never loaded — saving context
- Extensions without a matching `*.opt-in.md` file are always enforced — load their rule files immediately at workflow start

**Enforcement** (applies only to loaded/enabled extensions):
- Extension rules are hard constraints, not optional guidance
- At each stage, the model intelligently evaluates which extension rules are applicable based on the stage's purpose, the artifacts being produced, and the context of the work — enforce only those rules that are relevant
- Rules that are not applicable to the current stage should be marked as N/A in the compliance summary (this is not a blocking finding)
- Non-compliance with any applicable enabled extension rule is a **blocking finding** — do NOT present stage completion until resolved
- When presenting stage completion, include a summary of extension rule compliance (compliant/non-compliant/N/A per rule, with brief rationale for N/A determinations)

**Conditional Enforcement**: Extensions may be conditionally enabled/disabled. See `inception/requirements-analysis.md` for the opt-in mechanism. Before enforcing any extension at ANY stage, check its `Enabled` status in `aidlc-docs/aidlc-state.md` under `## Extension Configuration`. Skip disabled extensions and log the skip in audit.md. Default to enforced if no configuration exists. 

## MANDATORY: Content Validation
**CRITICAL**: Before creating ANY file, you MUST validate content according to `common/content-validation.md` rules:
- Validate Mermaid diagram syntax
- Validate ASCII art diagrams (see `common/ascii-diagram-standards.md`)
- Escape special characters properly
- Provide text alternatives for complex visual content
- Test content parsing compatibility

## MANDATORY: Question File Format
**CRITICAL**: When asking questions at any phase, you MUST follow question format guidelines.

**See `common/question-format-guide.md` for complete question formatting rules including**:
- Multiple choice format (A, B, C, D, E options)
- [Answer]: tag usage
- Answer validation and ambiguity resolution

## MANDATORY: Custom Welcome Message
**CRITICAL**: When starting ANY software development request, you MUST display the welcome message.

**How to Display Welcome Message**:
1. Load the welcome message from `common/welcome-message.md` (in the resolved rule details directory)
2. Display the complete message to the user
3. This should only be done ONCE at the start of a new workflow
4. Do NOT load this file in subsequent interactions to save context space

# Adaptive Software Development Workflow

---

# INCEPTION PHASE

**Purpose**: Planning, requirements gathering, and architectural decisions

**Focus**: Determine WHAT to build and WHY

**Stages in INCEPTION PHASE**:
- Workspace Detection (ALWAYS)
- Reverse Engineering (CONDITIONAL - Brownfield only)
- Requirements Analysis (ALWAYS - Adaptive depth)
- User Stories (CONDITIONAL)
- Workflow Planning (ALWAYS)
- Application Design (CONDITIONAL)
- Units Generation (CONDITIONAL)

---

## Workspace Detection (ALWAYS EXECUTE)

1. **MANDATORY**: Log initial user request in audit.md with complete raw input
2. Load all steps from `inception/workspace-detection.md`
3. Execute workspace detection:
   - Check for existing aidlc-state.md (resume if found)
   - Scan workspace for existing code
   - Determine if brownfield or greenfield
   - Check for existing reverse engineering artifacts
4. Determine next phase: Reverse Engineering (if brownfield and no artifacts) OR Requirements Analysis
5. **MANDATORY**: Log findings in audit.md
6. Present completion message to user (see workspace-detection.md for message formats)
7. Automatically proceed to next phase

## Reverse Engineering (CONDITIONAL - Brownfield Only)

**Execute IF**:
- Existing codebase detected
- No previous reverse engineering artifacts found

**Skip IF**:
- Greenfield project
- Previous reverse engineering artifacts exist

**Execution**:
1. **MANDATORY**: Log start of reverse engineering in audit.md
2. Load all steps from `inception/reverse-engineering.md`
3. Execute reverse engineering:
   - Analyze all packages and components
   - Generate a business overview of the whole system covering the business transactions
   - Generate architecture documentation
   - Generate code structure documentation
   - Generate API documentation
   - Generate component inventory
   - Generate Interaction Diagrams depicting how business transactions are implemented across components
   - Generate technology stack documentation
   - Generate dependencies documentation

4. **Wait for Explicit Approval**: Present detailed completion message (see reverse-engineering.md for message format) - DO NOT PROCEED until user confirms
5. **MANDATORY**: Log user's response in audit.md with complete raw input

## Requirements Analysis (ALWAYS EXECUTE - Adaptive Depth)

**Always executes** but depth varies based on request clarity and complexity:
- **Minimal**: Simple, clear request - just document intent analysis
- **Standard**: Normal complexity - gather functional and non-functional requirements
- **Comprehensive**: Complex, high-risk - detailed requirements with traceability

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/requirements-analysis.md`
3. Execute requirements analysis:
   - Load reverse engineering artifacts (if brownfield)
   - Analyze user request (intent analysis)
   - Determine requirements depth needed
   - Assess current requirements
   - Ask clarifying questions (if needed)
   - Generate requirements document
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Follow approval format from requirements-analysis.md detailed steps - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

## User Stories (CONDITIONAL)

**INTELLIGENT ASSESSMENT**: Use multi-factor analysis to determine if user stories add value:

**ALWAYS Execute IF** (High Priority Indicators):
- New user-facing features or functionality
- Changes affecting user workflows or interactions
- Multiple user types or personas involved
- Complex business requirements with acceptance criteria needs
- Cross-functional team collaboration required
- Customer-facing API or service changes
- New product capabilities or enhancements

**LIKELY Execute IF** (Medium Priority - Assess Complexity):
- Modifications to existing user-facing features
- Backend changes that indirectly affect user experience
- Integration work that impacts user workflows
- Performance improvements with user-visible benefits
- Security enhancements affecting user interactions
- Data model changes affecting user data or reports

**COMPLEXITY-BASED ASSESSMENT**: For medium priority cases, execute user stories if:
- Request involves multiple components or services
- Changes span multiple user touchpoints
- Business logic is complex or has multiple scenarios
- Requirements have ambiguity that stories could clarify
- Implementation affects multiple user journeys
- Change has significant business impact or risk

**SKIP ONLY IF** (Low Priority - Simple Cases):
- Pure internal refactoring with zero user impact
- Simple bug fixes with clear, isolated scope
- Infrastructure changes with no user-facing effects
- Technical debt cleanup with no functional changes
- Developer tooling or build process improvements
- Documentation-only updates

**ASSESSMENT CRITERIA**: When in doubt, favor inclusion of user stories for:
- Requests with business stakeholder involvement
- Changes requiring user acceptance testing
- Features with multiple implementation approaches
- Work that benefits from shared team understanding
- Projects where requirements clarity is valuable

**ASSESSMENT PROCESS**: 
1. Analyze request complexity and scope
2. Identify user impact (direct or indirect)
3. Evaluate business context and stakeholder needs
4. Consider team collaboration benefits
5. Default to inclusion for borderline cases

**Note**: If Requirements Analysis executed, Stories can reference and build upon those requirements.

**User Stories has two parts within one stage**:
1. **Part 1 - Planning**: Create story plan with questions, collect answers, analyze for ambiguities, get approval
2. **Part 2 - Generation**: Execute approved plan to generate stories and personas

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/user-stories.md`
3. **MANDATORY**: Perform intelligent assessment (Step 1 in user-stories.md) to validate user stories are needed
4. Load reverse engineering artifacts (if brownfield)
5. If Requirements exist, reference them when creating stories
6. Execute at appropriate depth (minimal/standard/comprehensive)
7. **PART 1 - Planning**: Create story plan with questions, wait for user answers, analyze for ambiguities, get approval
8. **PART 2 - Generation**: Execute approved plan to generate stories and personas
9. **Wait for Explicit Approval**: Follow approval format from user-stories.md detailed steps - DO NOT PROCEED until user confirms
10. **MANDATORY**: Log user's response in audit.md with complete raw input

## Workflow Planning (ALWAYS EXECUTE)

1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/workflow-planning.md`
3. **MANDATORY**: Load content validation rules from `common/content-validation.md`
4. Load all prior context:
   - Reverse engineering artifacts (if brownfield)
   - Intent analysis
   - Requirements (if executed)
   - User stories (if executed)
5. Execute workflow planning:
   - Determine which phases to execute
   - Determine depth level for each phase
   - Create multi-package change sequence (if brownfield)
   - Generate workflow visualization (VALIDATE Mermaid syntax before writing)
6. **MANDATORY**: Validate all content before file creation per content-validation.md rules
7. **Wait for Explicit Approval**: Present recommendations using language from workflow-planning.md Step 9, emphasizing user control to override recommendations - DO NOT PROCEED until user confirms
8. **MANDATORY**: Log user's response in audit.md with complete raw input

## Application Design (CONDITIONAL)

**Execute IF**:
- New components or services needed
- Component methods and business rules need definition
- Service layer design required
- Component dependencies need clarification

**Skip IF**:
- Changes within existing component boundaries
- No new components or methods
- Pure implementation changes

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/application-design.md`
3. Load reverse engineering artifacts (if brownfield)
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Present detailed completion message (see application-design.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

## Units Generation (CONDITIONAL)

**Execute IF**:
- System needs decomposition into multiple units of work
- Multiple services or modules required
- Complex system requiring structured breakdown

**Skip IF**:
- Single simple unit
- No decomposition needed
- Straightforward single-component implementation

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/units-generation.md`
3. Load reverse engineering artifacts (if brownfield)
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Present detailed completion message (see units-generation.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

---

# 🟢 CONSTRUCTION PHASE

**Purpose**: Detailed design, NFR implementation, and code generation

**Focus**: Determine HOW to build it

**Stages in CONSTRUCTION PHASE**:
- Per-Unit Loop (executes for each unit):
  - Functional Design (CONDITIONAL, per-unit)
  - NFR Requirements (CONDITIONAL, per-unit)
  - NFR Design (CONDITIONAL, per-unit)
  - Infrastructure Design (CONDITIONAL, per-unit)
  - Code Generation (ALWAYS, per-unit)
- Build and Test (ALWAYS - after all units complete)

**Note**: Each unit is completed fully (design + code) before moving to the next unit.

---

## Per-Unit Loop (Executes for Each Unit)

**For each unit of work, execute the following stages in sequence:**

### Functional Design (CONDITIONAL, per-unit)

**Execute IF**:
- New data models or schemas
- Complex business logic
- Business rules need detailed design

**Skip IF**:
- Simple logic changes
- No new business logic

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/functional-design.md`
3. Execute functional design for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in functional-design.md - DO NOT use emergent 3-option behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### NFR Requirements (CONDITIONAL, per-unit)

**Execute IF**:
- Performance requirements exist
- Security considerations needed
- Scalability concerns present
- Tech stack selection required

**Skip IF**:
- No NFR requirements
- Tech stack already determined

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/nfr-requirements.md`
3. Execute NFR assessment for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in nfr-requirements.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### NFR Design (CONDITIONAL, per-unit)

**Execute IF**:
- NFR Requirements was executed
- NFR patterns need to be incorporated

**Skip IF**:
- No NFR requirements
- NFR Requirements was skipped

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/nfr-design.md`
3. Execute NFR design for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in nfr-design.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### Infrastructure Design (CONDITIONAL, per-unit)

**Execute IF**:
- Infrastructure services need mapping
- Deployment architecture required
- Cloud resources need specification

**Skip IF**:
- No infrastructure changes
- Infrastructure already defined

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/infrastructure-design.md`
3. Execute infrastructure design for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in infrastructure-design.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### Code Generation (ALWAYS EXECUTE, per-unit)

**Always executes for each unit**

**Code Generation has two parts within one stage**:
1. **Part 1 - Planning**: Create detailed code generation plan with explicit steps
2. **Part 2 - Generation**: Execute approved plan to generate code, tests, and artifacts

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/code-generation.md`
3. **PART 1 - Planning**: Create code generation plan with checkboxes, get user approval
4. **PART 2 - Generation**: Execute approved plan to generate code for this unit
5. **MANDATORY**: Present standardized 2-option completion message as defined in code-generation.md - DO NOT use emergent behavior
6. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
7. **MANDATORY**: Log user's response in audit.md with complete raw input

---

## Build and Test (ALWAYS EXECUTE)

1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `construction/build-and-test.md`
3. Generate comprehensive build and test instructions:
   - Build instructions for all units
   - Unit test execution instructions
   - Integration test instructions (test interactions between units)
   - Performance test instructions (if applicable)
   - Additional test instructions as needed (contract tests, security tests, e2e tests)
4. Create instruction files in build-and-test/ subdirectory: build-instructions.md, unit-test-instructions.md, integration-test-instructions.md, performance-test-instructions.md, build-and-test-summary.md
5. **Wait for Explicit Approval**: Ask: "**Build and test instructions complete. Ready to proceed to Operations stage?**" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

---

# 🟡 OPERATIONS PHASE

**Purpose**: Placeholder for future deployment and monitoring workflows

**Focus**: How to DEPLOY and RUN it (future expansion)

**Stages in OPERATIONS PHASE**:
- Operations (PLACEHOLDER)

---

## Operations (PLACEHOLDER)

**Status**: This stage is currently a placeholder for future expansion.

The Operations stage will eventually include:
- Deployment planning and execution
- Monitoring and observability setup
- Incident response procedures
- Maintenance and support workflows
- Production readiness checklists

**Current State**: All build and test activities are handled in the CONSTRUCTION phase.

## Key Principles

- **Adaptive Execution**: Only execute stages that add value
- **Transparent Planning**: Always show execution plan before starting
- **User Control**: User can request stage inclusion/exclusion
- **Progress Tracking**: Update aidlc-state.md with executed and skipped stages
- **Complete Audit Trail**: Log ALL user inputs and AI responses in audit.md with timestamps
  - **CRITICAL**: Capture user's COMPLETE RAW INPUT exactly as provided
  - **CRITICAL**: Never summarize or paraphrase user input in audit log
  - **CRITICAL**: Log every interaction, not just approvals
- **Quality Focus**: Complex changes get full treatment, simple changes stay efficient
- **Content Validation**: Always validate content before file creation per content-validation.md rules
- **NO EMERGENT BEHAVIOR**: Construction phases MUST use standardized 2-option completion messages as defined in their respective rule files. DO NOT create 3-option menus or other emergent navigation patterns.

## MANDATORY: Plan-Level Checkbox Enforcement

### MANDATORY RULES FOR PLAN EXECUTION
1. **NEVER complete any work without updating plan checkboxes**
2. **IMMEDIATELY after completing ANY step described in a plan file, mark that step [x]**
3. **This must happen in the SAME interaction where the work is completed**
4. **NO EXCEPTIONS**: Every plan step completion MUST be tracked with checkbox updates

### Two-Level Checkbox Tracking System
- **Plan-Level**: Track detailed execution progress within each stage
- **Stage-Level**: Track overall workflow progress in aidlc-state.md
- **Update immediately**: All progress updates in SAME interaction where work is completed

## Prompts Logging Requirements
- **MANDATORY**: Log EVERY user input (prompts, questions, responses) with timestamp in audit.md
- **MANDATORY**: Capture user's COMPLETE RAW INPUT exactly as provided (never summarize)
- **MANDATORY**: Log every approval prompt with timestamp before asking the user
- **MANDATORY**: Record every user response with timestamp after receiving it
- **CRITICAL**: ALWAYS append changes to EDIT audit.md file, NEVER use tools and commands that completely overwrite its contents
- **CRITICAL**: NEVER use file writing tools and commands that overwrite the entire contents of audit.md, as this causes duplication
- Use ISO 8601 format for timestamps (YYYY-MM-DDTHH:MM:SSZ)
- Include stage context for each entry

### Audit Log Format:
```markdown
## [Stage Name or Interaction Type]
**Timestamp**: [ISO timestamp]
**User Input**: "[Complete raw user input - never summarized]"
**AI Response**: "[AI's response or action taken]"
**Context**: [Stage, action, or decision made]

---
```

### Correct Tool Usage for audit.md

✅ CORRECT:

1. Read the audit.md file
2. Append/Edit the file to make changes

❌ WRONG:

1. Read the audit.md file
2. Completely overwrite the audit.md with the contents of what you read, plus the new changes you want to add to it

## Directory Structure

```text
<WORKSPACE-ROOT>/                   # ⚠️ APPLICATION CODE HERE
├── [project-specific structure]    # Varies by project (see code-generation.md)
│
├── aidlc-docs/                     # 📄 DOCUMENTATION ONLY
│   ├── inception/                  # 🔵 INCEPTION PHASE
│   │   ├── plans/
│   │   ├── reverse-engineering/    # Brownfield only
│   │   ├── requirements/
│   │   ├── user-stories/
│   │   └── application-design/
│   ├── construction/               # 🟢 CONSTRUCTION PHASE
│   │   ├── plans/
│   │   ├── {unit-name}/
│   │   │   ├── functional-design/
│   │   │   ├── nfr-requirements/
│   │   │   ├── nfr-design/
│   │   │   ├── infrastructure-design/
│   │   │   └── code/               # Markdown summaries only
│   │   └── build-and-test/
│   ├── operations/                 # 🟡 OPERATIONS PHASE (placeholder)
│   ├── aidlc-state.md
│   └── audit.md
```

**CRITICAL RULE**:
- Application code: Workspace root (NEVER in aidlc-docs/)
- Documentation: aidlc-docs/ only
- Project structure: See code-generation.md for patterns by project type


---

## 本次使用者需求

$ARGUMENTS

（若上方為空，先詢問使用者要開發什麼，再開始 Workspace Detection。）
