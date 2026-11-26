# 安裝與重新安裝

把 AI-DLC 協作交付團隊裝進你的專案。**不需要安裝任何程式**，只是把範本檔案複製到專案的 `.claude/` 資料夾。

- 需要：已安裝並登入的 [Claude Code](https://code.claude.com/)、Git
- 以下指令都在**專案目錄裡**執行（先 `cd` 到你的專案）
- 範本下載一次即可：Windows 放在 `C:\src\Personal-AI-DLC`，Ubuntu 放在 `~/work/Personal-AI-DLC`

---

## Windows（在專案目錄執行）

Windows 有兩種終端機，**指令不能混用**：

| 終端機 | 怎麼分辨 | 用哪一段 |
| --- | --- | --- |
| **Git Bash** | 提示字元是 `$`，路徑像 `/c/Users/...` | [Git Bash](#git-bash) |
| **PowerShell** | 提示字元是 `PS C:\...>` | [PowerShell](#powershell) |

> [!warning] 在 Git Bash 執行 `robocopy` 會失敗
> Git Bash 會把 `\` 吃掉、把 `/E` 轉成 `E:/`，出現「錯誤 : 無效的參數 #3 : "E:/"」。在 Git Bash 請改用下方的 `apply-template.sh`。

### Git Bash

```bash
# 首次安裝（範本只需下載一次；已下載過就改用 git -C /c/src/Personal-AI-DLC pull）
git clone https://github.com/josh-giant/Personal-AI-DLC.git /c/src/Personal-AI-DLC
/c/src/Personal-AI-DLC/scripts/apply-template.sh .

# 重新安裝／更新到最新版
git -C /c/src/Personal-AI-DLC switch main && git -C /c/src/Personal-AI-DLC pull
rm -rf .claude/agents .claude/aidlc-team .claude/skills/aidlc-v1
[ -d aidlc-docs ] && mv aidlc-docs aidlc-docs.bak   # 選擇性：備份舊的工作紀錄
/c/src/Personal-AI-DLC/scripts/apply-template.sh .

# 啟動
CLAUDE_CODE_FORK_SUBAGENT=0 claude --agent pm
```

舊版裝在使用者層級的 Skill：`rm -rf ~/.claude/skills/aidlc-v1`

### PowerShell


#### 首次安裝

```powershell
# 1. 下載範本（只需做一次；已下載過就改用 git -C C:\src\Personal-AI-DLC pull）
git clone https://github.com/josh-giant/Personal-AI-DLC.git C:\src\Personal-AI-DLC

# 2. 複製範本到目前的專案（只補上缺少的檔案，不覆蓋專案既有的檔案）
robocopy C:\src\Personal-AI-DLC\template\skill      . /E /XC /XN /XO /NFL /NDL /NJH /NJS
robocopy C:\src\Personal-AI-DLC\template\agent-team . /E /XC /XN /XO /NFL /NDL /NJH /NJS

# 3. 確認：應該看到 agents、aidlc-team、settings.json、skills
Get-ChildItem .claude
```

> 專案原本就有 `.claude\settings.json` 時不會被覆蓋，請手動把 `C:\src\Personal-AI-DLC\template\skill\.claude\settings.json` 的 `permissions.ask` 清單合併進去。

#### 重新安裝／更新到最新版

```powershell
# 1. 更新範本
git -C C:\src\Personal-AI-DLC checkout main
git -C C:\src\Personal-AI-DLC pull

# 2. 移除專案裡的舊版（settings.json 保留）
Remove-Item -Recurse -Force .claude\agents, .claude\aidlc-team, .claude\skills\aidlc-v1 -ErrorAction SilentlyContinue

# 3. （選擇性）舊的工作紀錄改名備份，否則 PM 會從舊紀錄接續
if (Test-Path aidlc-docs) { Rename-Item aidlc-docs aidlc-docs.bak }

# 4. 重新複製
robocopy C:\src\Personal-AI-DLC\template\skill      . /E /XC /XN /XO /NFL /NDL /NJH /NJS
robocopy C:\src\Personal-AI-DLC\template\agent-team . /E /XC /XN /XO /NFL /NDL /NJH /NJS
```

> 曾照舊版說明把 Skill 裝在使用者層級的，請一併移除，避免出現兩個同名 Skill：
> `Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\aidlc-v1" -ErrorAction SilentlyContinue`

#### 啟動

```powershell
$env:CLAUDE_CODE_FORK_SUBAGENT = "0"; claude --agent pm
```

---

## Ubuntu（在專案目錄執行）

### 首次安裝

```bash
# 下載範本（只需做一次；已下載過就改用 git -C ~/work/Personal-AI-DLC pull）
git clone https://github.com/josh-giant/Personal-AI-DLC.git ~/work/Personal-AI-DLC

# 套用到目前的專案
~/work/Personal-AI-DLC/scripts/apply-template.sh .
```

### 重新安裝／更新到最新版

```bash
git -C ~/work/Personal-AI-DLC switch main && git -C ~/work/Personal-AI-DLC pull
rm -rf .claude/agents .claude/aidlc-team .claude/skills/aidlc-v1
[ -d aidlc-docs ] && mv aidlc-docs aidlc-docs.bak   # 選擇性：備份舊的工作紀錄
~/work/Personal-AI-DLC/scripts/apply-template.sh .
```

舊版裝在使用者層級的 Skill：`rm -rf ~/.claude/skills/aidlc-v1`

### 啟動

```bash
CLAUDE_CODE_FORK_SUBAGENT=0 claude --agent pm
```

---

## 啟動後怎麼用

完整的可用指令與設定（核准模式、風險等級、擴充規則、TDD 等）見 [操作提示詞速查表](template/agent-team/.claude/aidlc-team/prompts.md)；套用到專案後也在 `.claude/aidlc-team/prompts.md`，或直接問 PM「有哪些指令」。

輸入需求，例如「建立一個 hello.js，執行後印出 Hello」。

| 情況 | 你要做的 |
| --- | --- |
| PM 請你回答問題 | 打開它說的問題檔，在每題 `[Answer]:` 後填選項字母，存檔後回覆「完成」 |
| 階段完成、停下等核准 | 沒問題回「繼續」；要修改就直接說明 |
| 想知道做到哪 | 問「進度？」 |
| 覺得停下來太多／太少 | PM 會依風險自動選模式（低風險只在最終交付停）；要覆寫就說「用自動模式」「用標準模式」「用強化模式」或「用嚴格模式」 |
| 寫高風險檔案時跳出權限確認（migration、`infra/`、`cdk/`、`auth/` 等） | 確認內容後按「允許」（對話中的「核准」不等於寫檔權限）；一般程式碼不會詢問 |
| 中斷後要繼續 | 重新啟動 `claude --agent pm`，會從上次的階段接續 |

## 確認裝好了

- PM 的第一則回覆是**繁體中文**的歡迎訊息，接著派 BA 做需求分析
- 專案的 `.claude/` 有 `agents`、`aidlc-team`、`settings.json`、`skills` 四項
- 版本：歡迎訊息第一行顯示「Personal-AI-DLC v…」，或查看 `.claude/aidlc-team/VERSION`；和 Personal-AI-DLC repo 的 [`CHANGELOG.md`](CHANGELOG.md) 最新版本不同時，照上方「重新安裝」更新

## 常見問題

| 問題 | 解法 |
| --- | --- |
| 輸入需求後是一般 Claude 在回答，沒有派工 | 沒有用 `claude --agent pm` 啟動 |
| PM 派工後沒等角色完成就往下 | 啟動前沒設 `CLAUDE_CODE_FORK_SUBAGENT=0` |
| 執行 `robocopy` 出現「無效的參數 #3 : "E:/"」 | 你在 Git Bash 執行了 PowerShell 指令，改用 Git Bash 段落的 `apply-template.sh`，或改開 PowerShell |
| PM 說找不到規則庫 | `.claude\skills\aidlc-v1` 不存在，重新執行安裝步驟 |
| 一啟動就接著舊的需求做 | 專案有舊的 `aidlc-docs/`，改名備份後重新啟動 |
