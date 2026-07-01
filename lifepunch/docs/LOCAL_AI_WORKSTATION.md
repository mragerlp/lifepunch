# LifePunch Local AI Workstation — Setup & Operating Guide

> Codename: **Cornerman** *(confirmed)*
> Hardware: Corsair AI Workstation 300 — Ryzen AI Max 385 / Radeon 8050S
> (AMD "Strix Halo", `gfx1151`), 64 GB LPDDR5X-8000 unified (up to ~48 GB as VRAM),
> 1 TB NVMe, 2.5 GbE + Wi-Fi 6E + USB4, ships **Windows 11 Home** preinstalled.
>
> This guide is for any agent or operator setting up or working on the local AI box.
> It does not change the law: the monorepo's `.cursor/rules` still govern. See
> `lifepunch/docs/AGENT_ONBOARDING.md` and `WORKSPACE_STRUCTURE.md` first.
>
> **Day-one setup:** paste `lifepunch/docs/DAY_ONE_AGENT_PROMPT.md` into the fresh Cursor
> instance on the new box. This file is its companion reference.

## TL;DR — it really is mostly plug-and-play

The Corsair AI Workstation 300 ships ready to run local AI: Windows 11 preinstalled, the
**CORSAIR AI Software Stack** (a web-based, no-CLI installer for LM Studio / Ollama / Python /
ComfyUI / Whisper with auto-configured presets), **Jan.ai preinstalled** with offline models,
and **Amuse.ai** for image generation. You can chat with a local model out of the box.

The part that is **NOT** turn-key — and the reason this doc exists — is the LifePunch
integration: a secure LAN pipeline to the monorepo, exposing the model as an endpoint our
tooling/MCP can use, and RAG over the repo with secrets excluded. Sections 6–7 own that.

## 0. Role of this machine (read first)

**Machine cast:** **VENGEANCE** = primary PC (source of truth). **Cornerman** = this box (home LAN).
**lifepunchnet** = always-on hosted server (DXRP ops, Whisper hub) — not Cornerman, not VENGEANCE.
See `AGENT_ONBOARDING.md` § Named systems.

- This box is a **private local inference + RAG node** for LifePunch. It is **NOT** the
  source of truth.
- Source of truth stays the GitHub monorepo (`https://github.com/mragerlp/lifepunch`) on the
  primary dev machine (`C:\Users\jared\Projects\LIFEPUNCH`). This box is a read-only or
  lane-scoped clone — never the canonical host.
- It runs local LLMs (coding assist, summarization, embeddings/RAG) and local MCP servers.
- Frontier cloud models still do the hardest agentic coding. This box handles **private,
  bulk, offline, and experimental** work — so sensitive data never has to leave the LAN.
- **Cornerman is Tier-3 in our model routing:** it does the cheap heavy-lifting — bulk
  summarize, log/RAG context-prep, first-draft boilerplate, classification — and feeds Cursor
  *distilled* context, not raw dumps. **Local preps, it does not decide:** spot-check any context
  a local model produces before it drives a real decision; a local summary is never the sole basis
  for a high-stakes change. (Routing law: `.cursor/rules/lifepunch-operating-context.mdc`.)
- **Honest scope / VRAM ceiling:** this is the **64 GB SKU** → Variable Graphics Memory caps
  at **~48 GB**. Comfortable for up to ~30B-class coding models at good quant; a 70B Q4
  (~40 GB) fits but runs slow. The "GPT-OSS 120B / Mistral 123B locally" headlines are the
  128 GB / Ryzen AI Max+ 395 SKU — **not** this box. A local 20–70B model is also meaningfully
  weaker than frontier cloud for deep multi-file work. Right tool for private/bulk/offline.
- **Compute backends:** llama.cpp (LM Studio / Ollama) runs on the **iGPU via Vulkan**. The
  **XDNA2 NPU (~50 TOPS)** is usable for LLMs through **AMD Lemonade / Ryzen AI ONNX-GenAI**
  (NPU-only or hybrid NPU+iGPU), and for ONNX vision/image workloads — not via llama.cpp.

## 1. Prep (have ready before/at first boot)

- A wired CAT6 run to the same LAN as the primary machine (use the 2.5 GbE port, not Wi-Fi).
- The account plan + a password-manager entry for this box (§2.3). **Owner's choice: a
  Microsoft/Outlook-tied admin** (ties the encrypted box to the owner's own identity for clear
  ownership / chain-of-custody of the IP) **with MFA on and all Windows sync disabled** — a local
  account (no email) is the equally-valid alternative.
- A USB stick for an offline recovery-key backup (Device Encryption / BitLocker).
- Keyboard, mouse, and a DisplayPort/HDMI or USB-C cable to a monitor (none are included).
- Confirm the codename (used for hostname + git author; and Tailscale if remote is ever added).

## 2. First-boot hardening (Windows 11 Home)

1. Windows Update → install everything, reboot until clean.
2. BIOS/firmware: update to latest Corsair/AMD firmware (Strix Halo perf + security fixes).
3. **Account — owner's policy: a Microsoft/Outlook-tied admin is acceptable and preferred** (it ties
   the encrypted box to the owner's own identity, which supports ownership / chain-of-custody of the
   IP). **Required when using a Microsoft account:** turn on **MFA** + a strong unique password (that
   account now both unlocks the box and escrows the BitLocker key), and disable every sync surface in
   step 4. A **local account** is the equally-valid alternative — OOBE: **Shift+F10** →
   `start ms-cxh:localonly`, or stay offline during setup; no email, so recovery is on you. Either
   way: add a **Windows Hello PIN**; no shared/blank admin. *The security that matters is identity
   isolation + no project secrets on the box (below), not the account type.*
4. **Disable ALL Windows sync.** (Your Outlook **mailbox** still syncs — that's your data; what we
   kill is system/file/settings sync.)
   - **OneDrive:** Settings → Apps → uninstall **Microsoft OneDrive** (or unlink + disable
     run-at-login); confirm Documents/Desktop/Pictures are **local**, not redirected. (Same rule that
     retired the OneDrive clone, §6.2.)
   - **Windows Backup:** Settings → Accounts → Windows backup → "Remember my apps" + "Remember my
     preferences" + OneDrive folder syncing → **Off**.
   - **Edge:** Settings → Profiles → **Sync → Off**.
   - **Clipboard:** Settings → System → Clipboard → sync across devices → **Off**.
   - **Cloud search:** Privacy & security → Search permissions → Cloud content search → **Off**.
   - **Activity history / Find My Device / Phone Link / Nearby sharing → Off.**
   - **Diagnostics:** Required only; tailored experiences + advertising ID → **Off**.
   - **Office / 365 apps (if installed):** default Save = **This PC**; don't connect cloud storage.
5. Rename the PC to the codename (Settings → System → About → Rename).
6. Storage encryption: this box runs **Win11 Pro/Enterprise = full managed BitLocker**. Turn on **BitLocker**
   for the OS drive (Control Panel → System and Security → **BitLocker Drive Encryption**, or search
   "BitLocker"). **Microsoft account:** the recovery key auto-escrows to account.microsoft.com
   (MFA-protected) — fine; also keep an **offline copy** (USB + password manager). **Local account:**
   no escrow → **save the key yourself** (USB + password manager, never the cloud). Pro also lets you
   pick **XTS-AES 256** and encrypt any second/data drive — do the OS drive now, add data-drive
   encryption only if one is attached. (Win11 Home would give *Device Encryption* only; lockout isn't
   catastrophic anyway — the box is a clone.)
7. Firewall: keep Windows Firewall ON, default-deny inbound. Ports are opened later, **LAN-scoped only**.
8. Disable what you won't use (WAN-facing RDP, internet-facing SMB, etc.).
9. Review preinstalled AI apps (Jan.ai, Amuse.ai, Corsair AI Software Stack). Keep what we use;
   nothing here phones sensitive data out by default, but treat all models as local-only.

## 3. AMD graphics stack + Variable Graphics Memory (do this before loading big models)

1. The AMD Adrenalin / Ryzen AI driver ships preinstalled; update it from Corsair.com product support
   → **Downloads** (for big-model loads AMD/Corsair may provide an Adrenalin **Preview/Press** driver).
2. **Set the unified-memory split — two ways (per the Corsair quick-start):**
   - **AMD Adrenalin (easy, dynamic):** right-click desktop → **AMD Software: Adrenalin Edition →
     Performance → Tuning → Variable Graphics Memory** → presets **Minimum 0.5 GB / Medium 32 GB /
     High (max)**, or **Custom** → set to the **max this SKU offers (~48 GB on the 64 GB box)** →
     accept the **restart** prompt. (Medium 32 GB is the safe fallback if ~48 GB causes instability.)
   - **BIOS UMA Frame Buffer (firmware floor):** at the **CORSAIR** boot logo press **DEL** →
     **Advanced** → **GFX Configuration** → **UMA Frame Buffer Size** → choose the size → **F10 →
     Save → restart.** Leave **iGPU Configuration**, **Resizable BAR (PCIE)**, and **Above 4G
     Decoding** at their preconfigured (enabled) values.
3. **Performance Level Selector (front-panel button):** cycles **Quiet / Balanced / Max** (on-screen
   toast confirms). Run in **Max** when serving models; Quiet/Balanced for idle.
4. Confirm the iGPU is seen as a **Vulkan** device (RADV/AMD) — the llama.cpp inference path.
5. (Advanced, optional) ROCm on Windows for `gfx1151` is still maturing — skip for v1; revisit
   via AMD's native `gfx1151` builds or Lemonade's ROCm backend if we later need max throughput.

## 4. Local LLM runtime (fastest path first)

### Option A — Corsair AI Software Stack + LM Studio (recommended, near zero-setup)

1. Open the **CORSAIR AI Software Stack** (preinstalled web assistant) → install **LM Studio**
   (and Python/Ollama if wanted). No CLI required.
2. Launch LM Studio → "Skip onboarding" → enable **Developer Mode** and **Start LLM service on
   login** (Settings).
3. Discover → **Runtime** → update the runtime; ensure the **Vulkan** backend is selected.
4. Download a coding-focused model that fits the ~48 GB budget (see Section 5).
5. Load with advanced settings: **GPU Offload = MAX**, **Flash Attention = ON** (required for
   large/high-context loads), set **Context Length** high, check **Remember settings**.
6. Enable the **local server** (OpenAI-compatible, default port `1234`). Bind to the LAN IP,
   **not** `0.0.0.0` public → endpoint `http://<codename>.local:1234/v1`.

### Option B — AMD Lemonade (recommended for our tooling/MCP endpoint + NPU)

- AMD's open-source local AI **server**, OpenAI-compatible, tuned for Ryzen AI / Strix Halo;
  supports **Vulkan (iGPU)** and the **XDNA2 NPU** (flm / ryzenai-llm backends), plus speech,
  embeddings, and reranking. Standalone Windows GUI installer.
- Best fit when we want a stable, AMD-optimized OpenAI endpoint for scripts/MCP/RAG and want to
  put light models on the NPU while the iGPU serves the big coding model.

### Option C — Ollama (good for headless / scripting)

1. Install via the Corsair stack or directly. Confirm GPU (Vulkan) use, not silent CPU fallback.
2. Set as needed: `OLLAMA_KEEP_ALIVE = 30m`, `OLLAMA_FLASH_ATTENTION = 1`, and `OLLAMA_HOST`
   to the LAN IP (only if the firewall scopes it to LAN — Section 6). Endpoint `:11434`.

### Option D — llama.cpp from source (only if we need max perf/control later)

- Build with `-DGGML_VULKAN=ON` and `AMDGPU_TARGETS="gfx1151"`. Track as advanced/optional.

## 5. Recommended models (~48 GB VRAM budget — confirm current best at install time)

- **Coding (primary):** a strong open coding model in the ~30B class at Q5/Q6
  (e.g. Qwen-Coder-30B-class). Fits with room for context.
- **Fast/utility:** a ~20B general model (e.g. gpt-oss-20b class) for quick tasks.
- **Embeddings (RAG):** a dedicated embeddings model (e.g. `bge-m3` / `nomic-embed-text`).
- **Stretch:** a 70B at Q4 (~40 GB) fits but is slow — use only when quality > speed.
- Always enable **Flash Attention**; it massively helps prompt processing at long context.

## 6. Secure data pipeline (no leaks, no spaghetti)

Principles: **LAN-only by default, encrypted in transit, one source of truth, secrets quarantined.**

1. **Networking / remote access**
   - **v1 DECISION: LAN-only.** Both machines are wired to the same router and talk over the
     2.5 GbE for the model endpoint, file transfer, and git. The box is used only when the
     owner is home. Nothing is exposed to the public internet. No Tailscale, no port forwarding.
   - Scope any opened firewall port (`1234`/`11434`/`8000`/`22`) to the **LAN subnet only**.
   - **Deferred (future discussion):** remote LLM access from VENGEANCE when away from home LAN.
     **Preferred path when needed:** [LM Link](https://lmstudio.ai/link) (LM Studio + Tailscale
     `tsnet`, E2E encrypted P2P, no public exposure) — remote models appear as local on
     `localhost:1234`. See §7d. Generic **Tailscale** tailnet remains an option for non–LM Studio
     services (SSH, RDP, file transfer). Not enabled in v1 — Cornerman is home-LAN + owner-present.
     Revisit when off-LAN Tier-3 use is real. **Never** port-forward the LLM server to the public internet.

2. **Code / repo sync (this box is a clone, not the master)**
   - Clone the monorepo over **git + SSH**. Treat it like any agent: always `git pull --rebase`,
     normal `push`, **NEVER** force-push. Single shared `main`.
   - Do **not** use OneDrive/cloud folder sync for the repo (cloud-sync corruption risk — the
     OneDrive clone was retired in June 2026 for exactly this reason).

3. **Secrets quarantine**
   - `lifepunch/secure/` and any API keys/webhooks/tokens **do not** belong on this box.
   - If a secret must cross, move it **encrypted** (age/GPG or an encrypted volume) over
     SSH/Tailscale, decrypt only at point of use, never commit it, and keep it out of model
     context and RAG indexes.
   - RAG/embeddings indexes are built **only** from non-secret repo content. The index build must
     **enforce an explicit exclude list** (`secure/`, `.env`, credentials, private player/economy
     data) rather than trusting convention — and the exclusions are **verified once** after the
     first index (grep the index/manifest for a known secret path; confirm zero hits).

4. **File transfer**
   - Use SSH/SFTP (`scp`, or rsync over SSH) for ad-hoc transfers. No USB sneakernet for
     sensitive data unless the drive is encrypted.

5. **Backup**
   - The box holds nothing irreplaceable (source of truth = monorepo). Back up only local-only
     artifacts (model configs, custom prompts, RAG indexes) to an encrypted location.

## 7. Using the local endpoint

- The OpenAI-compatible endpoint (LM Studio `:1234/v1`, Lemonade, or Ollama `:11434`) can be
  consumed by our own scripts, local MCP servers, RAG tooling, and any tool that accepts a
  custom base URL.
- Keep a short note of the endpoint URL + loaded model in dev docs (**not** in secrets).

## 7b. Remote access (LAN-only: SSH + RDP)

You drive Cornerman **from VENGEANCE** — you don't sit at the box. v1 stays LAN-only: every
rule is scoped to the LAN subnet + Private profile, nothing is exposed to the public internet,
no port-forwarding. Win11 **Pro/Enterprise** is what makes the RDP host available (Home can't host RDP).

**Two channels:**
- **SSH (OpenSSH Server)** — terminal + agent ops. Key auth only; client public key lives in
  `administrators_authorized_keys` (admin account), no private key/secret on the box. NOTE: the
  model endpoint is normally bound to the **LAN IP**, so VENGEANCE reaches it **directly** at
  `http://<LAN-IP>:1234/v1/...` — no tunnel needed. A tunnel (`ssh -L 11234:127.0.0.1:1234 cornerman`)
  is only for an endpoint bound to loopback.
- **RDP (Remote Desktop)** — occasional GUI (LM Studio, AMD Adrenalin). NLA required; uses the
  account **password** (not the Windows Hello PIN, which only works at the physical machine).

**Verified working 2026-06-10 (cornerman @ 192.168.1.227):** key-only SSH (`ssh cornerman` →
`cornerman\jared`, password + keyboard-interactive disabled), RDP reachable, and the LAN model
endpoint serving (`qwen2.5-coder-32b-instruct`). Firewall rules scoped to LocalSubnet/Private.

**Headless boot (no keyboard):** `Enable-CornermanHeadless.ps1` (once, elevated) sets auto-login
and registers `LifePunch-Cornerman-Headless-Startup` + `-Logon` so power/SSH/RDP/network settings
re-apply every reboot (`Install-CornermanHeadlessBoot.ps1` / `Invoke-CornermanHeadlessBoot.ps1`).
Log: `C:\lifepunch\cornerman\headless-boot.log`. Recovery: `lifepunch/scripts/CORNERMAN_HEADLESS_RECOVERY.txt`.

**Setup (Cornerman side, run elevated):**
```powershell
powershell -ExecutionPolicy Bypass -File "lifepunch\scripts\Enable-CornermanRemote.ps1" -SshPublicKey "<VENGEANCE public key>"
```
The script installs/starts OpenSSH Server, sets the default SSH shell to PowerShell, authorizes
the client key (admin account -> `administrators_authorized_keys`, locked ACLs), enables RDP with
NLA, and scopes both firewall rules to the LAN subnet (Private). It prints the hostname, LAN IP,
and the SSH host-key fingerprint to verify on first connect. Flags: `-Subnet '192.168.x.0/24'`,
`-DisablePasswordAuth` (key-only — only after you confirm key login works), `-SkipSSH` / `-SkipRDP`.

**VENGEANCE side (already prepared by the owner):** a dedicated key `~/.ssh/cornerman` + an SSH
config entry (`Host cornerman`). Connect with `ssh cornerman`, or `mstsc /v:cornerman` for RDP.
If the hostname doesn't resolve, replace `HostName cornerman` with the box's LAN IP.

**Off-LAN later (not v1):** prefer **LM Link** (§7d) for remote model access from VENGEANCE; add a
full **Tailscale** tailnet only if other services (SSH/RDP off-LAN) need it too. Firewall rules
stay bound to LAN or tailnet — never a raw public port-forward.

## 7c. Publishing Cornerman-authored work (read-only key -> patch handoff)

> **June 2026 — Green off-Cursor:** Cornerman no longer runs Cursor agents. Red ships on VENGEANCE;
> optional inbox drops via `Push-CornermanOffCursorHandoff.ps1`. See `CORNERMAN_OFF_CURSOR_HANDOFF.md`.
> Patch handoff below remains valid if Cursor returns on Green.

Cornerman clones over a **read-only deploy key by design** — it can commit locally but **cannot
push**, and no push credential (a secret) ever lives on the box. Anything Cornerman authors reaches
origin through VENGEANCE over the existing SSH channel:

1. **Cornerman:** commit locally on its clone (`C:\Projects\lifepunch`) with real messages. Then
   ping VENGEANCE: "N commits on top of `origin/main`, ready to publish" + the one-line subjects.
2. **VENGEANCE (Red / primary):** after Green pings, either `git pull origin main` if Red already
   pushed the same work, or run `lifepunch/scripts/Pull-CornermanPatches.ps1 -Push` (SSH
   `format-patch` → `C:\lifepunch\cornerman\outbox\patches\` → `git am --whitespace=nowarn` →
   `git push`). If `git am` fails on a duplicate (e.g. ulx already on `main`), `git am --abort` and
   `git apply --3way` the remaining patch from `.cornerman-patches/`. For binary assets, confirm
   first with `git apply --check --binary` before `am`.
3. **Cornerman:** `git fetch && git pull --rebase` — rebase detects the patches are already upstream
   and drops the local duplicates, landing exactly on `origin/main`. (Fallback, only if not
   auto-dropped and the working tree is clean: `git reset --hard origin/main`.)

This is the **standard path, not a workaround**: it keeps Cornerman read-only and secret-free while
preserving authorship. Verified 2026-06-10 (the terminal-icon + boot-wallpaper branding commits
were published this way). Doctrine: `.cursor/rules/lifepunch-operating-context.mdc` (Git workflow).

## 7d. LM Link (remote LM Studio models — preview, June 2026)

LM Studio's **LM Link** lets VENGEANCE use Cornerman's loaded models as if they were local — same
`localhost:1234` API, traffic over Tailscale's embedded `tsnet` (E2E encrypted, devices not exposed
to the public internet). Partnership: [lmstudio.ai/link](https://lmstudio.ai/link).

| Role | Machine | Job |
|------|---------|-----|
| Model host | Cornerman | Qwen distill / coder / embed on Green GPU |
| Client | VENGEANCE | LM Studio lists + routes to remote weights |

**Status:** captured for evaluation; **not enabled** (preview / batched access). v1 stays LAN +
`Send-CornermanWorkflow.ps1` + direct `http://192.168.1.227:1234` on subnet.

**Does not replace:** Claude Bridge (s&box visibility), lifepunchnet STT, inbox/outbox handoff, or
Tier-3 vs Opus routing — see `CORNERMAN_MODEL_ROUTING.md` § LM Link.

**When adopting:** Green `lms link enable` (+ headless boot hook if needed); Red LM Studio link to
Green; smoke-test `localhost:1234/v1` with a model whose weights live on Green only.

## 8. Optional layer — Odysseus AI workspace (EXPERIMENTAL, Tier-3)

> **June 2026 routing:** Odysseus + session hub live on **lifepunchnet** (RDP), not Cornerman.
> Cornerman keeps mic + voice relay only. Runbook: `lifepunch/server/LIFEPUNCHNET_RDP_ODYSSEUS.txt`.
> The constraints below still apply; substitute "this box" → **lifepunchnet** when installing.

[Odysseus](https://github.com/pewdiepie-archdaemon/odysseus) is a self-hosted AI workspace
(chat + agent + RAG/memory + "Cookbook" model-fit + deep research). It is a candidate **UI/agent
layer on top of** the local runtime in Section 4 — **not** a replacement for LM Studio/Lemonade/
Ollama, and **not** core infra. Treat it as an experimental Tier-3 prep tool until proven.

**Status:** trial-only (added June 2026). It is ~days old and its default `dev` branch is
explicitly unstable. **Pin the reviewed `main` commit `7690860ab1a7b50afd1887b5a61ca60f38961847`;
never track `dev` on this box.** Re-pin only after reviewing the diff.

### Hard constraints (do not relax without owner sign-off)

1. **LAN-only, no public exposure.** Keep `AUTH_ENABLED=true`, `LOCALHOST_BYPASS=false`. Bind to
   `127.0.0.1` (or a LAN IP with an mkcert cert per the README's HTTPS section). Never port-forward
   to the public internet. Same rule as the model endpoint (Section 6).
2. **Secrets stay quarantined (Section 6.3 still governs).** Do **NOT** configure Odysseus's
   email (IMAP/SMTP), API tokens, webhooks, or CalDAV with **real** LifePunch credentials. Those
   features are the whole tension with our "no secrets on this box" rule — leave them off or use
   throwaway test creds only. Point its model backend at the **local** Ollama/LM Studio endpoint,
   not a paid cloud key.
3. **Agent is sandboxed; it preps, it does not decide.** Do **not** give Odysseus's agent
   write-git credentials. Repo access is a **read-only / dev clone** for RAG + drafting only; any
   commit is human-reviewed and pushed by the operator, never by the agent (mirrors the
   operating-context "commit only your own lane / commits nothing it didn't author" rule).
4. **RAG = non-secret content only.** Build its ChromaDB/memory index over the same allow-listed,
   secret-excluded repo content as Section 6.3, and verify the exclusions once.
5. **License — AGPL-3.0-or-later.** Unmodified internal use is fine. **Do NOT modify Odysseus and
   then expose it over any network** (even LAN/Tailscale to the partner) without first resolving
   AGPL §13 — the network-use clause can obligate us to publish our modified source. Flag to the
   owner before any fork-and-serve. (Repo metadata is contradictory — sidebar shows MIT, README
   footer shows AGPL; treat the stricter AGPL as binding until confirmed.)

### Windows / AMD reality on this box

- GPU **serving** via Odysseus (vLLM/SGLang) is CUDA/ROCm and needs Linux/WSL2; ROCm on `gfx1151`
  is immature (Section 3.4). So run Odysseus as the **UI/agent over the existing Ollama-Vulkan
  endpoint** (`http://localhost:11434/v1` in its Settings), and use **Cookbook only as advisory**
  model-fit, not as the serving path.
- Native Windows launcher (pinned commit):

  ```powershell
  git clone https://github.com/pewdiepie-archdaemon/odysseus.git
  cd odysseus
  git checkout 7690860ab1a7b50afd1887b5a61ca60f38961847
  powershell -ExecutionPolicy Bypass -File .\launch-windows.ps1
  # open http://localhost:7000 ; grab the admin password from the terminal; change it in Settings
  ```

- If it doesn't earn its place over the plain LM Studio/Ollama + scripted RAG plan, **drop it** —
  don't run two competing stacks (infra-level spaghetti).

## 8b. Scope guardrails — common "AI box" advice to REJECT

Generic setup guides (and some LLM answers) push steps that conflict with Cornerman's role as a
**Tier-3 clone/prep node**. Hold the line:

- **Do NOT make Cornerman the s&box editor / primary dev box.** No Steam + s&box SDK + ModelDoc +
  Source2Viewer build-out here. The editor runs on the Primary PC / Steam checkout
  (`D:\Steam\steamapps\common\sbox\dxrp`). Cornerman gets the **repo clone for RAG/codegen only**.
- **Do NOT wire raw cloud API keys (Anthropic/OpenAI) into tools on this box.** That's a secret on a
  no-secrets box *and* separate spend outside the Cursor Ultra pool. Cursor here uses the Cursor
  account; local serving uses local models.
- **Do NOT fork per-project `/AI` doc trees.** Grounding already lives once in `.cursor/rules` +
  `lifepunch/docs`. Adding parallel `AI/README.md` etc. violates the single-source-of-truth rule.
- **Win11 Home (preinstalled) is fine** — no mandatory fresh "Win11 Pro" reinstall. Pro is optional
  only if we later want managed BitLocker/remote policy (Section 2.5).
- **Prefer native Odysseus + host Ollama over Docker-GPU on this AMD box.** Docker GPU passthrough
  for the Radeon iGPU on Windows is weak/ROCm-immature; the native launcher pointing at the host
  Ollama endpoint is the reliable path (Section 8).
- **`mistral-medium` is an API model, not a local Ollama pull** — use real local models (Section 5).

**Worth adopting from generic guides:** update-everything-first (Windows/AMD/BIOS — Section 2–3),
install **Git + Git LFS + Git Credential Manager** (the monorepo uses LFS), the **local-vs-Opus work
split** (already our routing law), and the "treat it as another developer / dedicated AI appliance"
framing — that's exactly the Cornerman concept.

## 9. Acceptance check (done = all true)

- [ ] Win11 updated, firmware updated, Device Encryption ON, recovery key backed up offline.
- [ ] AMD driver updated; **Variable Graphics Memory set to ~48 GB**; iGPU visible as Vulkan.
- [ ] A coding model loads (GPU Offload MAX + Flash Attention) and answers via the local
      OpenAI-compatible endpoint.
- [ ] Endpoint reachable from the primary machine over the **LAN**, **not** from the public internet.
- [ ] (If remote access enabled) SSH + RDP reachable from VENGEANCE over the **LAN only**; firewall
      rules scoped to the LAN subnet/Private; SSH host-key fingerprint verified; key login works.
- [ ] Monorepo cloned over SSH; `pull --rebase` works; secrets lane absent from this box.
- [ ] RAG index (if built) **enforces** the secret-exclude list and is **verified** (no `secure/`
      path or known secret appears in the index/manifest).
- [ ] If Odysseus is trialed: pinned `main` commit, `AUTH_ENABLED=true`, bound LAN/loopback only,
      **no real email/API/webhook/CalDAV creds**, agent has **no write-git creds**, backend points
      at the local Ollama/LM Studio endpoint.

## 10. Branding (OPTIONAL, cosmetic — does not affect security)

Hacker Job **machine uniforms** live in `lifepunch/branding/lifepunch-ops/` (`OUTFITS.md`).
**VENGEANCE** = Enhanced Hacker Terminal (red). **Cornerman** = Hacker Terminal (green).
**lifepunchnet** = Government Terminal (cyan, `lifepunch@lifepunch.net`). OneDrive outfit folders
are canonical art; `Sync-OutfitsFromOneDrive.ps1` → `Apply-LifePunchOpsConsole.ps1 -Machine <node>`.
Cosmetic only; no security impact.

## Sources (verified June 2026)

- Corsair AI Workstation 300 product page + quick-start (CORSAIR AI Software Stack, preinstalled apps).
- BabelTechReviews deep-dive (LM Studio behavior, Variable Graphics Memory, Flash Attention, NPU results).
- AMD Ryzen AI Max+ "personal AI supercomputing" guide + Ryzen AI LLM docs (LM Studio settings, NPU/hybrid).
- AMD Lemonade (OpenAI-compatible local server; Vulkan + XDNA2 NPU backends).
- Strix Halo (`gfx1151`) community guidance (Vulkan most stable; ROCm maturing).
