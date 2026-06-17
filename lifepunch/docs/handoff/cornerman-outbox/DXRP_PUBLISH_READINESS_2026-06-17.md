# DXRP publish readiness map - 2026-06-17

Future ship gate per package (document only).

| Package | repoIdent | Entities ready (A bucket) | Blockers |
|---------|-----------|---------------------------|----------|
| lpbanker | bankerjob | 3 | No _c compile ├é┬╖ no prepare-publish yet |
| lpbitcoin | bitcoinmining | 2 | No _c compile ├é┬╖ no prepare-publish yet |
| lpblackmarket | blackmarketdealer | 1 | No _c compile ├é┬╖ no prepare-publish yet |
| lpchemist | advanceddrugprocessing | 3 | No _c compile ├é┬╖ no prepare-publish yet |
| lpdrugdrops | TBD | 3 | No _c compile ├é┬╖ no prepare-publish yet |
| lpflashdrive | TBD | 2 | No _c compile ├é┬╖ no prepare-publish yet |
| lpgovernment | governmentdatacenter | 2 | No _c compile ├é┬╖ no prepare-publish yet |
| lphacker | hackerjob | 4 | No _c compile ├é┬╖ no prepare-publish yet |
| lppolice | governmentdatacenter | 1 | No _c compile ├é┬╖ no prepare-publish yet |
| lpweapons | ak47 | 3 | No _c compile ├é┬╖ no prepare-publish yet |

## Per-package checklist (all)
- [ ] All entity vmdl/vmat compile to _c
- [ ] `prepare-publish.ps1 -Addon <repoIdent>`
- [ ] Upload Assets + Code from `.dxrp-publish/upload`
- [ ] Portal content row + gamemode pin
