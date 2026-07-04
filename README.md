# zh-writing-distill

## 它是什么？

`zh-writing-distill` 是一个用来蒸馏个人写作风格的 Skill。

我一直想找一个简单易用的写作风格蒸馏工具，但大多数方案要么步骤复杂，要么对中文不够友好，也很难去掉明显的 AI 味。于是我做了这个 Skill。

## 如何使用？

1. 在你的电脑上创建一个目录（比如：`writing`）

2. 用你喜欢的 AI Agent 工具（比如：Codex、Claude Code、Gemini、OpenCode 等）打开 `writing` 目录，然后告诉它：

  ```text
  帮我安装 https://github.com/CoolCat2000/zh-writing-distill 这个 Skill
  ```

  如果你想手动安装，也可以执行：

  ```text
  npx skills add https://github.com/CoolCat2000/zh-writing-distill.git
  ```

3. 在 `writing` 目录下创建一个 `docs` 目录，把你的文章放进去

4. 然后在 AI Agent 中调用技能：

  ```text
  /distill
  ```

  如果你还需要去除 AI 味使用：

  ```text
  /distill-humanized
  ```

  > 如果找不到技能，得重启下 AI Agent 工具。

5. 如果一切顺利，你会在 `writing` 目录下看到 `AGENTS.md` 和 `CLAUDE.md`。它们就是你的写作风格规则文件，你还可以自己手动细调。这两个文件是链接在一起的，你只需要编辑其中一个文件，另一个文件就会自动同步更新。

6. 现在，你就可以在 `writing` 目录下使用 AI Agent，按照自己的写作风格进行写作了。比如：

  ```text
  帮我写一篇关于 AI 的文章
  ```
