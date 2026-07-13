# s&box Claude Bridge — tool census + risk classification (2026-07-12)

> **Class: REFERENCE** (living; amend as the bridge surface changes). Red census 2026-07-12.
> Sensor: `mcp__sbox__get_bridge_status` (addon v2.0.0 / server v2.0.0, **237 handlers**) + the
> `mcp__sbox__*` tool surface. Purpose: let the FRONTLINE seat (Codex) know which bridge calls are
> **safe concurrent eyes** vs which require the **single driver seat** (see the Driver Law:
> `CLAUDE.md` + `lifepunch-editor-gate` skill). The parallel `mcp__sbox-editor__*` HTTP surface
> (~541 tools) is the editor-hosted MCP; it does not retry and drops when the editor closes — the
> file-IPC `mcp__sbox__*` bridge (237 handlers) is the durable driver surface classified here.

## Classification rule (by verb prefix — any handler classifies from its name)
- **READ-ONLY** — reads state, never writes: `get_*`, `list_*`, `read_*`, `describe_*`, `search_*`,
  `find_*`, `*_status`, `is_*`, screenshots/captures, `measure_*`, `raycast*`, `*_overlap`,
  `*_lint`, `validate_*`, `inspect_*`. **Safe for concurrent eyes — a non-driver may call these
  while Red drives.**
- **SCENE-MUTATING** — writes scene/asset/prefab/component/transform state: `create_*`, `add_*`,
  `set_*`, `delete_*`, `remove_*`, `spawn_*`, `assign_*`, `move_*`/`rotate_*`/`scale_*`,
  `duplicate_*`, `group_*`, `batch_*`, `align_*`/`distribute_*`, `place_*`/`scatter_*`,
  `sculpt_*`/`paint_*`/`build_*`, `bake_*`, `save_scene`, `checkpoint_*`/`restore_*`, `undo`/`redo`,
  `set_ownership`, `network_spawn`, `drive_player`/`simulate_input`. **Driver seat only.**
- **COMPILE / SYNC-TRIGGERING** — writes code or forces a build/hotload/play (heaviest; changes the
  running assembly): `trigger_hotload`, `execute_csharp`, `recompile_asset`, `asset_compile`,
  `write_file`/`code_write_file`/`code_edit_file`, `create_script`/`edit_script`/`delete_script`,
  `install_asset`, `restart_editor`, `start_play`/`stop_play`/`playtest*`, `editor_play`/`editor_stop`.
  **Driver seat only; EDITOR_LAUNCH_LAW + launch-set rule bind whoever calls these.**

## Bucket A — READ-ONLY (concurrent eyes OK) — the frontline's safe surface
Status/health: `get_bridge_status`, `get_network_status`, `is_playing`, `playtest_status`,
`get_profiler_stats`, `session_info`. Compile/console: `get_compile_errors`, `read_log`,
`read_console_messages`, `logs_search`. Project/scene: `get_project_info`, `get_project_config`,
`describe_project`, `describe_scene`, `get_scene_hierarchy`, `scene_get_status`, `scene_get_stats`,
`scene_diff`, `scene_validate`, `validate_project`, `list_scenes`, `get_selected_objects`.
Introspection: `describe_type`, `search_types`, `get_method_signature`, `get_all_properties`,
`get_property`, `get_runtime_property`, `get_component_property`, `get_static_property`, `get_tags`,
`get_bounds`, `find_objects`, `find_in_project`, `find_broken_references`, `inspect_networked_object`,
`save_inspect`, `get_asset_info`, `get_prefab_info`, `get_package_details`, `list_prefabs`,
`list_project_files`, `list_available_components`, `list_component_buttons`, `list_animations`,
`list_sounds`, `list_movies`, `list_asset_library`, `list_libraries`, `list_checkpoints`,
`read_file`, `search_assets`, `search_docs`, `get_doc_page`, `list_doc_categories`, `services_query`.
Screenshots/measure: `take_screenshot`, `screenshot_from`, `screenshot_orbit`, `capture_view`,
`measure_distance`, `raycast`, `raycast_terrain`, `physics_overlap`, `get_navmesh_path`.
Lint: `networking_lint`, `sandbox_lint`, `razor_lint`. Debug overlays (`debug_draw_*`,
`debug_clear`) are transient view aids — READ-ONLY-adjacent, but treat as driver-only if a run is live.

## Bucket B — SCENE-MUTATING (driver seat only)
`create_gameobject`/`create_scene`/`create_prefab`/`create_material`/`create_*`,
`add_component_*`/`add_collider`/`add_light`/`add_*`, `set_property`/`set_transform`/`set_parent`/
`set_enabled`/`set_tags`/`set_material_property`/`set_*`, `delete_gameobject`/`remove_component`,
`spawn_model`/`spawn_camera`/`spawn_light`/`spawn_citizen`/`spawn_particle`/`network_spawn`,
`assign_material`/`assign_model`/`assign_sound`, `move_by`/`rotate_by`/`scale_by`/`duplicate_gameobject`/
`group_objects`/`batch_*`/`align_objects`/`distribute_objects`/`randomize_transforms`/`snap_to_ground`/
`place_along_path`/`scatter_props`/`grid_duplicate`, `sculpt_terrain`/`paint_forest_density`/
`build_terrain_mesh`/`bake_navmesh`/`bake_reflections`, `apply_atmosphere`/`set_fog`/`set_skybox`/
`set_time_scale`, `save_scene`/`checkpoint_scene`/`restore_checkpoint`/`undo`/`redo`,
`set_ownership`, `drive_player`/`simulate_input`, `set_project_config`, `install_asset` (also compile).

## Bucket C — COMPILE / SYNC-TRIGGERING (driver seat only; heaviest)
`trigger_hotload`, `execute_csharp` (recompiles the editor assembly briefly — sweep `Editor/__Exec_*.cs`
after), `recompile_asset`, `create_script`/`edit_script`/`delete_script`, `write_file`, restart via
`restart_editor`, and play control `start_play`/`stop_play`/`playtest`/`playtest_abort`
(leaves edit mode, triggers a play build; blocks scene-mutating calls while live).
Editor-tree **SYNC** is external (`Sync-LifePunchAddonsToDxrp.ps1`, not a bridge handler) but is the
same risk class — the launch-set rule (`lpbitcoin,adminmenu`, never a lone addon) binds it.

## Operational takeaway (feeds the Driver Law)
- Codex (frontline) may hold **Bucket A concurrently** with Red — status/screenshot/log/compile
  loops are safe multi-eye.
- **Buckets B and C require the single driver seat.** Never two seats issuing B/C at once.
- Whoever holds the driver seat is bound by EDITOR_LAUNCH_LAW (Launch Report) + the launch-set rule.
