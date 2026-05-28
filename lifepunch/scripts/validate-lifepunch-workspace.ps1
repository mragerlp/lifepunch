$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Errors = New-Object System.Collections.Generic.List[string]

function Add-WorkspaceError {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
}

function Test-JsonFile {
    param(
        [string]$RelativePath,
        [string]$ExpectedSchemaVersion = '1'
    )

    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-WorkspaceError "Missing required file: $RelativePath"
        return $null
    }

    try {
        $Json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        if ([string]$Json.schemaVersion -ne $ExpectedSchemaVersion) {
            Add-WorkspaceError "$RelativePath must use schemaVersion $ExpectedSchemaVersion"
        }
        return $Json
    } catch {
        Add-WorkspaceError "$RelativePath is not valid JSON: $($_.Exception.Message)"
        return $null
    }
}

foreach ($Directory in @(
    'addons',
    'gamemode',
    'server',
    'maps',
    'portal',
    'admin-panel',
    'players',
    'economy',
    'audit',
    'website',
    'discord',
    'webhooks',
    'API',
    'secure',
    'docs',
    'templates',
    'scripts'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $Directory) -PathType Container)) {
        Add-WorkspaceError "Missing required LifePunch directory: $Directory"
    }
}

foreach ($File in @(
    'README.md',
    'docs\WORKSPACE_STRUCTURE.md',
    'docs\COMPLIANCE.md',
    'docs\DXRP_DOCS_REFERENCE.md',
    'maps\README.md',
    'players\README.md',
    'economy\README.md',
    'audit\README.md',
    'website\README.md',
    'website\profile\README.md',
    'website\admin-panel\README.md',
    'website\discord\README.md',
    'website\rules\README.md',
    'website\rules\current-rules.md',
    'website\rewards\README.md',
    'website\steam-group\README.md',
    'website\store\README.md',
    'website\config\website-auth.json',
    'website\config\discord-page.json',
    'website\config\rules-page.json',
    'website\config\rewards-page.json',
    'website\config\steam-group-page.json',
    'website\config\store-page.json',
    'discord\README.md',
    'webhooks\README.md',
    'API\README.md',
    'secure\README.md',
    'secure\.gitignore',
    'secure\templates\secrets-inventory.md',
    'secure\templates\local-env.example',
    'templates\portal-review.md',
    'templates\change-request.md',
    'templates\incident-report.md',
    'templates\server-change.md',
    'templates\economy-change.md',
    'templates\admin-audit.md',
    'templates\player-profile-review.md',
    'templates\gamemode-change.md',
    'players\config\player-profile-fields.json',
    'players\ranks\README.md',
    'players\ranks\none-rank.json',
    'players\ranks\members-rank.json',
    'players\ranks\vip-rank.json',
    'players\ranks\evip-rank.json',
    'admin-panel\roles\owner.md',
    'admin-panel\permissions\owner-rank.json',
    'admin-panel\permissions\super-admin-rank.json',
    'admin-panel\permissions\community-manager-rank.json',
    'admin-panel\permissions\admin-rank.json',
    'admin-panel\permissions\moderator-rank.json',
    'admin-panel\permissions\developer-rank.json'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $File) -PathType Leaf)) {
        Add-WorkspaceError "Missing required LifePunch file: $File"
    }
}

$PortalTabs = Test-JsonFile 'portal\config\portal-tabs.json'
$NetworkSettings = Test-JsonFile 'portal\config\network-settings.json'
$Dashboard = Test-JsonFile 'portal\config\dashboard.json'
$WebsiteAuth = Test-JsonFile 'website\config\website-auth.json'
$DiscordPage = Test-JsonFile 'website\config\discord-page.json'
$RulesPage = Test-JsonFile 'website\config\rules-page.json'
$RewardsPage = Test-JsonFile 'website\config\rewards-page.json'
$SteamGroupPage = Test-JsonFile 'website\config\steam-group-page.json'
$StorePage = Test-JsonFile 'website\config\store-page.json'
$PlayerProfileFields = Test-JsonFile 'players\config\player-profile-fields.json'
$NoneRank = Test-JsonFile 'players\ranks\none-rank.json'
$MembersRank = Test-JsonFile 'players\ranks\members-rank.json'
$VipRank = Test-JsonFile 'players\ranks\vip-rank.json'
$EvipRank = Test-JsonFile 'players\ranks\evip-rank.json'
$AdminRoles = Test-JsonFile 'admin-panel\config\admin-roles.json'
$OwnerRank = Test-JsonFile 'admin-panel\permissions\owner-rank.json'
$SuperAdminRank = Test-JsonFile 'admin-panel\permissions\super-admin-rank.json'
$CommunityManagerRank = Test-JsonFile 'admin-panel\permissions\community-manager-rank.json'
$AdminRank = Test-JsonFile 'admin-panel\permissions\admin-rank.json'
$ModeratorRank = Test-JsonFile 'admin-panel\permissions\moderator-rank.json'
$DeveloperRank = Test-JsonFile 'admin-panel\permissions\developer-rank.json'
$AuditTaxonomy = Test-JsonFile 'audit\config\audit-taxonomy.json'

if ($null -ne $PortalTabs) {
    foreach ($PublicNav in @($PortalTabs.publicNavigation)) {
        $Folder = [string]$PublicNav.folder
        if ([string]::IsNullOrWhiteSpace($Folder)) {
            Add-WorkspaceError 'Public navigation entry is missing folder'
            continue
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root $Folder) -PathType Container)) {
            Add-WorkspaceError "Missing public navigation folder: $Folder"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root "$Folder\README.md") -PathType Leaf)) {
            Add-WorkspaceError "Missing public navigation README: $Folder\README.md"
        }
    }

    foreach ($Tab in @($PortalTabs.tabs)) {
        $Folder = [string]$Tab.folder
        if ([string]::IsNullOrWhiteSpace($Folder)) {
            Add-WorkspaceError 'Portal tab entry is missing folder'
            continue
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root $Folder) -PathType Container)) {
            Add-WorkspaceError "Missing portal tab folder: $Folder"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root "$Folder\README.md") -PathType Leaf)) {
            Add-WorkspaceError "Missing portal tab README: $Folder\README.md"
        }
    }

    foreach ($MenuItem in @('Maps', 'Rulesets', 'Ranks', 'Inventory', 'Addons', 'Factions', 'Sanctions')) {
        $Match = @($PortalTabs.overflowMenu) | Where-Object { $_.name -eq $MenuItem } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-WorkspaceError "portal\config\portal-tabs.json overflow menu is missing '$MenuItem'"
            continue
        }
        $Folder = [string]$Match.folder
        if ([string]::IsNullOrWhiteSpace($Folder)) {
            Add-WorkspaceError "Portal overflow menu entry '$MenuItem' is missing folder"
            continue
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root $Folder) -PathType Container)) {
            Add-WorkspaceError "Missing portal overflow menu folder: $Folder"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root "$Folder\README.md") -PathType Leaf)) {
            Add-WorkspaceError "Missing portal overflow menu README: $Folder\README.md"
        }
    }
}

if ($null -ne $NetworkSettings) {
    if ($NetworkSettings.network.name -ne 'LifePunch') {
        Add-WorkspaceError "portal\config\network-settings.json network name must be LifePunch"
    }
    if ($NetworkSettings.network.identifier -ne 'lifepunch') {
        Add-WorkspaceError "portal\config\network-settings.json network identifier must be lifepunch"
    }
    foreach ($WebhookName in @('Mod Log', 'Media', 'Chat Log')) {
        $Match = @($NetworkSettings.discordWebhooks) | Where-Object { $_.name -eq $WebhookName } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-WorkspaceError "portal\config\network-settings.json is missing Discord webhook category '$WebhookName'"
        }
    }
}

if ($null -ne $Dashboard) {
    foreach ($ServerId in @('lifepunchmainserver', 'lifepunchdevelopment')) {
        $Match = @($Dashboard.serverRows) | Where-Object { $_.serverId -eq $ServerId } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-WorkspaceError "portal\config\dashboard.json is missing live overview server '$ServerId'"
        }
    }
    foreach ($MenuItem in @('Maps', 'Rulesets', 'Ranks', 'Inventory', 'Addons', 'Factions', 'Sanctions')) {
        if ($MenuItem -notin @($Dashboard.observedOverflowMenu)) {
            Add-WorkspaceError "portal\config\dashboard.json observed overflow menu is missing '$MenuItem'"
        }
    }
}

if ($null -ne $WebsiteAuth) {
    if ($WebsiteAuth.site.baseUrl -ne 'https://lifepunch.co') {
        Add-WorkspaceError "website\config\website-auth.json baseUrl must be https://lifepunch.co"
    }
    if ($WebsiteAuth.site.authProvider -ne 'Steam') {
        Add-WorkspaceError "website\config\website-auth.json auth provider must be Steam"
    }
    if ($WebsiteAuth.site.stablePlayerIdentifier -ne 'SteamID64') {
        Add-WorkspaceError "website\config\website-auth.json stable player identifier must be SteamID64"
    }
    foreach ($Control in @('Panel', 'Profile', 'Logout')) {
        if ($Control -notin @($WebsiteAuth.authenticatedControls)) {
            Add-WorkspaceError "website\config\website-auth.json authenticated controls missing '$Control'"
        }
    }
    foreach ($ProfileSection in @('Steam/profile card', 'Discord Integration', 'Referral Program')) {
        if ($ProfileSection -notin @($WebsiteAuth.profilePage.observedSections)) {
            Add-WorkspaceError "website\config\website-auth.json profile page missing '$ProfileSection'"
        }
    }
    foreach ($ModuleName in @('Ban Management', 'Transactions', 'Reward Claims', 'Email Inbox', 'System Settings')) {
        $Match = @($WebsiteAuth.adminPanel.modules) | Where-Object { $_.name -eq $ModuleName } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-WorkspaceError "website\config\website-auth.json admin panel missing '$ModuleName'"
        }
    }
    if ('Do not store raw tokens, emails, Discord IDs, purchase records, or session data in Git.' -notin @($WebsiteAuth.securityRules)) {
        Add-WorkspaceError "website\config\website-auth.json must include website secret storage rule"
    }
}

if ($null -ne $DiscordPage) {
    if ($DiscordPage.page.url -ne 'https://lifepunch.co/discord') {
        Add-WorkspaceError "website\config\discord-page.json URL must be https://lifepunch.co/discord"
    }
    if ($DiscordPage.loggedOutState.headerControl -ne 'Login') {
        Add-WorkspaceError "website\config\discord-page.json logged-out header must be Login"
    }
    foreach ($Action in @('Join Server', 'Copy Invite Link')) {
        if ($Action -notin @($DiscordPage.loggedOutState.actions)) {
            Add-WorkspaceError "website\config\discord-page.json logged-out actions missing '$Action'"
        }
        if ($Action -notin @($DiscordPage.loggedInState.actions)) {
            Add-WorkspaceError "website\config\discord-page.json logged-in actions missing '$Action'"
        }
    }
    foreach ($Control in @('Panel', 'Profile', 'Logout')) {
        if ($Control -notin @($DiscordPage.loggedInState.authenticatedControls)) {
            Add-WorkspaceError "website\config\discord-page.json logged-in controls missing '$Control'"
        }
    }
    if ('Do not store Discord bot tokens in Git.' -notin @($DiscordPage.securityRules)) {
        Add-WorkspaceError "website\config\discord-page.json must include Discord bot token storage rule"
    }
}

if ($null -ne $RulesPage) {
    if ($RulesPage.page.url -ne 'https://lifepunch.co/rules') {
        Add-WorkspaceError "website\config\rules-page.json URL must be https://lifepunch.co/rules"
    }
    if ($RulesPage.features.searchable -ne $true) {
        Add-WorkspaceError "website\config\rules-page.json must mark rules as searchable"
    }
    if ($RulesPage.features.copyRuleText -ne $true) {
        Add-WorkspaceError "website\config\rules-page.json must mark rule text as copyable"
    }
    if ($RulesPage.features.directRuleLinks -ne $true) {
        Add-WorkspaceError "website\config\rules-page.json must mark direct rule links as supported"
    }
    $NoStaffImpersonation = @($RulesPage.exampleDirectLinks) | Where-Object { $_.slug -eq 'no-staff-impersonation' } | Select-Object -First 1
    if ($null -eq $NoStaffImpersonation) {
        Add-WorkspaceError "website\config\rules-page.json must include no-staff-impersonation example link"
    } elseif ($NoStaffImpersonation.url -ne 'https://lifepunch.co/rules#no-staff-impersonation') {
        Add-WorkspaceError "website\config\rules-page.json no-staff-impersonation URL mismatch"
    }
    foreach ($Section in @('Serverwide Rules', 'Basic RP Rules', 'Basic RP Guidelines', 'Building Rules', 'Job Rules', 'Raiding, Mugging, & Cooldowns', 'Minging & Trolling')) {
        if ($Section -notin @($RulesPage.observedSections)) {
            Add-WorkspaceError "website\config\rules-page.json observed sections missing '$Section'"
        }
    }
    if ($RulesPage.reviewPolicy.stableSlugsRequired -ne $true) {
        Add-WorkspaceError "website\config\rules-page.json must require stable rule slugs"
    }
}

if ($null -ne $RewardsPage) {
    if ($RewardsPage.page.url -ne 'https://lifepunch.co/rewards') {
        Add-WorkspaceError "website\config\rewards-page.json URL must be https://lifepunch.co/rewards"
    }
    if ($RewardsPage.page.authProvider -ne 'Steam') {
        Add-WorkspaceError "website\config\rewards-page.json auth provider must be Steam"
    }
    if ($RewardsPage.page.discordAuthorizationRequired -ne $true) {
        Add-WorkspaceError "website\config\rewards-page.json must require Discord authorization"
    }
    if ($RewardsPage.loggedOutState.message -ne 'You must be logged into Steam and authorize your Discord for rewards.') {
        Add-WorkspaceError "website\config\rewards-page.json logged-out message mismatch"
    }
    foreach ($RewardName in @('Join Discord Reward', 'Weekend Bonus', 'Monthly $100,000 Giveaway')) {
        $Match = @($RewardsPage.rewardCards) | Where-Object { $_.name -eq $RewardName } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-WorkspaceError "website\config\rewards-page.json reward cards missing '$RewardName'"
        }
    }
    foreach ($StatusField in @('Ends in', 'Monthly entry count', 'Participant avatars', "Last month's winner")) {
        if ($StatusField -notin @($RewardsPage.giveawayStatus.fields)) {
            Add-WorkspaceError "website\config\rewards-page.json giveaway status missing '$StatusField'"
        }
    }
    if ($RewardsPage.giveawayStatus.doNotStoreRawParticipantsInGit -ne $true) {
        Add-WorkspaceError "website\config\rewards-page.json must forbid raw participant storage in Git"
    }
    if ('Currency and rank reward fulfillment requires owner review before automation changes.' -notin @($RewardsPage.securityRules)) {
        Add-WorkspaceError "website\config\rewards-page.json must require owner review for reward fulfillment"
    }
}

if ($null -ne $SteamGroupPage) {
    if ($SteamGroupPage.currentBehavior.externalUrl -ne 'https://steamcommunity.com/groups/lifepunchofficial') {
        Add-WorkspaceError "website\config\steam-group-page.json Steam Group URL mismatch"
    }
    if ($SteamGroupPage.currentBehavior.type -ne 'external-direct-link') {
        Add-WorkspaceError "website\config\steam-group-page.json current behavior must be external-direct-link"
    }
    if ($SteamGroupPage.desiredFuturePage.priority -ne 'low') {
        Add-WorkspaceError "website\config\steam-group-page.json desired future page priority must be low"
    }
    foreach ($Action in @('Join Steam Group', 'Copy Steam Group Link')) {
        if ($Action -notin @($SteamGroupPage.desiredFuturePage.suggestedActions)) {
            Add-WorkspaceError "website\config\steam-group-page.json suggested actions missing '$Action'"
        }
    }
    if ($SteamGroupPage.foundationReadiness.blocksCoreInfrastructure -ne $false) {
        Add-WorkspaceError "website\config\steam-group-page.json must not block core infrastructure"
    }
    if ('Do not store Steam API keys in Git.' -notin @($SteamGroupPage.securityRules)) {
        Add-WorkspaceError "website\config\steam-group-page.json must include Steam API key storage rule"
    }
}

if ($null -ne $StorePage) {
    if ($StorePage.page.url -ne 'https://lifepunch.co/store') {
        Add-WorkspaceError "website\config\store-page.json URL must be https://lifepunch.co/store"
    }
    if ($StorePage.page.paymentProcessor -ne 'Stripe') {
        Add-WorkspaceError "website\config\store-page.json payment processor must be Stripe"
    }
    if ($StorePage.page.stablePlayerIdentifier -ne 'SteamID64') {
        Add-WorkspaceError "website\config\store-page.json stable player identifier must be SteamID64"
    }
    foreach ($Panel in @('My Transactions', 'Select Package', 'Finalize', 'Stripe Checkout')) {
        if ($Panel -notin @($StorePage.observedPanels)) {
            Add-WorkspaceError "website\config\store-page.json observed panels missing '$Panel'"
        }
    }
    $VipPackage = @($StorePage.packages) | Where-Object { $_.name -eq 'VIP' } | Select-Object -First 1
    if ($null -eq $VipPackage) {
        Add-WorkspaceError "website\config\store-page.json must include VIP package"
    } elseif ($VipPackage.rankBaseline -ne 'players/ranks/vip-rank.json') {
        Add-WorkspaceError "website\config\store-page.json VIP package must map to players/ranks/vip-rank.json"
    }
    $EvipPackage = @($StorePage.packages) | Where-Object { $_.name -eq 'EVIP' } | Select-Object -First 1
    if ($null -eq $EvipPackage) {
        Add-WorkspaceError "website\config\store-page.json must include EVIP package"
    } elseif ($EvipPackage.rankBaseline -ne 'players/ranks/evip-rank.json') {
        Add-WorkspaceError "website\config\store-page.json EVIP package must map to players/ranks/evip-rank.json"
    }
    foreach ($Action in @('Apply referral code', 'Back', 'Pay Securely')) {
        if ($Action -notin @($StorePage.checkout.actions)) {
            Add-WorkspaceError "website\config\store-page.json checkout actions missing '$Action'"
        }
    }
    foreach ($Method in @('Card', 'Cash App Pay', 'Klarna', 'Afterpay', 'Crypto', 'Amazon Pay')) {
        if ($Method -notin @($StorePage.checkout.stripePaymentMethodsObserved)) {
            Add-WorkspaceError "website\config\store-page.json Stripe methods missing '$Method'"
        }
    }
    if ('Stripe webhook signing secret' -notin @($StorePage.secrets)) {
        Add-WorkspaceError "website\config\store-page.json must track Stripe webhook signing secret as secure-only"
    }
    if ($StorePage.transactionHistory.doNotStoreRawTransactionsInGit -ne $true) {
        Add-WorkspaceError "website\config\store-page.json must forbid raw transaction storage in Git"
    }
    if ($StorePage.fulfillmentReview.supporterRolesGrantCommandsOrAdministrativePermissions -ne $false) {
        Add-WorkspaceError "website\config\store-page.json must state supporter roles do not grant commands or administrative permissions"
    }
    foreach ($Perk in @($StorePage.observedPackagePerks)) {
        if ([string]$Perk -match '(?i)moderation|admin|command') {
            Add-WorkspaceError "website\config\store-page.json supporter package perks must not include moderation/admin/command labels"
        }
    }
    foreach ($ReviewItem in @($StorePage.fulfillmentReview.reviewRequired)) {
        if ([string]$ReviewItem -match '(?i)moderation powers') {
            Add-WorkspaceError "website\config\store-page.json must not list moderation powers for supporter fulfillment"
        }
    }
}

if ($null -ne $PlayerProfileFields) {
    if ($PlayerProfileFields.identifier.type -ne 'SteamID64') {
        Add-WorkspaceError "players\config\player-profile-fields.json identifier type must be SteamID64"
    }
    if ($PlayerProfileFields.identifier.exampleOwnerSteamId64 -ne '76561198103223564') {
        Add-WorkspaceError "players\config\player-profile-fields.json owner SteamID64 mismatch"
    }
    foreach ($RequiredPanel in @('sanctionsPanel', 'auditLog', 'rankDisplay')) {
        if (-not ($PlayerProfileFields.PSObject.Properties.Name -contains $RequiredPanel)) {
            Add-WorkspaceError "players\config\player-profile-fields.json is missing $RequiredPanel"
        }
    }
}

if ($null -ne $NoneRank) {
    if ($NoneRank.rank.rankId -ne '100547a0-3f91-42af-b8ec-e5e3a188c045') {
        Add-WorkspaceError "players\ranks\none-rank.json None rank ID mismatch"
    }
    if ($NoneRank.rank.defaultRank -ne $true) {
        Add-WorkspaceError "players\ranks\none-rank.json None must be marked as the default rank"
    }
    if ($NoneRank.rank.administrative -ne $false) {
        Add-WorkspaceError "players\ranks\none-rank.json None must be non-administrative"
    }
    if ($NoneRank.rank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "players\ranks\none-rank.json None must not be wildcard"
    }
    if ($NoneRank.rank.flags.hideOnPlayerList -ne $true) {
        Add-WorkspaceError "players\ranks\none-rank.json None must hide on player list"
    }
    if ($NoneRank.permissionMeaning.none -ne 'No access.') {
        Add-WorkspaceError "players\ranks\none-rank.json must define None as no access"
    }
    if ($NoneRank.playerPolicy.regularPlayerRole -ne $true) {
        Add-WorkspaceError "players\ranks\none-rank.json must mark None as a regular player role"
    }
    if ($NoneRank.playerPolicy.defaultPlayerRole -ne $true) {
        Add-WorkspaceError "players\ranks\none-rank.json must mark None as the default player role"
    }
    if ($NoneRank.playerPolicy.administrativeAccessAllowed -ne $false) {
        Add-WorkspaceError "players\ranks\none-rank.json must forbid administrative access"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($NoneRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "players\ranks\none-rank.json is missing permission group '$Group'"
            continue
        }
        foreach ($State in @('granted', 'denied', 'none', 'inherited')) {
            if (-not ($NoneRank.permissionGroups.$Group.PSObject.Properties.Name -contains $State)) {
                Add-WorkspaceError "players\ranks\none-rank.json group '$Group' is missing '$State' permissions"
            }
        }
    }
    foreach ($AdministrativeGroup in @('portal', 'moderation', 'serverManagement')) {
        if (@($NoneRank.permissionGroups.$AdministrativeGroup.granted).Count -gt 0) {
            Add-WorkspaceError "players\ranks\none-rank.json must not grant $AdministrativeGroup permissions"
        }
    }
}

if ($null -ne $MembersRank) {
    if ($MembersRank.rank.rankId -ne '019db841-3c15-7c69-bd44-07fc15153947') {
        Add-WorkspaceError "players\ranks\members-rank.json Members rank ID mismatch"
    }
    if ($MembersRank.rank.administrative -ne $false) {
        Add-WorkspaceError "players\ranks\members-rank.json Members must be non-administrative"
    }
    if ($MembersRank.rank.discordVerified -ne $true) {
        Add-WorkspaceError "players\ranks\members-rank.json Members must be marked as Discord verified"
    }
    if ($MembersRank.rank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "players\ranks\members-rank.json Members must not be wildcard"
    }
    if ($MembersRank.permissionMeaning.none -ne 'No access.') {
        Add-WorkspaceError "players\ranks\members-rank.json must define None as no access"
    }
    if ($MembersRank.playerPolicy.regularPlayerRole -ne $true) {
        Add-WorkspaceError "players\ranks\members-rank.json must mark Members as a regular player role"
    }
    if ($MembersRank.playerPolicy.administrativeAccessAllowed -ne $false) {
        Add-WorkspaceError "players\ranks\members-rank.json must forbid administrative access"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($MembersRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "players\ranks\members-rank.json is missing permission group '$Group'"
            continue
        }
        foreach ($State in @('granted', 'denied', 'none', 'inherited')) {
            if (-not ($MembersRank.permissionGroups.$Group.PSObject.Properties.Name -contains $State)) {
                Add-WorkspaceError "players\ranks\members-rank.json group '$Group' is missing '$State' permissions"
            }
        }
    }
    foreach ($AdministrativeGroup in @('portal', 'moderation', 'serverManagement')) {
        if (@($MembersRank.permissionGroups.$AdministrativeGroup.granted).Count -gt 0) {
            Add-WorkspaceError "players\ranks\members-rank.json must not grant $AdministrativeGroup permissions"
        }
    }
}

if ($null -ne $VipRank) {
    if ($VipRank.rank.rankId -ne '019db2da-c303-7c94-99e9-f3dbb6efb525') {
        Add-WorkspaceError "players\ranks\vip-rank.json VIP rank ID mismatch"
    }
    if ($VipRank.rank.administrative -ne $false) {
        Add-WorkspaceError "players\ranks\vip-rank.json VIP must be non-administrative"
    }
    if ($VipRank.rank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "players\ranks\vip-rank.json VIP must not be wildcard"
    }
    if ($VipRank.permissionMeaning.none -ne 'No access.') {
        Add-WorkspaceError "players\ranks\vip-rank.json must define None as no access"
    }
    if ($VipRank.supporterPolicy.donatorRole -ne $true) {
        Add-WorkspaceError "players\ranks\vip-rank.json must mark VIP as a donor/supporter role"
    }
    if ($VipRank.supporterPolicy.administrativeAccessAllowed -ne $false) {
        Add-WorkspaceError "players\ranks\vip-rank.json must forbid administrative access"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($VipRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "players\ranks\vip-rank.json is missing permission group '$Group'"
            continue
        }
        foreach ($State in @('granted', 'denied', 'none', 'inherited')) {
            if (-not ($VipRank.permissionGroups.$Group.PSObject.Properties.Name -contains $State)) {
                Add-WorkspaceError "players\ranks\vip-rank.json group '$Group' is missing '$State' permissions"
            }
        }
    }
    foreach ($AdministrativeGroup in @('portal', 'moderation', 'serverManagement')) {
        if (@($VipRank.permissionGroups.$AdministrativeGroup.granted).Count -gt 0) {
            Add-WorkspaceError "players\ranks\vip-rank.json must not grant $AdministrativeGroup permissions"
        }
    }
}

if ($null -ne $EvipRank) {
    if ($EvipRank.rank.rankId -ne '019db2db-0656-7893-ae2b-3ae1be47c186') {
        Add-WorkspaceError "players\ranks\evip-rank.json EVIP rank ID mismatch"
    }
    if ($EvipRank.rank.administrative -ne $false) {
        Add-WorkspaceError "players\ranks\evip-rank.json EVIP must be non-administrative"
    }
    if ($EvipRank.rank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "players\ranks\evip-rank.json EVIP must not be wildcard"
    }
    if ($EvipRank.permissionMeaning.none -ne 'No access.') {
        Add-WorkspaceError "players\ranks\evip-rank.json must define None as no access"
    }
    if ($EvipRank.supporterPolicy.donatorRole -ne $true) {
        Add-WorkspaceError "players\ranks\evip-rank.json must mark EVIP as a donor/supporter role"
    }
    if ($EvipRank.supporterPolicy.administrativeAccessAllowed -ne $false) {
        Add-WorkspaceError "players\ranks\evip-rank.json must forbid administrative access"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($EvipRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "players\ranks\evip-rank.json is missing permission group '$Group'"
            continue
        }
        foreach ($State in @('granted', 'denied', 'none', 'inherited')) {
            if (-not ($EvipRank.permissionGroups.$Group.PSObject.Properties.Name -contains $State)) {
                Add-WorkspaceError "players\ranks\evip-rank.json group '$Group' is missing '$State' permissions"
            }
        }
    }
    foreach ($AdministrativeGroup in @('portal', 'moderation', 'serverManagement')) {
        if (@($EvipRank.permissionGroups.$AdministrativeGroup.granted).Count -gt 0) {
            Add-WorkspaceError "players\ranks\evip-rank.json must not grant $AdministrativeGroup permissions"
        }
    }
}

if ($null -ne $AdminRoles) {
    if ($AdminRoles.ownerVisibility.ownerRankId -ne '64367f56-9492-4340-91e4-e2866d1b653a') {
        Add-WorkspaceError "admin-panel\config\admin-roles.json owner rank ID mismatch"
    }
    if ($AdminRoles.ownerVisibility.ownerRankWildcard -ne $true) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json owner rank must be marked wildcard"
    }

    foreach ($Role in @($AdminRoles.roles)) {
        if ([string]::IsNullOrWhiteSpace([string]$Role.slug)) {
            Add-WorkspaceError 'Admin role entry is missing slug'
            continue
        }
        $RolePath = "admin-panel\roles\$($Role.slug).md"
        if (-not (Test-Path -LiteralPath (Join-Path $Root $RolePath) -PathType Leaf)) {
            Add-WorkspaceError "Admin role '$($Role.name)' missing document: $RolePath"
        }
    }

    $Developer = @($AdminRoles.roles) | Where-Object { $_.slug -eq 'developer' } | Select-Object -First 1
    if ($null -eq $Developer) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json is missing Developer role"
    } elseif ($Developer.observedPortalRank.rankId -ne '019dee95-9eb9-7e04-99ce-b70562842e08') {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Developer rank ID mismatch"
    }

    $SuperAdmin = @($AdminRoles.roles) | Where-Object { $_.slug -eq 'super-admin' } | Select-Object -First 1
    if ($null -eq $SuperAdmin) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json is missing Super Admin role"
    } elseif ($SuperAdmin.observedPortalRank.rankId -ne '019dff06-68ca-700a-89f2-acdbed20e74a') {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Super Admin rank ID mismatch"
    }

    $CommunityManager = @($AdminRoles.roles) | Where-Object { $_.slug -eq 'community-manager' } | Select-Object -First 1
    if ($null -eq $CommunityManager) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json is missing Community Manager role"
    } elseif ($CommunityManager.observedPortalRank.rankId -ne '019e1a5e-8866-7a44-8137-35cd32f13c06') {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Community Manager rank ID mismatch"
    }

    $Admin = @($AdminRoles.roles) | Where-Object { $_.slug -eq 'admin' } | Select-Object -First 1
    if ($null -eq $Admin) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json is missing Admin role"
    } elseif ($Admin.observedPortalRank.rankId -ne '019db2da-0c97-78a1-abca-78203b56daad') {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Admin rank ID mismatch"
    } elseif ($Admin.observedPortalRank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Admin rank must not be wildcard"
    }

    $Moderator = @($AdminRoles.roles) | Where-Object { $_.slug -eq 'moderator' } | Select-Object -First 1
    if ($null -eq $Moderator) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json is missing Moderator role"
    } elseif ($Moderator.observedPortalRank.rankId -ne '019db2da-5dc9-7e36-b0f5-09a713791c26') {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Moderator rank ID mismatch"
    } elseif ($Moderator.observedPortalRank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "admin-panel\config\admin-roles.json Moderator rank must not be wildcard"
    }
}

if ($null -ne $OwnerRank) {
    if ($OwnerRank.rank.rankId -ne '64367f56-9492-4340-91e4-e2866d1b653a') {
        Add-WorkspaceError "admin-panel\permissions\owner-rank.json owner rank ID mismatch"
    }
    if ($OwnerRank.rank.grantAllPermissionsWildcard -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\owner-rank.json must grant wildcard permissions"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($OwnerRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "admin-panel\permissions\owner-rank.json is missing permission group '$Group'"
        }
    }
}

if ($null -ne $SuperAdminRank) {
    if ($SuperAdminRank.rank.rankId -ne '019dff06-68ca-700a-89f2-acdbed20e74a') {
        Add-WorkspaceError "admin-panel\permissions\super-admin-rank.json Super Admin rank ID mismatch"
    }
    if ($SuperAdminRank.rank.grantAllPermissionsWildcard -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\super-admin-rank.json must record observed wildcard permissions"
    }
    if ($SuperAdminRank.policyTarget.removeWildcardBeforeDelegation -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\super-admin-rank.json must require wildcard removal before broad delegation"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($SuperAdminRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "admin-panel\permissions\super-admin-rank.json is missing permission group '$Group'"
        }
    }
}

if ($null -ne $CommunityManagerRank) {
    if ($CommunityManagerRank.rank.rankId -ne '019e1a5e-8866-7a44-8137-35cd32f13c06') {
        Add-WorkspaceError "admin-panel\permissions\community-manager-rank.json Community Manager rank ID mismatch"
    }
    if ($CommunityManagerRank.rank.grantAllPermissionsWildcard -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\community-manager-rank.json must record observed wildcard permissions"
    }
    if ($CommunityManagerRank.policyTarget.removeWildcardBeforeDelegation -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\community-manager-rank.json must require wildcard removal before broad delegation"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($CommunityManagerRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "admin-panel\permissions\community-manager-rank.json is missing permission group '$Group'"
        }
    }
}

if ($null -ne $AdminRank) {
    if ($AdminRank.rank.rankId -ne '019db2da-0c97-78a1-abca-78203b56daad') {
        Add-WorkspaceError "admin-panel\permissions\admin-rank.json Admin rank ID mismatch"
    }
    if ($AdminRank.rank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "admin-panel\permissions\admin-rank.json must not record wildcard permissions"
    }
    if ($AdminRank.permissionMeaning.none -ne 'No access.') {
        Add-WorkspaceError "admin-panel\permissions\admin-rank.json must define None as no access"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($AdminRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "admin-panel\permissions\admin-rank.json is missing permission group '$Group'"
            continue
        }
        foreach ($State in @('granted', 'denied', 'none')) {
            if (-not ($AdminRank.permissionGroups.$Group.PSObject.Properties.Name -contains $State)) {
                Add-WorkspaceError "admin-panel\permissions\admin-rank.json group '$Group' is missing '$State' permissions"
            }
        }
    }
}

if ($null -ne $ModeratorRank) {
    if ($ModeratorRank.rank.rankId -ne '019db2da-5dc9-7e36-b0f5-09a713791c26') {
        Add-WorkspaceError "admin-panel\permissions\moderator-rank.json Moderator rank ID mismatch"
    }
    if ($ModeratorRank.rank.grantAllPermissionsWildcard -ne $false) {
        Add-WorkspaceError "admin-panel\permissions\moderator-rank.json must not record wildcard permissions"
    }
    if ($ModeratorRank.permissionMeaning.none -ne 'No access.') {
        Add-WorkspaceError "admin-panel\permissions\moderator-rank.json must define None as no access"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($ModeratorRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "admin-panel\permissions\moderator-rank.json is missing permission group '$Group'"
            continue
        }
        foreach ($State in @('granted', 'denied', 'none')) {
            if (-not ($ModeratorRank.permissionGroups.$Group.PSObject.Properties.Name -contains $State)) {
                Add-WorkspaceError "admin-panel\permissions\moderator-rank.json group '$Group' is missing '$State' permissions"
            }
        }
    }
}

if ($null -ne $DeveloperRank) {
    if ($DeveloperRank.rank.rankId -ne '019dee95-9eb9-7e04-99ce-b70562842e08') {
        Add-WorkspaceError "admin-panel\permissions\developer-rank.json Developer rank ID mismatch"
    }
    if ($DeveloperRank.rank.grantAllPermissionsWildcard -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\developer-rank.json must record observed wildcard permissions"
    }
    if ($DeveloperRank.policyTarget.removeWildcardBeforeDelegation -ne $true) {
        Add-WorkspaceError "admin-panel\permissions\developer-rank.json must require wildcard removal before delegation"
    }
    foreach ($Group in @('portal', 'moderation', 'serverManagement', 'commands', 'ability', 'building', 'misc')) {
        if (-not ($DeveloperRank.permissionGroups.PSObject.Properties.Name -contains $Group)) {
            Add-WorkspaceError "admin-panel\permissions\developer-rank.json is missing permission group '$Group'"
        }
    }
}

if ($null -ne $AuditTaxonomy) {
    foreach ($Action in @('Chat', 'DispatchAction', 'Update', 'GenerateToken')) {
        if ($Action -notin @($AuditTaxonomy.observedActions)) {
            Add-WorkspaceError "audit\config\audit-taxonomy.json is missing observed action '$Action'"
        }
    }

    foreach ($Folder in @(
        'audit\staff\owner',
        'audit\staff\moderator',
        'audit\staff\admin',
        'audit\staff\super-admin',
        'audit\staff\community-manager',
        'audit\staff\developer',
        'audit\players\none',
        'audit\players\members',
        'audit\supporters\vip',
        'audit\supporters\evip'
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $Folder) -PathType Container)) {
            Add-WorkspaceError "Missing audit bucket folder: $Folder"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $Root "$Folder\README.md") -PathType Leaf)) {
            Add-WorkspaceError "Missing audit bucket README: $Folder\README.md"
        }
    }
}

foreach ($Forbidden in @('Assets', 'Code', 'config', 'gamemodes')) {
    if (Test-Path -LiteralPath (Join-Path $Root $Forbidden)) {
        Add-WorkspaceError "Top-level lifepunch '$Forbidden' is not allowed; use the scoped folders"
    }
}

$AddonCodeRoot = Join-Path $Root 'addons\Code\Addons\lifepunch'
if (Test-Path -LiteralPath $AddonCodeRoot -PathType Container) {
    $ForbiddenReferenceIdentifiers = @('SWB', 'SWE', 'BeCreativeRP')
    Get-ChildItem -LiteralPath $AddonCodeRoot -Recurse -File -Filter '*.cs' -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $Relative = $_.FullName.Substring($Root.Length + 1)
        $Content = Get-Content -LiteralPath $_.FullName -Raw

        foreach ($Identifier in $ForbiddenReferenceIdentifiers) {
            if ($Content -match [regex]::Escape($Identifier)) {
                Add-WorkspaceError "Addon code must not contain public reference identifier '$Identifier': $Relative"
            }
        }

        if ($Content -match 'namespace\s+' -and $Content -notmatch 'namespace\s+LifePunch\.') {
            Add-WorkspaceError "Addon code namespace must be LifePunch-owned: $Relative"
        }
    }
}

$LegacyFolders = Get-ChildItem -LiteralPath $Root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('upload-assets', 'upload-code') }

foreach ($Folder in $LegacyFolders) {
    $Relative = Resolve-Path -LiteralPath $Folder.FullName -Relative
    Add-WorkspaceError "Legacy flat publish folder is not allowed: $Relative"
}

if ($Errors.Count -gt 0) {
    Write-Host 'LifePunch workspace validation failed:' -ForegroundColor Red
    foreach ($ErrorMessage in $Errors) {
        Write-Host " - $ErrorMessage" -ForegroundColor Red
    }
    exit 1
}

& (Join-Path $Root 'addons\scripts\validate-layout.ps1')
if (-not $?) { exit 1 }

& (Join-Path $Root 'gamemode\scripts\validate-gamemode-workspace.ps1')
if (-not $?) { exit 1 }

& (Join-Path $Root 'server\scripts\validate-server-workspace.ps1')
if (-not $?) { exit 1 }

Write-Host 'LifePunch workspace validation passed.' -ForegroundColor Green
