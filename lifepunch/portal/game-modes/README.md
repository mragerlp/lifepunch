# Game Modes

Purpose: manage LifePunch gamemode imports, addon attachments, revision pins, and gamemode-level content.

Observed list page:

- Warning banner: `Work In Progress`.
- Subtitle: `Manage game modes that define server content and jobs`.
- Search field: `Search by name or description`.
- Buttons: `Clear`, `Refresh`, `Add`.
- Columns: `Name`, `Visibility`, `Jobs`, `Addons`, `Created`.
- Pagination: `Showing 1 to 1 of 1 game modes`.

Observed LifePunch row:

- Name: `LifePunch`.
- Description: `The LifePunch DXRP Gamemode experience. Tweaked and tuned to the LifePunch Community DXRP server.`
- Visibility: `Private`.
- Jobs: `26`.
- Addons: `8`.
- Created: `17/05/26, 12:24 PM`.

Observed detail page:

- URL pattern: `https://dxrp.net/portal/gamemodes/<gamemodeId>`.
- LifePunch gamemode id observed: `019e36c0-a67f-701c-90f2-460e0b0f1487`.
- Details: Visibility `Private`, Created `1 week ago`, Last Modified `2 days ago`.
- Actions: `Edit`, `Back`, `Sync Servers`, `Delete Game Mode`.
- Tabs: `General`, `Addons (8)`, `Content`, `Jobs`, `Market`, `Minigames`.

Observed General tab:

- Default Job: `Citizen`.
- Starting Balance: `$15,000`.
- Default Loadout: `Hands`, `Fists`, `Tool`, `Camera`, `Build`.

Observed edit mode:

- Top actions: `Cancel`, `Save`.
- Dangerous actions: `Sync Servers`, `Reset to Vanilla`, `Delete Game Mode`.
- File/data actions: `Export`, `Import`.
- View toggle: `UI`, `JSON`.
- Editable General fields: name, description, visibility, default job, starting balance, default loadout.

Expected responsibilities:

- Canonical `.gamemode` exports.
- Addon revision pinning.
- Content-to-equipment relationships.
- Market and job linkage.
- Import/save validation.

Operational rules:

- Do not mix gamemode edits with addon package publishing.
- Publish addon revisions first, then update gamemode pins.
- Keep canonical exports under `../../gamemodes`.
- Treat gamemode import/save/sync as high-risk.
- Use `Export` before risky edits to capture a rollback point.
- Use `Import` later for the canonical `lifepunch.gamemode` file.
- Do not click `Sync Servers` until the gamemode has been validated and owner-approved.
- Never use `Reset to Vanilla` or `Delete Game Mode` without explicit owner approval.

Portal confirmation needed:

- Exact addon attachment UI fields.
- Revision pin behavior.
- Whether content rows can be edited directly from the gamemode page.
- Equipment and market row workflow.
- Exact JSON view structure.
