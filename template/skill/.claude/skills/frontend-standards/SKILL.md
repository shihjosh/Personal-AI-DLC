---
name: frontend-standards
description: >-
  前端規範（FE-01～08，Vue 2／Vue 3 為主）：防 XSS（v-html）、前端變數無機密與 token 處理、依 API 契約串接、載入／錯誤／空狀態、路由守衛、無障礙、不新增 Vue 2 專屬依賴、元件測試。Use when designing, implementing, or reviewing frontend code: Vue components, pages, router, Vuex/Pinia stores, API calls from the browser.
---

# 前端規範（FE-01～08，Vue 2／Vue 3）

> AI-DLC 流程中，專案偵測到前端時由各角色套用；平常用 Claude Code 開發前端時也會依描述自動套用。
> React 等其他框架：FE-02～06 的原則一樣適用，Vue 專屬的寫法（`v-html`、Vue Router、Vuex／Pinia、Vue 2 相容性）改用該框架的對應機制或標示 N/A。

## Overview

適用時（AI-DLC 流程中由各角色在自己負責的階段套用；平常開發時由 Claude 在撰寫或審查相關程式碼時套用）遵守本文件規則。違反適用規則即為 **blocking finding**（AI-DLC 流程中：列在完成訊息、不能進下一階段、記錄在 `audit.md`；平常開發時：修正後再交付）。不適用的規則標示 **N/A**。

---


## 版本判定

依 `package.json` 的 `vue` 版本判定 Vue 2（`^2`）或 Vue 3（`^3`）；monorepo 依各子專案判定。**沿用該子專案既有的寫法**，不在同一個專案混用兩種版本的模式。

| | Vue 2 | Vue 3 |
| --- | --- | --- |
| 元件寫法 | 沿用既有（Options API；Vue 2.7 可用 Composition API） | 沿用既有（`<script setup>`／Composition API 或 Options API） |
| 狀態管理 | 沿用既有（通常是 Vuex） | 沿用既有（Pinia 或 Vuex） |
| 元件測試 | `@vue/test-utils` v1 | `@vue/test-utils` v2 |
| 型別檢查 | `tsc` 或專案設定 | `vue-tsc --noEmit`（使用 TypeScript 時） |
| 建置 | 沿用既有（Vue CLI／webpack 等） | 沿用既有（通常是 Vite） |

---

## Rule FE-01：防止 XSS

**Rule**：不以 `v-html`、`innerHTML` 渲染未經淨化的內容；確實需要時使用淨化函式庫（例如 DOMPurify）並說明理由。

**Verification**：
- 新增的 `v-html` 都有淨化處理與註解說明
- 不以使用者輸入組成 URL 的 `javascript:` 或動態 script

## Rule FE-02：Token 與機密

**Rule**：前端程式碼與 `.env` 中的 `VITE_*`、`VUE_APP_*` 變數會公開到瀏覽器，不得放機密；存取 token 的存放方式沿用專案既有設計，不新增 `localStorage` 存放長效 token 的做法。

**Verification**：
- 沒有 API secret、私鑰等寫在前端
- token 處理變更標示為高風險

## Rule FE-03：依 API 契約串接

**Rule**：呼叫後端時依已核准的 API 契約（路由、request、response、錯誤碼），透過專案既有的 API client 呼叫，不散落各處直接用 `fetch`／`axios`。

**Verification**：
- 沒有使用契約外的欄位
- 4xx／5xx 有對應的處理與使用者提示

## Rule FE-04：載入、錯誤、空資料狀態

**Rule**：有非同步資料的畫面都處理載入中、錯誤、空資料三種狀態。

## Rule FE-05：路由與權限

**Rule**：需要登入或權限的頁面由路由守衛（router guard）或專案既有機制保護；前端隱藏不等於授權，後端仍須檢查。

**Verification**：
- 路由守衛變更標示為高風險

## Rule FE-06：基本無障礙

**Rule**：表單欄位有 label、圖片有 alt、互動元件可用鍵盤操作。

## Rule FE-07：不新增 Vue 2 專屬依賴

**Rule**：Vue 2 已停止官方維護；Vue 2 專案中不新增只支援 Vue 2 的套件（除非沒有替代方案並在設計中說明），以免增加日後升級成本。

## Rule FE-08：元件測試

**Rule**：專案已設定元件測試時（Vitest／Jest + `@vue/test-utils`），新增或修改的元件邏輯要有測試；沒有設定時不自行引入新框架，在交付摘要註明。
