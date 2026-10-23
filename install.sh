#!/usr/bin/env bash
# install.sh — myrules 安装/同步脚本
#
# 用法:
#   ./install.sh             安装/更新（符号链接，推荐）
#   ./install.sh --copy      拷贝模式（Windows / CI 等不支持 symlink 的环境）
#   ./install.sh --status    检查各工具规则文件状态
#
# 原理: 符号链接模式下，仓库中的文件就是事实来源。
#       编辑仓库文件后即时生效，无需重新运行本脚本。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-symlink}"

# ── 目标路径 ──────────────────────────────────────────
OMP_AGENT="${HOME}/.omp/agent"
CLAUDE_DIR="${HOME}/.claude"
CODEX_DIR="${HOME}/.codex"
AI_RULES_DIR="${HOME}/.config/ai-rules"

# ── 源 → 目标 映射（每行一对，允许同源多目标）────────
declare -a SRC=() DST=()
add_entry() { SRC+=("$1"); DST+=("$2"); }

add_entry "${REPO_DIR}/user-global.md" "${AI_RULES_DIR}/user-global.md"
add_entry "${REPO_DIR}/user-global.md" "${OMP_AGENT}/AGENTS.md"
add_entry "${REPO_DIR}/user-global.md" "${CLAUDE_DIR}/CLAUDE.md"
add_entry "${REPO_DIR}/user-global.md" "${CODEX_DIR}/AGENTS.md"
add_entry "${REPO_DIR}/RULES.md"       "${OMP_AGENT}/RULES.md"

# ── 函数 ──────────────────────────────────────────────
link_or_copy() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ "$MODE" = "copy" ]; then
    cp "$src" "$dst"
    echo "  COPY  $dst"
  else
    # 普通文件 → 备份后替换
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
      cp "$dst" "${dst}.bak" 2>/dev/null || true
      echo "  BACKUP ${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "  LINK  $dst"
  fi
}

status_check() {
  local ok=0 miss=0
  echo "=== myrules 规则状态 ==="
  for i in "${!DST[@]}"; do
    local dst="${DST[$i]}" src="${SRC[$i]}"
    if [ -L "$dst" ]; then
      tgt="$(readlink "$dst")"
      if [ "$tgt" = "${src}" ]; then
        echo "  ✅ ${dst}"
      else
        echo "  ⚠️  ${dst} → $tgt（指向非仓库路径）"
      fi
      ((ok++))
    elif [ -f "$dst" ]; then
      echo "  📄 ${dst}（普通文件，非 symlink）"
      ((ok++))
    else
      echo "  ❌ ${dst}（缺失）"
      ((miss++))
    fi
  done
  echo ""
  [ "$miss" -gt 0 ] && echo "缺失 $miss 个文件。运行 ./install.sh 部署。"
  return $miss
}

# ── 主流程 ────────────────────────────────────────────
case "${MODE}" in
  --status)  status_check; exit $? ;;
  --copy)    MODE="copy" ;;
  --symlink|symlink) MODE="symlink" ;;
  *)
    echo "用法: $0 [--symlink|--copy|--status]"
    echo "  默认 --symlink"
    exit 1
    ;;
esac

echo "=== myrules install (${MODE} mode) ==="
mkdir -p "$OMP_AGENT" "$CLAUDE_DIR" "$CODEX_DIR" "$AI_RULES_DIR"

for i in "${!SRC[@]}"; do
  link_or_copy "${SRC[$i]}" "${DST[$i]}"
done

echo ""
echo "工作区规则 AGENTS.md（按需部署到项目根）:"
echo "  cp ${REPO_DIR}/workspace-AGENTS.md <project>/AGENTS.md"
echo "  [ -d <project> ] && ln -sf AGENTS.md <project>/CLAUDE.md"
echo ""
echo "完成。新会话自动生效；当前会话用 /clear 或 /new 重载。"
