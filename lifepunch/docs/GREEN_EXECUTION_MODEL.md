# LifePunch — Green execution model (three agent groups)

> **July 2026 canon.** Bloodwave orchestrates on **Red**; **Cornerman** warms/distills and executes
> heavy agent work; **MacBook** is Green control plane + **Design Architect (ChatGPT)** · RDP → Cornerman.
> **Red always owns runtime truth** (s&box, bridge, flatgrass proof, primary publish).

Every agent session: **`git pull --rebase`** on the machine you are on before work.

---

## Three agent groups

| Group | Machine | Repo path | Primary job |
|-------|---------|-----------|-------------|
| **Red** | VENGEANCE | `C:\Users\jared\Projects\lifepunchdxrp` | Orchestrate · compose · s&box editor · bridge · Host Play · proof · **git push** |
| **Green B** | Cornerman (`192.168.1.229`) | `C:\Projects\lifepunch` | Warm LM · distill · **heavy agent implementation** · bridge MCP (via SMB to Red) |
| **Green A** | MacBook (macOS) | `~/Projects/lifepunch` | **Design Architect (ChatGPT)** · control plane · Cursor + Copilot · RDP → Cornerman |

**lifepunchnet** (blue) is a separate ops lane — not part of this Green/Red dev triangle.

---

## Workflow patterns (all valid)

Pick per slice — no single mandatory path.

1. **Compose on Red → execute on Cornerman → proof on Red → push from Red** (default heavy slice)
2. **Plan on Mac Green A → RDP Cornerman Green B for work → proof on Red**
3. **Everything at Red desk** — skip Cornerman when zero handoff desired
4. **Cornerman distill only** — prep inbox; implement elsewhere

---

## Sync law (mandatory)

> **Whoever did heavy work — the other nodes pull before the next session.**

| Heavy work on… | Before working elsewhere… |
|----------------|---------------------------|
| **Cornerman** | Red **`git pull`** or **`Pull-CornermanPatches.ps1 -Push`** · Mac **`git pull --rebase`** |
| **Red** | Cornerman + Mac **`git pull --rebase`** |
| **Mac** | Red + Cornerman pull if Mac pushed |

Cornerman: **read-only deploy key** — local commits OK; origin via **patch-handoff** on Red
(`handoff/GREEN_PATCH_HANDOFF_QUICKREF.txt`).

---

## IDE + MCP by surface

| Surface | Cursor MCP 3/3 | Copilot MCP 3/3 | Reload after bridge |
|---------|----------------|-----------------|---------------------|
| **Red** | `sbox` · `sbox-editor` · `sbox-jtc` (+ `cornerman-lm` in full capacity) | In-editor · Red stack | Cursor reload as needed |
| **Cornerman Cursor** | `sbox` · `sbox-editor` · `cornerman-lm` | — | **Reload Window** |
| **Cornerman Copilot** | — | `claudebridge` · `chromr-mcp` · `jct-server` | **No reload** — project open |
| **Mac native** | Not wired to Red bridge by default | — | — |

Preflight on Cornerman (Red editor up first): **Map → Tunnel → `Test-Path \\VENGEANCE\SboxBridgeIpc\status.json`**

---

## Fixed laws (any workflow)

- **Flatgrass proof** = Red Host Play — not Cornerman alone, not Mac Green A alone
- **Owner GO** before hub code commits (H4/H5 etc.)
- **Commit hygiene** — `mragerlp <mragerlp@gmail.com>` · no AI trailers · propose scope first
- **LP lane** in monorepo only — DXRP upstream in separate repo/session

---

## Agent grounding pastes (copy-paste index)

**Master index:** `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md`

| Group | Cursor | Copilot |
|-------|--------|---------|
| Red | `RED_CURSOR_GROUNDING_PASTE.txt` | `RED_COPILOT_GROUNDING_PASTE.txt` |
| Cornerman (Green B) | `GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt` | `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt` |
| Mac (Green A) | `MAC_GREEN_CURSOR_GROUNDING_PASTE.txt` | `MAC_GREEN_COPILOT_GROUNDING_PASTE.txt` |

Short first messages: `RED_SESSION_FIRST_MESSAGE.txt` · `GREEN_*_SESSION_FIRST_MESSAGE.txt` · `MAC_SESSION_FIRST_MESSAGE.txt`

Full depth: `CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` · `COPILOT_NEW_SESSION_BOOTSTRAP.txt` · `GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt`

---

## Related docs

- `MACHINE_CAST.md` — codenames + RGB
- `RED_FULL_CAPACITY_BOOT.md` — Red editor + bridge
- `GREEN_SMB_BOOT_PASTE.md` — Cornerman SMB law
- `LOCAL_AI_WORKSTATION.md` §7c — patch-handoff
- `AGENT_ONBOARDING.md` · `AGENT_PROMPT.md` Block 0 / A / D / M
