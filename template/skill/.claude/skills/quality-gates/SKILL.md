---
name: quality-gates
description: >-
  偵測專案的技術模組（後端 API／前端 Vue 2、3／AWS CDK，支援 monorepo），並依專案設定自動執行品質門檻（test、lint、typecheck、build、vue-tsc、npm audit、cdk synth、gitleaks）。Use when checking which tech stack a project uses, or when asked to run tests, lint, type checks, security audit or quality gates before delivery or a PR.
---

# 品質門檻與技術模組偵測

兩個腳本都只讀取專案、執行專案已設定的工具：**不安裝套件、不修改檔案、不部署**。Windows 在 Git Bash 執行。

在專案根目錄以 `bash .claude/skills/quality-gates/scripts/<腳本> .` 呼叫（使用者層級安裝時為 `~/.claude/skills/...`）；範本的 `settings.json` 已允許這個寫法免確認。

## 偵測技術模組

```bash
bash <本 skill 目錄>/scripts/detect-modules.sh [專案根目錄]
```

輸出 Markdown 表（模組、子目錄、細節，例如「前端 `apps/admin` Vue 2（Vuex）」）。偵測依據：

| 模組 | 依據 |
| --- | --- |
| 後端 API | `package.json` 依賴 `fastify`、`express`、`@nestjs/core`、`koa`、`hono`；Python `fastapi`、`django`、`flask` |
| 前端 | 依賴 `vue`（依版本判定 2／3，並列出 Vuex、Pinia、Vite、vue-tsc）、`next`、`nuxt`、`react`、`svelte`、`@angular/core` |
| AWS CDK | `cdk.json` 或依賴 `aws-cdk-lib` |

對應規範 Skill：後端 `backend-api-standards`、前端 `frontend-standards`、CDK `aws-cdk-standards`；所有專案都適用 `personal-team-standards`。

## 執行品質門檻

```bash
bash <本 skill 目錄>/scripts/run-quality-gates.sh [專案根目錄]
```

對每個含 `package.json` 的子專案：

| 門檻 | 規則 |
| --- | --- |
| `test`、`lint`、`typecheck`、`build` | 有對應 npm script 才執行，否則 N/A |
| 型別檢查 | 沒有 `typecheck` script 但有 `tsconfig.json` 時，執行 `vue-tsc --noEmit`（有 vue-tsc）或 `tsc --noEmit` |
| `npm audit --audit-level=high` | 有 `package-lock.json` 時 |
| `cdk synth --quiet` | 有 `cdk.json` 時。腳本會標 FAIL；看 log 若是需要 AWS 查詢或憑證造成的失敗，由呼叫端改判 N/A（環境限制）並註明，不設定憑證 |
| 機密掃描 | 有安裝 `gitleaks` 時；沒有時腳本標 N/A，由呼叫端（QA 或 Claude）以 Grep 檢查常見金鑰格式 |

- 輸出結果表（PASS／**FAIL**／N/A）與完整 log 路徑；任一 FAIL 時 exit code 為 1
- `node_modules` 不存在時整個子專案標 N/A，請先 `npm ci`
- 腳本沒涵蓋的檢查（例如 API 契約比對、逐條驗收標準）仍需另外驗證
