# AI 工作区规则

> 放到项目根目录，重命名为 `AGENTS.md`（自动被 omp + Codex 发现）。
> 同一目录下 `ln -s AGENTS.md CLAUDE.md` 则 Claude Code 也能发现。

## 目录导航

替换为你的实际目录布局，例如：

```
workspace/
├── AGENTS.md          ← 本文件
├── CLAUDE.md          ← symlink → AGENTS.md
├── build/             ← 构建产物目录
├── projects/          ← 活跃项目
│   ├── foo/           ├── .omp/AGENTS.md（项目专属规则）
│   └── bar/
├── data/              ← 数据（只读）
├── learning/          ← 学习项目
└── scripts/           ← 脚本
```

## 项目级规则

每个子目录可自建 `.omp/AGENTS.md`（原生格式，最高优先级）细化规则。
无则继承本文件规则。

## 本地路径

机器相关配置统一写在 `AGENTS.local.md`，不进入 Git。
本文件只放通用导航和操作流程。
