# Immersion Test Scene Hierarchy

用于快速白盒验证“隧道 → 揭示 → 巨构前景 → 巨构远景”的沉浸感测试场景。

## 推荐场景名

- `ImmersionTest_FromTunnelToMega.tscn`

## 节点树（标注类型）

```text
ImmersionTest_FromTunnelToMega (Node3D)
├── World (Node3D)
│   ├── WorldEnvironment (WorldEnvironment)
│   ├── DirectionalLight3D_Sun (DirectionalLight3D)
│   ├── Node3D_SunRig (Node3D)
│   │   └── DirectionalLight3D_Fill (DirectionalLight3D)
│   ├── FogVolume_Main (FogVolume)
│   ├── ReflectionProbe_Reveal (ReflectionProbe)
│   └── VFX_Global (Node3D)
│       ├── GPUParticles3D_DustAmbient (GPUParticles3D)
│       ├── GPUParticles3D_FloatingAsh (GPUParticles3D)
│       └── GPUParticles3D_LightMotes (GPUParticles3D)
│
├── PlayerSetup (Node3D)
│   ├── SpawnPoints (Node3D)
│   │   ├── Marker3D_Start (Marker3D)
│   │   ├── Marker3D_TunnelMid (Marker3D)
│   │   ├── Marker3D_RevealPlatform (Marker3D)
│   │   └── Marker3D_ForegroundMega (Marker3D)
│   ├── Player (Node3D)
│   │   ├── CharacterBody3D (CharacterBody3D)
│   │   ├── CollisionShape3D (CollisionShape3D)
│   │   ├── Node3D_Head (Node3D)
│   │   │   ├── Camera3D (Camera3D)
│   │   │   ├── AudioListener3D (AudioListener3D)
│   │   │   ├── RayCast3D_Interact (RayCast3D)
│   │   │   └── RayCast3D_GroundCheck (RayCast3D)
│   │   └── DebugCameraAnchor (Marker3D)
│   └── PlayerHelpers (Node3D)
│       ├── Marker3D_LookTarget_Default (Marker3D)
│       └── Node3D_RespawnRoot (Node3D)
│
├── Section_A_Tunnel (Node3D)
│   ├── Geo (Node3D)
│   │   ├── CSGCombiner3D_TunnelShell (CSGCombiner3D)
│   │   │   ├── CSGBox3D_Floor (CSGBox3D)
│   │   │   ├── CSGBox3D_LeftWall (CSGBox3D)
│   │   │   ├── CSGBox3D_RightWall (CSGBox3D)
│   │   │   ├── CSGBox3D_Ceiling (CSGBox3D)
│   │   │   ├── CSGCylinder3D_Arch01 (CSGCylinder3D)
│   │   │   ├── CSGCylinder3D_Arch02 (CSGCylinder3D)
│   │   │   └── CSGPolygon3D_EndCap (CSGPolygon3D)
│   │   ├── CSGCombiner3D_TunnelCuts (CSGCombiner3D)
│   │   │   ├── CSGBox3D_CableTrenchCut (CSGBox3D)
│   │   │   ├── CSGBox3D_MaintenanceNicheCut (CSGBox3D)
│   │   │   └── CSGBox3D_SideGapCut (CSGBox3D)
│   │   ├── CSGCombiner3D_TunnelSupports (CSGCombiner3D)
│   │   │   ├── CSGBox3D_Beam01 (CSGBox3D)
│   │   │   ├── CSGBox3D_Beam02 (CSGBox3D)
│   │   │   ├── CSGBox3D_Beam03 (CSGBox3D)
│   │   │   └── CSGBox3D_PipeShelf (CSGBox3D)
│   │   └── MeshDetails (Node3D)
│   │       ├── MeshInstance3D_Cables (MeshInstance3D)
│   │       ├── MeshInstance3D_Pipes (MeshInstance3D)
│   │       ├── MeshInstance3D_Grates (MeshInstance3D)
│   │       └── MeshInstance3D_SmallProps (MeshInstance3D)
│   ├── Lighting (Node3D)
│   │   ├── OmniLight3D_Lamp01 (OmniLight3D)
│   │   ├── OmniLight3D_Lamp02 (OmniLight3D)
│   │   ├── SpotLight3D_LeakLight (SpotLight3D)
│   │   └── Decal_GrimeLight (Decal)
│   ├── Audio (Node3D)
│   │   ├── AudioStreamPlayer3D_Hum (AudioStreamPlayer3D)
│   │   ├── AudioStreamPlayer3D_Rumble (AudioStreamPlayer3D)
│   │   └── AudioStreamPlayer3D_Drip (AudioStreamPlayer3D)
│   ├── FX (Node3D)
│   │   ├── GPUParticles3D_DustDense (GPUParticles3D)
│   │   ├── GPUParticles3D_SteamLeak (GPUParticles3D)
│   │   └── Decal_DirtMarks (Decal)
│   └── Logic (Node3D)
│       ├── Area3D_EnterTunnel (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       ├── Area3D_MidTunnel (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       └── Marker3D_TunnelLookDir (Marker3D)
│
├── Section_B_Glimpse (Node3D)
│   ├── Geo (Node3D)
│   │   ├── CSGCombiner3D_TransitionCorridor (CSGCombiner3D)
│   │   │   ├── CSGBox3D_Floor (CSGBox3D)
│   │   │   ├── CSGBox3D_Walls (CSGBox3D)
│   │   │   ├── CSGBox3D_Ceiling (CSGBox3D)
│   │   │   └── CSGBox3D_BendBlocker (CSGBox3D)
│   │   ├── CSGCombiner3D_GlimpseFrame (CSGCombiner3D)
│   │   │   ├── CSGBox3D_FrameOuter (CSGBox3D)
│   │   │   ├── CSGBox3D_FrameCut (CSGBox3D)
│   │   │   ├── CSGBox3D_Slat01 (CSGBox3D)
│   │   │   ├── CSGBox3D_Slat02 (CSGBox3D)
│   │   │   └── CSGBox3D_Slat03 (CSGBox3D)
│   │   └── MeshDetails (Node3D)
│   │       ├── MeshInstance3D_Railing (MeshInstance3D)
│   │       ├── MeshInstance3D_PanelDebris (MeshInstance3D)
│   │       └── MeshInstance3D_MaintenanceSigns (MeshInstance3D)
│   ├── Lighting (Node3D)
│   │   ├── SpotLight3D_GlimpseRim (SpotLight3D)
│   │   ├── OmniLight3D_BackGlow (OmniLight3D)
│   │   └── Decal_RustStreaks (Decal)
│   ├── Audio (Node3D)
│   │   ├── AudioStreamPlayer3D_WindHint (AudioStreamPlayer3D)
│   │   └── AudioStreamPlayer3D_DistantDrone (AudioStreamPlayer3D)
│   ├── FX (Node3D)
│   │   ├── GPUParticles3D_FogLightBeam (GPUParticles3D)
│   │   └── GPUParticles3D_DustWindow (GPUParticles3D)
│   └── Logic (Node3D)
│       ├── Area3D_FirstGlimpseTrigger (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       ├── Marker3D_GlimpseLookTarget (Marker3D)
│       └── Marker3D_GlimpseCompositionCenter (Marker3D)
│
├── Section_C_Reveal (Node3D)
│   ├── Geo (Node3D)
│   │   ├── CSGCombiner3D_RevealPlatform (CSGCombiner3D)
│   │   │   ├── CSGBox3D_MainPlatform (CSGBox3D)
│   │   │   ├── CSGBox3D_SidePlatform (CSGBox3D)
│   │   │   ├── CSGBox3D_BrokenEdge (CSGBox3D)
│   │   │   ├── CSGBox3D_StairBlock (CSGBox3D)
│   │   │   └── CSGCylinder3D_SupportBase (CSGCylinder3D)
│   │   ├── CSGCombiner3D_RevealFrame (CSGCombiner3D)
│   │   │   ├── CSGBox3D_LeftColumn (CSGBox3D)
│   │   │   ├── CSGBox3D_RightColumn (CSGBox3D)
│   │   │   ├── CSGBox3D_TopBeam (CSGBox3D)
│   │   │   └── CSGBox3D_HangingPanel (CSGBox3D)
│   │   ├── CSGCombiner3D_ForegroundBeams (CSGCombiner3D)
│   │   │   ├── CSGBox3D_BeamA (CSGBox3D)
│   │   │   ├── CSGBox3D_BeamB (CSGBox3D)
│   │   │   ├── CSGBox3D_BeamC (CSGBox3D)
│   │   │   └── CSGCylinder3D_PipeBundle (CSGCylinder3D)
│   │   └── MeshDetails (Node3D)
│   │       ├── MeshInstance3D_Railings (MeshInstance3D)
│   │       ├── MeshInstance3D_CatwalkBits (MeshInstance3D)
│   │       ├── MeshInstance3D_CablesHang (MeshInstance3D)
│   │       └── MeshInstance3D_MachinerySilhouettes (MeshInstance3D)
│   ├── Lighting (Node3D)
│   │   ├── DirectionalLight3D_RevealBounce (DirectionalLight3D)
│   │   ├── SpotLight3D_PlatformAccent (SpotLight3D)
│   │   └── OmniLight3D_ConsoleLight (OmniLight3D)
│   ├── Audio (Node3D)
│   │   ├── AudioStreamPlayer3D_OpenWind (AudioStreamPlayer3D)
│   │   ├── AudioStreamPlayer3D_MegaDrone (AudioStreamPlayer3D)
│   │   └── AudioStreamPlayer3D_MetalCreak (AudioStreamPlayer3D)
│   ├── FX (Node3D)
│   │   ├── GPUParticles3D_OpenDust (GPUParticles3D)
│   │   ├── GPUParticles3D_FallingDebris (GPUParticles3D)
│   │   └── FogVolume_RevealDepth (FogVolume)
│   └── Logic (Node3D)
│       ├── Area3D_RevealTrigger (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       ├── Area3D_StopAndLookZone (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       ├── Marker3D_RevealLookTarget_Main (Marker3D)
│       ├── Marker3D_RevealLookTarget_Secondary (Marker3D)
│       └── Marker3D_PlayerPauseSpot (Marker3D)
│
├── Section_D_ForegroundMega (Node3D)
│   ├── Geo (Node3D)
│   │   ├── CSGCombiner3D_WalkableMegaPart (CSGCombiner3D)
│   │   │   ├── CSGBox3D_Catwalk (CSGBox3D)
│   │   │   ├── CSGBox3D_MaintenancePad (CSGBox3D)
│   │   │   ├── CSGBox3D_BridgeStub (CSGBox3D)
│   │   │   ├── CSGCylinder3D_CorePipe (CSGCylinder3D)
│   │   │   └── CSGBox3D_AnchorBlock (CSGBox3D)
│   │   ├── CSGCombiner3D_SupportMasses (CSGCombiner3D)
│   │   │   ├── CSGBox3D_PillarA (CSGBox3D)
│   │   │   ├── CSGBox3D_PillarB (CSGBox3D)
│   │   │   ├── CSGBox3D_PillarC (CSGBox3D)
│   │   │   └── CSGBox3D_CrossBrace (CSGBox3D)
│   │   └── MeshDetails (Node3D)
│   │       ├── MeshInstance3D_Ladders (MeshInstance3D)
│   │       ├── MeshInstance3D_ServiceBoxes (MeshInstance3D)
│   │       ├── MeshInstance3D_Rails (MeshInstance3D)
│   │       └── MeshInstance3D_CableClusters (MeshInstance3D)
│   ├── Lighting (Node3D)
│   │   ├── OmniLight3D_ServiceLamp01 (OmniLight3D)
│   │   ├── OmniLight3D_ServiceLamp02 (OmniLight3D)
│   │   └── SpotLight3D_BlinkingWarning (SpotLight3D)
│   ├── Audio (Node3D)
│   │   ├── AudioStreamPlayer3D_CloseMechanicalHum (AudioStreamPlayer3D)
│   │   ├── AudioStreamPlayer3D_PressureVent (AudioStreamPlayer3D)
│   │   └── AudioStreamPlayer3D_StructureGroan (AudioStreamPlayer3D)
│   ├── FX (Node3D)
│   │   ├── GPUParticles3D_Sparks (GPUParticles3D)
│   │   ├── GPUParticles3D_SteamBurst (GPUParticles3D)
│   │   └── Decal_OilStains (Decal)
│   └── Logic (Node3D)
│       ├── Area3D_ForegroundArrival (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       ├── Area3D_EdgeDangerHint (Area3D)
│       │   └── CollisionShape3D (CollisionShape3D)
│       └── Marker3D_BackLookTarget (Marker3D)
│
├── Vista_Megastructure (Node3D)
│   ├── Layer_01_NearSilhouette (Node3D)
│   │   ├── MeshInstance3D_RingSegment_A (MeshInstance3D)
│   │   ├── MeshInstance3D_RingSegment_B (MeshInstance3D)
│   │   ├── MeshInstance3D_BrokenBridge_A (MeshInstance3D)
│   │   └── MeshInstance3D_TowerCluster_A (MeshInstance3D)
│   ├── Layer_02_MidScale (Node3D)
│   │   ├── MeshInstance3D_SuperBeam_A (MeshInstance3D)
│   │   ├── MeshInstance3D_SuperBeam_B (MeshInstance3D)
│   │   ├── MeshInstance3D_DistantPlatform_A (MeshInstance3D)
│   │   ├── MeshInstance3D_DistantPlatform_B (MeshInstance3D)
│   │   └── MeshInstance3D_HabBlockSilhouette (MeshInstance3D)
│   ├── Layer_03_FarBackdrop (Node3D)
│   │   ├── MeshInstance3D_BackShell_A (MeshInstance3D)
│   │   ├── MeshInstance3D_BackShell_B (MeshInstance3D)
│   │   ├── MeshInstance3D_ArcWall (MeshInstance3D)
│   │   └── MeshInstance3D_FarVerticals (MeshInstance3D)
│   ├── Layer_04_Lights (Node3D)
│   │   ├── MeshInstance3D_LightBand_A (MeshInstance3D)
│   │   ├── MeshInstance3D_LightBand_B (MeshInstance3D)
│   │   ├── MeshInstance3D_WindowDots_A (MeshInstance3D)
│   │   └── MeshInstance3D_BeaconLights (MeshInstance3D)
│   ├── Atmosphere (Node3D)
│   │   ├── FogVolume_Distant (FogVolume)
│   │   ├── GPUParticles3D_DistantDust (GPUParticles3D)
│   │   └── GPUParticles3D_FallingMotes (GPUParticles3D)
│   └── CompositionMarkers (Node3D)
│       ├── Marker3D_MainFocalPoint (Marker3D)
│       ├── Marker3D_LeftBalancePoint (Marker3D)
│       └── Marker3D_RightBalancePoint (Marker3D)
│
├── NavigationAndCollision (Node3D)
│   ├── StaticBody3D_Blockers (StaticBody3D)
│   │   ├── CollisionShape3D_WorldBounds (CollisionShape3D)
│   │   ├── CollisionShape3D_FallBlockerA (CollisionShape3D)
│   │   └── CollisionShape3D_FallBlockerB (CollisionShape3D)
│   ├── NavigationRegion3D_Main (NavigationRegion3D)
│   └── VisibleOnScreenNotifier3D_Test (VisibleOnScreenNotifier3D)
│
├── SequenceControl (Node)
│   ├── AnimationPlayer (AnimationPlayer)
│   ├── Timer_RevealDelay (Timer)
│   ├── Timer_AudioStingerDelay (Timer)
│   ├── Node_RevealController (Node)
│   └── Node_AudioStateController (Node)
│
├── Materials (Node)
│   ├── Node_BlockoutMaterials (Node)
│   ├── Node_MegaMaterials (Node)
│   └── Node_DecalMaterials (Node)
│
└── Debug (Node3D)
    ├── Node3D_Gizmos (Node3D)
    │   ├── Marker3D_DebugCam01 (Marker3D)
    │   ├── Marker3D_DebugCam02 (Marker3D)
    │   └── Marker3D_DebugCam03 (Marker3D)
    ├── CanvasLayer_DebugUI (CanvasLayer)
    ├── Label3D_SectionNames (Label3D)
    └── Node_TestSwitches (Node)
```

## 结构说明

### 顶层
- `World (Node3D)`：全局环境、主光、雾、全局粒子。
- `PlayerSetup (Node3D)`：玩家本体、出生点、调试锚点。
- `Section_A_Tunnel ~ Section_D_ForegroundMega (Node3D)`：按空间段落拆分。
- `Vista_Megastructure (Node3D)`：专门放不可达或半不可达的巨构远景。
- `NavigationAndCollision (Node3D)`：集中处理碰撞边界和导航。
- `SequenceControl (Node)`：统一放过场节奏、触发延时、音效状态机。
- `Debug (Node3D)`：调试视角、调试 UI、测试开关。

### 每个 Section 统一结构
建议每个空间段都保持：

```text
Section_X_Name (Node3D)
├── Geo (Node3D)
├── Lighting (Node3D)
├── Audio (Node3D)
├── FX (Node3D)
└── Logic (Node3D)
```

这样后面：
- 开关某一段内容更方便
- 白盒替换正式 Mesh 更清楚
- 音效、灯光、触发器不会散乱

## 白盒阶段推荐保留的最小版本

如果你现在只想最快搭建，可以先保留：

```text
ImmersionTest (Node3D)
├── World (Node3D)
│   ├── WorldEnvironment (WorldEnvironment)
│   ├── DirectionalLight3D (DirectionalLight3D)
│   └── FogVolume_Main (FogVolume)
├── Player (CharacterBody3D)
│   ├── CollisionShape3D (CollisionShape3D)
│   ├── Camera3D (Camera3D)
│   └── AudioListener3D (AudioListener3D)
├── Tunnel (Node3D)
│   ├── CSGCombiner3D_Shell (CSGCombiner3D)
│   ├── CSGCombiner3D_Cuts (CSGCombiner3D)
│   ├── Audio (Node3D)
│   └── FX (Node3D)
├── Glimpse (Node3D)
│   ├── CSGCombiner3D_Frame (CSGCombiner3D)
│   ├── Area3D_Trigger (Area3D)
│   │   └── CollisionShape3D (CollisionShape3D)
│   └── Marker3D_LookTarget (Marker3D)
├── Reveal (Node3D)
│   ├── CSGCombiner3D_Platform (CSGCombiner3D)
│   ├── CSGCombiner3D_Foreground (CSGCombiner3D)
│   ├── Audio (Node3D)
│   ├── FX (Node3D)
│   └── Area3D_Trigger (Area3D)
│       └── CollisionShape3D (CollisionShape3D)
├── ForegroundMega (Node3D)
│   ├── CSGCombiner3D_WalkablePart (CSGCombiner3D)
│   └── MeshDetails (Node3D)
└── Vista (Node3D)
    ├── NearSilhouette (Node3D)
    ├── MidScale (Node3D)
    ├── FarBackdrop (Node3D)
    └── Lights (Node3D)
```

## 命名建议

### Section 命名
- `Section_A_Tunnel`
- `Section_B_Glimpse`
- `Section_C_Reveal`
- `Section_D_ForegroundMega`

### 组命名
- `Geo`
- `Lighting`
- `Audio`
- `FX`
- `Logic`

### CSG 节点命名
- `CSGCombiner3D_TunnelShell`
- `CSGCombiner3D_TunnelCuts`
- `CSGCombiner3D_RevealPlatform`
- `CSGCombiner3D_ForegroundBeams`

### 触发器命名
- `Area3D_FirstGlimpseTrigger`
- `Area3D_RevealTrigger`
- `Area3D_StopAndLookZone`

### 标记点命名
- `Marker3D_GlimpseLookTarget`
- `Marker3D_RevealLookTarget_Main`
- `Marker3D_PlayerPauseSpot`
- `Marker3D_BackLookTarget`

## 使用建议

1. CSG 只负责大形和空间节奏。
2. 可走到的前景结构放在 `Section_C_Reveal` 和 `Section_D_ForegroundMega`。
3. 远景巨构统一放到 `Vista_Megastructure`，不要混进可玩区。
4. 先测“视线揭示”和“尺度感”，再补细节材质。
5. 优先保证：压缩隧道 → 偷看一角 → 开阔揭示 → 靠近巨构，这四个节奏点明确。
