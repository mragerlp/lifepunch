# Cursor + xAI Grok (manual setup)

**Updated:** July 2026  
**Key file:** `lifepunch/secure/xai.local.env` (gitignored)  
**Bootstrap:** `lifepunch/scripts/Install-CursorGrokXai.ps1`

Cursor does **not** expose a dedicated **xAI** provider. Grok uses the **OpenAI-compatible override** path.

---

## 1. Store the key (Red only)

Copy `lifepunch/secure/templates/xai.local.env.example` → `lifepunch/secure/xai.local.env`

```env
XAI_API_KEY=xai-...
XAI_API_BASE=https://api.x.ai/v1
XAI_GROK_MODEL=grok-build-0.1
```

Never commit `xai.local.env`. Rotate keys at [console.x.ai](https://console.x.ai/) if exposed.

---

## 2. Validate the key (chat/completions — what Cursor uses)

```powershell
cd C:\Users\jared\Projects\lifepunch
powershell -File lifepunch\scripts\Install-CursorGrokXai.ps1 -CopyKeyToClipboard
```

This tests **`POST /v1/chat/completions`**, copies the key to clipboard, and prints Cursor steps.

Responses-only test (optional): `lifepunch/scripts/Test-XaiGrokApi.ps1`

---

## 3. Cursor Settings → Models (manual)

| Field | Value |
|-------|--------|
| **OpenAI API Key** | Your **`xai-...`** key (same as `XAI_API_KEY`) |
| **Override OpenAI Base URL** | **On** → `https://api.x.ai/v1` |
| **Custom model** | Add **`grok-build-0.1`** (or your `XAI_GROK_MODEL`) and **enable** it |

**Common mistakes**

- Putting the xai key in **Anthropic** or a non-OpenAI slot → `Incorrect API key`
- Base URL `https://api.x.ai/v1/chat/completions` → wrong (base must be `/v1` only)
- Using an **OpenAI `sk-` key** while override points at x.ai
- Trailing spaces when pasting the key

---

## 4. Switching back to Claude / Opus

**Turn OFF** “Override OpenAI Base URL” before using Anthropic models.

Cursor applies the override globally; leaving it on breaks Claude (known Cursor limitation).

---

## 5. LifePunch routing law

| Tier | Tool | Grok use |
|------|------|----------|
| **Tier-2A** | Grok Build 1 | Planning, audits, bounded slices (`GROK REQUIRED`) |
| **Tier-1** | Opus | Architecture / economy — not Grok |
| **Tier-2B** | Composer/Auto | Routine work |

See `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`.

---

## Related

- `lifepunch/scripts/Test-XaiGrokApi.ps1` — `/v1/responses` smoke test
- `lifepunch/scripts/Install-CursorGrokXai.ps1` — `/v1/chat/completions` + Cursor checklist
