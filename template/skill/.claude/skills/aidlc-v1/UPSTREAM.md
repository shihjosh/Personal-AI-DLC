# 上游來源

| 項目 | 值 |
| --- | --- |
| Repo | [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) |
| 版本 | `v1.0.1`（tag commit `e49341d`，2026-06-30） |
| 授權 | MIT No Attribution |
| `SKILL.md` 來源 | `aidlc-rules/aws-aidlc-rules/core-workflow.md` |
| `rule-details/` 來源 | `aidlc-rules/aws-aidlc-rule-details/`（31 個檔案，原文未修改）；另有 Personal Team 新增的 `extensions/personal-team/` |

## 本地修改

1. `SKILL.md` 開頭加上 Claude Code skill frontmatter：
   - `disable-model-invocation: true`：只有輸入 `/aidlc-v1` 才會啟動，不會在一般開發對話中自動接管
2. 「MANDATORY: Rule Details Loading」段落：原本依序檢查 `.aidlc-rule-details/`、`.kiro/` 等路徑，改為讀取本 skill 目錄下的 `rule-details/`
3. 結尾加上 `$ARGUMENTS`，讓 `/aidlc-v1 <需求>` 的內容直接帶入
4. 在主流程前加上「語言規則」：對話與 `aidlc-docs/` 文件一律使用繁體中文；`[Answer]:`、選項字母、核取方塊、檔名、`aidlc-state.md` 欄位與階段名稱、程式碼與識別字保持原樣

5. 在主流程前加上「擴充預設值」：Security、Resiliency、Property-Based Testing 一律預設啟用且不提問，使用者明確要求時才關閉
6. 新增 `rule-details/extensions/personal-team/team-standards/personal-team-standards.md`（PTEAM-01～07）：沒有 opt-in 檔，依上游擴充機制每次自動載入並強制套用
7. 範本另附 `template/skill/.claude/settings.json`：以 `permissions.ask` 讓寫入程式碼類檔案前一定要使用者確認（不屬於 Skill 本身，見 template/README.md）

## 限制

v1 是純 markdown 規則，「每個階段停下等核准」靠模型遵守，沒有 hook 強制、沒有核准後修改偵測；本 repo 以權限關卡（`settings.json`）補強程式碼寫入。

本 Skill 是協作交付團隊的規則庫，由 PM 與各角色讀取；`SKILL.md` 開頭的本地規則有修改時，要同步更新 `agent-team/.claude/aidlc-team/protocol.md`。

## 更新上游版本

```bash
git -C <aidlc-workflows clone> fetch --depth 1 origin tag v1.x.y
git -C <aidlc-workflows clone> diff v1.0.1 v1.x.y -- aidlc-rules/
```

比對後手動套用，並更新本檔的版本與修改紀錄。
