# Website

This folder is reserved for LifePunch website work.

Use it for website planning, integration notes, deployment procedures, and future source references for `https://lifepunch.co/`.

Do not put DXRP addon packages, gamemode exports, server records, or raw secrets here.

Future structure:

```text
website/
  admin-panel/
  config/
  discord/
  docs/
  integrations/
  profile/
  rewards/
  rules/
  steam-group/
  store/
  deployments/
  assets/
```

Secrets such as Cloudflare keys, website API tokens, or deployment credentials belong in `../secure`.

## Observed Public Site

Public URL: `https://lifepunch.co/`

Observed navigation:

- Home
- Rules
- Store
- Rewards
- Discord
- Steam Group
- Login

Observed authenticated controls:

- Panel
- Profile
- Logout

Observed login route:

```text
https://lifepunch.co/login?return=/
```

The login route enters the Steam sign-in flow. Treat Steam identity as the first source of truth for player verification work unless later backend/API review proves otherwise.

## Verification Readiness Notes

Future verification review should check:

- Steam login callback behavior.
- SteamID64 capture and storage.
- Discord account linking.
- `Members` rank assignment after Discord verification.
- VIP/EVIP fulfillment after store or donation events.
- Outdated API endpoints or webhook routes between website, Discord, and DXRP portal/server systems.

## Observed Logged-In Areas

Profile:

- URL: `https://lifepunch.co/profile`
- Steam/profile card.
- Discord Integration with linked account and `Unlink` action.
- Referral Program with total referrals and earned credit.

Owner/admin panel:

- URL: `https://lifepunch.co/admin`
- Ban Management.
- Transactions.
- Reward Claims.
- Email Inbox.
- System Settings.

Website admin panel notes live in `admin-panel/`. Auth/profile structure is tracked in `config/website-auth.json`.

## Store And Donations

Store page:

```text
https://lifepunch.co/store
```

Observed store flow:

- My Transactions.
- Select Package.
- Finalize with referral code.
- Pay Securely.
- Stripe checkout.

Observed packages include `VIP`, `EVIP`, and `SLP` currency options. Store behavior is tracked in `store/` and `config/store-page.json`.

Do not store raw transaction records, Stripe checkout URLs, customer emails, payment method details, Stripe API keys, or webhook signing secrets in Git.

## Rewards Page

Rewards page:

```text
https://lifepunch.co/rewards
```

Observed rewards:

- Join Discord Reward: one-time `$10,000` bonus.
- Weekend Bonus: recurring `$10,000` weekend claim.
- Monthly `$100,000` Giveaway: prize pool includes `$100,000`, EVIP Rank, and Builder.

Logged-out users are told they must log into Steam and authorize Discord for rewards. Rewards behavior is tracked in `rewards/` and `config/rewards-page.json`.

## Discord Page

Discord page:

```text
https://lifepunch.co/discord
```

Observed actions:

- Join Server.
- Copy Invite Link.

The page looks mostly the same logged out and logged in, except authenticated users see `Panel`, `Profile`, and `Logout` instead of `Login`. Website Discord behavior is tracked in `discord/` and `config/discord-page.json`.

## Steam Group

Current Steam Group link:

```text
https://steamcommunity.com/groups/lifepunchofficial
```

Current behavior:

- `Steam Group` links directly to Steam Community.

Future idea:

- Build a LifePunch-controlled landing page similar to the Discord page.
- Use Steam branding/logo.
- Ask the user to join the Steam Group before sending them to Steam.

This is tracked in `steam-group/` and `config/steam-group-page.json`. It is a low-priority website polish item and should not block infrastructure work.

## Rules Page

Rules page:

```text
https://lifepunch.co/rules
```

Example direct rule link:

```text
https://lifepunch.co/rules#no-staff-impersonation
```

The rules page is searchable, supports copying rule text, and supports direct links to individual rules. Rules documentation lives in `rules/`, with page behavior tracked in `config/rules-page.json`.
