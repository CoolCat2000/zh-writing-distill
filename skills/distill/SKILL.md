---
name: distill
description: 从当前目录 docs 中的中文文章蒸馏个人写作风格，并生成 AGENTS.md 与 CLAUDE.md 兼容入口。用于用户调用 /distill，要求提炼文风、生成个人写作规则、创建中文写作记忆文件，或让 Codex、Claude Code、Gemini、OpenCode 等 Agent 按个人风格写作时。
user-invocable: true
license: MIT
compatibility: Designed for Codex, Claude Code, Gemini CLI, OpenCode, and other Agent Skills-compatible tools.
metadata:
  author: CoolCat2000
  version: "1.0.0"
  openclaw:
    emoji: ""
  homepage: https://github.com/CoolCat2000/zh-writing-distill
requires:
  bins: []
  install: []
allowed-tools: Read Write Edit Glob Grep Bash(sh:*) Bash(find:*) Bash(ls:*) Bash(cat:*)
---

# 中文写作风格蒸馏

把当前目录 `docs/` 下的中文文章蒸馏成可复用的个人写作规则，并写入当前目录的 `AGENTS.md`。`CLAUDE.md` 始终作为指向 `AGENTS.md` 的软链接存在，方便 Codex、Claude Code、Gemini、OpenCode 等 Agent 共用同一份规则。

当用户调用 `/distill`、要求提炼个人写作风格、生成 `AGENTS.md`、让 AI 学习个人中文文风，或创建写作记忆文件时，执行本 Skill。

如果用户明确要求去除 AI 痕迹、人味化、反 AI 腔、自然化改写，改用 `distill-humanized` skill。

## 必须遵守

- 以调用时的当前工作目录作为目标项目根目录。
- 只读取 `docs/` 下的 `.md`、`.mdx`、`.txt` 文件。
- 不修改 `docs/` 原文。
- 输出默认使用中文。
- 不编造作者特征；每条重要风格结论都必须能从素材中找到依据。
- 只生成真实文件 `AGENTS.md`。
- `CLAUDE.md` 必须是指向 `AGENTS.md` 的相对软链接。
- 如目标目录已有 `AGENTS.md` 或 `CLAUDE.md`，写入前必须先备份为 `原文件名.bak_{yyyyMMddHHmmss}`。

## 执行流程

1. 检查当前目录是否存在 `docs/`，并确认其中至少有一个 `.md`、`.mdx` 或 `.txt` 文件。
2. 读取 `references/style_distillation.md`，按其中方法分析素材。
3. 生成完整的中文 `AGENTS.md` 内容。
4. 按操作系统使用本 Skill 自带的 `scripts/write_memory_files.sh` 或 `scripts/write_memory_files.ps1` 写入文件并创建软链接，不要手写备份和软链逻辑。

## 素材读取

优先读取全部文章。若素材很多导致上下文不足：

- 先列出所有候选文件。
- 优先选取不同标题、不同长度、不同主题的文章。
- 至少覆盖 5 篇；不足 5 篇则全部读取。
- 对未完整读取的文件，记录文件名，并避免对未读内容下强结论。

## 生成 AGENTS.md

`AGENTS.md` 必须是可直接被 agent 执行的项目记忆文件，不是风格分析报告。使用祈使句和明确规则，让后续 agent 能按规则写作。

建议结构：

```markdown
# 写作风格规则

## 写作身份
## 核心价值取向
## 语气与姿态
## 句式与节奏
## 结构习惯
## 词汇偏好
## 禁用表达
## 写作自检
## 素材依据
```

## 写入文件

生成内容后，按用户电脑系统调用本 Skill 包内的脚本。脚本路径必须解析为 Skill 安装目录下的 `scripts/`，不要假设当前写作目录里存在 `scripts/`。

macOS / Linux：

```bash
sh <skill-dir>/scripts/write_memory_files.sh --root . --stdin
```

Windows PowerShell：

```powershell
Get-Content -Raw path\to\generated-agents.md | powershell -ExecutionPolicy Bypass -File <skill-dir>\scripts\write_memory_files.ps1 -Root . -Stdin
```

`<skill-dir>` 表示当前 Skill 的安装目录；执行命令时的当前目录仍然应该是用户的写作目录。把完整 `AGENTS.md` 内容通过 stdin 传给脚本。脚本会：

- 备份现有 `AGENTS.md` 与 `CLAUDE.md`。
- 写入新的 `AGENTS.md`。
- 创建指向 `AGENTS.md` 的相对软链接 `CLAUDE.md`。

不要假设用户电脑有 Python、Node.js、Ruby 或其他额外运行时。本 Skill 的确定性文件操作只依赖：

- macOS / Linux：系统自带 POSIX `sh`、`mv`、`ln`、`date`。
- Windows：系统自带 PowerShell。

如果 Windows 创建符号链接失败，通常是权限或开发者模式限制。此时停止并提示用户开启开发者模式或以允许创建符号链接的权限重新运行；不要把 `CLAUDE.md` 改成普通复制文件。

写入完成后，向用户简要说明：

- 使用了 `/distill` 工作流。
- 读取了多少个 `docs/` 文件。
- 是否创建了备份。
- `CLAUDE.md` 已作为软链接指向 `AGENTS.md`。
