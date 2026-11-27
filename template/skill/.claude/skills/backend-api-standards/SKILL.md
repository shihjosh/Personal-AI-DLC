---
name: backend-api-standards
description: >-
  後端 API 規範（BE-01～08）：輸入驗證、安全的錯誤回應、授權與 IDOR、介面向後相容、參數化查詢與分頁、migration 可回滾、外部呼叫 timeout、API 整合測試。Use when designing, implementing, or reviewing backend HTTP APIs, routes, request/response schemas, database access or migrations (Fastify, Express, NestJS, Koa, FastAPI, Django, Flask).
---

# 後端 API 規範（BE-01～08）

> AI-DLC 流程中，專案偵測到後端 API 時由各角色套用；平常用 Claude Code 開發後端時也會依描述自動套用。

## Overview

適用時（AI-DLC 流程中由各角色在自己負責的階段套用；平常開發時由 Claude 在撰寫或審查相關程式碼時套用）遵守本文件規則。違反適用規則即為 **blocking finding**（AI-DLC 流程中：列在完成訊息、不能進下一階段、記錄在 `audit.md`；平常開發時：修正後再交付）。不適用的規則標示 **N/A**。

---


## Rule BE-01：所有路由都有輸入驗證

**Rule**：每個路由的 params、querystring、body 都以 schema 驗證（例如 Fastify route schema、zod、joi），不信任任何輸入。

**Verification**：
- 新增或修改的路由都有對應的 request schema
- 驗證失敗回 400，訊息不洩漏內部實作

## Rule BE-02：一致且安全的錯誤回應

**Rule**：錯誤回應格式與專案既有慣例一致，不回傳 stack trace、SQL、內部路徑或機密。

**Verification**：
- 404、400、401／403、500 都有明確處理
- 未預期錯誤統一由錯誤處理器轉成通用訊息，細節只寫入 log

## Rule BE-03：授權檢查

**Rule**：需要權限的路由在處理前完成認證與授權檢查，並檢查資源擁有權（避免 IDOR）。

**Verification**：
- 未登入回 401、權限不足回 403，並有對應測試
- 存取單一資源時確認該資源屬於呼叫者

## Rule BE-04：介面向後相容

**Rule**：已發佈的 API 不做破壞性變更；必要時以新版本路徑或新欄位提供。

**Verification**：
- 沒有移除或改名既有欄位、改變狀態碼或語意；有的話標示為高風險並經人員核准
- response schema 已更新且與實際回應一致

## Rule BE-05：資料存取安全與效率

**Rule**：使用參數化查詢；多筆寫入使用交易；列表 API 有分頁；避免 N+1 查詢。

**Verification**：
- 沒有以字串拼接組 SQL
- 列表查詢有 limit 上限

## Rule BE-06：Migration 可回滾

**Rule**：每個 schema 變更都有 migration，且可回滾（down）或寫明無法回滾的原因與備份方式；先部署 migration、再部署使用它的程式碼。

**Verification**：
- migration 檔與程式碼分屬不同單元
- 對既有資料的影響（預設值、回填、鎖表時間）已在設計中說明

## Rule BE-07：外部呼叫有 timeout 與錯誤處理

**Rule**：呼叫外部 API、資料庫、AWS 服務時設定 timeout，失敗時有明確處理，不無限重試。

## Rule BE-08：API 整合測試

**Rule**：每個新增或修改的路由都有實際打路由的整合測試（例如 Fastify `app.inject()`、supertest），涵蓋成功、驗證失敗、未授權、找不到。
