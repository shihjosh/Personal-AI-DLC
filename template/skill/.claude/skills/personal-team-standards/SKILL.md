---
name: personal-team-standards
description: >-
  Personal Team 規範（PTEAM-01～07）：部署只走 CI + OIDC、AWS 資源用 CDK、IAM 最小權限、機密不進 repo、破壞性與成本變更標示、自動化測試、EAC_Wiki 唯讀。Use when writing, reviewing, or planning any code, infrastructure, deployment, IAM, secrets or tests in Personal Team projects.
---

# Personal Team 規範（PTEAM-01～07）

> 所有 Personal Team 專案一律適用。AI-DLC 協作交付團隊的每個角色都會預先載入；平常用 Claude Code 開發時也會依描述自動套用。

## Overview

以下規則是團隊規範：AI-DLC 流程的每個階段，以及平常開發時，在產生設計文件、程式碼與完成交付前都要檢查適用的規則。

**Enforcement**：每個適用階段在顯示完成訊息前，必須確認符合本文件規則。

### Blocking Finding 行為

違反適用規則即為 **blocking finding**：

1. 在階段完成訊息中以「Personal Team 規範檢查」段落列出規則 ID 與說明
2. 未解決前不得提供「繼續下一階段（Continue to Next Stage）」選項，只能提供「要求修改（Request Changes）」並說明需要改什麼
3. 在 `aidlc-docs/audit.md` 記錄規則 ID、說明與階段

不適用的規則（例如專案沒有 AWS 資源時的 PTEAM-02）在檢查摘要標示 **N/A**，不算 blocking finding。

### 與專案規則的關係

- 專案根目錄的 `AGENTS.md` / `CLAUDE.md` 規則一併遵守
- 專案規則比本文件**更嚴格**時，以專案規則為準；專案規則較寬鬆時，仍以本文件為準

---

## Rule PTEAM-01：部署只走 CI + OIDC

**Rule**：任何部署到雲端環境的動作只能由 GitHub Actions 透過 OIDC 取得短期憑證執行。

**Verification**：
- 設計、計畫與 build-and-test 說明中，沒有要求在本機執行 `cdk deploy`、`sam deploy`、`aws cloudformation deploy` 等部署指令
- 不要求開發者在本機設定可部署的 AWS 憑證（`AWS_ACCESS_KEY_ID`、長期 access key 等）
- 需要部署時，產出或更新 GitHub Actions workflow，並使用 `aws-actions/configure-aws-credentials` 搭配 OIDC role

---

## Rule PTEAM-02：AWS 資源以 IaC（AWS CDK）管理

**Rule**：新增或修改 AWS 資源一律以 AWS CDK 定義；既有專案使用 CloudFormation 時沿用之。

**Verification**：
- 沒有「到 AWS Console 手動建立／修改」的步驟作為正式做法
- 網路、儲存、運算、資料庫、負載平衡等職責分到不同 stack 或 construct
- 資源命名或 stack 名稱可區分環境（dev / sit / prod）

---

## Rule PTEAM-03：IAM 最小權限

**Rule**：IAM policy 只授予完成工作所需的最小權限。

**Verification**：
- 沒有 `"Action": "*"`、`"Resource": "*"` 或 `AdministratorAccess`；確實需要時，在設計文件寫明理由
- 優先使用 CDK 的 `grant*()` 方法而非手寫寬鬆 policy

---

## Rule PTEAM-04：機密不進程式碼與 repo

**Rule**：密碼、API key、token、憑證等機密不得寫入程式碼、設定檔或 `aidlc-docs/`。

**Verification**：
- 機密由 AWS Secrets Manager 或 SSM Parameter Store 提供，或於 CI 以 GitHub Secrets 注入
- 範例設定檔只放佔位值（例如 `.env.example`），真實 `.env` 列入 `.gitignore`

---

## Rule PTEAM-05：破壞性與成本變更必須標示

**Rule**：會刪除或取代資源、造成停機、或增加費用的變更，必須明確標示。

**Verification**：
- 涉及 CDK 變更時，本機執行 `cdk synth` 與 CDK 測試（不需部署憑證）；`cdk diff` 由 CI 以 OIDC 唯讀角色在 PR 上執行並貼出結果，交付摘要提醒人員檢查 `[-]` 刪除與 replace 的資源
- 設計或完成訊息中列出受影響資源、停機風險與預估成本變化（無法估算時說明）
- 有資料遺失風險的變更（刪除資料庫、S3 bucket 等）提出備份或回滾方式

---

## Rule PTEAM-06：自動化測試

**Rule**：程式碼產生階段必須同時產出自動化測試，並沿用專案既有的測試框架與慣例。

**Verification**：
- 新增或修改的功能有對應的單元測試；API 有至少一個整合層級的測試（例如 Fastify 的 `app.inject()`）
- 測試框架、目錄結構依專案現況（例如既有的 Vitest / Jest），不自行引入新框架
- build-and-test 說明列出實際可執行的測試指令

---

## Rule PTEAM-07：EAC_Wiki 唯讀

**Rule**：任何路徑下的 `EAC_Wiki` 資料夾或 repo 只能讀取與搜尋。

**Verification**：
- 沒有在 `EAC_Wiki` 內建立、修改、搬移、刪除檔案，也沒有執行 `add`、`commit`、`checkout`、`fetch`、`pull`、`push` 等會改變狀態的 git 操作
- 需要其中內容時，複製到目前專案內再處理
