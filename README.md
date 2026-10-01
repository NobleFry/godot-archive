# Godot Projects Archive

个人 Godot 历史项目的归档备份仓库。集中保存各实验 / 学习 / 原型项目的完整源码快照，便于长期备份与检索。

> 生成日期：2026-10-01

## 目录结构

```
Godot/
├── blender-test/            # Blender 导入测试 (Godot 4.7)
├── project-horror/          # 恐怖题材 FPS 原型 (Godot 4.6)
├── project-mega/            # 大型灰盒实验 (Godot 4.6)
├── project-s/               # 原型项目 (Godot 4.6)
├── speed-is-everything/     # 关卡 / 角色控制器实验 (Godot 4.7)
├── study-project/           # 学习项目 (Godot 4.7)
├── the-backrooms/           # Backrooms 场景实验 (Godot 4.7)
├── third-person-tutorial/   # 第三人称控制器教程 (Godot 4.6)
├── assets/                  # 第三方素材包（已解压）
└── Assets/                  # 第三方素材包（已解压）
```

## 项目一览

| 项目 | Godot 版本 | 说明 |
|------|-----------|------|
| `blender-test`      | 4.7 | Blender 模型导入流程测试 |
| `project-horror`    | 4.6 | 恐怖题材第一人称原型，含无人机/敌人 AI 等 |
| `project-mega`      | 4.6 | 大型灰盒场景与 FPS 移动实验 |
| `project-s`         | 4.6 | 原型项目 |
| `speed-is-everything` | 4.7 | 关卡与角色控制器实验 |
| `study-project`     | 4.7 | 引擎学习项目 |
| `the-backrooms`     | 4.7 | Backrooms 场景探索实验 |
| `third-person-tutorial` | 4.6 | 第三人称控制器教程 |

## 关于备份的说明

- **未纳入版本控制的内容**
  - `.godot/`：Godot 编辑器缓存，打开项目时会自动重新生成，无需备份。
  - `project-horror.zip`、`assets/*.zip`、`Assets/*.zip`：均为已解压文件夹的冗余压缩包，已在 `.gitignore` 中排除以精简仓库体积。
  - 各项目原有的独立 Git 历史（`project-horror`、`speed-is-everything`）在合并进本归档时已被移除；如需追溯历史请参见本地备份 `_godot-backup/godot-git-history-*.tar.gz`。

- **注意事项**
  - `assets/` 与 `Assets/` 仅大小写不同。Linux 可正常共存，但在 Windows / macOS 等大小写不敏感的系统上检出时可能冲突，请留意。

## 恢复 / 使用

克隆本仓库后，直接用对应版本的 Godot 打开任意子目录中的 `project.godot` 即可（首次打开会重建 `.godot/` 缓存）。
