整个项目由chatgpt生成

# AmneziaVPN + Windscribe Route Builder

从 `input/*.txt` 读取 IPv4、CIDR 和域名，生成两种客户端路由 JSON，并通过 GitHub Actions 发布 Release。

## 输入
把条目放入 `input/` 下任意 `.txt` 文件，每行一条。支持空行、整行 `#` 注释和行尾注释。IPv4/CIDR 与域名共用输入源；自动校验、规范化、去重和排序。不设置人为条目数量上限，不做 CIDR 聚合。

```text
192.0.2.10
198.51.100.0/24
example.com
```

## 输出
- `dist/amnezia-routes.json`
- `dist/windscribe-routes.json`

AmneziaVPN 新条目：`{"hostname":"value","ip":"","ips":[]}`。Windscribe 新条目：`{"active":true,"name":"value","type":0}`，其中 IPv4/CIDR 为 `type: 0`，域名为 `type: 1`。

## Windscribe 模板注意事项
当前 `template/windscribe.template.json` 是仅含 `networkRoutes` 的最小模板，不是完整导出配置。若需保留 Windscribe 的其他设置，请用客户端导出的完整 JSON 替换该文件。脚本只更新 `networkRoutes`，其他字段原样保留。不要将账户令牌、私钥等敏感信息提交到公开仓库。

## 本地运行
Python 3.10+，无第三方依赖：

```bash
python scripts/build_routes.py
```

## GitHub Actions
上传仓库后，在 `input/` 维护 TXT 文件；必要时替换 Windscribe 完整模板。进入 **Actions → Create Release → Run workflow**，填写 tag（如 `routes-2026-11-17`）并选择是否为 Pre-release。工作流构建、校验 JSON，并将两个 JSON 上传为 Release assets。需要 `contents: write` 权限。

## 校验范围
支持 IPv4、IPv4 CIDR、ASCII 域名及 IDN（转为 Punycode）。暂不支持 IPv6、URL、端口、路径及通配符域名。无效行会报告文件和行号并使构建失败，不会静默忽略。

### Windscribe 配置导入注意事项

**请勿使用生成的 `windscribe-routes.json` 完整覆盖 Windscribe 原始配置文件。**

正确操作步骤：

1. 打开生成的 `windscribe-routes.json`。
2. 找到 `networkRoutes` 字段。
3. 复制该字段对应的完整数组，从 `[` 开始，到 `]` 结束。
4. 打开 Windscribe 原始配置 JSON 文件。
5. 找到原文件中的 `networkRoutes` 字段，仅替换其原有数组值。
6. 保存文件，保留原配置中的其他所有字段。

![Windscribe networkRoutes 数组替换示例]([docs/images/windscribe-networkroutes-example.png](https://github.com/DFR11/amnezia-windscribe-routes-github-project/blob/main/windscribe-networkroutes-readme-example.png))

**注意：** 不要复制或覆盖最外层 JSON 对象，也不要删除原配置中的其他字段。
