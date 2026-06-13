# Player And Supporter Ranks

This folder tracks non-administrative DXRP rank baselines.

Use this for regular player and supporter ranks such as `None`, `Members`, `VIP`, and `EVIP`.

**Addon-era OG ranks (planned):** `VIP (OG)` and `EVIP (OG)` for early donors at first LPDXRP addon launch — see `lifepunch/docs/LPDXRP_OG_SUPPORTERS.md`.

Current regular player baselines:

- `none-rank.json`
- `members-rank.json`

Current supporter baselines:

- `vip-rank.json`
- `evip-rank.json`

Rules:

- Supporter ranks are not administrative roles.
- Regular player ranks are not administrative roles.
- `None` is the default normal player rank.
- Supporter rank records must not contain payment secrets, transaction records, or private donor data.
- `None` means no access.
- The rank named `None` is separate from the permission state `none`.
- Regular player ranks must not have wildcard permissions.
- Supporter ranks must not have wildcard permissions.
- Any supporter benefit that affects economy, inventory, or progression needs owner review before automation.
- Discord verification rank sync needs owner review before automation.
