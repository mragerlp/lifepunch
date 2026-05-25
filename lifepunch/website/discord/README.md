# Website Discord Page

This folder documents the LifePunch website Discord landing page.

Observed URL:

```text
https://lifepunch.co/discord
```

Observed page subtitle:

```text
Join Our Community
```

Observed logged-out state:

- Header shows `Login`.
- Main card says `Join The Community`.
- Description: stay updated, report rulebreakers, and chat with the community.
- Actions:
  - `Join Server`
  - `Copy Invite Link`

Observed logged-in state:

- Header shows `Panel`, `Profile`, and `Logout`.
- Main card still says `Join The Community`.
- Actions remain:
  - `Join Server`
  - `Copy Invite Link`

Operational notes:

- This page is a public/community entry point, not the Discord verification flow by itself.
- Discord verification and rewards are tracked through `../rewards/`, `../profile/`, and `../../discord/`.
- Do not store private invite management tokens, bot tokens, or private Discord IDs in Git.
- If the public invite URL changes, update website config and Discord docs together.
