# Website Steam Group

This folder documents the LifePunch website Steam Group navigation.

Current external URL:

```text
https://steamcommunity.com/groups/lifepunchofficial
```

Current behavior:

- The website `Steam Group` navigation button links directly to the Steam Community group.
- This is an external Steam page, not a LifePunch-controlled landing page.

Desired future behavior:

- Add a LifePunch-controlled page similar to `https://lifepunch.co/discord`.
- Show the Steam logo or Steam Group branding.
- Ask the user to join the Steam Group before sending them to Steam.
- Keep public actions simple, such as `Join Steam Group` and `Copy Steam Group Link`.

Priority:

- Low compared to core infrastructure, DXRP portal workflows, verification, API/webhook repair, and addon/server foundations.

Operational notes:

- Do not treat Steam Group membership as proof of DXRP identity unless it is tied back to SteamID64.
- Do not store private Steam account data or group member exports in Git.
- If future automation checks Steam Group membership, document the API route and secret handling before implementation.
