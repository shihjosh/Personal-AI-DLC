#!/usr/bin/env bash
# 偵測專案的技術模組（後端 API／前端／AWS CDK），支援 monorepo。
# 用法：detect-modules.sh [專案根目錄，預設 .]
# 輸出：Markdown 表格（模組、子目錄、細節）；找不到任何模組時輸出「無」。只讀取檔案，不修改任何東西。
set -uo pipefail
root=${1:-.}
cd "$root" || exit 2

rows=""
add() { rows+="| $1 | \`$2\` | $3 |"$'\n'; }
dep() { grep -Eq "\"$2\"[[:space:]]*:" "$1" 2>/dev/null; }
ver() { grep -Eo "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$1" 2>/dev/null | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/'; }

while IFS= read -r pkg; do
  dir=$(dirname "$pkg"); dir=${dir#./}; [ -z "$dir" ] && dir=.
  # 後端 API
  for fw in fastify express @nestjs/core koa hono; do
    if dep "$pkg" "$fw"; then add "後端 API" "$dir" "$fw $(ver "$pkg" "$fw")"; break; fi
  done
  # 前端
  if dep "$pkg" vue; then
    v=$(ver "$pkg" vue); major=$(printf '%s' "$v" | grep -Eo '[0-9]+' | head -1)
    extra=""; dep "$pkg" vuex && extra+="、Vuex"; dep "$pkg" pinia && extra+="、Pinia"
    dep "$pkg" vite && extra+="、Vite"; dep "$pkg" vue-tsc && extra+="、vue-tsc"
    add "前端" "$dir" "Vue ${major:-?}（vue $v${extra}）"
  else
    for fw in next nuxt react svelte @angular/core; do
      if dep "$pkg" "$fw"; then add "前端" "$dir" "$fw $(ver "$pkg" "$fw")"; break; fi
    done
  fi
  # AWS CDK（package.json 依賴）
  if dep "$pkg" aws-cdk-lib && [ ! -f "$(dirname "$pkg")/cdk.json" ]; then add "AWS CDK" "$dir" "aws-cdk-lib $(ver "$pkg" aws-cdk-lib)"; fi
done < <(find . -name package.json -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/cdk.out/*' -maxdepth 4 | sort)

# AWS CDK（cdk.json）
while IFS= read -r c; do
  dir=$(dirname "$c"); dir=${dir#./}; [ -z "$dir" ] && dir=.
  add "AWS CDK" "$dir" "cdk.json"
done < <(find . -name cdk.json -not -path '*/node_modules/*' -not -path '*/cdk.out/*' -maxdepth 4 | sort)

# Python 後端
while IFS= read -r f; do
  dir=$(dirname "$f"); dir=${dir#./}; [ -z "$dir" ] && dir=.
  for fw in fastapi django flask; do
    if grep -Eiq "^[[:space:]\"']*$fw" "$f"; then add "後端 API" "$dir" "$fw（Python）"; break; fi
  done
done < <(find . \( -name requirements.txt -o -name pyproject.toml \) -not -path '*/node_modules/*' -not -path '*/.venv/*' -maxdepth 4 | sort)

if [ -z "$rows" ]; then echo "無"; exit 0; fi
echo "| 模組 | 子目錄 | 細節 |"
echo "| --- | --- | --- |"
printf '%s' "$rows" | sort -u
