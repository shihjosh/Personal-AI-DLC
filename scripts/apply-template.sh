#!/usr/bin/env bash
# 把 AI-DLC 協作交付團隊套用到目標專案；已存在的檔案一律跳過，不覆蓋。
#   apply-template.sh <目標專案目錄>
# 會建立：.claude/agents/（PM + 5 角色）、.claude/aidlc-team/protocol.md、
#         .claude/skills/aidlc-v1/（團隊的規則庫）、.claude/settings.json（權限關卡）
set -euo pipefail

[ $# -eq 1 ] || { echo "用法: apply-template.sh <目標專案目錄>" >&2; exit 2; }
target="$(cd "$1" && pwd)"

case "$target" in
  */EAC_Wiki|*/EAC_Wiki/*) echo "拒絕：EAC_Wiki 為唯讀" >&2; exit 1 ;;
esac

copied=0 skipped=0
for part in skill agent-team; do   # 團隊角色會讀規則庫（skill/）的 rule-details/
  src="$(cd "$(dirname "$0")/../template/$part" && pwd)"
  while IFS= read -r -d '' file; do
    rel=${file#"$src"/}
    dest="$target/$rel"
    if [ -e "$dest" ]; then
      echo "SKIP  $rel（已存在）"
      skipped=$((skipped + 1))
    else
      mkdir -p "$(dirname "$dest")"
      cp "$file" "$dest"
      echo "COPY  $rel"
      copied=$((copied + 1))
    fi
  done < <(find "$src" -type f -print0)
done

echo "完成：複製 $copied 個、跳過 $skipped 個"
