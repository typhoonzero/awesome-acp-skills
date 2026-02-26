# awesome-acp-skills

Awesome ACP skills 是一个 Claude/Copilot 技能集合，旨在完全自动化你在 [Alauda Container Platform](https://www.alauda.io/) 上的工作。例如，你可以通过 0 行手写代码完成以下步骤：

1. 使用 Copilot 辅助编写目标项目代码。
2. 使用像 Rancher Desktop 这样的“开发容器”在容器环境或 K8s 环境中运行单元测试。
3. 使用 `violet` 打包你的 Operator/Helm chart（待定）。
4. 使用 `violet` 将你的包上传到测试 ACP 平台以运行测试。
5. 使用 `webapp-testing` 技能测试 ACP Web 界面。

# 快速开始

克隆此仓库，将所有内容复制到你的 Claude `skills` 目录。对于 Copilot 用户，请在当前项目下创建一个文件夹 `.github/skills`，并将此内容放入该文件夹中。

在开始之前，请在本地机器上安装这些技能所需的 `kubectl`, `violet`, `nerdctl` 命令行工具。

然后只需告诉 Claude/Copilot 做什么即可。

# 使用一行提示词从文档创建其他 ACP 技能

你可以使用 [灵雀云文档](https://docs.alauda.io/container_platform/4.2/) 中提供的文档简单地创建一个新的 ACP 技能。下载 PDF 格式的文档，使用该文件作为上下文，并输入如下提示词来创建你的技能：

```
Read this document, and create a agent skill under current directory that can implement operations, trouble shootings in this document.
```

> 注意：此代码库中的所有 ACP 技能都是由来自 https://github.com/ComposioHQ/awesome-claude-skills 的 `skill-creator` 技能生成的。
