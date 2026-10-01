# Godot 3D Puzzle Project Directory Structure

```
res://
  scenes/                          # 所有场景文件
    main/
      Main.tscn                    # 游戏入口，加载关卡+UI
    levels/
      Level_01.tscn                # 关卡场景（环境、谜题布置）
    actors/
      Player.tscn                  # 玩家场景（CharacterBody3D + Camera）
      Door.tscn                    # 门（含InteractArea子节点）
      Switch.tscn                  # 开关
      Pickup.tscn                  # 拾取物
    ui/
      HUD.tscn                     # 游戏内UI
      PauseMenu.tscn               # 暂停菜单

  scripts/                         # 所有脚本
    main/
      Main.gd                      # 入口逻辑（加载关卡、切场景）
    actors/
      Player.gd                    # 玩家移动+交互检测
      Door.gd                      # 门逻辑
      Switch.gd                    # 开关逻辑
      Pickup.gd                    # 拾取逻辑
    interact/
      InteractArea.gd              # 交互触发区（统一交互入口）
    puzzles/
      Puzzle_Base.gd               # 谜题基类（通用完成逻辑）
      Puzzle_KeyLock.gd            # 钥匙门谜题
    ui/
      HUD.gd
      PauseMenu.gd

  autoload/                        # 全局单例
    Game.gd                        # 存档/进度/背包
    Signals.gd                     # 全局信号中心

  data/                            # 配置与数据资源
    items/
      key_01.tres                  # 钥匙配置
    puzzles/
      light_sequence_01.tres       # 谜题配置

  assets/                          # 美术与音频
    art/
    audio/
    fonts/
```
