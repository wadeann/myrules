# myrules — 多 Agent 跨机器规则同步方案

一套规则，同时生效于 **omp** / **Claude Code** / **Codex CLI**，多台机器一键同步。

## 文件结构

| 文件 | 用途 | 分发到 |
|---|---|---|
| `user-global.md` | **唯一编辑源**。全局编码规范、安全约束、沟通习惯 | `~/.omp/agent/AGENTS.md`<br>`~/.claude/CLAUDE.md`<br>`~/.codex/AGENTS.md`<br>`~/.config/ai-rules/user-global.md` |
| `RULES.md` | omp 粘性规则，短且硬，每次请求携带 | `~/.omp/agent/RULES.md` |
| `workspace-AGENTS.md` | 工作区目录导航模板，按需部署到项目根 | 项目根 → 重命名 `AGENTS.md` |
| `install.sh` | 安装 / 同步 / 状态检查 | 运行入口，放在仓库中 |

## 首次安装

```bash
# 1. 克隆到目标机器
git clone https://github.com/wadeann/myrules.git ~/myrules

# 2. 安装（默认符号链接模式）
cd ~/myrules && ./install.sh

# 符号链接 → 编辑仓库文件即时生效，无需重跑脚本
```

## 日常使用

```bash
# 编辑规范（唯一编辑点）
vim ~/myrules/user-global.md

# 提交同步到其他机器
cd ~/myrules
git add -A && git commit -m "update rules"
git push
```

另一台机器上：

```bash
cd ~/myrules && git pull
# 符号链接模式下，pull 后自动生效
# 若新增、删除了映射文件，重新运行 install.sh
```

## 多机器差异配置

在每台机器的项目根创建 `AGENTS.local.md`（不进入 Git）：

```bash
# 以 omp 为例，先在 ~/.omp/agent/config.yml 中启用：
#   contextFiles:
#     extra:
#       - AGENTS.local.md
# 然后在项目根写入本机特有的路径 / 环境变量
```

内容示例（`<project>/AGENTS.local.md`）：

```markdown
# 本地覆盖
- Python: 使用 conda 环境 ai-dev
- 数据目录: /mnt/data/models/
```

## 工作区规则部署

```bash
# 复制模板到项目根
cp ~/myrules/workspace-AGENTS.md ~/projects/myapp/AGENTS.md

# 创建兼容 symlink（optional，用于 Claude Code）
cd ~/projects/myapp && ln -sf AGENTS.md CLAUDE.md

# 编辑 AGENTS.md 填充实际目录结构和业务规则
```

## 如果不用 omp

本方案只依赖三个用户级规则文件位置，与 omp 无关亦可工作：

- `~/.claude/CLAUDE.md` → Claude Code 读取
- `~/.codex/AGENTS.md` → Codex CLI 读取
- `~/workspace/ai/AGENTS.md` → omp + Codex 读取

`install.sh` 只是把同一个文件放到多个已知位置。

## .gitignore

```
# 本机覆盖文件
AGENTS.local.md
*.bak
```
