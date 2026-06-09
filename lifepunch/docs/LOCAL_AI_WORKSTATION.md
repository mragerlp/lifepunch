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

- This box is a **private local inference + RAG node** for LifePunch. It is **NOT** the
  source of truth.
- Source of truth stays the GitHub monorepo (`https://github.com/mragerlp/lifepunch`) on the
  primary dev machine (`C:\Users\jared\Projects\lifepunchaddons`). This box is a read-only or
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
- The Microsoft/local account credentials you want; a password-manager entry for this box.
- A USB stick for an offline recovery-key backup (Device Encryption / BitLocker).
- Keyboard, mouse, and a DisplayPort/HDMI or USB-C cable to a monitor (none are included).
- Confirm the codename (used for hostname + git author; and Tailscale if remote is ever added).

## 2. First-boot hardening (Windows 11 Home)

1. Windows Update → install everything, reboot until clean.
2. BIOS/firmware: update to latest Corsair/AMD firmware (Strix Halo perf + security fixes).
3. Rename the PC to the codename (Settings → System → About → Rename).
4. Accounts: strong password + Windows Hello PIN. No shared/blank local admin.
5. Storage encryption: enable **Device Encryption** (Settings → Privacy & security → Device
   encryption). Win11 Home only has Device Encryption, not full BitLocker management — if you
   want manageable full-disk encryption + remote policy, upgrade this box to **Win11 Pro**.
   Back up the recovery key to the USB stick + password manager (**not** to the cloud).
6. Firewall: keep Windows Firewall ON, default-deny inbound. Ports are opened later, **LAN-scoped only**.
7. Disable what you won't use (WAN-facing RDP, internet-facing SMB, etc.).
8. Review preinstalled AI apps (Jan.ai, Amuse.ai, Corsair AI Software Stack). Keep what we use;
   nothing here phones sensitive data out by default, but treat all models as local-only.

## 3. AMD graphics stack + Variable Graphics Memory (do this before loading big models)

1. The AMD Adrenalin / Ryzen AI driver ships preinstalled; update it from Corsair/AMD support.
2. **Set Variable Graphics Memory:** right-click desktop → **AMD Software: Adrenalin Edition →
   Performance → Tuning → Variable Graphics Memory → set to max (~48 GB on this SKU) → Restart.**
   This is what lets large models load fully on the iGPU.
3. Confirm the iGPU is seen as a **Vulkan** device (RADV/AMD) — the llama.cpp inference path.
4. (Advanced, optional) ROCm on Windows for `gfx1151` is still maturing — skip for v1; revisit
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
   - **Deferred (future discussion):** remote access from iPhone/laptop when away. The clean
     path then is **Tailscale** (WireGuard mesh — encrypted, no port forwarding, device-scoped
     ACLs); a 5-minute drop-in with no other changes. Not done now because it implies keeping
     the box always-on (power) for a need that doesn't exist this early. Revisit when remote
     use is real. **Never** port-forward the LLM server to the public internet.

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

## 8. Acceptance check (done = all true)

- [ ] Win11 updated, firmware updated, Device Encryption ON, recovery key backed up offline.
- [ ] AMD driver updated; **Variable Graphics Memory set to ~48 GB**; iGPU visible as Vulkan.
- [ ] A coding model loads (GPU Offload MAX + Flash Attention) and answers via the local
      OpenAI-compatible endpoint.
- [ ] Endpoint reachable from the primary machine over the **LAN**, **not** from the public internet.
- [ ] Monorepo cloned over SSH; `pull --rebase` works; secrets lane absent from this box.
- [ ] RAG index (if built) **enforces** the secret-exclude list and is **verified** (no `secure/`
      path or known secret appears in the index/manifest).

## Sources (verified June 2026)

- Corsair AI Workstation 300 product page + quick-start (CORSAIR AI Software Stack, preinstalled apps).
- BabelTechReviews deep-dive (LM Studio behavior, Variable Graphics Memory, Flash Attention, NPU results).
- AMD Ryzen AI Max+ "personal AI supercomputing" guide + Ryzen AI LLM docs (LM Studio settings, NPU/hybrid).
- AMD Lemonade (OpenAI-compatible local server; Vulkan + XDNA2 NPU backends).
- Strix Halo (`gfx1151`) community guidance (Vulkan most stable; ROCm maturing).
