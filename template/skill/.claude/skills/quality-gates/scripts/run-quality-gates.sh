#!/usr/bin/env bash
# 依專案自動偵測並執行品質門檻，支援 monorepo。只執行專案已設定的工具；不安裝套件、不修改檔案、不部署。
# 用法：run-quality-gates.sh [專案根目錄，預設 .]
# 輸出：Markdown 結果表；任一門檻 FAIL 時 exit 1。完整輸出寫到 $TMPDIR/quality-gates-<時間>/。
set -uo pipefail
root=${1:-.}
cd "$root" || exit 2
logdir="${TMPDIR:-/tmp}/quality-gates-$(date +%Y%m%d%H%M%S)"; mkdir -p "$logdir"
rows=""; failed=0
add() { rows+="| \`$1\` | $2 | $3 | $4 |"$'\n'; }
has_script() { grep -Eq "\"scripts\"" "$1/package.json" && node -e "process.exit(require('./$1/package.json').scripts?.['$2']?0:1)" 2>/dev/null; }
run() { # dir gate cmd...
  local dir=$1 gate=$2; shift 2
  local log="$logdir/$(echo "$dir-$gate" | tr '/ ' '__').log"
  if (cd "$dir" && "$@") >"$log" 2>&1; then add "$dir" "$gate" "PASS" "\`$*\`"
  else add "$dir" "$gate" "**FAIL**" "\`$*\`（log: $log）"; failed=1; fi
}
skip() { add "$1" "$2" "N/A" "$3"; }

while IFS= read -r pkg; do
  dir=$(dirname "$pkg"); dir=${dir#./}; [ -z "$dir" ] && dir=.
  if [ ! -d "$dir/node_modules" ] && [ ! -d node_modules ]; then
    skip "$dir" "全部" "node_modules 不存在，請先安裝依賴（npm ci）"; continue
  fi
  for s in test lint typecheck build; do
    if has_script "$dir" "$s"; then run "$dir" "$s" npm run "$s" --silent
    else skip "$dir" "$s" "專案未設定 \`$s\` script"; fi
  done
  if ! has_script "$dir" typecheck && [ -f "$dir/tsconfig.json" ]; then
    if grep -q '"vue-tsc"' "$dir/package.json"; then run "$dir" "typecheck(vue-tsc)" npx --no-install vue-tsc --noEmit
    else run "$dir" "typecheck(tsc)" npx --no-install tsc --noEmit; fi
  fi
  if [ -f "$dir/package-lock.json" ]; then run "$dir" "npm audit" npm audit --audit-level=high
  else skip "$dir" "npm audit" "沒有 package-lock.json"; fi
  if [ -f "$dir/cdk.json" ]; then run "$dir" "cdk synth" npx --no-install cdk synth --quiet; fi
done < <(find . -name package.json -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/cdk.out/*' -maxdepth 4 | sort)

if command -v gitleaks >/dev/null 2>&1; then run . "機密掃描" gitleaks detect --no-git -s . --no-banner
else skip . "機密掃描" "未安裝 gitleaks，請以 Grep 檢查常見金鑰格式"; fi

echo "| 目錄 | 門檻 | 結果 | 指令／說明 |"
echo "| --- | --- | --- | --- |"
printf '%s' "$rows"
echo
echo "完整輸出：$logdir"
exit $failed
