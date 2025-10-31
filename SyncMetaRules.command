#!/usr/bin/env bash
# macOS 双击运行：同步 MetaCubeX/meta-rules-dat 的所有非默认分支到你的 fork
set -euo pipefail

USERNAME="huangsongping62"     # ←← 改成你的用户名
REPO="meta-rules-dat"
UPSTREAM_URL="https://github.com/MetaCubeX/meta-rules-dat.git"

cd "$(dirname "$0")"

if [ ! -d "$REPO/.git" ]; then
  echo "==> 克隆你的 fork ..."
  git clone "https://github.com/${USERNAME}/${REPO}.git"
fi

cd "$REPO"

# 确保 origin 指向你的 fork
git remote set-url origin "https://github.com/${USERNAME}/${REPO}.git"

# 确保 upstream 指向上游
if git remote get-url upstream >/dev/null 2>&1; then
  :
else
  git remote add upstream "$UPSTREAM_URL"
fi

echo "==> 拉取上游 ..."
git fetch upstream --prune

echo "==> 同步分支（排除 HEAD/main/master）..."
UPSTREAM_BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/remotes/upstream \
  | sed 's#^upstream/##' | grep -v -E '^(HEAD|main|master)$' || true)

if [[ -z "$UPSTREAM_BRANCHES" ]]; then
  echo "没有需要同步的分支。"
else
  while IFS= read -r b; do
    [[ -z "$b" ]] && continue
    echo "   - $b"
    git checkout -B "$b" "upstream/$b"
    git push -u origin "$b"
  done <<< "$UPSTREAM_BRANCHES"
fi

echo "✅ 完成：https://github.com/${USERNAME}/${REPO}/branches"
echo "如需同步 master/main："
echo "  git checkout master && git pull upstream master && git push origin master"
echo "  # 或 main 分支：git checkout main && git pull upstream main && git push origin main"