---
name: aws-cdk-standards
description: >-
  AWS CDK 規範（CDK-01～08）：有狀態資源 RETAIN、logical ID 穩定、最小權限、安全群組、加密與存取記錄、環境不寫死、assertions 測試、cdk-nag suppression 需理由。Use when writing, reviewing, or planning AWS CDK / infrastructure-as-code: stacks, constructs, IAM policies, security groups, RDS/DynamoDB/S3 resources.
---

# AWS CDK 規範（CDK-01～08）

> AI-DLC 流程中，專案偵測到 AWS CDK 時由各角色套用；平常用 Claude Code 開發 CDK 時也會依描述自動套用。

## Overview

適用時（AI-DLC 流程中由各角色在自己負責的階段套用；平常開發時由 Claude 在撰寫或審查相關程式碼時套用）遵守本文件規則。違反適用規則即為 **blocking finding**（AI-DLC 流程中：列在完成訊息、不能進下一階段、記錄在 `audit.md`；平常開發時：修正後再交付）。不適用的規則標示 **N/A**。

---


## Rule CDK-01：有狀態資源保護

**Rule**：RDS、DynamoDB、S3、EFS、Cognito User Pool 等有狀態資源設定 `RemovalPolicy.RETAIN`（或 `SNAPSHOT`），並啟用備份或刪除保護。

**Verification**：
- 新增或修改的有狀態資源都有 `removalPolicy`
- 更動有狀態資源一律標示為高風險

## Rule CDK-02：Logical ID 穩定

**Rule**：不改名或搬移有狀態資源的 construct（會改變 logical ID 而導致資源被取代）；必要時使用 `overrideLogicalId` 並經人員核准。

**Verification**：
- `cdk synth` 前後比對沒有非預期的 logical ID 變動

## Rule CDK-03：最小權限

**Rule**：優先使用 `grant*()`；手寫 policy 不使用 `*`（同 PTEAM-03）。

## Rule CDK-04：網路

**Rule**：安全群組不開放 `0.0.0.0/0`，除非是已核准的公開入口（例如 ALB 的 443）。

## Rule CDK-05：加密與記錄

**Rule**：儲存資源啟用靜態加密；ALB、API Gateway、CloudFront 等入口啟用存取記錄。

## Rule CDK-06：環境不寫死

**Rule**：帳號、區域、資源名稱依環境由 context 或 props 傳入，不寫死在程式碼。

## Rule CDK-07：CDK 測試

**Rule**：新增或修改的 stack 有 assertions 測試（`Template.fromStack`）驗證關鍵資源與屬性；專案有 snapshot 測試時一併更新並說明差異。

## Rule CDK-08：cdk-nag

**Rule**：專案使用 `cdk-nag` 時，新增的 suppression 必須附理由並經審查者確認。
