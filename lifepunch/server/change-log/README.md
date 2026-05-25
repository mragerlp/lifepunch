# Server Change Log

Use this folder to track every meaningful change made from the DXRP portal Servers page.

Do not rely only on memory or portal state. If a developer/admin changes a server setting, create a dated change record from `../../../templates/server-change.md`.

Track changes for:

- `lifepunchmainserver` (`70p`)
- `lifepunchdevelopment` (`Development`)

Required record details:

- Who made the change.
- Which server was affected.
- Before value.
- After value.
- Why the change was made.
- Whether owner approval was given.
- Whether the change was tested on `lifepunchdevelopment`.
- Rollback steps.

High-risk actions that always need owner approval:

- Sync.
- Restart.
- Stop/start.
- Delete.
- Save configuration.
- Change gamemode.
- Change ruleset.
- Change map.
- Change addon/gamemode revision pins.

Live portal details are still pending confirmation. Once screenshots or direct browser access are available, update `../../config/server-page-fields.json` with exact field/action names.
