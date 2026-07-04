export default {
    async fetch(request, env) {
        const url = new URL(request.url);
        const linksKv = env.LINKS;

        // --- REDIRECT WWW TO ROOT ---
        if (url.hostname === "www.lifepunch.co") {
            url.hostname = "lifepunch.co";
            return Response.redirect(url.toString(), 301);
        }

        const path = url.pathname;
        const hostname = url.hostname;

        // --- DETECTION LOGIC ---
        const userAgent = (request.headers.get("User-Agent") || "").toLowerCase();
        const isSbox = userAgent.includes("sbox") || path.startsWith("/sbox") || url.searchParams.get("sbox") === "true";
        const isEmbed = url.searchParams.get("embed") === "true" || isSbox;

        // --- SECURITY HEADERS (CSP + HSTS) ---
        // Inline scripts/styles are used throughout the generated HTML, so 'unsafe-inline'
        // stays until pages move to nonced scripts. Embed/sbox pages must remain frameable.
        const buildSecurityHeaders = (embed) => {
            const csp = [
                "default-src 'self'",
                "script-src 'self' 'unsafe-inline'",
                "style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com",
                "font-src 'self' https://cdnjs.cloudflare.com https://fonts.gstatic.com",
                "img-src 'self' data: https:",
                "connect-src 'self'",
                "object-src 'none'",
                "base-uri 'self'",
                "form-action 'self'",
                embed ? "frame-ancestors *" : "frame-ancestors 'none'"
            ].join("; ");

            const headers = {
                "Content-Security-Policy": csp,
                "Strict-Transport-Security": "max-age=31536000; includeSubDomains"
            };

            if (!embed) {
                headers["X-Frame-Options"] = "DENY";
            }

            return headers;
        };

        // --- COOKIE HELPERS ---
        const getCookie = (name) => {
            const cookies = request.headers.get("Cookie");
            if (!cookies) return null;
            const match = cookies.match(new RegExp('(^| )' + name + '=([^;]+)'));
            return match ? match[2] : null;
        };

        const sessionToken = getCookie("lp_session");
        let steamid = null;
        if (sessionToken && env.LINKS) {
            steamid = await env.LINKS.get(`session:${sessionToken}`);
        }

        // --- ADMIN CHECK ---
        const isAdmin = (sid) => {
            if (!sid || !env.ADMIN_STEAMIDS) return false;
            const admins = env.ADMIN_STEAMIDS.split(",").map(id => id.trim());
            return admins.includes(sid);
        };
        const userIsAdmin = isAdmin(steamid);

        const esc = (s) =>
            String(s ?? "")
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#39;");
        // --- LIFE PUNCH RULES CATALOG (single source of truth) ---
        // Edit rule text here only — both /rules and /rules/raw render from this data.
        const LP_RULES = [
            {
                num: 1,
                title: "Serverwide Rules",
                icon: "fa-globe",
                rules: [
                    { id: "en-only", html: `<b>Language Rules</b><ul class="rule-sublist"><li>We're an English-speaking community. Please keep all roleplay in English.</li></ul>` },
                    { id: "no-cheat", html: `<b>Cheating Rules</b><ul class="rule-sublist"><li>Using third-party software, cheats, macros, or autoclickers will result in a permanent ban.</li></ul>` },
                    { id: "no-exploit", html: `<b>Exploiting Rules</b><ul class="rule-sublist"><li>Exploiting maps, items, or tools for an unfair advantage is not allowed (drug creation and gun shops are excluded).</li></ul>` },
                    { id: "no-mic-spam", html: `<b>Mic & Text Spam Rules</b><ul class="rule-sublist"><li>Intentionally disrupting roleplay through your microphone or chat spam is not allowed.</li></ul>` },
                    { id: "no-staff-impersonation", html: `<b>Staff Impersonation Rules</b><ul class="rule-sublist"><li>Impersonating staff will result in a permanent ban.</li></ul>` },
                    { id: "no-lie-staff", html: `<b>Lying to Staff Rules</b><ul class="rule-sublist"><li>Lying to staff will result in a permanent ban.</li><li>This includes false reporting, deleting ticket evidence, or misleading staff during a report.</li></ul>` },
                    { id: "no-staff-baiting", html: `<b>Staff Baiting Rules</b><ul class="rule-sublist"><li>Saying you will break a rule counts as breaking that rule.</li></ul>` },
                    { id: "no-minimodding", html: `<b>Minimodding Rules</b><ul class="rule-sublist"><li>Do not threaten others with reports.</li><li>Submit reports properly and move on.</li></ul>` },
                    { id: "admin-final-say", html: `<b>Admin Judgement Rules</b><ul class="rule-sublist"><li>Do not argue with staff about rules or punishments.</li><li>Staff always have the final say in situations not listed.</li></ul>` },
                    { id: "no-begging", html: `<b>Begging Rules</b><ul class="rule-sublist"><li>Soliciting real money or real-life items is not allowed.</li></ul>` },
                    { id: "no-bullying", html: `<b>Bullying Rules</b><ul class="rule-sublist"><li>Targeting or harassing players outside of roleplay is never tolerated.</li></ul>` },
                    { id: "no-politics", html: `<b>Politics, War & Religion Rules</b><ul class="rule-sublist"><li>Political arguments are not allowed.</li><li>Jokes are fine; arguments are not.</li></ul>` },
                    { id: "no-racism", html: `<b>Racism & Homophobia Rules</b><ul class="rule-sublist"><li>There is zero tolerance for racism or homophobia.</li><li>Violations will result in a permanent ban.</li></ul>` },
                    { id: "no-nsfw", html: `<b>Sexual & NSFW Content Rules</b><ul class="rule-sublist"><li>All media must remain PG-rated.</li><li>This includes ERP and pornographic content.</li></ul>` },
                    { id: "no-doxing", html: `<b>Doxing Rules</b><ul class="rule-sublist"><li>Posting real-life pictures of someone without permission will result in a permanent ban.</li></ul>` },
                    { id: "no-cybercrime", html: `<b>Cybercrime Threats Rules</b><ul class="rule-sublist"><li>Threatening DDoS attacks or doxing will result in a permanent ban.</li></ul>` },
                    { id: "no-advertising", html: `<b>Advertising Rules</b><ul class="rule-sublist"><li>Only official DXRP or S&box links are allowed.</li></ul>` },
                    { id: "no-irl-illegal", html: `<b>IRL Illegal Activity Rules</b><ul class="rule-sublist"><li>Encouraging illegal real-life activity will result in a permanent ban.</li></ul>` }
                ]
            },
            {
                num: 2,
                title: "Basic RP Rules",
                icon: "fa-lightbulb",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 2A: RDM / RDA",
                        webBtn: "🔫 RDM / RDA",
                        rules: [
                            { id: "rdm-definition", html: `<b>RDM Definition</b><ul class="rule-sublist"><li>Random Deathmatch (RDM) is killing someone without a valid roleplay reason</li><li>RDM is not allowed</li></ul>` },
                            { id: "rda-definition", html: `<b>RDA Definition</b><ul class="rule-sublist"><li>Random Death Arrest (RDA) is arresting someone without a valid roleplay reason</li><li>RDA is not allowed</li></ul>` },
                            { id: "rdm-reason", html: `<b>RDM Reasoning Rules</b><ul class="rule-sublist"><li>Disrespect or threats alone are not valid reasons to kill someone</li><li>Taking damage or having items stolen are valid reasons</li></ul>` },
                            { id: "rdm-warnings", html: `<b>Warning Rules</b><ul class="rule-sublist"><li>You may kill someone after warning them three times in chat to step away or to leave your property</li></ul>` },
                            { id: "rdm-mayor", html: `<b>Killing the Mayor Rules</b><ul class="rule-sublist"><li>Killing the Mayor requires a valid roleplay reason, such as a Police Department raid or mugging</li></ul>` }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2B: KOS",
                        webBtn: "⚠️ KOS",
                        rules: [
                            { id: "kos-line-definition", html: `<b>KOS Line Definition</b><ul class="rule-sublist"><li>An indicator that implies that moving past a certain point results in being killed</li></ul>` },
                            { id: "base-kos-line", html: `<b>KOS Line Placement Rules</b><ul class="rule-sublist"><li>KOS zones must start at a base's purchasable front door, fading door, or the start of an airlock</li><li>KOS lines must be a text sign that implies crossing it results in death</li></ul>` },
                            { id: "kos-understandable", html: `<b>KOS Clarity Rules</b><ul class="rule-sublist"><li>KOS zones must be easy to understand and must never be deceptive</li></ul>` },
                            { id: "rdm-kos2", html: `<b>KOS Boundaries Rules</b><ul class="rule-sublist"><li>KOS lines are markers for where KOS begins at a base</li><li>Once a KOS line is placed, the intended base behind that line is considered KOS</li><li>Example: If a KOS line is at a front door and you enter through a window, you may still be killed</li></ul>` },
                            { id: "rdm-kos", html: `<b>KOS General Rules</b><ul class="rule-sublist"><li>Crossing a clearly marked KOS line is not considered RDM</li></ul>` }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2C: NLR",
                        webBtn: "💀 NLR",
                        rules: [
                            { id: "nlr-definition", html: `<b>NLR Definition</b><ul class="rule-sublist"><li>The New Life Rule (NLR) means you may remember past events, but you cannot act on them</li><li>You must adhere to NLR on our server</li></ul>` },
                            { id: "nlr-trigger", html: `<b>NLR Trigger Rules</b><ul class="rule-sublist"><li>NLR applies on death, job change, and jail release (unless you escaped)</li></ul>` },
                            { id: "nlr-raid", html: `<b>NLR Raid Rules</b><ul class="rule-sublist"><li>You may not return to a raid after death</li><li>You must wait until the raid is completed to return to your base as a defender</li></ul>` },
                            { id: "nlr-revive", html: `<b>NLR Revive Rules</b><ul class="rule-sublist"><li>Revived players may continue their raid or scenario</li></ul>` },
                            { id: "nlr-hitman", html: `<b>NLR Hitman Rules</b><ul class="rule-sublist"><li>A failed hit cannot be re-attempted</li><li>A hit fails upon death</li></ul>` }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2D: Fail RP",
                        webBtn: "🎭 Fail RP",
                        rules: [
                            {
                                id: "fail-rp",
                                html: `<b>Fail RP Definition</b><ul class="rule-sublist"><li>Fail RP is roleplay that breaks character, violates the setting's logic, or disregards server rules, resulting in poor-quality, unrealistic, or disruptive play</li><li>Fail RP is not allowed</li></ul>`
                            },
                            {
                                id: "fail-rp-examples",
                                html: `<b>Fail RP Examples</b><ul class="rule-sublist"><li>Stealing your base mate's valuables and then starting a new base</li><li>Mugging someone with a partner, then killing that partner</li><li>Door camping or blocking doors</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2E: METAGAMING",
                        webBtn: "🔍 Metagaming",
                        rules: [
                            {
                                id: "metagaming",
                                html: `<b>Metagaming Definition</b><ul class="rule-sublist"><li>Metagaming is using out-of-character (OOC) knowledge to influence your character's in-game decisions</li><li>It occurs when your character acts on information they realistically should not know, bridging the gap between what you know and what your character knows</li><li>Metagaming is not allowed</li></ul>`
                            }
                        ]
                    }
                ]
            },
            {
                num: 3,
                title: "Basic RP Guidelines",
                icon: "fa-brain",
                rules: [
                    { id: "fearrp", html: `<b>FearRP Rules</b><ul class="rule-sublist"><li>FearRP is not enforced, but you should still value your life reasonably</li></ul>` },
                    { id: "no-suicide-rp", html: `<b>SuicideRP Rules</b><ul class="rule-sublist"><li>You may not commit suicide to avoid roleplay scenarios such as muggings</li></ul>` },
                    { id: "job-desc", html: `<b>Job Description Rules</b><ul class="rule-sublist"><li>You must follow your job description (Medics heal, Merchants/Dealers sell, and Cops protect)</li></ul>` },
                    { id: "merchants", html: `<b>Merchant Rules</b><ul class="rule-sublist"><li>Merchants may not deny service for non-roleplay reasons (for example, refusing to sell guns to a potential raider)</li><li>Merchants may not scam other players</li></ul>` },
                    { id: "no-job-change", html: `<b>Job Change Rules</b><ul class="rule-sublist"><li>You may not change jobs during active roleplay</li></ul>` },
                    { id: "demote-reasons", html: `<b>Demotion Rules</b><ul class="rule-sublist"><li>Valid reasons include: not doing job, 30+ min AFK, police corruption</li></ul>` },
                    { id: "no-vigilante", html: `<b>Vigilante Rules</b><ul class="rule-sublist"><li>Do not punish rulebreakers yourself through AOS, KOS, or prop blocking</li></ul>` }
                ]
            },
            {
                num: 4,
                title: "Building Rules",
                icon: "fa-hammer",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 4A: BUILDING GUIDELINES",
                        webBtn: "📐 Building Guidelines",
                        rules: [
                            { id: "special-doors", html: `<b>Door Rules</b><ul class="rule-sublist"><li>If you buy doors, you must actively use the space behind them as part of your base</li><li>You may not purchase interior doors and leave that area unused while basing on the roof or elsewhere</li></ul>` },
                            { id: "base-size-limits", html: `<b>Base Size Limits</b><ul class="rule-sublist"><li>A base's length and width must not exceed 1500×1500 units, measured with the Ruler tool</li><li>A base must not be over 1000 units tall from its floor, measured with the Ruler tool</li></ul>` },
                            { id: "base-rooftop", html: `<b>Rooftop Base Rules</b><ul class="rule-sublist"><li>Rooftop bases are built on top of an existing map structure; this is not considered a skybase</li><li>Rooftop bases are allowed</li><li>You must have a ramp or other clear method of getting to the first fading door</li><li>Rooftop-only bases do not need to own the interior doors below</li><li>Rooftop base's first fading door must be located on the roof level</li><li>Rooftop bases must not obstruct or interfere with property on lower floors</li><li>If you do not own the property below, you may not hide or make it difficult for others to access its doors</li></ul>` },
                            { id: "no-skybases", html: `<b>Sky Base Rules</b><ul class="rule-sublist"><li>A skybase is a base over 750 units tall measured with the Ruler tool from the ground of the map to the top of the base</li><li>Skybases are not allowed</li></ul>` },
                            { id: "no-blackout", html: `<b>Blackout Base Rules</b><ul class="rule-sublist"><li>Blackout bases are not allowed</li></ul>` },
                            { id: "hobo-aerial", html: `<b>Hobo Aerial Build Rules</b><ul class="rule-sublist"><li>Hobos may build aerial structures for roleplay features such as ramps and slides</li></ul>` }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4B: PLACEMENT & MAP RULES",
                        webBtn: "🗺️ Placement & Map Rules",
                        rules: [
                            { id: "map-boundary", html: `<b>Map Boundary Rules</b><ul class="rule-sublist"><li>You may not base outside the map; the rock boundary is the limit</li></ul>` },
                            { id: "public-space", html: `<b>Public Space Rules</b><ul class="rule-sublist"><li>Do not take up excessive public space</li></ul>` },
                            {
                                id: "checkpoints",
                                html: `<b>Checkpoint Rules</b><ul class="rule-sublist"><li>Checkpoints must not block spawn-area entrances or exits, and must not extend raid duration</li><li>All checkpoints must leave another way around that does not require payment to reach the destination</li><li>Only two checkpoints are allowed on the entire map at a time</li><li>There may only be one police checkpoint and one hobo checkpoint or toll booth at a time</li><li>This limit is intended to encourage Hobos and Police to roleplay at their own respective checkpoints</li><li>Trying to directly bypass a Hobo checkpoint can result in death</li><li>Trying to directly bypass a Police checkpoint can result in AOS</li></ul>`
                            },
                            { id: "pd-building", html: `<b>Police Department Building Rules</b><ul class="rule-sublist"><li>Non-government players may not build in the Police Department, including the lobby, without the Mayor's permission</li><li>Only two fading doors are allowed inside of the Police Department</li></ul>` },
                            { id: "blocking-off", html: `<b>Blocking Off Rules</b><ul class="rule-sublist"><li>Do not block ATMs, drop-offs, trash cans, or the recycler</li></ul>` },
                            { id: "atm-rules", html: `<b>ATM Rules</b><ul class="rule-sublist"><li>Props must not touch or obstruct an ATM</li><li>ATMs must be exposed on all sides and be fully walkable</li><li>You cannot access an ATM from your base</li></ul>` },
                            { id: "drop-offs", html: `<b>Drop-Off Rules</b><ul class="rule-sublist"><li>Do not block weed drop-offs</li><li>Weed drop-off areas must be fully walkable</li><li>Your base may have only one connection to a drug drop-off location</li></ul>` }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4C: BASE LAYOUT & FAIRNESS",
                        webBtn: "🏠 Base Layout & Fairness",
                        rules: [
                            { id: "base-reachable", html: `<b>Base Reachability Rules</b><ul class="rule-sublist"><li>Bases must remain reachable and accessible at all times</li></ul>` },
                            { id: "base-entrance", html: `<b>Base Entrance Rules</b><ul class="rule-sublist"><li>Bases must have exactly one entrance</li><li>Unused map doors must be blocked off</li><li>You must own every door that is part of your base</li><li>You may only own doors in areas where you are actively basing</li></ul>` },
                            { id: "base-entrance-visibility", html: `<b>Entrance Visibility Rules</b><ul class="rule-sublist"><li>Entrances must be reasonably easy to find, visible, and distinct from surrounding walls, with a minimum 2×2 standing area (80×80 units)</li></ul>` },
                            { id: "base-walkways", html: `<b>Base Walkway Rules</b><ul class="rule-sublist"><li>Walkways must be at least one 1×1 prop wide (40 units), including ramps</li><li>You may not build aerial walkways from roof to roof</li></ul>` },
                            { id: "entity-ladders", html: `<b>Entity Ladder Rules</b><ul class="rule-sublist"><li>Bases must not require entity ladders to access at any time</li><li>Entity ladders may be used to get over public obstacles such as a toll booth or the open roof of a base</li></ul>` },
                            { id: "base-crouch", html: `<b>Base Jump/Crouch Rules</b><ul class="rule-sublist"><li>Raiders must never be forced to crouch or jump inside, outside, or to gain access to a base</li></ul>` },
                            { id: "base-mazes", html: `<b>Base Maze Rules</b><ul class="rule-sublist"><li>Mazes are not allowed</li><li>A maze is more than one 180° turn, more than two 90° turns, or multiple disorienting pathways used to artificially extend raid duration</li></ul>` },
                            { id: "kos-airlocks", html: `<b>Raid Hallways & Airlock Rules</b><ul class="rule-sublist"><li>Artificial raid hallways and airlocks start at your KOS sign and must not exceed 25 total 1×1 props (1000 units), excluding natural map layouts</li></ul>` },
                            { id: "base-shooting", html: `<b>Base Shooting Rules</b><ul class="rule-sublist"><li>Raiders must be able to clearly see you and shoot back</li><li>You may not use tiny hitboxes for an unfair advantage</li></ul>` },
                            { id: "base-crowbar", html: `<b>Base Crowbar Rules</b><ul class="rule-sublist"><li>Bases must be crowbar-raidable</li><li>Code-only bases are not allowed</li></ul>` },
                            { id: "base-damage", html: `<b>Base Damage Rules</b><ul class="rule-sublist"><li>Bases may not damage players</li></ul>` },
                            { id: "base-movement", html: `<b>Base Movement Rules</b><ul class="rule-sublist"><li>Bases may not slow down or impede player movement</li></ul>` },
                            { id: "base-no-collide", html: `<b>Base No-Collide Rules</b><ul class="rule-sublist"><li>No-collide props must not confuse raiders and should be visually distinct</li></ul>` }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4D: FADING DOORS",
                        webBtn: "🚪 Fading Doors",
                        rules: [
                            { id: "fd-limit", html: `<b>Fading Door Limit</b><ul class="rule-sublist"><li>You may use a maximum of two fading doors to access your raidables</li></ul>` },
                            {
                                id: "fd-utility",
                                html: `<b>Utility Fading Door Rules</b><ul class="rule-sublist"><li>Utility fading doors are allowed (examples: one-way exits, peeking holes, merchant airlocks)</li><li>Airlocks/fading door entrances must be identifiable and distinct through color or material</li><li>Merchant or Dealer "airlock" doors are permitted, provided they are publicly accessible and are not part of a base's main entrance or raidable area (2 Max)</li><li>Merchants include: Gun Dealer, Medic, Cook</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4E: PROP & WIRE",
                        webBtn: "🔌 Prop & Wire",
                        rules: [
                            { id: "spawn-build", html: `<b>Spawn Build Rules</b><ul class="rule-sublist"><li>You may not build in spawn</li><li>Prop climbing, flying, and blocking are not allowed</li></ul>` },
                            { id: "prop-blocking", html: `<b>Prop Blocking Rules</b><ul class="rule-sublist"><li>Prop blocking and prop spamming are not allowed</li><li>You may not spam props in the street or other public areas</li></ul>` },
                            { id: "wire-abuse", html: `<b>Wire Abuse Rules</b><ul class="rule-sublist"><li>Wire abuse is not allowed</li><li>This includes auto-stealing money, loud sounds, stealing shipments, and using wire to annoy other players</li></ul>` },
                            { id: "prop-permission", html: `<b>Property Respect Rules</b><ul class="rule-sublist"><li>You may not place props on, build into, or occupy another player's property or base without permission</li></ul>` }
                        ]
                    }
                ]
            },
            {
                num: 5,
                title: "Job Rules",
                icon: "fa-briefcase",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 5A: MAYOR & POLICE",
                        webBtn: "👮 Mayor & Police",
                        rules: [
                            {
                                id: "mayor-base",
                                html: `<b>Mayor Rules</b><ul class="rule-sublist"><li>The Mayor must base in the Police Department</li><li>Gun licenses may include a fee, but the Mayor is not obligated to provide them to criminals</li><li>The Mayor may build outside the Police Department only for government or roleplay use, such as checkpoints or toll booths</li><li>Major law changes must be announced before enforcement</li><li>Laws must be reasonable and must not contradict server rules</li><li>You cannot make things said in text/voice chat illegal (i.e. Police Disrespect)</li><li>AOS laws are allowed; KOS laws are not</li><li>Laws may not target specific individuals or jobs</li><li>Lockdowns may only be enforced outdoors</li><li>A valid reason is required for a lockdown, such as a bank raid or active shooting</li></ul>`
                            },
                            {
                                id: "police-base",
                                html: `<b>Police Rules</b><ul class="rule-sublist"><li>Police must base in the Police Department and allow all government members to base and roleplay with them</li><li>Follow the command hierarchy: Mayor>Police Chief>Police Officers</li><li>Attempt to arrest before killing, unless the suspect has a weapon drawn or you are defending an active raid</li><li>Police may create a checkpoint in public</li><li>Police do not use toll booths, as their checkpoints cannot require a fee</li><li>A police checkpoint may only enforce that a search is required to pass</li><li>Searches require a roleplay reason, such as being a police checkpoint, being near gunshots, or loitering near a drug drop-off</li><li>Government may raid alongside a Hitman on an active hit</li><li>Government may not raid with other criminals</li></ul>`
                            },
                            {
                                id: "police-raids",
                                html: `<b>Police & Raid Rules</b><ul class="rule-sublist"><li>While a Police Department raid is active, Government players may respawn and return to defend it; this does not count as breaking NLR</li><li>Police responding to an active raid to defend a base are not considered counter raiding</li><li>Police may kill active raiders to defend someone's base during an active raid</li></ul>`
                            },
                            {
                                id: "pd-lobby-kos",
                                html: `<b>Police Department — Lobby & KOS Rules</b><ul class="rule-sublist"><li>The Police Department lobby is the front room from the main entrance (the area past the front doors), including the public speaking window and ATM</li><li>Entering or being in the PD lobby is never AOS or KOS, and the lobby cannot be made AOS or KOS; KOS cannot start in the lobby</li><li>Only areas behind government-owned interior doors are AOS by default</li><li>The Mayor or Chief of Police may place a valid KOS line at any Police Department entrance except the lobby; areas beyond that line may be KOS</li><li>No law is required to enforce Police Department trespassing as AOS</li></ul>`
                            },
                            {
                                id: "arrests-warrants",
                                html: `<b>Arrest & Warrant Rules</b><ul class="rule-sublist"><li>Government players cannot raid or arrest someone solely because of their job</li><li>Arrests may only be made against lawbreakers</li><li>You may not arrest innocent players, even if bribed</li><li>You may arrest during a lockdown, but KOS is not allowed</li><li>Warrants require valid roleplay evidence</li><li>You must witness illegal activity; you cannot arrest or warrant based off of sound</li><li>Warrants expire when the target is jailed or dies</li><li>Warrants expire on successful raid defense, including when all attending police die</li><li>An individual officer's death does not expire the warrant for other attending police</li><li>You may be killed by the person you are trying to arrest or their basemates</li></ul>`
                            },
                            {
                                id: "corruption",
                                html: `<b>Police Corruption Rules</b><ul class="rule-sublist"><li>Corruption is allowed in roleplay, but not against other government members</li><li>Bribes are allowed</li><li>Cannot raid with criminals, except alongside a Hitman on an active hit</li><li>Cannot allow the Police Department to be raided</li><li>Cannot kill government officials or allow them to be killed</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 5B: CIVILIAN",
                        webBtn: "👷 Civilian",
                        rules: [
                            {
                                id: "gun-dealer",
                                html: `<b>Gun Dealer Rules</b><ul class="rule-sublist"><li>Gun Dealers must intend to sell weapons</li><li>They may not base with another Gun Dealer</li><li>They must sell individual weapons, not only shipments</li></ul>`
                            },
                            {
                                id: "medic",
                                html: `<b>Medic Rules</b><ul class="rule-sublist"><li>Medics must actively provide service</li><li>Only one Medic is allowed per raid party</li><li>Only one Medic is allowed per base</li></ul>`
                            },
                            {
                                id: "theatre-manager",
                                html: `<b>Theatre Manager Rules</b><ul class="rule-sublist"><li>The Theatre Manager must base in the Theatre</li></ul>`
                            },
                            {
                                id: "hobo",
                                html: `<b>Hobo Rules</b><ul class="rule-sublist"><li>Hobos may create a checkpoint or toll booth</li><li>Hobo checkpoint and toll booth fees may not exceed $50</li><li>Hitting players with excrement can lead to a valid kill or arrest</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 5C: CRIMINAL",
                        webBtn: "🕶️ Criminal",
                        rules: [
                            {
                                id: "hitman",
                                html: `<b>Hitman Rules</b><ul class="rule-sublist"><li>Only Hitmen may perform hits</li><li>Hitmen may not metagame hits</li><li>Hitmen may only raid active target locations</li><li>A valid roleplay reason is not required unless the target is the Mayor</li><li>Only one Hitman is allowed per raid</li></ul>`
                            }
                        ]
                    }
                ]
            },
            {
                num: 6,
                title: "Raiding, Mugging, & Cooldowns",
                icon: "fa-bomb",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 6A: RAIDING RULES",
                        webBtn: "⚔️ Raiding Rules",
                        rules: [
                            { id: "raid-guidelines", html: `<b>Raiding Guidelines</b><ul class="rule-sublist"><li>A raid starts when a prybar is out, a base member is damaged, or when a weapon is drawn on the property</li><li>A raid ends when no raiders remain inside or on the property</li></ul>` },
                            { id: "building-sign", html: `<b>Building Sign Rules</b><ul class="rule-sublist"><li>You may not raid a base that has a building sign placed</li><li>You may not place a building sign with valuables in your base</li></ul>` },
                            { id: "mid-raid", html: `<b>Mid-Raid Rules</b><ul class="rule-sublist"><li>Props may not be moved, changed, deleted, or added during a raid</li><li>During a raid, you may use an entity ladder to enter a flawed or open base as allowed under Entity Ladders</li></ul>` },
                            { id: "warrant-raid", html: `<b>Warrant Raid Rules</b><ul class="rule-sublist"><li>A police raid with a warrant ends when all attending police die</li><li>Returning to a location with an active warrant after death breaks NLR</li></ul>` },
                            { id: "no-counter-raid", html: `<b>Counter Raiding Rules</b><ul class="rule-sublist"><li>Counter raiding is joining a raid while not being a part of the original group; this may also be called third-party raiding</li><li>Counter raiding is not allowed</li></ul>` },
                            { id: "base-defense", html: `<b>Base Defense Rules</b><ul class="rule-sublist"><li>To defend a base, you must own valuables inside that base (such as your printers or weed stations)</li><li>You may not defend someone else's base unless you are actively basing with them</li></ul>` }
                        ],
                        guide: {
                            rawHeading: "RAID GUIDE (✅ Can Raid)",
                            webHeading: "Raid Guide (✅ Can Raid)",
                            items: [
                                "Drug Dealer",
                                "Thief",
                                "Gangster",
                                "Mob Boss",
                                "Hitman (active hit required)",
                                "Medic (1 per raid)",
                            ]
                        }
                    },
                    {
                        rawTitle: "SUB-CATEGORY 6B: MUGGING RULES",
                        webBtn: "💰 Mugging Rules",
                        rules: [
                            { id: "mug-limit", html: `<b>Money Limit Rules</b><ul class="rule-sublist"><li>The maximum mug amount is $1,000</li><li>You must type a mug warning, and the victim must be given 10 seconds to respond</li></ul>` },
                            { id: "mug-defense", html: `<b>Defense Rules</b><ul class="rule-sublist"><li>Victims of a mugging may always defend themselves without warning</li></ul>` },
                            { id: "mug-base", html: `<b>Base Mugging Rules</b><ul class="rule-sublist"><li>You may not mug people from your base</li></ul>` },
                            { id: "mug-shipments", html: `<b>Shipment Rules</b><ul class="rule-sublist"><li>You may mug shipments or guns if you see someone collect them</li><li>The same warning rules apply</li></ul>` },
                            { id: "mug-cooldown", html: `<b>Cooldown Rules</b><ul class="rule-sublist"><li>There is a 5-minute cooldown between mugs</li><li>Don't mug the same person repeatedly</li></ul>` }
                        ],
                        guide: {
                            rawHeading: "MUG GUIDE (✅ Can Mug)",
                            webHeading: "Mug Guide (✅ Can Mug)",
                            items: ["Drug Dealer", "Thief", "Gangster", "Mob Boss", "Hobo"]
                        }
                    },
                    {
                        rawTitle: "SUB-CATEGORY 6C: COOLDOWNS",
                        webBtn: "⏳ Cooldowns",
                        rules: [
                            {
                                id: "targeting",
                                html: `<b>Targeting Rules</b><ul class="rule-sublist"><li>You may not spam-mug, spam-hit, or spam-raid the same person after successful attempts. Space things out and RP with other people or it could be considered harassment</li><li>Three or more repeated actions on the same person is considered spam</li></ul>`
                            },
                            {
                                id: "cooldowns",
                                html: `<b>Cooldowns</b><ul class="rule-sublist"><li>Mugging: 5 Minute Cooldown</li><li>Hits: 15 minutes (Same Player)</li><li>Raiding (Same Base): 10 minutes</li><li>Police Department Raid: 10 minutes (Serverwide)</li><li>No raiding for 10 minutes after a server crash</li></ul>`
                            },
                            {
                                id: "mayor-grace",
                                html: `<b>Mayor Grace Period Rules</b><ul class="rule-sublist"><li>For 10 minutes after a Mayor is elected, the Mayor may not be raided, mugged, or killed</li></ul>`
                            }
                        ]
                    }
                ]
            },
            {
                num: 7,
                title: "Minging & Trolling",
                icon: "fa-mask",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 7A: MINGING & TROLLING",
                        webBtn: "🎭 Minging & Trolling",
                        rules: [
                            {
                                id: "minging-prohibited",
                                html: `<b>Minging & Trolling Rules</b><ul class="rule-sublist"><li>Baiting RDM or RDA is not allowed</li><li>Excessive trolling is not allowed</li><li>Preventing others from building is not allowed</li><li>Preventing new players from learning is not allowed</li><li>Repeatedly raiding someone with no valuables is not allowed</li><li>Disobeying staff or reasonable requests is not allowed</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 7B: REPORTING RULES",
                        webBtn: "📝 Reporting",
                        rules: [
                            {
                                id: "report-respect",
                                html: `<b>Reporting Rules</b><ul class="rule-sublist"><li>Be respectful when submitting a report</li><li>Do not spam reports</li><li>Provide proof with your reports (Medal, OBS, or Steam)</li><li>Use @ or /Staff in-game to report issues</li></ul>`
                            }
                        ]
                    }
                ]
            }
        ];

        const htmlToPlainText = (html) =>
            String(html ?? "")
                .replace(/<br\s*\/?>/gi, "\n")
                .replace(/<\/li>\s*<li>/gi, "\n")
                .replace(/<[^>]+>/g, "")
                .replace(/&amp;/g, "&")
                .replace(/&lt;/g, "<")
                .replace(/&gt;/g, ">")
                .replace(/&#39;/g, "'")
                .replace(/&quot;/g, '"')
                .replace(/\s+/g, " ")
                .trim();

        const extractRuleTitle = (introHtml) => {
            const match = String(introHtml ?? "").match(/<b>([^<]*)<\/b>/i);
            return match ? match[1].trim() : "";
        };

        const parseRuleSublist = (html) => {
            const marker = '<ul class="rule-sublist">';
            if (!html || !html.includes(marker)) return null;
            const first = html.indexOf(marker);
            if (html.indexOf(marker, first + marker.length) !== -1) return null;
            const start = first;
            const end = html.indexOf("</ul>", start);
            if (start === -1 || end === -1) return null;
            const intro = html.slice(0, start).trim();
            const listHtml = html.slice(start + marker.length, end);
            const bullets = [];
            const liRegex = /<li>([\s\S]*?)<\/li>/gi;
            let match;
            while ((match = liRegex.exec(listHtml)) !== null) {
                const item = match[1].trim();
                if (item) bullets.push(item);
            }
            if (bullets.length === 0) return null;
            return { intro, bullets };
        };

        const makeRuleNumberStream = (catNum, sectionNum = null) => {
            let n = 0;
            return {
                next() {
                    n += 1;
                    return sectionNum == null ? `${catNum}.${n}` : `${catNum}.${sectionNum}.${n}`;
                }
            };
        };

        const renderRawRuleEntry = (id, html, stream) => {
            const parsed = parseRuleSublist(html);
            if (!parsed) {
                const num = stream.next();
                return `<li id="${id}"><span class="rule-num">${num}.</span> ${html}</li>`;
            }
            const parts = [];
            if (parsed.intro) parts.push(`<li class="rule-intro">${parsed.intro}</li>`);
            parsed.bullets.forEach((bullet, index) => {
                const num = stream.next();
                parts.push(`<li id="${id}-${index + 1}"><span class="rule-num">${num}.</span> ${bullet}</li>`);
            });
            return parts.join("\n                            ");
        };

        const renderRawRulesList = (rules, stream) =>
            (rules || []).map((r) => renderRawRuleEntry(r.id, r.html, stream)).join("\n                            ");

        const renderRawSubcategory = (sub, stream) => {
            let html = `<h4>${sub.rawTitle}</h4>`;
            if (sub.guide) html += renderRawGuide(sub.guide);
            html += `<ul>\n                            ${renderRawRulesList(sub.rules, stream)}\n                        </ul>`;
            return html;
        };

        const renderRawGuide = (block) => `
                        <h4>${block.rawHeading}</h4>
                        <ul>
                            ${block.items.map((item) => `<li>${item} — ✅</li>`).join("\n                            ")}
                        </ul>`;

        const renderRawBlock = (block, stream) => {
            if (block.type === "heading") return `<h4${block.underline ? ' class="rule-heading-underline"' : ""}>${block.raw}</h4>`;
            if (block.type === "rules") return `<ul>\n                            ${renderRawRulesList(block.rules, stream)}\n                        </ul>`;
            if (block.type === "guide") return renderRawGuide(block);
            if (block.type === "cooldowns") {
                return `<ul>\n                            ${block.rawItems.map((item) => `<li>${item}</li>`).join("\n                            ")}\n                        </ul>`;
            }
            return "";
        };

        const renderRawCategoryBody = (cat) => {
            let html = "";
            if (cat.rules) {
                html += `<ul>\n                            ${renderRawRulesList(cat.rules, makeRuleNumberStream(cat.num))}\n                        </ul>`;
                if (cat.footer) html += cat.footer;
            }
            if (cat.subcategories) {
                html += cat.subcategories
                    .map((sub, index) => renderRawSubcategory(sub, makeRuleNumberStream(cat.num, index + 1)))
                    .join("");
            }
            if (cat.blocks) {
                let rulesBlockIdx = 0;
                html += cat.blocks
                    .map((block) => {
                        if (block.type === "rules") {
                            rulesBlockIdx += 1;
                            return renderRawBlock(block, makeRuleNumberStream(cat.num, rulesBlockIdx));
                        }
                        return renderRawBlock(block, null);
                    })
                    .join("");
            }
            return html;
        };

        const renderRawRulesDocument = (options = {}) => {
            const lite = options.lite === true;
            return `
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                ${lite ? "" : `<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">`}
                ${lite ? "" : `<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@900&family=Inter:wght@400;600&display=swap" rel="stylesheet">`}
                <style>
                    :root { --lp-blue: #017AEF; --lp-blue-hover: #33A0FF; --lp-blue-rgb: 1, 122, 239; --bg: #000000; --surface: #1a1d23; --surface-inset: #12151a; --border: #374151; }
                    body { font-family: ${lite ? "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif" : "'Inter', sans-serif"}; background: var(--bg); color: #fff; margin: 0; padding: 20px; line-height: 1.6; }
                    .header { text-align: center; margin-bottom: 30px; }
                    .header h1 { font-family: ${lite ? "inherit" : "'Montserrat', sans-serif"}; font-size: 32px; text-transform: uppercase; margin: 0; color: var(--lp-blue); font-weight: 800; }
                    .header p { color: #9ca3af; font-size: 14px; }
                    ${lite ? `.sbox-hint { text-align: center; color: #9ca3af; font-size: 12px; font-weight: 600; margin: 0 0 18px; padding: 10px 14px; border: 1px solid rgba(1, 122, 239, 0.35); border-radius: 8px; background: rgba(1, 122, 239, 0.08); }` : ""}
                    details { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; margin-bottom: 10px; overflow: hidden; }
                    summary { padding: 15px 20px; cursor: pointer; font-weight: bold; list-style: none; display: flex; justify-content: space-between; align-items: center; text-transform: uppercase; font-size: 14px; letter-spacing: 1px; }
                    summary::-webkit-details-marker { display: none; }
                    summary::after { content: '➔'; color: var(--lp-blue); transition: 0.3s; }
                    details[open] summary::after { transform: rotate(90deg); }
                    details[open] summary { border-bottom: 1px solid var(--border); background: var(--lp-blue); color: #fff; }
                    .content { padding: 20px; font-size: 14px; color: #ffffff; }
                    .content ul { list-style: none; padding: 0; margin: 0; }
                    .content li { margin-bottom: 12px; padding-left: 15px; border-left: 2px solid var(--lp-blue); }
                    .content li.rule-intro { border-left-color: rgba(var(--lp-blue-rgb), 0.35); }
                    .content li.rule-intro ul.rule-sublist { display: none; }
                    .content .rule-num { color: #6b8499; font-weight: 600; font-size: 0.92em; margin-right: 0.35em; font-variant-numeric: tabular-nums; letter-spacing: 0.03em; }
                    .content b { color: var(--lp-blue); }
                    .content h4.rule-heading-underline { text-decoration: underline; }
                    .content li > b + ul.rule-sublist { margin-top: 6px; }
                    .important { color: #ff4d4d; font-weight: bold; margin-top: 15px; display: block; }
                    .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid var(--border); color: #9ca3af; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>LifePunch Rules</h1>
                    <p>Official s&box DXRP Guidelines</p>
                </div>
                ${lite ? `<p class="sbox-hint">Press Tab to close the dashboard. Expand a section below to read rules.</p>` : ""}
                ${LP_RULES.map((cat) => `
                <details>
                    <summary>${cat.num}. ${cat.title}</summary>
                    <div class="content">${renderRawCategoryBody(cat)}</div>
                </details>`).join("")}
                <div class="footer">
                    Searchable rules available at lifepunch.co/rules<br>
                    &copy; 2026 LifePunch Network
                </div>
            </body>
            </html>`;
        };

        const renderWebRulesList = (rules, rule) =>
            (rules || []).map((r) => rule(r.id, r.html)).join("\n                          ");

        const renderWebSubcategory = (sub, rule) => {
            let inner = "";
            if (sub.guide) inner += renderWebGuide(sub.guide);
            inner += renderWebRulesList(sub.rules, rule);
            return `
                          <div class="sub-cat">
                              <button class="sub-btn">${sub.webBtn} <i class="fa-solid fa-chevron-down chevron"></i></button>
                              <div class="content-wrapper"><div class="content"><div class="content-inner">
                                  ${inner}
                              </div></div></div>
                          </div>`;
        };

        const renderWebGuide = (block) => `
                          <div class="sub-title">${block.webHeading}</div>
                          <div class="guide-grid">
                              ${block.items.map((item) => `<div class="guide-item">${item}<span>✅</span></div>`).join("\n                              ")}
                          </div>`;

        const renderWebBlock = (block, rule) => {
            if (block.type === "heading") {
                const label = block.webEmoji
                    ? `<span class="sub-title-emoji">${block.webEmoji}</span><span${block.underline ? ' class="sub-title--underline"' : ""}>${block.web}</span>`
                    : block.web;
                return `<div class="sub-title${block.underline && !block.webEmoji ? " sub-title--underline" : ""}">${label}</div>`;
            }
            if (block.type === "rules" && rule) return renderWebRulesList(block.rules, rule);
            if (block.type === "guide") return renderWebGuide(block);
            if (block.type === "cooldowns" && rule) return rule(block.webRule.id, block.webRule.html);
            return "";
        };

        const renderWebCategoryBody = (cat, createRule) => {
            let html = "";
            if (cat.rules) {
                html += renderWebRulesList(cat.rules, createRule(makeRuleNumberStream(cat.num)));
                if (cat.footer) html += cat.footer;
            }
            if (cat.subcategories) {
                html += cat.subcategories
                    .map((sub, index) => renderWebSubcategory(sub, createRule(makeRuleNumberStream(cat.num, index + 1))))
                    .join("");
            }
            if (cat.blocks) {
                let rulesBlockIdx = 0;
                html += cat.blocks
                    .map((block) => {
                        if (block.type === "rules" || block.type === "cooldowns") {
                            rulesBlockIdx += 1;
                            return renderWebBlock(block, createRule(makeRuleNumberStream(cat.num, rulesBlockIdx)));
                        }
                        return renderWebBlock(block, null);
                    })
                    .join("");
            }
            return html;
        };

        const renderWebRulesRoot = (createRule) =>
            LP_RULES.map((cat) => `
              <div class="category">
                  <button class="cat-btn">
                      <div class="icon-box"><i class="fa-solid ${cat.icon}"></i></div>
                      ${cat.num}. ${cat.title}
                      <i class="fa-solid fa-chevron-down chevron"></i>
                  </button>
                  <div class="content-wrapper">
                      <div class="content">
                          <div class="content-inner">
                              ${renderWebCategoryBody(cat, createRule)}
                          </div>
                      </div>
                  </div>
              </div>`).join("");


        // --- DXRP AUTOMATION HELPERS ---
        async function updateDxrpBalance(steamid, newBalance, reason = "Automated Store Purchase") {
            const token = await linksKv.get("config:dxrp_token");
            const tenant = await linksKv.get("config:dxrp_tenant") || "019db2d6-fc3d-743f-9dc6-2620c69078c2";
            if (!token) throw new Error("DXRP Token not configured");

            const res = await fetch(`https://api.dxrp.net/v1/players/${steamid}/balance`, {
                method: 'POST',
                headers: {
                    'authorization': `Bearer ${token}`,
                    'content-type': 'application/json',
                    'x-tenant': tenant,
                    'accept': 'application/octet-stream',
                    'user-agent': 'LifePunch-Bridge/1.0'
                },
                body: JSON.stringify({ balance: Math.floor(newBalance), reason: reason })
            });
            if (res.status === 401) {
                await linksKv.put("status:dxrp_error", "Token Expired (401)");
                throw new Error("DXRP Token Expired. Please update in Admin Panel.");
            }
            if (!res.ok) {
                const text = await res.text();
                throw new Error(`DXRP API Error (${res.status}): ${text}`);
            }
            await linksKv.delete("status:dxrp_error");
            return true;
        }

        async function testDxrpConnection() {
            const token = await linksKv.get("config:dxrp_token");
            const tenant = await linksKv.get("config:dxrp_tenant") || "019db2d6-fc3d-743f-9dc6-2620c69078c2";
            if (!token) return { ok: false, error: "No Bearer token saved. Paste your DXRP session token and click Update Config first." };
            if (!token.trim().startsWith("eyJ")) {
                return { ok: false, error: "This looks like a portal API key, not a Bearer token. The Automation Bridge requires the long JWT from dxrp.net (DevTools or Update Token bookmark)." };
            }

            const res = await fetch(`https://api.dxrp.net/v1/me`, {
                headers: {
                    'authorization': `Bearer ${token.trim()}`,
                    'x-tenant': tenant,
                    'user-agent': 'LifePunch-Bridge/1.0'
                }
            });

            if (res.status === 401) {
                return { ok: false, error: "Bearer token rejected (401). Log into dxrp.net and refresh it with the Update Token bookmark or copy a new token from DevTools." };
            }
            if (!res.ok) {
                const text = await res.text();
                return { ok: false, error: `DXRP API error (${res.status}): ${text || res.statusText}` };
            }

            const me = await res.json();
            return {
                ok: true,
                name: me.name || me.displayName || "Connected",
                balance: me.balance ?? null
            };
        }

        async function getDxrpPlayer(steamid) {
            const token = await linksKv.get("config:dxrp_token");
            const tenant = await linksKv.get("config:dxrp_tenant") || "019db2d6-fc3d-743f-9dc6-2620c69078c2";

            if (!token) return null;

            const res = await fetch(`https://api.dxrp.net/v1/players/${steamid}`, {
                headers: {
                    'authorization': `Bearer ${token}`,
                    'x-tenant': tenant,
                    'user-agent': 'LifePunch-Bridge/1.0'
                }
            });

            if (res.ok) return await res.json();
            return null;
        }

        async function updateDxrpLevel(steamid, level) {
            const token = await linksKv.get("config:dxrp_token");
            const tenant = await linksKv.get("config:dxrp_tenant") || "019db2d6-fc3d-743f-9dc6-2620c69078c2";
            if (!token) throw new Error("DXRP Token not configured");

            const res = await fetch(`https://api.dxrp.net/v1/players/${steamid}/level`, {
                method: 'POST',
                headers: {
                    'authorization': `Bearer ${token}`,
                    'content-type': 'application/json',
                    'x-tenant': tenant,
                    'user-agent': 'LifePunch-Bridge/1.0'
                },
                body: JSON.stringify({ level: parseInt(level) })
            });
            if (!res.ok) {
                const text = await res.text();
                throw new Error(`DXRP Level Error (${res.status}): ${text}`);
            }
            return true;
        }

        async function assignDxrpRank(steamid, rankId) {
            const token = await linksKv.get("config:dxrp_token");
            const tenant = await linksKv.get("config:dxrp_tenant") || "019db2d6-fc3d-743f-9dc6-2620c69078c2";
            if (!token) throw new Error("DXRP Token not configured");

            // Path from cURL: /v1/ranks/assign/{steamid}
            const res = await fetch(`https://api.dxrp.net/v1/ranks/assign/${steamid}`, {
                method: 'POST',
                headers: {
                    'authorization': `Bearer ${token}`,
                    'content-type': 'application/json',
                    'x-tenant': tenant,
                    'user-agent': 'LifePunch-Bridge/1.0'
                },
                body: JSON.stringify([rankId])
            });
            if (!res.ok) {
                const text = await res.text();
                throw new Error(`DXRP Rank Error (${res.status}): ${text}`);
            }
            return true;
        }

        // --- DXRP AUTOMATION BRIDGE ---
        async function queueAutomation(steamid, packageName) {
            const queueKey = "queue:pending_automation";
            const currentQueue = await linksKv.get(queueKey);
            const queue = currentQueue ? JSON.parse(currentQueue) : [];
            queue.push({ steamid, packageName, timestamp: Date.now() });
            await linksKv.put(queueKey, JSON.stringify(queue));
        }

        async function processQueuedAutomation() {
            const queueKey = "queue:pending_automation";
            const currentQueue = await linksKv.get(queueKey);
            if (!currentQueue) return { message: "Queue is empty." };
            
            const queue = JSON.parse(currentQueue);
            const processedKey = "processed:automation_ids";
            const processedHistoryRaw = await linksKv.get(processedKey);
            const processedHistory = processedHistoryRaw ? JSON.parse(processedHistoryRaw) : [];
            
            const remaining = [];
            let processedCount = 0;

            for (const item of queue) {
                const taskId = `${item.steamid}:${item.packageName}:${item.timestamp}`;
                
                if (processedHistory.includes(taskId)) {
                    continue;
                }

                try {
                    await runAutomation(item.steamid, item.packageName);
                    processedHistory.push(taskId);
                    processedCount++;
                } catch (e) {
                    remaining.push(item);
                }
            }
            
            await linksKv.put(processedKey, JSON.stringify(processedHistory.slice(-500)));
            if (remaining.length > 0) {
                await linksKv.put(queueKey, JSON.stringify(remaining));
            } else {
                await linksKv.delete(queueKey);
            }
            return { message: `Successfully processed ${processedCount} tasks.` };
        }

        async function runAutomation(steamid, packageName) {
            const results = [];
            try {
                // 1. Balance Update
                let bonusMoney = 0;
                if (packageName.includes("VIP")) bonusMoney = 10000;
                if (packageName.includes("EVIP")) bonusMoney = 25000;
                if (packageName.includes("$LP")) {
                    const lpMatch = packageName.match(/\((\d+)\)/);
                    if (lpMatch) bonusMoney = parseInt(lpMatch[1]) * 2000;
                }

                if (bonusMoney > 0) {
                    try {
                        const player = await getDxrpPlayer(steamid);
                        if (player) {
                            await updateDxrpBalance(steamid, (player.balance || 0) + bonusMoney, `Store Purchase: ${packageName}`);
                            results.push("Balance: OK");
                        } else {
                            results.push("Balance: Player Not Found");
                        }
                    } catch (e) {
                        results.push(`Balance: ${e.message}`);
                        throw e;
                    }
                }

                // 2. Rank & Level Assignment
                try {
                    if (packageName.includes("EVIP")) {
                        await assignDxrpRank(steamid, "019db2db-0656-7893-ae2b-3ae1be47c186");
                        await updateDxrpLevel(steamid, 2);
                        results.push("EVIP Perks: OK");
                    } else if (packageName.includes("VIP")) {
                        await assignDxrpRank(steamid, "019db2da-c303-7c94-99e9-f3dbb6efb525");
                        await updateDxrpLevel(steamid, 1);
                        results.push("VIP Perks: OK");
                    }
                } catch (e) {
                    results.push(`Perks Error: ${e.message}`);
                    throw e;
                }

                if (linksKv) {
                    const status = results.join(" | ");
                    if (results.some(r => !r.endsWith("OK"))) {
                        await linksKv.put("status:dxrp_error", `Automation [${packageName}]: ${status}`);
                    } else {
                        await linksKv.delete("status:dxrp_error");
                    }
                }
            } catch (e) {
                console.error("DXRP Bridge Error:", e.message);
                if (linksKv) await linksKv.put("status:dxrp_error", `Bridge Error: ${e.message}`);
                throw e;
            }
        }

        /** Must match the redirect URL in the Discord app (OAuth2). */
        const getDiscordRedirectUri = () =>
            (env.DISCORD_REDIRECT_URI || "").trim() || `${url.origin}/discord/callback`;

        function discordAvatarUrl(acc) {
            if (!acc?.id) return "https://cdn.discordapp.com/embed/avatars/0.png";
            if (acc.avatar) {
                return `https://cdn.discordapp.com/avatars/${acc.id}/${acc.avatar}.png?size=128`;
            }
            try {
                const idx = Number((BigInt(acc.id) >> 22n) % 6n);
                return `https://cdn.discordapp.com/embed/avatars/${idx}.png`;
            } catch {
                return "https://cdn.discordapp.com/embed/avatars/0.png";
            }
        }

        // --- STEAM API HELPER ---
        async function getSteamProfileData(steamId) {
            try {
                const res = await fetch(
                    `https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=${env.STEAM_API_KEY}&steamids=${steamId}`
                );
                const data = await res.json();
                if (data.response?.players?.length > 0) {
                    return data.response.players[0];
                }
                return null;
            } catch (e) {
                console.error("Error fetching Steam profile:", e);
                return null;
            }
        }

        // Shared page variables need to be declared before any route handlers that set them
        let bodyContent = "";
        let pageTitle = "LIFEPUNCH";
        let subHeaderTitle = "HOME"; // Default subheader
        let bodyClass = "";

        // --- AUTH ROUTES ---
        if (path === "/login") {
            const returnPath = url.searchParams.get("return") || "/";
            const returnTo = `${url.origin}/auth/callback?return=${encodeURIComponent(returnPath)}`;
            const params = new URLSearchParams({
                "openid.ns": "http://specs.openid.net/auth/2.0",
                "openid.mode": "checkid_setup",
                "openid.return_to": returnTo,
                "openid.realm": url.origin,
                "openid.identity": "http://specs.openid.net/auth/2.0/identifier_select",
                "openid.claimed_id": "http://specs.openid.net/auth/2.0/identifier_select"
            });
            return Response.redirect(`https://steamcommunity.com/openid/login?${params.toString()}`, 302);
        }

        if (path === "/logout") {
            if (sessionToken && env.LINKS) {
                await env.LINKS.delete(`session:${sessionToken}`);
            }
            let returnPath = url.searchParams.get("return") || "/";
            // If logging out from profile, go home to prevent re-auth loop
            if (returnPath.toLowerCase().startsWith("/profile")) {
                returnPath = "/";
            }
            // Simple safety check: ensure returnPath starts with / and not //
            const safeReturn = (returnPath.startsWith("/") && !returnPath.startsWith("//")) ? returnPath : "/";
            
            return new Response(null, {
                status: 302,
                headers: {
                    "Location": safeReturn,
                    "Set-Cookie": "lp_session=; Path=/; Max-Age=0; HttpOnly; SameSite=Lax"
                }
            });
        }

        if (path === "/auth/callback") {
            const params = new URLSearchParams(url.search);
            const originalParams = new URLSearchParams(params); 
            params.set("openid.mode", "check_authentication");
            
            const verifyRes = await fetch("https://steamcommunity.com/openid/login", {
                method: "POST",
                body: params.toString(),
                headers: { 
                    "Content-Type": "application/x-www-form-urlencoded",
                    "User-Agent": "LifePunch-Auth-System/1.0"
                }
            });
            const text = await verifyRes.text();

            if (text.includes("is_valid:true")) {
                const claimedId = originalParams.get("openid.claimed_id");
                const authSteamId = claimedId.split("/").pop();
                
                // --- SECURE KV SESSION ---
                
                // --- BAN CHECK ---
                const isBanned = await linksKv.get(`ban:steam:${authSteamId}`);
                if (isBanned) {
                    return new Response("You are banned from this website.", { status: 403 });
                }

                const newSessionToken = crypto.randomUUID();
                if (linksKv) {
                    // Set session to expire in 30 days in KV
                    await linksKv.put(`session:${newSessionToken}`, authSteamId, { expirationTtl: 2592000 });   
                    // Mark user as registered for referral system
                    await linksKv.put(`user:seen:${authSteamId}`, "1");

                    // Generate Unique Referral Code if not exists
                    const existingCode = await linksKv.get(`user:refcode:${authSteamId}`);
                    if (!existingCode) {
                        const newCode = Math.random().toString(36).substring(2, 10).toUpperCase();
                        await linksKv.put(`user:refcode:${authSteamId}`, newCode);
                        await linksKv.put(`refcode:to:steam:${newCode}`, authSteamId);
                    }
                }

                const returnPath = originalParams.get("return") || "/";
                const safeReturn = (returnPath.startsWith("/") && !returnPath.startsWith("//")) ? returnPath : "/";

                return new Response(null, {
                    status: 302,
                    headers: {
                        "Location": safeReturn,
                        "Set-Cookie": `lp_session=${newSessionToken}; Path=/; Max-Age=2592000; HttpOnly; SameSite=Lax` 
                    }
                });
            }
            return new Response(`Authentication Failed. Server Response: ${text}`, { status: 401 });
        }

        async function fetchDiscordUserGuildIds(accessToken) {
            const guildIds = [];
            let after = null;
            for (let page = 0; page < 30; page++) {
                const u = new URL("https://discord.com/api/v10/users/@me/guilds");
                u.searchParams.set("limit", "200");
                if (after) u.searchParams.set("after", after);
                const res = await fetch(u.toString(), {
                    headers: { Authorization: `Bearer ${accessToken}` }
                });
                if (!res.ok) {
                    console.error("Discord /users/@me/guilds failed", res.status);
                    return null;
                }
                const arr = await res.json();
                if (!Array.isArray(arr)) return null;

                for (const g of arr) {
                    if (g?.id) guildIds.push(String(g.id));
                }
                if (arr.length < 200) break;
                after = arr[arr.length - 1].id;
            }
            return guildIds;
        }

        /** After guild + account checks; sends webhook and sets KV + caller sets cookie via redirect. */
        async function executeRewardClaim(forSteamId) {
            if (!linksKv) return { ok: false, reason: "no_kv" };

            const claimKey = `reward_claimed:discord:${forSteamId}`;
            const claimedKv = await linksKv.get(claimKey);
            if (claimedKv) {
                return { ok: false, reason: "already_claimed" };
            }
            // Also check legacy key for now
            const legacyClaimed = await linksKv.get(`discord_reward_claimed:${forSteamId}`);
            if (legacyClaimed) {
                return { ok: false, reason: "already_claimed" };
            }

            const linkRaw = await linksKv.get(`link:steam:${forSteamId}`);
            let discordLink = null;
            if (linkRaw) {
                try {
                    discordLink = JSON.parse(linkRaw);
                } catch {
                    discordLink = null;
                }
            }
            if (!discordLink?.id) return { ok: false, reason: "not_linked" };

            const LEGACY_REWARDS_WEBHOOK =
                "https://discord.com/api/webhooks/1500544505374576710/-rdBS4Qe5gRoDAo8YIkznR4IYME1LzEG4zFGr3Qeb_XaXvkPVw-erl6FVQc6QtOgQX3t";
            const rewardsHook =
                (env.DISCORD_REWARDS_WEBHOOK_URL || "").trim() ||
                LEGACY_REWARDS_WEBHOOK ||
                (env.DISCORD_WEBHOOK_URL || "").trim();

            if (!rewardsHook) return { ok: false, reason: "no_webhook" };

            const portalLink = `https://dxrp.net/portal/players/${forSteamId}`;
            const discordTag =
                discordLink.global_name ||
                discordLink.username || "Linked user";

            const safeTag = String(discordTag).replace(/`/g, "'").slice(0, 100);
            const discordField = `<@${discordLink.id}> (\`${discordLink.id}\`)\n**${safeTag}**`;

            const embed = {
                title: "🎁 Discord Reward Claimed!",
                color: 0x00c853,
                fields: [
                    { name: "SteamID64", value: `\`${forSteamId}\``, inline: true },
                    { name: "Discord", value: discordField, inline: true },
                    { name: "Reward", value: "**$10,000** (Join Discord)", inline: false },
                    { name: "Admin Panel", value: "[Manage Rewards](https://lifepunch.co/admin/rewards)", inline: false }
                ],
                footer: { text: "LifePunch Rewards • 2026" },
                timestamp: new Date().toISOString()
            };

                // --- DXRP AUTOMATION BRIDGE ---
                try {
                    const player = await getDxrpPlayer(forSteamId);
                    if (player) {
                        const newBalance = (player.balance || 0) + 10000;
                        await updateDxrpBalance(forSteamId, newBalance, "Reward: Join Discord");
                    }
                } catch (e) {
                    console.error("DXRP Reward Bridge Error:", e.message);
                    if (linksKv) await linksKv.put("status:dxrp_error", `Reward Bridge Failed: ${e.message}`);
                }

                await linksKv.put(claimKey, JSON.stringify({ at: Date.now(), type: 'discord', discord_id: discordLink.id, steamid: forSteamId }));
                return { ok: true };
            }

            async function oauthErrorRedirect(discordState, encodedMessage) {
            let base = `${url.origin}/profile`;
            if (discordState && linksKv) {
                const raw = await linksKv.get(`oauth:discord:state:${discordState}`);
                if (raw) {
                    try {
                        const parsed = JSON.parse(raw);
                        if (parsed.mode === "claim_guild_verify") {
                            base = `${url.origin}/rewards`;
                        }
                    } catch {
                        /* ignore */
                    }
                }
            }
            return Response.redirect(`${base}?discord_error=${encodedMessage}`, 302);
        }

        // --- DISCORD LINK (OAuth2 + KV) ---
        if (path === "/auth/discord" && request.method === "GET") {
            if (!steamid) {
                return Response.redirect(`${url.origin}/login?return=${encodeURIComponent("/profile")}`, 302);
            }
            if (!env.DISCORD_CLIENT_ID || !env.DISCORD_CLIENT_SECRET) {
                return new Response(
                    "Discord OAuth is not configured (set DISCORD_CLIENT_ID and DISCORD_CLIENT_SECRET).",
                    { status: 503 }
                );
            }
            if (!linksKv) {
                return new Response(
                    "KV is not bound (add a KV namespace with binding name LINKS or KV in wrangler.toml).",
                    { status: 503 }
                );
            }

            const state = crypto.randomUUID();
            await linksKv.put(
                `oauth:discord:state:${state}`,
                JSON.stringify({ steamid, mode: "link" }),
                { expirationTtl: 600 }
            );

            const redirectUri = getDiscordRedirectUri();
            const authorize = new URL("https://discord.com/api/oauth2/authorize");
            authorize.searchParams.set("client_id", env.DISCORD_CLIENT_ID);
            authorize.searchParams.set("redirect_uri", redirectUri);
            authorize.searchParams.set("response_type", "code");
            authorize.searchParams.set("scope", "identify");
            authorize.searchParams.set("state", state);

            return Response.redirect(authorize.toString(), 302);
        }

        if (path === "/rewards/claim-weekend" && request.method === "GET") {
            if (!steamid) {
                return Response.redirect(`${url.origin}/login?return=${encodeURIComponent("/rewards")}`, 302);
            }
            if (!linksKv) {
                return new Response("KV is not bound.", { status: 503 });
            }

            const getET = (d) => new Date(d.toLocaleString("en-US", {timeZone: "America/New_York"}));
            const nowET = getET(new Date());
            const dayET = nowET.getDay(); 
            const hourET = nowET.getHours();

            let isWeekend = false;
            if (dayET === 5 && hourET >= 18) isWeekend = true; 
            if (dayET === 6 || dayET === 0) isWeekend = true; 

            if (!isWeekend) {
                return Response.redirect(`${url.origin}/rewards?weekend_error=not_weekend`, 302);
            }

            let friDate = new Date(nowET);
            if (dayET === 0) friDate.setDate(nowET.getDate() - 2);
            else if (dayET === 6) friDate.setDate(nowET.getDate() - 1);
            else if (dayET === 5) friDate.setDate(nowET.getDate());
            
            const weekendId = friDate.toISOString().split('T')[0];

            const stateKey = `claimed_weekend:${weekendId}:${steamid}`;
            const alreadyClaimed = await linksKv.get(stateKey);
            if (alreadyClaimed) {
                return Response.redirect(`${url.origin}/rewards?weekend_error=already_claimed`, 302);
            }

            let linkData = null;
            const lr = await linksKv.get(`link:steam:${steamid}`);
            if (lr) {
                try {
                    linkData = JSON.parse(lr);
                } catch {}
            }
            if (!linkData || !linkData.id) {
                return Response.redirect(`${url.origin}/rewards?weekend_error=discord_not_linked`, 302);
            }

            // Save claim
            await linksKv.put(stateKey, JSON.stringify({ at: Date.now() }));

            // Log for admin panel
            const adminKey = `reward_claimed:weekend:${steamid}:${Date.now()}`;
            await linksKv.put(adminKey, JSON.stringify({
                at: Date.now(),
                type: "weekend",
                steamid: steamid,
                discord_id: linkData.id,
                weekend_id: weekendId,
                key: adminKey
            }));

            // Notify Staff via Webhook
            const rewardsHook = (env.DISCORD_REWARDS_WEBHOOK_URL || "").trim() || 
                              "https://discord.com/api/webhooks/1500544505374576710/-rdBS4Qe5gRoDAo8YIkznR4IYME1LzEG4zFGr3Qeb_XaXvkPVw-erl6FVQc6QtOgQX3t" ||
                              (env.DISCORD_WEBHOOK_URL || "").trim();

            if (rewardsHook) {
                try {
                    const discordTag = linkData.global_name || linkData.username || steamid;
                    const portalLink = `https://dxrp.net/portal/players/${steamid}`;

                    await fetch(rewardsHook, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({
                            content: `@here **${discordTag}** claimed their Weekend Bonus!`,
                            username: "LifePunch Rewards",
                            embeds: [{
                                title: "🎁 Weekend Bonus Claimed",
                                color: 0x0076e3,
                                fields: [
                                    { name: "SteamID64", value: `\`${steamid}\``, inline: true },
                                    { name: "Discord", value: `<@${linkData.id}>`, inline: true },
                                    { name: "Reward", value: "**$10,000** (Weekend Bonus)", inline: false },
                                    { name: "Admin Panel", value: "[Manage Rewards](https://lifepunch.co/admin/rewards)", inline: false }
                                ],
                                footer: { text: "LifePunch Rewards • 2026" },
                                timestamp: new Date().toISOString()
                            }]
                        })
                    });
                } catch (e) { console.error("Webhook failed", e); }
            }

            return Response.redirect(`${url.origin}/rewards?reward_claimed=weekend`, 302);
        }

        if (path === "/auth/discord/claim-verify" && request.method === "GET") {
            if (!steamid) {
                return Response.redirect(`${url.origin}/login?return=${encodeURIComponent("/rewards")}`, 302);
            }
            if (!env.DISCORD_CLIENT_ID || !env.DISCORD_CLIENT_SECRET) {
                return new Response("Discord OAuth is not configured.", { status: 503 });
            }
            if (!linksKv) {
                return new Response("KV is not bound.", { status: 503 });
            }

            const guildId = (env.DISCORD_GUILD_ID || "").trim();
            if (!guildId) {
                return new Response(
                    "Set DISCORD_GUILD_ID in Worker environment (Discord server ID, Developer Mode → Copy ID).",
                    { status: 503 }
                );
            }

            const claimedKv = await linksKv.get(`reward_claimed:discord:${steamid}`) || await linksKv.get(`discord_reward_claimed:${steamid}`);
            if (claimedKv) {
                return Response.redirect(
                    `${url.origin}/rewards?discord_error=${encodeURIComponent("already_claimed")}`,
                    302
                );
            }

            let linkedOk = false;
            const lr = await linksKv.get(`link:steam:${steamid}`);
            if (lr) {
                try {
                    const o = JSON.parse(lr);
                    if (o?.id) linkedOk = true;
                } catch {
                    linkedOk = false;
                }
            }
            if (!linkedOk) {
                return Response.redirect(
                    `${url.origin}/rewards?discord_error=${encodeURIComponent("discord_not_linked")}`,
                    302
                );
            }

            const state = crypto.randomUUID();
            await linksKv.put(
                `oauth:discord:state:${state}`,
                JSON.stringify({ steamid, mode: "claim_guild_verify" }),
                { expirationTtl: 600 }
            );

            const redirectUri = getDiscordRedirectUri();
            const authorize = new URL("https://discord.com/api/oauth2/authorize");
            authorize.searchParams.set("client_id", env.DISCORD_CLIENT_ID);
            authorize.searchParams.set("redirect_uri", redirectUri);
            authorize.searchParams.set("response_type", "code");
            authorize.searchParams.set("scope", "identify guilds");
            authorize.searchParams.set("state", state);
            authorize.searchParams.set("prompt", "consent");

            return Response.redirect(authorize.toString(), 302);
        }

        if (
            (path === "/auth/discord/callback" || path === "/discord/callback") &&
            request.method === "GET"
        ) {
            const errParam = url.searchParams.get("error");
            const errDesc = url.searchParams.get("error_description") || "";
            const stateQ = url.searchParams.get("state");

            if (errParam) {
                const msg = errDesc ? `${errParam}: ${errDesc}` : errParam;
                return oauthErrorRedirect(stateQ, encodeURIComponent(msg));
            }

            const code = url.searchParams.get("code");
            const state = stateQ;

            if (!code || !state || !linksKv || !env.DISCORD_CLIENT_ID || !env.DISCORD_CLIENT_SECRET) {
                return oauthErrorRedirect(state, encodeURIComponent("missing_params"));
            }

            const stateRaw = await linksKv.get(`oauth:discord:state:${state}`);
            if (!stateRaw) {
                return oauthErrorRedirect(state, encodeURIComponent("invalid_or_expired_state"));
            }
            await linksKv.delete(`oauth:discord:state:${state}`);

            let stateParsed;
            try {
                stateParsed = JSON.parse(stateRaw);
            } catch {
                return oauthErrorRedirect(null, encodeURIComponent("bad_state"));
            }

            const linkSteamId = stateParsed.steamid;
            const oauthMode =
                stateParsed.mode === "claim_guild_verify" ? "claim_guild_verify" : "link";

            if (!linkSteamId) {
                return oauthErrorRedirect(null, encodeURIComponent("bad_state"));
            }

            const rewardErrBase = `${url.origin}/rewards`;
            const redirectUri = getDiscordRedirectUri();

            const tokenRes = await fetch("https://discord.com/api/oauth2/token", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({
                    client_id: env.DISCORD_CLIENT_ID,
                    client_secret: env.DISCORD_CLIENT_SECRET,
                    grant_type: "authorization_code",
                    code,
                    redirect_uri: redirectUri
                }).toString()
            });

            const tokenJson = await tokenRes.json().catch(() => ({}));
            if (!tokenRes.ok || !tokenJson.access_token) {
                console.error("Discord token exchange failed", tokenJson);
                const b = oauthMode === "claim_guild_verify" ? rewardErrBase : `${url.origin}/profile`;
                return Response.redirect(`${b}?discord_error=${encodeURIComponent("token_exchange_failed")}`, 302);
            }

            const userRes = await fetch("https://discord.com/api/v10/users/@me", {
                headers: { Authorization: `Bearer ${tokenJson.access_token}` }
            });
            const discordUser = await userRes.json().catch(() => null);

            if (!userRes.ok || !discordUser?.id) {
                console.error("Discord @me failed", discordUser);
                const b = oauthMode === "claim_guild_verify" ? rewardErrBase : `${url.origin}/profile`;
                return Response.redirect(`${b}?discord_error=${encodeURIComponent("discord_user_fetch_failed")}`, 302);
            }

            const discordId = discordUser.id;

            if (oauthMode === "claim_guild_verify") {
                const gid = (env.DISCORD_GUILD_ID || "").trim().replace(/^"|"$/g, "");
                if (!gid) {
                    return Response.redirect(
                        `${rewardErrBase}?discord_error=${encodeURIComponent("guild_id_not_configured")}`,
                        302
                    );
                }

                const linkedRaw = await linksKv.get(`link:steam:${linkSteamId}`);
                let linked = null;
                if (linkedRaw) {
                    try {
                        linked = JSON.parse(linkedRaw);
                    } catch {
                        linked = null;
                    }
                }
                if (!linked?.id || String(linked.id) !== String(discordId)) {
                    return Response.redirect(
                        `${rewardErrBase}?discord_error=${encodeURIComponent("wrong_discord_account_use_linked_account")}`,
                        302
                    );
                }

                const guildList = await fetchDiscordUserGuildIds(tokenJson.access_token);
                if (guildList === null) {
                    return Response.redirect(
                        `${rewardErrBase}?discord_error=${encodeURIComponent("could_not_read_guild_list")}`,
                        302
                    );
                }

                if (!guildList.includes(String(gid))) {
                    return Response.redirect(
                        `${rewardErrBase}?discord_error=${encodeURIComponent("not_in_discord_server_join_first")}`,
                        302
                    );
                }

                const result = await executeRewardClaim(linkSteamId);
                if (!result.ok) {
                    const m =
                        result.reason === "already_claimed"
                            ? "already_claimed"
                            : result.reason === "not_linked"
                              ? "discord_not_linked"
                              : result.reason === "webhook_failed"
                                ? "webhook_failed"
                                : "claim_failed";

                    return Response.redirect(`${rewardErrBase}?discord_error=${encodeURIComponent(m)}`, 302);
                }

                return new Response(null, {
                    status: 302,
                    headers: {
                        Location: `${rewardErrBase}?reward_claimed=1`
                    }
                });
            }

            const existingSteamForDiscord = await linksKv.get(`link:discord_user:${discordId}`);
            if (existingSteamForDiscord && existingSteamForDiscord !== linkSteamId) {
                return Response.redirect(
                    `${url.origin}/profile?discord_error=This_Discord_is_already_linked_to_another_Steam_account`,
                    302
                );
            }

            const oldRaw = await linksKv.get(`link:steam:${linkSteamId}`);
            if (oldRaw) {
                try {
                    const old = JSON.parse(oldRaw);
                    if (old?.id && old.id !== discordId) {
                        await linksKv.delete(`link:discord_user:${old.id}`);
                    }
                } catch {
                    /* ignore */
                }
            }

            const linkPayload = JSON.stringify({
                id: discordId,
                username: discordUser.username,
                global_name: discordUser.global_name || null,
                discriminator: discordUser.discriminator,
                avatar: discordUser.avatar,
                linked_at: Date.now()
            });

            await linksKv.put(`link:steam:${linkSteamId}`, linkPayload);
            await linksKv.put(`link:discord_user:${discordId}`, linkSteamId);

            return Response.redirect(`${url.origin}/profile?discord_linked=1`, 302);
        }

        if (path === "/auth/discord/unlink" && request.method === "POST") {
            if (!steamid) {
                return new Response("Unauthorized", { status: 401 });
            }
            if (!linksKv) {
                return new Response("KV not configured", { status: 503 });
            }

            const raw = await linksKv.get(`link:steam:${steamid}`);
            if (raw) {
                try {
                    const d = JSON.parse(raw);
                    if (d?.id) {
                        await linksKv.delete(`link:discord_user:${d.id}`);
                    }
                } catch {
                    /* ignore */
                }
            }
            await linksKv.delete(`link:steam:${steamid}`);

            return Response.redirect(`${url.origin}/profile?discord_unlinked=1`, 302);
        }

        if (path === "/claim-reward" && request.method === "POST") {
            const jsonHeaders = { "Content-Type": "application/json" };
            return new Response(
                JSON.stringify({
                    error: "guild_verify_required",
                    message:
                        "Claims must verify Discord server membership at claim time. Open /auth/discord/claim-verify (use the Claim button on the Rewards page).",
                    verify_url: `${url.origin}/auth/discord/claim-verify`
                }),
                { status: 410, headers: jsonHeaders }
            );
        }

        // Handle rules/raw for DXRP (High-Performance In-Game HTML)
        if (path === "/rules/raw") {
            return new Response(renderRawRulesDocument(), {
                headers: {
                    "Content-Type": "text/html;charset=UTF-8",
                    "Cache-Control": "public, max-age=120, stale-while-revalidate=600"
                }
            });
        }

        // --- STRIPE & DISCORD HELPERS ---

        const STORE_RANK_PACKAGES = {
            VIP: {
                priceUsd: 10,
                stripePriceId: "price_1TinR5980UYbxT0B4iv7DQ5v",
                lookupKey: "VIP_Monthly"
            },
            EVIP: {
                priceUsd: 25,
                stripePriceId: "price_1TinMD980UYbxT0BPfZs8K8g",
                lookupKey: "EVIP_Monthly"
            }
        };

        function resolveStoreRankPackage(env, packageName) {
            const base = STORE_RANK_PACKAGES[packageName];
            if (!base) return null;
            const stripePriceId =
                packageName === "VIP"
                    ? (env.STRIPE_PRICE_VIP || base.stripePriceId)
                    : (env.STRIPE_PRICE_EVIP || base.stripePriceId);
            return { ...base, stripePriceId };
        }
        
        async function verifyStripeSignature(body, signatureHeader, secret) {
            try {
                if (!signatureHeader || !secret) return false;

                const parts = signatureHeader.split(",").map((p) => p.trim());
                const tsPart = parts.find((p) => p.startsWith("t="));
                if (!tsPart) return false;
                const timestamp = tsPart.slice(2);

                const v1hex = parts
                    .filter((p) => p.startsWith("v1="))
                    .map((p) => p.slice(3));

                if (v1hex.length === 0) return false;
                const signedPayload = `${timestamp}.${body}`;
                const encoder = new TextEncoder();

                const key = await crypto.subtle.importKey(
                    "raw",
                    encoder.encode(secret),
                    { name: "HMAC", hash: "SHA-256" },
                    false,
                    ["verify"]
                );

                const payloadBytes = encoder.encode(signedPayload);
                for (const hex of v1hex) {
                    if (!hex || hex.length % 2 !== 0) continue;

                    const sigBytes = hexToBytes(hex);
                    const ok = await crypto.subtle.verify("HMAC", key, sigBytes, payloadBytes);
                    if (ok) return true;
                }
                return false;
            } catch (e) {
                console.error("verifyStripeSignature:", e);
                return false;
            }
        }

        function hexToBytes(hex) {
            const bytes = new Uint8Array(hex.length / 2);
            for (let i = 0; i < hex.length; i += 2) {
                bytes[i / 2] = parseInt(hex.slice(i, i + 2), 16);
            }
            return bytes;
        }

        async function sendDiscordNotification(data) {
            const hookUrl = env.DISCORD_WEBHOOK_URL;
            if (!hookUrl) {
                throw new Error("DISCORD_WEBHOOK_URL is not set");
            }

            const portalLink = `https://dxrp.net/portal/players/${data.steamid}`;
            const discordField = data.discord_id ? `<@${data.discord_id}>` : "`N/A`";

            const embed = {
                title: "💰 New Donation Received!",
                color: 0x0076e3,
                fields: [
                    { name: "SteamID64", value: `\`${data.steamid}\``, inline: true },
                    { name: "Discord", value: discordField, inline: true },
                    { name: "Package", value: `**${data.package}**`, inline: true },
                    { name: "Amount", value: `**$${data.amount}**`, inline: true },
                    { name: "Admin Panel", value: "[Manage Transactions](https://lifepunch.co/admin/transactions)", inline: false },
                    { name: "Transaction ID", value: `\`${data.id}\``, inline: false }
                ],
                footer: { text: "LifePunch Store • 2026" },
                timestamp: new Date().toISOString()
            };

            const res = await fetch(hookUrl, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ 
                    content: `@here A new purchase was made for **${data.package}**!`,
                    username: "LifePunch Store",
                    embeds: [embed] 
                })
            });

            if (!res.ok) {
                const errText = await res.text().catch(() => "");
                throw new Error(`Discord webhook HTTP ${res.status}: ${errText.slice(0, 300)}`);
            }
        }

        // --- API ROUTES ---
        if (path === "/api/validate-referral" && request.method === "POST") {
            try {
                const { referralCode, buyerSteamId } = await request.json();
                if (!referralCode || !buyerSteamId) return new Response(JSON.stringify({ error: "Missing params" }), { status: 400 });
                
                const referrerSteamId = await linksKv.get(`refcode:to:steam:${referralCode.toUpperCase()}`);
                if (!referrerSteamId) {
                    return new Response(JSON.stringify({ valid: false, message: "Invalid referral code." }), { status: 200 });
                }

                if (referrerSteamId === buyerSteamId) {
                    return new Response(JSON.stringify({ valid: false, message: "You cannot refer yourself." }), { status: 200 });
                }

                const alreadyUsed = await linksKv.get(`user:referral_used:${buyerSteamId}`);
                if (alreadyUsed === "1") {
                    return new Response(JSON.stringify({ valid: false, message: "Discount only available for your first purchase." }), { status: 200 });
                }

                return new Response(JSON.stringify({ valid: true, message: "10% Discount Applied!" }), { status: 200 });
            } catch (e) {
                return new Response(JSON.stringify({ error: "Server error" }), { status: 500 });
            }
        }

        if (path === "/api/my-transactions" && request.method === "GET") {
            if (!steamid || !linksKv) {
                return new Response("[]", { headers: { 'Content-Type': 'application/json' } });
            }
            const raw = await linksKv.get(`tx:${steamid}`);
            return new Response(raw || "[]", {
                headers: { 'Content-Type': 'application/json' }
            });
        }

        if (path === "/create-checkout-session" && request.method === "POST") {
            try {
                const { packageName, price, steamid, referralCode, creditUsed } = await request.json();
                if (!steamid || !packageName || price == null) {
                    return new Response(JSON.stringify({ error: "Missing parameters" }), { status: 400, headers: { 'Content-Type': 'application/json' } });
                }

                const rankPkg = resolveStoreRankPackage(env, packageName);
                if (rankPkg) {
                    const listPrice = parseFloat(price);
                    if (Number.isNaN(listPrice) || Math.abs(listPrice - rankPkg.priceUsd) > 0.01) {
                        return new Response(JSON.stringify({ error: "Invalid package price." }), { status: 400, headers: { 'Content-Type': 'application/json' } });
                    }

                    const referralAttempt = referralCode && referralCode.trim() !== "";
                    const creditAttempt = Math.max(0, parseFloat(creditUsed) || 0) > 0;
                    if (referralAttempt || creditAttempt) {
                        return new Response(JSON.stringify({
                            error: "Referral codes and store credit do not apply to monthly VIP/EVIP subscriptions."
                        }), { status: 400, headers: { 'Content-Type': 'application/json' } });
                    }

                    const stripeBody = new URLSearchParams({
                        'success_url': `${url.origin}/store?success=true`,
                        'cancel_url': `${url.origin}/store`,
                        'mode': 'subscription',
                        'line_items[0][price]': rankPkg.stripePriceId,
                        'line_items[0][quantity]': 1,
                        'metadata[steamid]': steamid,
                        'metadata[package]': packageName,
                        'metadata[billing]': 'monthly',
                        'subscription_data[metadata][steamid]': steamid,
                        'subscription_data[metadata][package]': packageName
                    });

                    const stripeRes = await fetch('https://api.stripe.com/v1/checkout/sessions', {
                        method: 'POST',
                        headers: {
                            'Authorization': `Bearer ${env.STRIPE_SECRET_KEY}`,
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: stripeBody.toString()
                    });

                    const session = await stripeRes.json();

                    if (!stripeRes.ok) {
                        console.error("Stripe API Error:", session);
                        return new Response(JSON.stringify({
                            error: session.error?.message || "Stripe session creation failed",
                            detail: session.error
                        }), { status: stripeRes.status, headers: { 'Content-Type': 'application/json' } });
                    }

                    return new Response(JSON.stringify({ url: session.url }), {
                        headers: { 'Content-Type': 'application/json' }
                    });
                }

                let finalPrice = parseFloat(price);
                let usedReferral = null;
                let appliedCredit = Math.max(0, parseFloat(creditUsed) || 0);

                // 1. Validate Referral (10% off)
                if (referralCode && referralCode.trim() !== "") {
                    const referrerSteamId = await linksKv.get(`refcode:to:steam:${referralCode.trim().toUpperCase()}`);
                    const alreadyUsed = await linksKv.get(`user:referral_used:${steamid}`);

                    if (referrerSteamId && referrerSteamId !== steamid && alreadyUsed !== "1") {
                        finalPrice = finalPrice * 0.9;
                        usedReferral = referrerSteamId;
                    }
                }

                // 2. Validate & Apply Credit
                if (appliedCredit > 0) {
                    const rawUserCredit = await linksKv.get(`user:credit:${steamid}`);
                    const availableCredit = parseFloat(rawUserCredit) || 0;
                    
                    if (appliedCredit > availableCredit) {
                        return new Response(JSON.stringify({ error: "Insufficient credit balance." }), { status: 400 });
                    }
                    
                    finalPrice = Math.max(0, finalPrice - appliedCredit);
                }

                // 3. Handle $0.00 Checkout (Fully covered by credit)
                if (finalPrice <= 0) {
                    // Deduct credit immediately
                    const rawUserCredit = await linksKv.get(`user:credit:${steamid}`);
                    let currentCredit = parseFloat(rawUserCredit) || 0;
                    currentCredit = Math.max(0, currentCredit - appliedCredit);
                    await linksKv.put(`user:credit:${steamid}`, currentCredit.toFixed(2));

                    // Save transaction to KV
                    const transactionId = "credit_" + Date.now() + "_" + Math.random().toString(36).slice(2, 7);
                    
                    let discordId = null;
                    const linkRaw = await linksKv.get(`link:steam:${steamid}`);
                    if (linkRaw) {
                        try { discordId = JSON.parse(linkRaw).id; } catch {}
                    }

                    const tx = {
                        id: transactionId,
                        package: packageName + " (Paid with Credit)",
                        amount: "0.00",
                        date: Date.now(),
                        discord_id: discordId
                    };

                    const existingRaw = await linksKv.get(`tx:${steamid}`);
                    let txs = [];
                    if (existingRaw) try { txs = JSON.parse(existingRaw); } catch {}
                    txs.unshift(tx);
                    await linksKv.put(`tx:${steamid}`, JSON.stringify(txs.slice(0, 50)));

                    // Log to purchase history
                    const purchaseLog = { date: Date.now(), package: packageName, amount: "0.00" };
                    const existingPurchasesRaw = await linksKv.get(`referral:purchases:${steamid}`);
                    let purchases = [];
                    if (existingPurchasesRaw) try { purchases = JSON.parse(existingPurchasesRaw); } catch {}
                    purchases.unshift(purchaseLog);
                    await linksKv.put(`referral:purchases:${steamid}`, JSON.stringify(purchases.slice(0, 50)));

                    // Process Referral Stats (Referrer still gets credit even if buyer used credit)
                    if (usedReferral) {
                        await linksKv.put(`user:referral_used:${steamid}`, "1");
                        const statsKey = `referral:stats:${usedReferral}`;
                        const creditKey = `user:credit:${usedReferral}`;

                        const rawStats = await linksKv.get(statsKey);
                        let stats = { total_referrals: 0, earned_credit: 0 };
                        if (rawStats) try { stats = JSON.parse(rawStats); } catch {}
                        stats.total_referrals += 1;
                        stats.earned_credit += 1.00;
                        await linksKv.put(statsKey, JSON.stringify(stats));

                        const rawRefCredit = await linksKv.get(creditKey);
                        let refCredit = parseFloat(rawRefCredit) || 0;
                        refCredit += 1.00;
                        await linksKv.put(creditKey, refCredit.toFixed(2));
                    }

                    // Discord Alert
                    try {
                        await sendDiscordNotification({
                            steamid: steamid,
                            package: packageName + " (Store Credit)",
                            amount: "0.00",
                            id: transactionId,
                            discord_id: discordId
                        });
                    } catch(e) { console.error("Discord notify failed", e); }

                    // --- DXRP AUTOMATION BRIDGE ---
                    try {
                        await runAutomation(steamid, packageName);
                    } catch (e) {
                        await queueAutomation(steamid, packageName);
                    }

                    return new Response(JSON.stringify({ success: true }), { headers: { 'Content-Type': 'application/json' } });
                }

                // 4. Create Stripe Session for remaining balance
                const stripeBody = new URLSearchParams({
                    'success_url': `${url.origin}/store?success=true`,
                    'cancel_url': `${url.origin}/store`,
                    'mode': 'payment',
                    'line_items[0][price_data][currency]': 'usd',
                    'line_items[0][price_data][product_data][name]': packageName + (usedReferral ? " (Referral Discount Applied)" : "") + (appliedCredit > 0 ? ` (Credit Used: $${appliedCredit.toFixed(2)})` : ""),
                    'line_items[0][price_data][unit_amount]': Math.round(finalPrice * 100),
                    'line_items[0][quantity]': 1,
                    'metadata[steamid]': steamid,
                    'metadata[package]': packageName,
                    'metadata[referral_code]': usedReferral || "",
                    'metadata[credit_used]': appliedCredit.toString()
                });

                const stripeRes = await fetch('https://api.stripe.com/v1/checkout/sessions', {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${env.STRIPE_SECRET_KEY}`,
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: stripeBody.toString()
                });

                const session = await stripeRes.json();
                
                if (!stripeRes.ok) {
                    console.error("Stripe API Error:", session);
                    return new Response(JSON.stringify({ 
                        error: session.error?.message || "Stripe session creation failed",
                        detail: session.error
                    }), { status: stripeRes.status, headers: { 'Content-Type': 'application/json' } });
                }

                return new Response(JSON.stringify({ url: session.url }), {
                    headers: { 'Content-Type': 'application/json' }
                });

            } catch (err) {
                console.error("Internal Server Error:", err);
                return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: { 'Content-Type': 'application/json' } });
            }
        }

        if (path === "/webhook" && request.method === "POST") {
            const signature = request.headers.get("stripe-signature");
            const body = await request.text();

            if (!env.STRIPE_WEBHOOK_SECRET) {
                console.error("Stripe webhook: STRIPE_WEBHOOK_SECRET is not set");
                return new Response(JSON.stringify({ error: "webhook secret not configured" }), {
                    status: 500,
                    headers: { "Content-Type": "application/json" }
                });
            }

            const isValid = await verifyStripeSignature(body, signature, env.STRIPE_WEBHOOK_SECRET);
            if (!isValid) {
                console.error("Stripe webhook: signature verification failed (check STRIPE_WEBHOOK_SECRET matches this endpoint in Stripe Dashboard)");
                return new Response("Invalid signature", { status: 400 });
            }

            let event;
            try {
                event = JSON.parse(body);
            } catch {
                return new Response("Invalid JSON", { status: 400 });
            }

            if (event.type === "checkout.session.completed") {
                const session = event.data?.object ?? {};
                const meta = session.metadata ?? {};
                const steamidMeta = meta.steamid ?? "";
                const packageName = meta.package ?? "Unknown package";
                const referralCode = meta.referral_code ?? "";
                const creditUsed = parseFloat(meta.credit_used) || 0;

                const amount =
                    session.amount_total != null && !Number.isNaN(Number(session.amount_total))
                        ? (Number(session.amount_total) / 100).toFixed(2)
                        : "0.00";
                const pi = session.payment_intent;
                const transactionId =
                    typeof pi === "string" ? pi : pi?.id != null ? String(pi.id) : String(session.id ?? "");

                // --- DXRP AUTOMATION BRIDGE ---
                try {
                    await runAutomation(steamidMeta, packageName);
                } catch (e) {
                    await queueAutomation(steamidMeta, packageName);
                }

                // --- SAVE TRANSACTION TO KV ---
                if (linksKv && steamidMeta) {
                    // Deduct credit if used
                    if (creditUsed > 0) {
                        const rawCredit = await linksKv.get(`user:credit:${steamidMeta}`);
                        let currentCredit = parseFloat(rawCredit) || 0;
                        currentCredit = Math.max(0, currentCredit - creditUsed);
                        await linksKv.put(`user:credit:${steamidMeta}`, currentCredit.toFixed(2));
                    }

                    let discordId = null;
                    const linkRaw = await linksKv.get(`link:steam:${steamidMeta}`);
                    if (linkRaw) {
                        try {
                            const d = JSON.parse(linkRaw);
                            discordId = d.id;
                        } catch { /* ignore */ }
                    }
                    const tx = {
                        id: transactionId,
                        package: packageName,
                        amount: amount,
                        date: Date.now(),
                        discord_id: discordId
                    };
                    const existingRaw = await linksKv.get(`tx:${steamidMeta}`);
                    let txs = [];
                    if (existingRaw) {
                        try { txs = JSON.parse(existingRaw); } catch { txs = []; }
                    }

                    txs.unshift(tx); // Newest first
                    // Keep last 50 transactions
                    await linksKv.put(`tx:${steamidMeta}`, JSON.stringify(txs.slice(0, 50)));

                    // --- SAVE TO PROFILE PURCHASE HISTORY ---
                    const purchaseLog = { date: Date.now(), package: packageName, amount: amount };
                    const existingPurchasesRaw = await linksKv.get(`referral:purchases:${steamidMeta}`);
                    let purchases = [];
                    if (existingPurchasesRaw) {
                        try { purchases = JSON.parse(existingPurchasesRaw); } catch { purchases = []; }
                    }
                    purchases.unshift(purchaseLog);
                    await linksKv.put(`referral:purchases:${steamidMeta}`, JSON.stringify(purchases.slice(0, 50)));

                    // --- PROCESS REFERRAL ---
                    if (referralCode && referralCode !== steamidMeta) {
                        // 1. Mark referral as used for buyer
                        await linksKv.put(`user:referral_used:${steamidMeta}`, "1");

                        // 2. Award Referrer
                        const statsKey = `referral:stats:${referralCode}`;
                        const historyKey = `referral:history:${referralCode}`;
                        const creditKey = `user:credit:${referralCode}`;

                        // Update Stats
                        const rawStats = await linksKv.get(statsKey);
                        let stats = { total_referrals: 0, earned_credit: 0 };
                        if (rawStats) {
                            try { stats = JSON.parse(rawStats); } catch { /* ignore */ }
                        }
                        stats.total_referrals += 1;
                        stats.earned_credit += 1.00;
                        await linksKv.put(statsKey, JSON.stringify(stats));

                        // Update Credit
                        const rawCredit = await linksKv.get(creditKey);
                        let currentCredit = parseFloat(rawCredit) || 0;
                        currentCredit += 1.00;
                        await linksKv.put(creditKey, currentCredit.toFixed(2));

                        // Log History
                        const rawHistory = await linksKv.get(historyKey);
                        let history = [];
                        if (rawHistory) {
                            try { history = JSON.parse(rawHistory); } catch { /* ignore */ }
                        }
                        history.unshift({ date: Date.now(), buyer_steamid: steamidMeta, amount: 1.00 });
                        await linksKv.put(historyKey, JSON.stringify(history.slice(0, 50)));
                    }
                }

                let dId = "n/a";
                if (linksKv && steamidMeta) {
                    const dRaw = await linksKv.get(`link:steam:${steamidMeta}`);
                    if (dRaw) {
                        try { dId = JSON.parse(dRaw).id; } catch{}
                    }
                }

                try {
                    /*
                    await sendDiscordNotification({
                        steamid: steamidMeta || "unknown",
                        package: packageName,
                        amount,
                        id: transactionId || "n/a",
                        discord_id: dId !== "n/a" ? dId : null
                    });
                    */
                } catch (e) {
                    console.error("Stripe webhook: Discord notification failed:", e);
                    // Don't return 500 here if we already saved the KV record
                }
            }

            return new Response(JSON.stringify({ received: true }), {
                headers: { "Content-Type": "application/json" }
            });
        }

        // --- SHARED CSS AND HTML HEAD ---
        const isSboxRules = isSbox && path === "/rules";
        const sharedHead = `
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="theme-color" content="#017AEF">
        <meta name="description" content="LIFEPUNCH — official s&box DXRP roleplay servers, rules, store, and community.">
        <meta property="og:site_name" content="LIFEPUNCH">
        <meta property="og:type" content="website">
        <meta property="og:title" content="LIFEPUNCH | s&box DXRP Servers">
        <meta property="og:description" content="Official LIFEPUNCH s&box DXRP roleplay servers, rules, store, and community.">
        <meta property="og:image" content="https://assets.lifepunch.co/logo.png">
        ${isSboxRules ? "" : `<meta name="view-transition" content="same-origin">`}
        <link rel="icon" type="image/png" href="https://i.imgur.com/WTosTpq.png">
        ${isSboxRules ? `<link rel="preload" as="image" href="https://assets.lifepunch.co/logo.png">` : ""}
        ${isSboxRules
            ? `<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" media="print" onload="this.media='all'"><noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"></noscript>`
            : `<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">`}
        ${isSboxRules ? "" : `<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@700;900&family=Inter:wght@400;600&display=swap" rel="stylesheet">`}
        <style>
            :root { 
                --lp-blue: #017AEF; 
                --lp-blue-hover: #33A0FF;
                --lp-blue-rgb: 1, 122, 239;
                --bg: #000000; 
                --surface: #1a1d23; 
                --surface-inset: #12151a;
                --card-header: #22262e;
                --border: #374151;
                --text-main: #ffffff;
                --text-dim: #9ca3af;
            }

            @view-transition {
                navigation: auto;
            }

            @keyframes pageReveal {
                0% { opacity: 0; transform: translateY(10px) scale(0.98); }
                100% { opacity: 1; transform: translateY(0) scale(1); }
            }

            /* Custom Scrollbar */
            ::-webkit-scrollbar {
                width: 10px;
            }
            ::-webkit-scrollbar-track {
                background: var(--surface);
            }
            ::-webkit-scrollbar-thumb {
                background: var(--lp-blue);
                border-radius: 10px;
                border: 2px solid var(--bg);
            }
            ::-webkit-scrollbar-thumb:hover {
                background: var(--lp-blue-hover);
            }
            * {
                scrollbar-width: thin;
                scrollbar-color: var(--lp-blue) var(--surface);
            }
            html {
                scrollbar-gutter: stable;
            }
            body { 
                font-family: 'Inter', sans-serif;
                background: var(--bg); 
                color: var(--text-main); 
                margin: 0; padding: 0; line-height: 1.6;
                display: flex; flex-direction: column; min-height: 100vh;
                position: relative; overflow-x: hidden;
            }
            body::before {
                content: "";
                position: fixed;
                top: 0; left: 0; width: 100%; height: 100%;
                background-color: var(--bg);
                background-image:
                    radial-gradient(at 75% 45%, rgba(34, 38, 46, 0.75) 0px, transparent 68%),
                    radial-gradient(at 25% 82%, rgba(42, 47, 56, 0.52) 0px, transparent 72%),
                    radial-gradient(at 50% 12%, rgba(34, 38, 46, 0.4) 0px, transparent 58%);
                background-attachment: fixed;
                z-index: -1;
            }
            .container { 
                max-width: 900px;
                margin: 0 auto; 
                flex: 1; 
                width: 100%; 
                position: relative; 
                z-index: 2; 
                display: flex; 
                flex-direction: column; 
                padding: 40px 20px;
                box-sizing: border-box;
                animation: pageReveal 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
            }
            header { text-align: center; margin-bottom: 0; padding-bottom: 10px; }
            .logo { 
                width: 140px;
                margin-bottom: 15px; 
                filter: drop-shadow(0 0 20px rgba(var(--lp-blue-rgb), 0.7)); 
                animation: logoStrobe 3s ease-in-out infinite;
            }
            @keyframes logoStrobe {
                0% { filter: drop-shadow(0 0 15px rgba(var(--lp-blue-rgb), 0.45)); opacity: 0.85; }
                50% { filter: drop-shadow(0 0 35px rgba(var(--lp-blue-rgb), 0.95)); opacity: 1; }
                100% { filter: drop-shadow(0 0 15px rgba(var(--lp-blue-rgb), 0.45)); opacity: 0.85; }
            }
            h1 { 
                font-family: 'Montserrat', sans-serif;
                font-weight: 900; 
                color: #fff; 
                text-transform: uppercase; 
                letter-spacing: -2px; 
                margin: 0; 
                font-size: 48px; 
                text-shadow: 0 0 12px rgba(var(--lp-blue-rgb), 0.18);
            }
            .sub-h { color: var(--lp-blue); font-weight: bold; letter-spacing: 2px; font-size: 14px; margin-bottom: 20px; }
            .links { 
                margin-bottom: 30px;
                border-bottom: 1px solid var(--border); 
                padding-bottom: 30px; 
                text-align: center; 
            }
            .links a { 
                color: #fff;
                text-decoration: none; 
                background: var(--surface); 
                padding: 10px 18px; 
                border-radius: 6px; 
                font-size: 11px; 
                margin: 5px; 
                display: inline-block;
                border: 1px solid var(--border); 
                transition: 0.2s; 
                font-weight: bold; 
            }
            .links a:hover { 
                background: var(--lp-blue);
                border-color: rgba(var(--lp-blue-rgb), 0.45); 
                transform: translateY(-2px); 
                box-shadow: 0 5px 15px rgba(var(--lp-blue-rgb), 0.25);
            }
            footer {
                padding: 30px 20px;
                border-top: 1px solid var(--border);
                text-align: center;
                width: 100%;
                box-sizing: border-box;
                position: relative;
                z-index: 2;
            }
            .footer-disclaimer {
                max-width: 800px;
                margin: auto;
                color: var(--text-dim);
                font-size: 13px;
                line-height: 1.8;
            }
            .footer-disclaimer a {
                color: var(--lp-blue);
                text-decoration: none;
                font-weight: bold;
            }
            img, video { max-width: 100%; }
            html { -webkit-text-size-adjust: 100%; text-size-adjust: 100%; }

            /* Account pill (top-right on desktop, inline on mobile) */
            .account-pill {
                position: absolute;
                top: 10px;
                right: 20px;
                z-index: 100;
            }

            /* --- MOBILE --- */
            @media (max-width: 700px) {
                .container { padding: 20px 14px; }
                h1 { font-size: 34px; letter-spacing: -1px; }
                .logo { width: 100px; margin-bottom: 10px; }
                .account-pill {
                    position: static;
                    display: flex;
                    justify-content: center;
                    margin-bottom: 14px;
                }
                .links { padding-bottom: 20px; margin-bottom: 20px; }
                .links a { padding: 12px 14px; margin: 4px 3px; font-size: 11px; }
                .sub-h { letter-spacing: 1px; }
                footer { padding: 20px 14px; }
                /* Prevent iOS zoom-on-focus (inputs must be >=16px) */
                input, select, textarea { font-size: 16px; }
            }
            @media (max-width: 380px) {
                h1 { font-size: 28px; }
                .links a { padding: 11px 10px; margin: 3px 2px; font-size: 10px; }
            }
        </style>
        `;

        const getHeader = (subTitle) => {
            const currentPath = path + url.search;
            const returnParam = encodeURIComponent(currentPath);
            
            return `
        <header style="${isSbox ? 'margin-bottom: 20px;' : ''}">
            ${isSbox ? '' : `
            <div class="account-pill">
                ${steamid ? `
                    <div style="display: flex; align-items: center; gap: 10px; background: var(--surface); padding: 8px 15px; border-radius: 20px; border: 1px solid var(--border); backdrop-filter: blur(10px);">
                        ${userIsAdmin ? `<a href="/admin" style="color: var(--lp-blue); text-decoration: none; font-size: 11px; font-weight: 900; transition: 0.2s;" onmouseover="this.style.opacity='0.7'" onmouseout="this.style.opacity='1'">PANEL</a>` : ''}
                        ${userIsAdmin ? `<span style="width: 1px; height: 20px; background: var(--border);"></span>` : ''}
                        <a href="/profile" style="color: var(--lp-blue); text-decoration: none; font-size: 11px; font-weight: 900; transition: 0.2s;" onmouseover="this.style.opacity='0.7'" onmouseout="this.style.opacity='1'">PROFILE</a>
                        <span style="width: 1px; height: 20px; background: var(--border);"></span>
                        <a href="/logout?return=${returnParam}" style="color: #ff4d4d; text-decoration: none; font-size: 11px; font-weight: 900;">LOGOUT</a>
                    </div>
                ` : `
                    <a href="/login?return=${returnParam}" style="display: flex; align-items: center; gap: 8px; background: var(--surface); padding: 8px 15px; border-radius: 20px; border: 1px solid var(--border); backdrop-filter: blur(10px); color: #fff; text-decoration: none; font-size: 11px; font-weight: 900; transition: 0.2s;" onmouseover="this.style.borderColor='var(--lp-blue)'" onmouseout="this.style.borderColor='var(--border)'">
                        <i class="fa-brands fa-steam"></i> LOGIN
                    </a>
                `}
            </div>
            `}
            <img src="https://assets.lifepunch.co/logo.png" class="logo" alt="LIFEPUNCH logo">

            <h1>LifePunch</h1>
            <div class="sub-h">${subTitle}</div>
            ${isSbox ? '' : `
            <div class="links">
                <a href="/">HOME</a>
                <a href="/rules">RULES</a>
                <a href="/store">STORE</a>
                <a href="/rewards">REWARDS</a>
                <a href="/discord">DISCORD</a>
                <a href="https://steamcommunity.com/groups/lifepunchofficial">STEAM GROUP</a>
            </div>
            `}
        </header>
        `;
        };

        const sharedFooter = `
        <footer>
            <div class="footer-disclaimer">
                Designed by LifePunch 2026 - <a href="/tos">ToS</a>
            </div>
        </footer>
        `;

        // --- EXTERNAL TOKEN SYNC (CORS ALLOWED) ---
        if (path === "/api/v1/sync-auth-token") {
            const origin = request.headers.get("Origin");
            const isAllowedOrigin = origin && (origin === "https://dxrp.net" || origin === "https://www.dxrp.net");
            const corsOrigin = isAllowedOrigin ? origin : "https://dxrp.net";

            if (request.method === "OPTIONS") {
                return new Response(null, {
                    headers: {
                        "Access-Control-Allow-Origin": corsOrigin,
                        "Access-Control-Allow-Methods": "POST, OPTIONS",
                        "Access-Control-Allow-Headers": "Content-Type",
                        "Access-Control-Max-Age": "86400",
                    }
                });
            }
            if (request.method === "POST") {
                try {
                    const { token } = await request.json();
                    if (!token) throw new Error("No token provided");
                    await linksKv.put("config:dxrp_token", token.trim());
                    await linksKv.put("config:dxrp_token_timestamp", Date.now().toString());
                    await linksKv.delete("status:dxrp_error");
                    return new Response(JSON.stringify({ success: true }), {
                        headers: {
                            'Content-Type': 'application/json',
                            "Access-Control-Allow-Origin": corsOrigin
                        }
                    });
                } catch (e) {
                    return new Response(JSON.stringify({ success: false, error: e.message }), {
                        status: 400,
                        headers: {
                            'Content-Type': 'application/json',
                            "Access-Control-Allow-Origin": corsOrigin
                        }
                    });
                }
            }
        }

        // --- MONTHLY GIVEAWAY ENTRY ---
        if (path === "/rewards/giveaway-enter" && request.method === "POST") {
            if (!steamid) {
                return Response.redirect(`${url.origin}/login?return=${encodeURIComponent("/rewards")}`, 302);
            }
            if (!linksKv) return new Response("KV not bound.", { status: 503 });

            const monthKey = new Date().toISOString().slice(0, 7);
            const entryKey = `giveaway:entry:${monthKey}:${steamid}`;
            
            const existing = await linksKv.get(entryKey);
            if (existing) {
                return Response.redirect(`${url.origin}/rewards?error=already_entered`, 302);
            }

            const profile = await getSteamProfileData(steamid);
            const entryData = {
                name: profile?.personaname || "Unknown",
                avatar: profile?.avatarfull || "https://cdn.discordapp.com/embed/avatars/0.png",
                at: Date.now()
            };

            await linksKv.put(entryKey, JSON.stringify(entryData));
            return Response.redirect(`${url.origin}/rewards?reward_claimed=giveaway`, 302);
        }

        // --- ADMIN PANEL ROUTES ---
        if (path.startsWith("/admin") || path.startsWith("/api/admin")) {
            if (!userIsAdmin) {
                return new Response("Unauthorized", { status: 403 });
            }

            // Detect Admin Name (Try Discord name, then fallback to SteamID)
            let adminName = steamid;
            if (linksKv && steamid) {
                const rawLink = await linksKv.get(`link:steam:${steamid}`);
                if (rawLink) {
                    try {
                        const d = JSON.parse(rawLink);
                        adminName = d.global_name || d.username || steamid;
                    } catch {}
                }
            }

            if (path === "/api/admin/toggle-fulfillment" && request.method === "POST") {
                try {
                    const { key, field, checked } = await request.json();
                    if (!key || !field) return new Response("Missing params", { status: 400 });

                    const stateKey = `fulfilment:${key}`;
                    const rawState = await linksKv.get(stateKey);
                    let state = {};
                    if (rawState) try { state = JSON.parse(rawState); } catch {}

                    state[field] = { checked: checked, by: adminName, at: Date.now() };
                    await linksKv.put(stateKey, JSON.stringify(state));

                    return new Response(JSON.stringify(state), { headers: { "Content-Type": "application/json" } });
                } catch (e) {
                    return new Response("Error", { status: 500 });
                }
            }

            if (path === "/api/admin/get-fulfillment" && request.method === "POST") {
                try {
                    const { keys } = await request.json();
                    const results = {};
                    await Promise.all(keys.map(async k => {
                        const raw = await linksKv.get(`fulfilment:${k}`);
                        if (raw) results[k] = JSON.parse(raw);
                    }));
                    return new Response(JSON.stringify(results), { headers: { "Content-Type": "application/json" } });
                } catch (e) {
                    return new Response("Error", { status: 500 });
                }
            }

            if (path === "/admin") {
                pageTitle = "LifePunch | Admin Panel";
                subHeaderTitle = "ADMIN DASHBOARD";
                bodyContent = `
                <style>
                    .admin-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px; }
                    .admin-card { background: var(--surface); border: 1px solid var(--border); padding: 40px; border-radius: 12px; text-align: center; text-decoration: none; transition: 0.3s; display: flex; flex-direction: column; align-items: center; justify-content: center; }
                    .admin-card:hover { border-color: var(--lp-blue); transform: translateY(-5px); box-shadow: 0 10px 20px rgba(var(--lp-blue-rgb),0.2); }
                    .admin-card i { font-size: 48px; color: var(--lp-blue); margin-bottom: 20px; }
                    .admin-card h3 { color: #fff; margin: 0; font-family: 'Montserrat', sans-serif; text-transform: uppercase; font-size: 20px; }
                    .admin-card p { color: var(--text-dim); margin: 10px 0 0; font-size: 14px; }
                    @media (max-width: 600px) { .admin-grid { grid-template-columns: 1fr; } }
                </style>
                <div class="admin-grid">
                    <a href="/admin/bans" class="admin-card">
                        <i class="fa-solid fa-ban"></i>
                        <h3>Ban Management</h3>
                        <p>Manage website bans for users</p>
                    </a>
                    <a href="/admin/transactions" class="admin-card">
                        <i class="fa-solid fa-receipt"></i>
                        <h3>Transactions</h3>
                        <p>View and search all store purchases</p>
                    </a>
                    <a href="/admin/rewards" class="admin-card">
                        <i class="fa-solid fa-gift"></i>
                        <h3>Reward Claims</h3>
                        <p>Manage and reset Discord reward claims</p>
                    </a>
                    <a href="/admin/inbox" class="admin-card">
                        <i class="fa-solid fa-inbox"></i>
                        <h3>Email Inbox</h3>
                        <p>View and manage legal/dmca emails</p>
                    </a>
                    <a href="/admin/settings" class="admin-card">
                        <i class="fa-solid fa-gears"></i>
                        <h3>System Settings</h3>
                        <p>Manage automation tokens and global config</p>
                    </a>
                </div>
                `;
            }
            else if (path === "/admin/bans") {
                if (request.method === "POST") {
                    const { action, steamid, reason } = await request.json();
                    if (action === "ban" && steamid) {
                        await linksKv.put(`ban:steam:${steamid}`, JSON.stringify({ reason, at: Date.now(), by: adminName }));
                    } else if (action === "unban" && steamid) {
                        await linksKv.delete(`ban:steam:${steamid}`);
                    }
                    return new Response(JSON.stringify({ success: true }), { headers: { 'Content-Type': 'application/json' } });
                }

                // List bans
                const banEntries = await linksKv.list({ prefix: "ban:steam:" });
                let banListHtml = "";
                for (const key of banEntries.keys) {
                    const sid = key.name.split(':').pop();
                    const raw = await linksKv.get(key.name);
                    const data = raw ? JSON.parse(raw) : { reason: "No reason", at: 0 };
                    banListHtml += `
                        <tr style="background: var(--surface); border-bottom: 1px solid var(--border);">
                            <td style="padding: 10px;">${sid}</td>
                            <td style="padding: 10px;">${esc(data.reason)}</td>
                            <td style="padding: 10px;">${new Date(data.at).toLocaleString()}</td>
                            <td style="padding: 10px;"><button onclick="unban('${sid}')" class="btn-save" style="background:#ff4d4d;">Unban</button></td>
                        </tr>
                    `;
                }

                pageTitle = "LifePunch | Ban Management";
                subHeaderTitle = "WEBSITE BAN MANAGEMENT";
                bodyContent = `
                <div class="settings-card">
                    <div class="form-group">
                        <label>Ban SteamID64</label>
                        <input type="text" id="ban-sid" class="settings-input" placeholder="7656119...">
                        <input type="text" id="ban-reason" class="settings-input" placeholder="Reason" style="margin-top:10px;">
                        <button onclick="ban()" class="btn-save" style="margin-top:10px;">Ban User</button>
                    </div>
                </div>
                <table style="width:100%; border-collapse: collapse; margin-top: 20px;">
                    <thead><tr style="text-align:left; color:var(--lp-blue); border-bottom:2px solid var(--lp-blue);">
                        <th style="padding:10px;">SteamID64</th>
                        <th style="padding:10px;">Reason</th>
                        <th style="padding:10px;">Banned At</th>
                        <th style="padding:10px;">Actions</th>
                    </tr></thead>
                    <tbody>${banListHtml}</tbody>
                </table>
                <script>
                    async function ban() {
                        const steamid = document.getElementById('ban-sid').value;
                        const reason = document.getElementById('ban-reason').value;
                        await fetch('/admin/bans', { method: 'POST', body: JSON.stringify({ action: 'ban', steamid, reason }) });
                        location.reload();
                    }
                    async function unban(steamid) {
                        await fetch('/admin/bans', { method: 'POST', body: JSON.stringify({ action: 'unban', steamid }) });
                        location.reload();
                    }
                </script>
                `;
            }
            else if (path === "/admin/settings") {
                if (!userIsAdmin) return new Response("Unauthorized", { status: 401 });

                if (request.method === "POST") {
                    const data = await request.json();
                    if (data.token) await linksKv.put("config:dxrp_token", data.token.trim());
                    if (data.tenant) await linksKv.put("config:dxrp_tenant", data.tenant.trim());
                    return new Response(JSON.stringify({ success: true }), { headers: { 'Content-Type': 'application/json' } });
                }

                const [token, tenant, lastErr] = await Promise.all([
                    linksKv.get("config:dxrp_token"),
                    linksKv.get("config:dxrp_tenant"),
                    linksKv.get("status:dxrp_error")
                ]);

                pageTitle = "LifePunch | System Settings";
                subHeaderTitle = "SYSTEM CONFIGURATION";

                const dxrpTokenBookmark = "javascript:(async function(){const n=v=>{if(!v||typeof v!=='string')return null;let s=v.trim();if(s.startsWith('Bearer '))s=s.slice(7).trim();return s.startsWith('eyJ')?s:null;};const e=v=>{if(typeof v==='string')return n(v);if(!v||typeof v!=='object')return null;for(const k of['access_token','accessToken','token','bearer','id_token','idToken']){const h=n(v[k]);if(h)return h}if(Array.isArray(v)){for(const i of v){const h=e(i);if(h)return h}}else{for(const k of Object.keys(v)){const h=e(v[k]);if(h)return h}}return null;};const f=()=>{if(!location.hostname.endsWith('dxrp.net'))return null;for(const s of[localStorage,sessionStorage]){for(let i=0;i<s.length;i++){const r=s.getItem(s.key(i));const d=n(r);if(d)return d;try{const h=e(JSON.parse(r));if(h)return h}catch(_){}}}return null};const t=f();if(!t){alert('Could not find a DXRP Bearer token. Stay logged into dxrp.net, refresh the page, then try again.');return}try{const r=await fetch('https://lifepunch.co/api/v1/sync-auth-token',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({token:t})});const d=await r.json().catch(()=>({}));if(r.ok&&d.success)alert('LifePunch DXRP token updated successfully!');else alert('Failed: '+(d.error||r.status))}catch(err){alert('Request failed: '+err.message)}})();";

                bodyContent = `
                <style>
                    .settings-grid { display: grid; gap: 30px; max-width: 800px; margin: 30px auto; }
                    .settings-card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 30px; }
                    .card-title { font-family: 'Montserrat', sans-serif; font-size: 14px; color: var(--lp-blue); margin-bottom: 20px; text-transform: uppercase; font-weight: 900; }
                    .form-group { margin-bottom: 20px; }
                    label { display: block; font-size: 10px; color: var(--text-dim); text-transform: uppercase; font-weight: 900; margin-bottom: 8px; }
                    .settings-input { width: 100%; padding: 15px; background: rgba(0,0,0,0.3); border: 1px solid var(--border); border-radius: 8px; color: #fff; font-family: monospace; font-size: 12px; box-sizing: border-box; }
                    .settings-input:focus { border-color: var(--lp-blue); outline: none; }
                    .error-banner { background: rgba(255, 77, 77, 0.1); border: 1px solid #ff4d4d; color: #ff4d4d; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 12px; font-weight: bold; }
                    .btn-save { background: var(--lp-blue); color: #fff; border: none; padding: 12px 25px; border-radius: 6px; font-weight: 900; cursor: pointer; text-transform: uppercase; transition: 0.3s; }
                    .btn-save:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(var(--lp-blue-rgb), 0.3); }
                </style>

                <div class="settings-grid">
                    ${lastErr ? `<div class="error-banner"><i class="fa-solid fa-triangle-exclamation"></i> CRITICAL: ${esc(lastErr)}</div>` : ''}
                    
                    <div class="settings-card">
                        <div class="card-title">DXRP Automation Bridge</div>
                        <p style="font-size: 12px; color: var(--text-dim); margin-bottom: 25px;">Paste your <b>Bearer token</b> from dxrp.net here. This is the long JWT from DevTools or the <b>Update Token</b> bookmark — <b>not</b> a portal API key. It expires in ~24 hours and is required for automatic store and reward payouts.</p>
                        
                        <div class="form-group">
                            <label>Bearer Token</label>
                            <div id="token-timer" style="font-size: 11px; font-family: monospace; font-weight: bold; color: var(--lp-blue); margin-bottom: 5px;">
                                TOKEN STATUS: LOADING...
                            </div>
                            <textarea id="dxrp-token" class="settings-input" style="height: 100px;">${esc(token)}</textarea>
                        </div>

                        <div class="form-group">
                            <label>Tenant ID</label>
                            <input type="text" id="dxrp-tenant" class="settings-input" value="${esc(tenant || '019db2d6-fc3d-743f-9dc6-2620c69078c2')}">
                        </div>

                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <button onclick="saveSettings()" class="btn-save">Update Config</button>
                            <button onclick="testConnection()" class="btn-save" style="background:transparent; border: 1px solid var(--border);">Test Connection</button>
                        </div>
                    </div>

                    <div class="settings-card">
                        <div class="card-title">Update Token Bookmark</div>
                        <p style="font-size: 12px; color: var(--text-dim); margin-bottom: 20px; line-height: 1.6;">
                            One-click refresh while logged into dxrp.net. Drag the button below to your bookmarks bar, then click it on dxrp.net about once per day.
                        </p>
                        <ol style="font-size: 12px; color: var(--text-dim); margin: 0 0 20px 20px; line-height: 1.8;">
                            <li>Show your bookmarks bar (<kbd style="background:#222;padding:2px 6px;border-radius:4px;">Ctrl+Shift+B</kbd> in Chrome/Edge).</li>
                            <li>Drag <a id="dxrp-token-bookmark" href="${dxrpTokenBookmark}" style="display:inline-block;background:var(--lp-blue);color:#fff;padding:8px 14px;border-radius:6px;font-weight:900;text-decoration:none;">Update Token</a> to the bar.</li>
                            <li>Log into <a href="https://dxrp.net" target="_blank" rel="noopener">dxrp.net</a>.</li>
                            <li>Click the bookmark. You should see <b>LifePunch DXRP token updated successfully!</b></li>
                        </ol>
                        <p style="font-size: 11px; color: var(--text-dim); margin: 0;">If the bookmark cannot find a token, copy it manually from DevTools → Network → any api.dxrp.net request → Headers → authorization.</p>
                    </div>
                </div>

                <script>
                    const lastTokenUpdate = ${await linksKv.get("config:dxrp_token_timestamp") || Date.now()};

                    function updateTokenTimer() {
                        const timerEl = document.getElementById('token-timer');
                        if (!timerEl) return;

                        const tokenVal = document.getElementById('dxrp-token')?.value?.trim() || '';
                        if (tokenVal && !tokenVal.startsWith('eyJ')) {
                            timerEl.innerHTML = '⚠️ NOT A BEARER TOKEN — Portal API keys do not work here';
                            timerEl.style.color = '#ff5252';
                            return;
                        }

                        const now = Date.now();
                        const expiry = lastTokenUpdate + (24 * 60 * 60 * 1000); // 24 Hours
                        const diff = expiry - now;

                        if (diff <= 0) {
                            timerEl.innerHTML = '⚠️ BEARER TOKEN EXPIRED — REFRESH WITH UPDATE TOKEN BOOKMARK';
                            timerEl.style.color = '#ff5252';
                            return;
                        }

                        const hours = Math.floor(diff / (1000 * 60 * 60));
                        const mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                        const secs = Math.floor((diff % (1000 * 60)) / 1000);
                        
                        const pad = (n) => n.toString().padStart(2, '0');
                        timerEl.innerHTML = 'BEARER TOKEN EXPIRES IN: ' + pad(hours) + ':' + pad(mins) + ':' + pad(secs);
                        
                        if (hours < 2) {
                            timerEl.style.color = '#ffb300';
                        } else {
                            timerEl.style.color = 'var(--lp-blue)';
                        }
                    }

                    setInterval(updateTokenTimer, 1000);
                    updateTokenTimer();

                    async function testConnection() {
                        const res = await fetch('/api/admin/test-dxrp');
                        const data = await res.json();
                        if (data.ok) {
                            const balance = data.balance != null ? ' (Balance: $' + data.balance + ')' : '';
                            alert('Success! Bearer token accepted by DXRP.' + balance);
                        } else {
                            alert('Failed: ' + data.error);
                        }
                    }
                    async function saveSettings() {
                        const token = document.getElementById('dxrp-token').value;
                        const tenant = document.getElementById('dxrp-tenant').value;
                        const res = await fetch('/admin/settings', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ token, tenant })
                        });
                        location.reload();
                    }
                </script>
                `;
            }
            else if (path === "/admin/inbox") {
                pageTitle = "LifePunch | Admin Inbox";
                subHeaderTitle = "EMAIL INBOX";
                
                const filter = url.searchParams.get("filter") || "all";
                let results = [];
                let dbError = null;
                let counts = { all: 0, legal: 0, dmca: 0 };

                try {
                    // 1. Get current view results
                    let query = "SELECT * FROM emails WHERE is_deleted = " + (filter === "trash" ? "1" : "0");
                    let params = [];

                    if (filter === "legal") {
                        query += " AND (LOWER(msg_to) = ? OR LOWER(msg_to) LIKE 'legal+%%')";
                        params = ["legal@lifepunch.co"];
                    } else if (filter === "dmca") {
                        query += " AND (LOWER(msg_to) = ? OR LOWER(msg_to) LIKE 'dmca+%%')";
                        params = ["dmca@lifepunch.co"];
                    } else if (filter === "sent") {
                        query += " AND LOWER(msg_from) IN ('legal@lifepunch.co', 'dmca@lifepunch.co')";
                    }
                    
                    query += " ORDER BY received_at DESC LIMIT 100";
                    const stmt = await env.DB.prepare(query).bind(...params).all();
                    results = stmt.results || [];

                    // 2. Get unread counts for badges
                    const allUnread = await env.DB.prepare("SELECT COUNT(*) as total FROM emails WHERE is_read = 0 AND is_deleted = 0").first();
                    const legalUnread = await env.DB.prepare("SELECT COUNT(*) as total FROM emails WHERE is_read = 0 AND is_deleted = 0 AND (LOWER(msg_to) = 'legal@lifepunch.co' OR LOWER(msg_to) LIKE 'legal+%%')").first();
                    const dmcaUnread = await env.DB.prepare("SELECT COUNT(*) as total FROM emails WHERE is_read = 0 AND is_deleted = 0 AND (LOWER(msg_to) = 'dmca@lifepunch.co' OR LOWER(msg_to) LIKE 'dmca+%%')").first();
                    
                    counts.all = allUnread?.total || 0;
                    counts.legal = legalUnread?.total || 0;
                    counts.dmca = dmcaUnread?.total || 0;

                } catch (e) {
                    dbError = e.message;
                }
                
                bodyContent = `
                <style>
                    .inbox-layout { display: flex; gap: 30px; margin-top: 30px; align-items: flex-start; }
                    .inbox-sidebar { width: 220px; flex-shrink: 0; }
                    .inbox-main { flex: 1; min-width: 0; }
                    
                    .nav-list { list-style: none; padding: 0; margin: 0; }
                    .nav-item { 
                        display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; 
                        color: var(--text-dim); text-decoration: none; border-radius: 8px; 
                        margin-bottom: 4px; font-size: 13px; font-weight: 600; transition: 0.2s;
                    }
                    .nav-item-content { display: flex; align-items: center; gap: 12px; }
                    .nav-item i { width: 16px; text-align: center; font-size: 14px; }
                    .nav-item:hover { background: rgba(255, 255, 255, 0.05); color: #fff; }
                    .nav-item.active { background: var(--lp-blue); color: #fff; }
                    .nav-item.active .count-badge { background: rgba(255,255,255,0.2); color: #fff; }

                    .count-badge { 
                        font-size: 10px; background: rgba(255,255,255,0.05); color: var(--text-dim); 
                        padding: 2px 8px; border-radius: 10px; font-weight: 900; 
                    }
                    .count-badge.has-unread { color: var(--lp-blue); }
                    
                    .compose-btn-large { 
                        display: flex; align-items: center; justify-content: center; gap: 10px;
                        background: var(--lp-blue); color: #fff; text-decoration: none; 
                        padding: 14px; border-radius: 12px; font-weight: 900; font-size: 12px; 
                        text-transform: uppercase; letter-spacing: 1px; margin-bottom: 25px;
                        box-shadow: 0 4px 15px rgba(var(--lp-blue-rgb), 0.3); transition: 0.3s;
                    }
                    .compose-btn-large:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(var(--lp-blue-rgb), 0.4); }

                    .inbox-table-container { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
                    .inbox-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
                    .inbox-table th, .inbox-table td { padding: 15px; text-align: left; border-bottom: 1px solid var(--border); font-size: 13px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
                    .inbox-table th { background: var(--card-header); color: var(--lp-blue); text-transform: uppercase; font-family: 'Montserrat', sans-serif; font-size: 10px; letter-spacing: 1px; }
                    .inbox-table tr:hover { background: rgba(255,255,255,0.02); cursor: pointer; }
                    
                    .unread { font-weight: 800; color: #fff; background: rgba(var(--lp-blue-rgb), 0.03); }
                    .unread td:first-child { border-left: 3px solid var(--lp-blue); }
                    
                    .badge { font-size: 9px; padding: 2px 6px; border-radius: 4px; font-weight: 900; text-transform: uppercase; }
                    .badge-new { background: var(--lp-blue); color: #fff; }
                    .badge-sent { background: rgba(255,255,255,0.1); color: var(--text-dim); }
                    
                    .empty-state { text-align: center; padding: 60px 20px; color: var(--text-dim); }
                    .empty-state i { font-size: 48px; margin-bottom: 20px; opacity: 0.2; }
                    .db-error { background: rgba(255, 77, 77, 0.1); color: #ff4d4d; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 12px; border: 1px solid rgba(255, 77, 77, 0.2); }
                </style>

                <div class="inbox-layout">
                    <div class="inbox-sidebar">
                        <a href="/admin/inbox/compose" class="compose-btn-large">
                            <i class="fa-solid fa-pen"></i> Compose
                        </a>

                        <nav class="nav-list">
                            <a href="/admin/inbox" class="nav-item ${filter === 'all' ? 'active' : ''}">
                                <div class="nav-item-content"><i class="fa-solid fa-inbox"></i> All Mail</div>
                                ${counts.all > 0 ? `<span class="count-badge has-unread">${counts.all}</span>` : ''}
                            </a>
                            <a href="/admin/inbox?filter=sent" class="nav-item ${filter === 'sent' ? 'active' : ''}">
                                <div class="nav-item-content"><i class="fa-solid fa-paper-plane"></i> Sent</div>
                            </a>
                            <a href="/admin/inbox?filter=legal" class="nav-item ${filter === 'legal' ? 'active' : ''}">
                                <div class="nav-item-content"><i class="fa-solid fa-scale-balanced"></i> Legal</div>
                                ${counts.legal > 0 ? `<span class="count-badge has-unread">${counts.legal}</span>` : ''}
                            </a>
                            <a href="/admin/inbox?filter=dmca" class="nav-item ${filter === 'dmca' ? 'active' : ''}">
                                <div class="nav-item-content"><i class="fa-solid fa-copyright"></i> DMCA</div>
                                ${counts.dmca > 0 ? `<span class="count-badge has-unread">${counts.dmca}</span>` : ''}
                            </a>
                            <div style="height: 1px; background: var(--border); margin: 15px 0;"></div>
                            <a href="/admin/inbox?filter=trash" class="nav-item ${filter === 'trash' ? 'active' : ''}">
                                <div class="nav-item-content"><i class="fa-solid fa-trash"></i> Trash</div>
                            </a>
                        </nav>
                    </div>

                    <div class="inbox-main">
                        ${dbError ? `<div class="db-error"><i class="fa-solid fa-triangle-exclamation"></i> <b>Database Error:</b> ${esc(dbError)}</div>` : ''}
                        
                        <div class="inbox-table-container">
                            <table class="inbox-table">
                                <thead>
                                    <tr>
                                        <th style="width: 180px;">Date</th>
                                        <th style="width: 200px;">${filter === 'sent' ? 'To' : 'Contact'}</th>
                                        <th>Subject</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${results.length === 0 ? `
                                        <tr>
                                            <td colspan="3">
                                                <div class="empty-state">
                                                    <i class="fa-solid fa-envelope-open"></i>
                                                    <p>${dbError ? 'Could not load messages' : `No messages found in ${filter}`}</p>
                                                </div>
                                            </td>
                                        </tr>
                                    ` : results.map(email => {
                                        const cleanFrom = String(email.msg_from || "").toLowerCase();
                                        const isSent = ["legal@lifepunch.co", "dmca@lifepunch.co"].includes(cleanFrom);
                                        
                                        let displayContact = email.msg_from;
                                        if (isSent) {
                                            displayContact = `<span style="color:var(--text-dim); font-size:11px;">To:</span> ${email.msg_to}`;
                                        }

                                        return `
                                        <tr onclick="window.location.href='/admin/inbox/view/${email.id}'" class="${email.is_read ? '' : 'unread'}">
                                            <td>${new Date(email.received_at).toLocaleDateString()} ${new Date(email.received_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</td>
                                            <td>
                                                ${displayContact} 
                                                ${!email.is_read ? '<span class="badge badge-new">NEW</span>' : ''}
                                                ${isSent && filter !== 'sent' ? '<span class="badge badge-sent">SENT</span>' : ''}
                                            </td>
                                            <td>${esc(email.subject)}</td>
                                        </tr>
                                        `;
                                    }).join('')}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                `;
            }
            else if (path === "/admin/inbox/compose") {
                pageTitle = "LifePunch | Compose Email";
                subHeaderTitle = "COMPOSE MESSAGE";
                
                bodyContent = `
                <style>
                    .compose-box { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 30px; margin-top: 20px; }
                    .form-group { margin-bottom: 20px; }
                    .form-group label { display: block; margin-bottom: 8px; font-size: 11px; font-weight: 900; color: var(--lp-blue); text-transform: uppercase; }
                    .form-input { width: 100%; padding: 12px; background: rgba(255,255,255,0.05); border: 1px solid var(--border); border-radius: 6px; color: #fff; font-family: inherit; box-sizing: border-box; outline: none; transition: 0.2s; }
                    .form-input:focus { border-color: var(--lp-blue); background: rgba(255,255,255,0.08); }
                    .form-textarea { min-height: 400px; resize: vertical; }
                    .btn-send { background: var(--lp-blue); color: #fff; border: none; padding: 12px 40px; border-radius: 6px; font-weight: 900; cursor: pointer; text-transform: uppercase; transition: 0.3s; font-size: 12px; letter-spacing: 1px; }
                    .btn-send:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(var(--lp-blue-rgb),0.4); }
                </style>
                <a href="/admin/inbox" style="color:var(--lp-blue); text-decoration:none; font-size:12px; font-weight:bold; margin-bottom:10px; display:inline-block;"><i class="fa-solid fa-arrow-left"></i> BACK TO INBOX</a>
                <div class="compose-box">
                    <form id="composeForm">
                        <div class="form-group">
                            <label>From Address</label>
                            <select id="compFrom" class="form-input">
                                <option value="legal@lifepunch.co">legal@lifepunch.co</option>
                                <option value="dmca@lifepunch.co">dmca@lifepunch.co</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>To (Recipient Email)</label>
                            <input type="email" id="compTo" class="form-input" placeholder="example@gmail.com" required>
                        </div>
                        <div class="form-group">
                            <label>Subject</label>
                            <input type="text" id="compSubject" class="form-input" placeholder="Enter subject..." required>
                        </div>
                        <div class="form-group">
                            <label>Attachments</label>
                            <input type="file" id="compAttachments" class="form-input" multiple>
                        </div>
                        <div class="form-group">
                            <label>Message Content</label>
                            <textarea id="compMessage" class="form-input form-textarea" placeholder="Type your message here..." required></textarea>
                        </div>
                        <button type="submit" class="btn-send">Send Email</button>
                    </form>
                </div>
                
                <script>
                    document.getElementById('composeForm').onsubmit = async (e) => {
                        e.preventDefault();
                        const btn = e.target.querySelector('button');
                        btn.disabled = true;
                        btn.innerText = 'SENDING...';
                        
                        const formData = new FormData();
                        formData.append('from', document.getElementById('compFrom').value);
                        formData.append('to', document.getElementById('compTo').value);
                        formData.append('subject', document.getElementById('compSubject').value);
                        formData.append('message', document.getElementById('compMessage').value);
                        
                        const files = document.getElementById('compAttachments').files;
                        for (let i = 0; i < files.length; i++) {
                            formData.append('attachments', files[i]);
                        }
                        
                        try {
                            const res = await fetch('/api/admin/send-email', {
                                method: 'POST',
                                body: formData
                            });
                            
                            if (res.ok) {
                                alert('Email sent successfully!');
                                window.location.href = '/admin/inbox';
                            } else {
                                const err = await res.text();
                                alert('Failed: ' + err);
                            }
                        } catch(e) { alert('Error: ' + e.message); }
                        
                        btn.disabled = false;
                        btn.innerText = 'SEND EMAIL';
                    };
                </script>
                `;
            }
            else if (path.startsWith("/admin/inbox/view/")) {
                const emailId = path.split('/').pop();
                const email = await env.DB.prepare("SELECT * FROM emails WHERE id = ?").bind(emailId).first();
                
                if (!email) {
                    return new Response("Email not found", { status: 404 });
                }
                
                // Mark as read
                await env.DB.prepare("UPDATE emails SET is_read = 1 WHERE id = ?").bind(emailId).run();
                
                pageTitle = `LifePunch | View Email`;
                subHeaderTitle = "VIEW MESSAGE";
                
                bodyContent = `
                <style>
                    .email-container { max-width: 800px; margin: 0 auto; }
                    .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
                    
                    .email-view { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
                    .email-header { border-bottom: 1px solid var(--border); padding-bottom: 30px; margin-bottom: 30px; }
                    .email-header h2 { font-family: 'Montserrat', sans-serif; font-size: 28px; font-weight: 900; margin: 0 0 25px; color: #fff; letter-spacing: -0.5px; }
                    
                    .meta-row { display: flex; align-items: flex-start; gap: 15px; margin-bottom: 12px; font-size: 14px; }
                    .meta-label { color: var(--lp-blue); font-weight: 900; font-size: 10px; text-transform: uppercase; width: 60px; margin-top: 4px; letter-spacing: 1px; }
                    .meta-val { color: var(--text-main); flex: 1; font-weight: 500; }
                    .meta-time { color: var(--text-dim); font-size: 12px; font-family: monospace; }

                    .email-body-wrapper { position: relative; }
                    .email-content { 
                        line-height: 1.7; color: #e1e4e8; font-size: 15px; white-space: pre-wrap; 
                        margin-bottom: 40px; font-family: 'Inter', system-ui, -apple-system, sans-serif;
                        padding: 20px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid rgba(255,255,255,0.03);
                    }
                    
                    .copy-btn { position: absolute; top: 10px; right: 10px; background: rgba(255,255,255,0.05); border: 1px solid var(--border); color: var(--text-dim); padding: 5px 10px; border-radius: 4px; font-size: 10px; cursor: pointer; transition: 0.2s; }
                    .copy-btn:hover { background: var(--lp-blue); color: #fff; border-color: var(--lp-blue); }

                    .btn-action { 
                        display: inline-flex; align-items: center; gap: 8px;
                        background: rgba(255,255,255,0.05); color: var(--text-dim); border: 1px solid var(--border); 
                        padding: 10px 18px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; font-size: 12px;
                        text-decoration: none;
                    }
                    .btn-action:hover { background: rgba(255,255,255,0.1); color: #fff; transform: translateY(-1px); }
                    .btn-danger { color: #ff4d4d; }
                    .btn-danger:hover { background: rgba(255, 77, 77, 0.1); border-color: rgba(255, 77, 77, 0.3); color: #ff6666; }

                    .reply-box { margin-top: 40px; padding-top: 40px; border-top: 1px solid var(--border); }
                    .reply-box h3 { font-family: 'Montserrat', sans-serif; font-size: 12px; color: var(--lp-blue); margin-bottom: 20px; text-transform: uppercase; font-weight: 900; letter-spacing: 1px; }
                    .form-group { margin-bottom: 20px; }
                    .form-input { width: 100%; padding: 18px; background: rgba(0,0,0,0.2); border: 1px solid var(--border); border-radius: 10px; color: #fff; font-family: inherit; box-sizing: border-box; outline: none; transition: 0.3s; font-size: 14px; }
                    .form-input:focus { border-color: var(--lp-blue); box-shadow: 0 0 0 3px rgba(var(--lp-blue-rgb), 0.1); }
                    .form-textarea { min-height: 180px; resize: vertical; line-height: 1.6; }
                    .btn-send { background: var(--lp-blue); color: #fff; border: none; padding: 14px 30px; border-radius: 8px; font-weight: 900; cursor: pointer; text-transform: uppercase; font-size: 12px; letter-spacing: 1px; transition: 0.3s; }
                    .btn-send:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(var(--lp-blue-rgb), 0.4); filter: brightness(1.1); }
                </style>

                <div class="email-container">
                    <div class="toolbar">
                        <a href="/admin/inbox" class="btn-action"><i class="fa-solid fa-arrow-left"></i> Back to Inbox</a>
                        <div style="display:flex; gap:10px;">
                            ${email.is_deleted ? `
                                <button onclick="handleAction('restore')" class="btn-action"><i class="fa-solid fa-rotate-left"></i> Restore</button>
                                <button onclick="handleAction('delete-perm')" class="btn-action btn-danger"><i class="fa-solid fa-skull"></i> Delete Permanently</button>
                            ` : `
                                <button onclick="handleAction('trash')" class="btn-action btn-danger"><i class="fa-solid fa-trash"></i> Move to Trash</button>
                            `}
                        </div>
                    </div>

                    <div class="email-view">
                        <div class="email-header">
                            <h2>${esc(email.subject)}</h2>
                            <div class="meta-row">
                                <span class="meta-label">From</span>
                                <span class="meta-val">${esc(email.msg_from)}</span>
                                <span class="meta-time">${new Date(email.received_at).toLocaleString()}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">To</span>
                                <span class="meta-val">${esc(email.msg_to)}</span>
                            </div>
                        </div>

                        <div class="email-body-wrapper">
                            <button class="copy-btn" onclick="copyBody()"><i class="fa-regular fa-copy"></i> Copy</button>
                            <div class="email-content" id="email-body">${esc(email.body)}</div>
                        </div>

                        ${!email.is_deleted ? `
                        <div class="reply-box">
                            <h3>Quick Reply</h3>
                            <form id="replyForm">
                                <div class="form-group">
                                    <textarea id="replyMessage" class="form-input form-textarea" placeholder="Write your message here..."></textarea>
                                </div>
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <span style="font-size:11px; color:var(--text-dim); font-weight: 700;">Replying from: <b style="color:var(--lp-blue);">${esc(email.msg_from)}</b></span>
                                    <button type="submit" class="btn-send">Send Reply</button>
                                    </div>
                                    </form>
                                    </div>
                                    ` : ''}
                                    </div>
                                    </div>

                                    <script>
                                    function copyBody() {
                                    const text = document.getElementById('email-body').innerText;
                                    navigator.clipboard.writeText(text);
                                    const btn = event.currentTarget;
                                    const old = btn.innerHTML;
                                    btn.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
                                    setTimeout(() => btn.innerHTML = old, 2000);
                                    }

                                    async function handleAction(action) {
                                    if (action === 'delete-perm' && !confirm('Permanently delete this email? This cannot be undone.')) return;

                                    try {
                                    const res = await fetch('/api/admin/email-action', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({ id: ${email.id}, action })
                                    });
                                    if (res.ok) window.location.href = '/admin/inbox' + (action === 'trash' ? '' : '?filter=trash');
                                    } catch(e) { alert(e.message); }
                                    }

                                    const replyForm = document.getElementById('replyForm');
                                    if (replyForm) {
                                    replyForm.onsubmit = async (e) => {
                                    e.preventDefault();
                                    const btn = e.target.querySelector('button');
                                    btn.disabled = true;
                                    btn.innerText = 'SENDING...';

                                    try {
                                    const formData = new FormData();
                                    formData.append('from', '${esc(email.msg_from)}');
                                    formData.append('to', '${esc(email.msg_to)}');
                                    formData.append('subject', 'Re: ${esc(email.subject)}');
                                    formData.append('message', document.getElementById('replyMessage').value);
                                    formData.append('parent_id', '${email.id}');

                                    const res = await fetch('/api/admin/send-email', {                                    method: 'POST',
                                    body: formData
                                    });
                                    if (res.ok) {
                                    alert('Reply sent!');
                                    window.location.reload();
                                    } else {
                                    const err = await res.text();
                                    alert('Failed: ' + err);
                                    }
                                    } catch(e) { alert('Error: ' + e.message); }
                                    btn.disabled = false;
                                    };
                                    }                </script>
                `;
            }
            else if (path === "/api/admin/email-action" && request.method === "POST") {
                const { id, action } = await request.json();
                if (action === "trash") {
                    await env.DB.prepare("UPDATE emails SET is_deleted = 1 WHERE id = ?").bind(id).run();
                } else if (action === "restore") {
                    await env.DB.prepare("UPDATE emails SET is_deleted = 0 WHERE id = ?").bind(id).run();
                } else if (action === "delete-perm") {
                    await env.DB.prepare("DELETE FROM emails WHERE id = ?").bind(id).run();
                }
                return new Response("OK");
            }
            else if (path === "/api/admin/process-queue" && request.method === "POST") {
                if (!userIsAdmin) return new Response("Unauthorized", { status: 401 });
                const result = await processQueuedAutomation();
                return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
            }
            else if (path === "/api/admin/test-dxrp") {
                try {
                    const result = await testDxrpConnection();
                    return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
                } catch (e) {
                    return new Response(JSON.stringify({ ok: false, error: e.message }), { headers: { 'Content-Type': 'application/json' } });
                }
            }
            else if (path === "/api/admin/giveaway-pick-winner" && request.method === "POST") {
                try {
                    const { month } = await request.json(); // YYYY-MM
                    if (!month) throw new Error("Month required");

                    const winnerKey = `giveaway:winner:${month}`;
                    const existingWinner = await linksKv.get(winnerKey);
                    if (existingWinner) throw new Error("Winner already picked for this month");

                    // Get all entrants
                    const list = await linksKv.list({ prefix: `giveaway:entry:${month}:` });
                    if (list.keys.length === 0) throw new Error("No entrants found for this month");

                    const entrants = [];
                    for (const key of list.keys) {
                        const sid = key.name.split(':').pop();
                        const raw = await linksKv.get(key.name);
                        if (raw) entrants.push({ ...JSON.parse(raw), steamid: sid });
                    }

                    // Pick random winner
                    const winner = entrants[Math.floor(Math.random() * entrants.length)];
                    
                    // Save winner
                    await linksKv.put(winnerKey, JSON.stringify({
                        ...winner,
                        picked_at: Date.now(),
                        picked_by: adminName
                    }));

                    // Award Prize
                    try {
                        const player = await getDxrpPlayer(winner.steamid);
                        const currentBalance = player ? (player.balance || 0) : 0;
                        await updateDxrpBalance(winner.steamid, currentBalance + 100000, `Monthly Giveaway Winner (${month})`);
                        
                        // EVIP Rank UUID: 019db2db-0656-7893-ae2b-3ae1be47c186
                        await assignDxrpRank(winner.steamid, "019db2db-0656-7893-ae2b-3ae1be47c186");
                        await updateDxrpLevel(winner.steamid, 2);
                    } catch (e) {
                        // Log the error but don't fail, admin can retry or fulfill manually
                        console.error("Giveaway reward distribution failed", e);
                    }

                    // Discord Notification
                    if (env.DISCORD_WEBHOOK_URL) {
                        await fetch(env.DISCORD_WEBHOOK_URL, {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify({
                                embeds: [{
                                    title: "🎉 Monthly Giveaway Winner! 🎉",
                                    description: `Congratulations to **${winner.name}** (${winner.steamid}) for winning the **$100,000**, **EVIP Rank**, and **Builder+** for **${month}**!`,
                                    color: 0x017AEF,
                                    thumbnail: { url: winner.avatar },
                                    timestamp: new Date().toISOString()
                                }]
                            })
                        });
                    }

                    return new Response(JSON.stringify({ ok: true, winner }));
                } catch (e) {
                    return new Response(JSON.stringify({ ok: false, error: e.message }), { status: 400 });
                }
            }

            // --- TOKEN EXPIRY MONITOR ---
            const lastUpdate = await linksKv.get("config:dxrp_token_timestamp");
            if (lastUpdate) {
                const ageHours = (Date.now() - parseInt(lastUpdate)) / (1000 * 60 * 60);
                const notified = await linksKv.get("status:dxrp_notified");
                if (ageHours >= 23 && !notified) {
                    // Ping the user
                    await fetch(env.DISCORD_WEBHOOK_URL, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({
                            content: "<@146055950363525120> ⚠️ **DXRP Token Expiry Warning**\nYour token is about to expire in 1 hour. Please visit dxrp.net and click your **Update Token** bookmark to refresh it!"
                        })
                    });
                    await linksKv.put("status:dxrp_notified", "true", { expirationTtl: 3600 });
                } else if (ageHours < 23) {
                    await linksKv.delete("status:dxrp_notified");
                }
            }

            if (path === "/api/admin/send-email" && request.method === "POST") {
                try {
                    const formData = await request.formData();
                    const from = formData.get('from');
                    const to = formData.get('to');
                    const subject = formData.get('subject');
                    const message = formData.get('message');
                    const parentId = formData.get('parent_id');
                    const files = formData.getAll('attachments');

                    if (!from || !to || !subject || !message) {
                        return new Response("Missing fields", { status: 400 });
                    }

                    const cleanFrom = from.trim().toLowerCase();
                    const cleanTo = to.trim().toLowerCase();

                    const attachments = [];
                    for (const file of files) {
                        if (file.size > 0) {
                            attachments.push({
                                filename: file.name,
                                contentType: file.type,
                                data: await file.arrayBuffer()
                            });
                        }
                    }

                    await env.EMAIL.send({
                        to: cleanTo,
                        from: cleanFrom,
                        subject: subject,
                        text: message,
                        attachments: attachments.length > 0 ? attachments : undefined
                    });

                    // Save sent email to DB
                    if (parentId) {
                        // Append to existing email thread
                        await env.DB.prepare(
                            "UPDATE emails SET body = body || ? WHERE id = ?"
                        ).bind("\n\n--- REPLY ---\n" + message, parentId).run();
                    } else {
                        // New email entry
                        await env.DB.prepare(
                            "INSERT INTO emails (msg_from, msg_to, subject, body, is_read) VALUES (?, ?, ?, ?, 1)"
                        ).bind(cleanFrom, cleanTo, subject, message).run();
                    }

                    return new Response("OK");
                } catch (e) {
                    console.error("Email Error:", e);
                    return new Response("Error sending email: " + e.message, { status: 500 });
                }
            }
            else if (path === "/admin/transactions") {
                pageTitle = "LifePunch | Admin Transactions";
                subHeaderTitle = "ALL TRANSACTIONS";
                
                // Fetch all transaction keys (prefix tx:)
                const list = await env.LINKS.list({ prefix: 'tx:' });
                const allTxs = [];

                for (const key of list.keys) {
                    const sid = key.name.split(':')[1];
                    const raw = await env.LINKS.get(key.name);
                    if (raw) {
                        try {
                            const userTxs = JSON.parse(raw);
                            userTxs.forEach(tx => {
                                allTxs.push({ ...tx, steamid: sid });
                            });
                        } catch(e) {}
                    }
                }

                allTxs.sort((a, b) => b.date - a.date);

                bodyContent = `
                <style>
                    .admin-search { width: 100%; padding: 15px; background: var(--surface); border: 1px solid var(--border); border-radius: 8px; color: #fff; margin-bottom: 20px; font-family: inherit; box-sizing: border-box; outline: none; transition: 0.2s; }
                    .admin-search:focus { border-color: var(--lp-blue); box-shadow: 0 0 10px rgba(var(--lp-blue-rgb),0.2); }
                    .tx-table-container { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow-x: auto; }
                    .tx-table { width: 100%; border-collapse: collapse; min-width: 800px; }
                    .tx-table th, .tx-table td { padding: 15px; text-align: left; border-bottom: 1px solid var(--border); font-size: 13px; }
                    .tx-table th { background: var(--card-header); color: var(--lp-blue); text-transform: uppercase; font-family: 'Montserrat', sans-serif; font-size: 11px; letter-spacing: 1px; }
                    .tx-table tr:hover { background: rgba(255,255,255,0.02); }
                    .tx-steamid { font-family: monospace; color: var(--lp-blue); text-decoration: none; font-weight: bold; }
                    .fulfil-cell { display: flex; flex-direction: column; gap: 5px; }
                    .fulfil-item { display: flex; align-items: center; gap: 8px; font-size: 10px; color: var(--text-dim); cursor: help; white-space: nowrap; }
                    .fulfil-item input { margin: 0; cursor: pointer; }

                    #toast {
                        position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%) translateY(100px);
                        background: var(--lp-blue); color: #fff; padding: 12px 24px; border-radius: 50px;
                        font-weight: 900; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
                        box-shadow: 0 10px 30px rgba(var(--lp-blue-rgb), 0.4); z-index: 9999;
                        transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                        pointer-events: none;
                    }
                    #toast.show { transform: translateX(-50%) translateY(0); }
                </style>
                <div id="toast">Copied to clipboard</div>
                <input type="text" id="tx-search" class="admin-search" placeholder="Search by SteamID, Package, or ID...">
                <div class="tx-table-container">
                    <table class="tx-table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>User (SteamID)</th>
                                <th>Discord ID</th>
                                <th>Package</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Transaction ID</th>
                            </tr>
                        </thead>
                        <tbody id="tx-body">
                            ${allTxs.length === 0 ? '<tr><td colspan="7" style="text-align:center;color:var(--text-dim);">No transactions found</td></tr>' : 
                                allTxs.map(tx => {
                                    const pkg = String(tx.package || "").toUpperCase();
                                    const isLP = pkg.includes("$LP");
                                    const rankLabel = isLP ? "$LP Given" : "Rank Given";
                                    const showBuilder = !isLP;
                                    
                                    return `
                                <tr data-key="${tx.id}" data-date="${tx.date}">
                                    <td style="white-space:nowrap;">${new Date(tx.date).toLocaleDateString()}</td>
                                    <td>
                                        <div style="display:flex; flex-direction:column; gap:2px;">
                                            <a href="/profile/${tx.steamid}" class="tx-steamid" style="font-size:12px;" onclick="copyAndNotify(event, '${tx.steamid}', 'SteamID')">${tx.steamid}</a>
                                            <a href="https://dxrp.net/portal/players/${tx.steamid}" target="_blank" style="color:var(--text-dim); text-decoration:none; font-size:10px; font-weight:900; text-transform:uppercase;" onmouseover="this.style.color='var(--lp-blue)'" onmouseout="this.style.color='var(--text-dim)'">View Portal ↗</a>
                                        </div>
                                    </td>
                                    <td style="font-family:monospace;font-size:11px;cursor:pointer;" onclick="copyAndNotify(event, '${tx.discord_id || ''}', 'Discord ID')">${tx.discord_id ? esc(tx.discord_id) : '<span style="opacity:0.3;">N/A</span>'}</td>
                                    <td>${esc(tx.package)}</td>
                                    <td style="font-weight:900;color:#00c853;">$${tx.amount}</td>
                                    <td>
                                        <div class="fulfil-cell">
                                            <label class="fulfil-item" title="Not fulfilled yet">
                                                <input type="checkbox" onchange="toggleFulfil('${tx.id}', 'rank', this.checked)"> ${rankLabel}
                                            </label>
                                            ${showBuilder ? `
                                            <label class="fulfil-item" title="Not fulfilled yet">
                                                <input type="checkbox" onchange="toggleFulfil('${tx.id}', 'builder', this.checked)"> Builder Given
                                            </label>
                                            ` : ''}
                                        </div>
                                    </td>
                                    <td style="font-family:monospace;font-size:11px;color:var(--text-dim);">${esc(tx.id)}</td>
                                </tr>
                                `;
                            }).join('')}
                        </tbody>
                    </table>
                </div>

                <script>
                    const CUTOFF_DATE = 1746835200000; // May 10, 2026

                    function showToast(msg) {
                        const t = document.getElementById('toast');
                        t.innerText = msg;
                        t.classList.add('show');
                        setTimeout(() => t.classList.remove('show'), 2000);
                    }
                    function copyAndNotify(ev, text, label) {
                        if (ev.ctrlKey || ev.metaKey || ev.button === 1) return; // Allow new tab
                        if (ev.target.tagName === 'A') ev.preventDefault();
                        if (!text) return;
                        navigator.clipboard.writeText(text).then(() => {
                            showToast(label + ' Copied');
                        });
                    }

                    async function toggleFulfil(key, field, checked) {
                        try {
                            const res = await fetch('/api/admin/toggle-fulfillment', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ key, field, checked })
                            });
                            if (res.ok) {
                                const data = await res.json();
                                updateFulfilUI(key, data);
                            }
                        } catch (e) { console.error(e); }
                    }

                    function updateFulfilUI(key, state, isLegacy = false) {
                        const row = document.querySelector('tr[data-key="' + key + '"]');
                        if (!row) return;
                        
                        const fields = isLegacy ? ['rank', 'builder'] : Object.keys(state);
                        
                        fields.forEach(field => {
                            const item = isLegacy ? { checked: true, by: 'System', at: parseInt(row.dataset.date) } : state[field];
                            const input = row.querySelector('input[onchange*="' + field + '"]');
                            if (!input) return;
                            const label = input.parentElement;
                            input.checked = item.checked;
                            if (item.checked) {
                                label.style.color = '#00c853';
                                label.title = isLegacy ? 'Legacy record (auto-marked)' : 'Checked by ' + item.by + ' on ' + new Date(item.at).toLocaleString();
                            } else {
                                label.style.color = '';
                                label.title = 'Not fulfilled yet';
                            }
                        });
                    }

                    async function loadFulfilment() {
                        const keys = [];
                        document.querySelectorAll('#tx-body tr[data-key]').forEach(r => {
                            if (parseInt(r.dataset.date) < CUTOFF_DATE) {
                                updateFulfilUI(r.dataset.key, {}, true);
                            } else {
                                keys.push(r.dataset.key);
                            }
                        });

                        if (keys.length === 0) return;
                        try {
                            const res = await fetch('/api/admin/get-fulfillment', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ keys })
                            });
                            if (res.ok) {
                                const data = await res.json();
                                Object.keys(data).forEach(key => updateFulfilUI(key, data[key]));
                            }
                        } catch (e) { console.error(e); }
                    }

                    window.addEventListener('load', loadFulfilment);

                    document.getElementById('tx-search').addEventListener('input', function(e) {
                        const term = e.target.value.toLowerCase();
                        document.querySelectorAll('#tx-body tr').forEach(row => {
                            if (row.cells.length < 5) return;
                            row.style.display = row.innerText.toLowerCase().includes(term) ? '' : 'none';
                        });
                    });
                </script>
                `;
            }
            else if (path === "/admin/rewards") {
                pageTitle = "LifePunch | Admin Rewards";
                subHeaderTitle = "REWARD MANAGEMENT";
                
                const allRewards = [];
                
                // Fetch new generic rewards
                const newList = await env.LINKS.list({ prefix: 'reward_claimed:' });
                for (const key of newList.keys) {
                    const parts = key.name.split(':');
                    const type = parts[1];
                    const sid = parts[2];
                    
                    const raw = await env.LINKS.get(key.name);
                    if (raw) {
                        try {
                            const data = JSON.parse(raw);
                            allRewards.push({ ...data, steamid: sid, type: type, key: key.name });
                        } catch(e) {}
                    }
                }

                // Fetch legacy rewards
                const legacyList = await env.LINKS.list({ prefix: 'discord_reward_claimed:' });
                for (const key of legacyList.keys) {
                    const sid = key.name.split(':')[1];
                    const raw = await env.LINKS.get(key.name);
                    if (raw) {
                        try {
                            const data = JSON.parse(raw);
                            allRewards.push({ ...data, steamid: sid, type: 'discord (legacy)', key: key.name });
                        } catch(e) {}
                    }
                }

                // Fetch giveaway entries
                const giveawayList = await env.LINKS.list({ prefix: 'giveaway:entry:' });
                for (const key of giveawayList.keys) {
                    const parts = key.name.split(':');
                    const sid = parts[3];
                    const month = parts[2];
                    const raw = await env.LINKS.get(key.name);
                    const linkData = await env.LINKS.get(`link:steam:${sid}`);
                    let discord_id = null;
                    if (linkData) {
                        try { discord_id = JSON.parse(linkData).id; } catch {}
                    }
                    if (raw) {
                        try {
                            const data = JSON.parse(raw);
                            allRewards.push({ ...data, steamid: sid, discord_id, type: `Giveaway (${month})`, key: key.name });
                        } catch(e) {}
                    }
                }

                allRewards.sort((a, b) => (b.at || 0) - (a.at || 0));

                bodyContent = `
                <style>
                    .admin-search { width: 100%; padding: 15px; background: var(--surface); border: 1px solid var(--border); border-radius: 8px; color: #fff; margin-bottom: 20px; font-family: inherit; box-sizing: border-box; outline: none; transition: 0.2s; }
                    .reward-table-container { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow-x: auto; }
                    .reward-table { width: 100%; border-collapse: collapse; }
                    .reward-table th, .reward-table td { padding: 15px; text-align: left; border-bottom: 1px solid var(--border); font-size: 13px; }
                    .reward-table th { background: var(--card-header); color: var(--lp-blue); text-transform: uppercase; font-family: 'Montserrat', sans-serif; font-size: 11px; letter-spacing: 1px; }
                    
                    .btn-reset { background: #ff4d4d; color: #fff; border: none; padding: 8px 15px; border-radius: 4px; font-weight: 900; cursor: pointer; font-size: 11px; transition: 0.2s; text-transform: uppercase; }
                    .btn-reset:hover { background: #cc0000; transform: scale(1.05); }
                    .btn-reset:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
                    
                    .type-badge { background: rgba(var(--lp-blue-rgb), 0.1); color: var(--lp-blue); padding: 4px 8px; border-radius: 4px; font-size: 10px; font-weight: 900; text-transform: uppercase; border: 1px solid rgba(var(--lp-blue-rgb), 0.3); }
                    
                    #toast {
                        position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%) translateY(100px);
                        background: var(--lp-blue); color: #fff; padding: 12px 24px; border-radius: 50px;
                        font-weight: 900; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
                        box-shadow: 0 10px 30px rgba(var(--lp-blue-rgb), 0.4); z-index: 9999;
                        transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                        pointer-events: none;
                    }
                    #toast.show { transform: translateX(-50%) translateY(0); }
                    .tx-steamid { font-family: monospace; color: var(--lp-blue); text-decoration: none; font-weight: bold; }
                    .tx-steamid:hover { text-decoration: underline; }
                </style>
                <div id="toast">Copied to clipboard</div>
                <div style="margin-bottom: 20px;">
                    <button id="sync-btn" class="btn-link" style="background: var(--lp-blue); color: #fff; border: none; padding: 10px 20px; cursor: pointer; border-radius: 6px; font-weight: 900;">Sync Pending Rewards (Retry Queue)</button>
                    <span id="sync-status" style="margin-left: 15px; color: var(--text-dim);"></span>
                </div>
                <script>
                    document.getElementById('sync-btn').addEventListener('click', async () => {
                        const status = document.getElementById('sync-status');
                        status.innerText = "Processing...";
                        try {
                            const res = await fetch('/api/admin/process-queue', { method: 'POST' });
                            const data = await res.json();
                            status.innerText = data.message || "Sync complete!";
                        } catch (e) {
                            status.innerText = "Error syncing.";
                        }
                    });
                </script>

                <input type="text" id="reward-search" class="admin-search" placeholder="Search by SteamID or Type...">
                <div class="reward-table-container">
                    <table class="reward-table">
                        <thead>
                            <tr>
                                <th>Claim Date</th>
                                <th>Type</th>
                                <th>User (SteamID)</th>
                                <th>Discord ID</th>
                                <th style="text-align:right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="reward-body">
                            ${allRewards.length === 0 ? '<tr><td colspan="4" style="text-align:center;color:var(--text-dim);">No rewards claimed yet</td></tr>' : 
                                allRewards.map((r, idx) => `
                                <tr id="row-${idx}" data-key="${r.key}" data-date="${r.at || 0}">
                                    <td>${r.at ? new Date(r.at).toLocaleString() : 'N/A'}</td>
                                    <td><span class="type-badge">${esc(r.type)}</span></td>
                                    <td>
                                        <div style="display:flex; flex-direction:column; gap:2px;">
                                            <a href="/profile/${r.steamid}" class="tx-steamid" style="font-size:12px;" onclick="copyAndNotify(event, '${r.steamid}', 'SteamID')">${r.steamid}</a>
                                            <a href="https://dxrp.net/portal/players/${r.steamid}" target="_blank" style="color:var(--text-dim); text-decoration:none; font-size:10px; font-weight:900; text-transform:uppercase;" onmouseover="this.style.color='var(--lp-blue)'" onmouseout="this.style.color='var(--text-dim)'">View Portal ↗</a>
                                        </div>
                                    </td>
                                    <td style="font-family:monospace;font-size:11px;cursor:pointer;" onclick="copyAndNotify(event, '${r.discord_id || ''}', 'Discord ID')">${r.discord_id ? esc(r.discord_id) : '<span style="opacity:0.3;">N/A</span>'}</td>
                                    <td style="text-align:right;">
                                        <button class="btn-reset" onclick="resetReward('${r.key}', ${idx}, this)">RESET</button>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
                
                <script>
                    const CUTOFF_DATE = 1746835200000; // May 10, 2026

                    function showToast(msg) {
                        const t = document.getElementById('toast');
                        t.innerText = msg;
                        t.classList.add('show');
                        setTimeout(() => t.classList.remove('show'), 2000);
                    }
                    function copyAndNotify(ev, text, label) {
                        if (ev.ctrlKey || ev.metaKey || ev.button === 1) return; // Allow new tab
                        if (ev.target.tagName === 'A') ev.preventDefault();
                        if (!text) return;
                        navigator.clipboard.writeText(text).then(() => {
                            showToast(label + ' Copied');
                        });
                    }

                    async function toggleFulfil(key, field, checked) {
                        try {
                            const res = await fetch('/api/admin/toggle-fulfillment', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ key, field, checked })
                            });
                            if (res.ok) {
                                const data = await res.json();
                                updateFulfilUI(key, data);
                            }
                        } catch (e) { console.error(e); }
                    }

                    function updateFulfilUI(key, state, isLegacy = false) {
                        const row = document.querySelector('tr[data-key="' + key + '"]');
                        if (!row) return;

                        const fields = isLegacy ? ['cash'] : Object.keys(state);

                        fields.forEach(field => {
                            const item = isLegacy ? { checked: true, by: 'System', at: parseInt(row.dataset.date) } : state[field];
                            const input = row.querySelector('input[onchange*="' + field + '"]');
                            if (!input) return;
                            const label = input.parentElement;
                            input.checked = item.checked;
                            if (item.checked) {
                                label.style.color = '#00c853';
                                label.title = isLegacy ? 'Legacy record (auto-marked)' : 'Checked by ' + item.by + ' on ' + new Date(item.at).toLocaleString();
                            } else {
                                label.style.color = '';
                                label.title = 'Not fulfilled yet';
                            }
                        });
                    }

                    async function loadFulfilment() {
                        const keys = [];
                        document.querySelectorAll('#reward-body tr[data-key]').forEach(r => {
                            if (parseInt(r.dataset.date) < CUTOFF_DATE) {
                                updateFulfilUI(r.dataset.key, {}, true);
                            } else {
                                keys.push(r.dataset.key);
                            }
                        });

                        if (keys.length === 0) return;
                        try {
                            const res = await fetch('/api/admin/get-fulfillment', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ keys })
                            });
                            if (res.ok) {
                                const data = await res.json();
                                Object.keys(data).forEach(key => updateFulfilUI(key, data[key]));
                            }
                        } catch (e) { console.error(e); }
                    }

                    window.addEventListener('load', loadFulfilment);

                    document.getElementById('reward-search').addEventListener('input', function(e) {
                        const term = e.target.value.toLowerCase();
                        document.querySelectorAll('#reward-body tr').forEach(row => {
                            if (row.cells.length < 4) return;
                            row.style.display = row.innerText.toLowerCase().includes(term) ? '' : 'none';
                        });
                    });

                    async function resetReward(key, idx, btn) {
                        if (!confirm('Are you sure you want to reset this reward?')) return;
                        
                        btn.disabled = true;
                        btn.innerText = 'RESETTING...';
                        
                        try {
                            const res = await fetch('/api/admin/reset-reward', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ key: key })
                            });
                            
                            if (res.ok) {
                                const row = document.getElementById('row-' + idx);
                                row.style.opacity = '0.5';
                                row.style.pointerEvents = 'none';
                                setTimeout(() => row.remove(), 500);
                            } else {
                                alert('Reset failed. Make sure you are still logged in.');
                                btn.disabled = false;
                                btn.innerText = 'RESET';
                            }
                        } catch(e) { 
                            alert('Error: ' + e.message);
                            btn.disabled = false;
                            btn.innerText = 'RESET';
                        }
                    }
                </script>
                `;
            }
            else if (path === "/api/admin/reset-reward" && request.method === "POST") {
                try {
                    const { key, steamid: targetSid } = await request.json();
                    if (key) {
                        // For Weekend rewards, we must also delete the 'claimed_weekend' state key
                        const raw = await env.LINKS.get(key);
                        if (raw) {
                            try {
                                const data = JSON.parse(raw);
                                if (data.type === "weekend" && data.weekend_id && data.steamid) {
                                    await env.LINKS.delete(`claimed_weekend:${data.weekend_id}:${data.steamid}`);
                                } else if (data.type === "discord" && data.steamid) {
                                    // This matches reward_claimed:discord:${steamid}
                                    await env.LINKS.delete(`reward_claimed:discord:${data.steamid}`);
                                    await env.LINKS.delete(`discord_reward_claimed:${data.steamid}`);
                                }
                            } catch(e) {}
                        }
                        
                        await env.LINKS.delete(key);
                        return new Response(JSON.stringify({ success: true }), { 
                            headers: { 'Content-Type': 'application/json' } 
                        });
                    } else if (targetSid) {
                        // Fallback for old reset calls
                        await env.LINKS.delete(`discord_reward_claimed:${targetSid}`);
                        await env.LINKS.delete(`reward_claimed:discord:${targetSid}`);
                        return new Response(JSON.stringify({ success: true }), { 
                            headers: { 'Content-Type': 'application/json' } 
                        });
                    }
                    return new Response("Missing Key or SteamID", { status: 400 });
                } catch(e) {
                    return new Response("Invalid JSON", { status: 400 });
                }
            }

            // Common structure for admin pages
            let finalHtml = `
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <title>${pageTitle}</title>
                ${sharedHead}
            </head>
            <body>
                <div class="container">
                    ${getHeader(subHeaderTitle)}
                    ${bodyContent}
                </div>
                ${isEmbed ? "" : sharedFooter}
            </body>
            </html>
            `;
            return new Response(finalHtml, {
                headers: {
                    "Content-Type": "text/html;charset=UTF-8",
                    "X-Content-Type-Options": "nosniff",
                    "Referrer-Policy": "strict-origin-when-cross-origin",
                    ...buildSecurityHeaders(false)
                }
            });
        }

        // --- PROFILE PAGE (MUST BE BEFORE OTHER ROUTES) ---
        if (path === "/profile" || path.startsWith("/profile/")) {
            let targetSteamId = steamid;
            if (path.startsWith("/profile/")) {
                const parts = path.split("/");
                if (parts[2] && parts[2].trim() !== "") {
                    targetSteamId = parts[2].trim();
                }
            }

            if (!targetSteamId) {
                return new Response(null, {
                    status: 302,
                    headers: { "Location": `/login?return=${encodeURIComponent(path + url.search)}` }
                });
            }

            // Ensure profile exists (user has logged in before)
            const userExists = await linksKv.get(`user:seen:${targetSteamId}`);
            if (userExists !== "1") {
                return new Response("Profile Not Found", { status: 404 });
            }

            const isOwner = (steamid !== null && steamid === targetSteamId);

            pageTitle = isOwner ? "LifePunch | My Profile" : `LifePunch | Profile - ${targetSteamId}`;
            subHeaderTitle = isOwner ? "YOUR PROFILE" : "PLAYER PROFILE";

            let discordAccount = null;
            if (linksKv && targetSteamId && isOwner) {
                const rawDiscord = await linksKv.get(`link:steam:${targetSteamId}`);
                if (rawDiscord) {
                    try {
                        discordAccount = JSON.parse(rawDiscord);
                    } catch {
                        discordAccount = null;
                    }
                }
            }

            let discordFlash = null;
            if (isOwner) {
                if (url.searchParams.get("discord_linked") === "1") {
                    discordFlash = { ok: true, text: "Discord account linked successfully." };
                } else if (url.searchParams.get("discord_unlinked") === "1") {
                    discordFlash = { ok: true, text: "Discord account unlinked." };
                } else if (url.searchParams.get("discord_error")) {
                    try {
                        discordFlash = {
                            ok: false,
                            text: decodeURIComponent(url.searchParams.get("discord_error"))
                        };
                    } catch {
                        discordFlash = { ok: false, text: "Discord link failed." };
                    }
                }
            }

            const discordDisplayName = discordAccount?.id
                ? esc(discordAccount.global_name || discordAccount.username || "Discord")
                : "";
            const discordAvatarSrc = discordAccount?.id ? esc(discordAvatarUrl(discordAccount)) : "";
            const discordIdEsc = discordAccount?.id ? esc(discordAccount.id) : "";

            // Fetch Referral Data
            let [rawRefStats, rawCredit, rawPurchases, rawRefHistory, userRefCode] = await Promise.all([
                linksKv.get(`referral:stats:${targetSteamId}`),
                linksKv.get(`user:credit:${targetSteamId}`),
                linksKv.get(`referral:purchases:${targetSteamId}`),
                linksKv.get(`referral:history:${targetSteamId}`),
                linksKv.get(`user:refcode:${targetSteamId}`)
            ]);

            // Auto-generate for existing users viewing their own profile
            if (!userRefCode && isOwner && linksKv) {
                userRefCode = Math.random().toString(36).substring(2, 10).toUpperCase();
                await linksKv.put(`user:refcode:${targetSteamId}`, userRefCode);
                await linksKv.put(`refcode:to:steam:${userRefCode}`, targetSteamId);
            }

            const displayRefCode = userRefCode || "NO CODE GENERATED";

            let refStats = { total_referrals: 0, earned_credit: 0 };
            if (rawRefStats) try { refStats = JSON.parse(rawRefStats); } catch {}

            let userCredit = parseFloat(rawCredit) || 0;

            let purchaseHistory = [];
            if (rawPurchases) try { purchaseHistory = JSON.parse(rawPurchases); } catch {}

            let refHistory = [];
            if (rawRefHistory) try { refHistory = JSON.parse(rawRefHistory); } catch {}

            // Fetch Steam profile data
            let steamProfile = await getSteamProfileData(targetSteamId);

            // Fallback profile if API fails
            if (!steamProfile) {
                steamProfile = {
                    personaname: "Player",
                    avatarmedium: "https://avatars.steamcontent.com/steamcommunity/public/images/avatars/base_default.jpg",
                    timecreated: Math.floor(Date.now() / 1000)
                };
            }

            bodyContent = `
            <style>
                .profile-header { 
                    background: var(--surface);
                    border: 1px solid var(--border);
                    border-radius: 12px; 
                    padding: 30px; 
                    backdrop-filter: blur(16px);
                    margin-bottom: 30px;
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    gap: 20px;
                }
                @media (max-width: 650px) {
                    .profile-header {
                        flex-direction: column;
                        text-align: center;
                        padding: 30px 20px;
                    }
                }
                .profile-main-info {
                    display: flex;
                    align-items: center;
                    gap: 25px;
                }
                @media (max-width: 650px) {
                    .profile-main-info {
                        flex-direction: column;
                        gap: 15px;
                    }
                }
                .profile-avatar {
                    width: 100px;
                    height: 100px;
                    border-radius: 10px;
                    overflow: hidden;
                    border: 2px solid var(--lp-blue);
                    box-shadow: 0 0 20px rgba(var(--lp-blue-rgb), 0.2);
                    flex-shrink: 0;
                }
                .profile-avatar img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    display: block;
                }
                .profile-details {
                    display: flex;
                    flex-direction: column;
                    gap: 5px;
                }
                .profile-name {
                    font-family: 'Montserrat', sans-serif;
                    font-size: 32px;
                    font-weight: 900;
                    color: #fff;
                    margin: 0;
                    line-height: 1;
                    letter-spacing: -1px;
                }
                .profile-steamid {
                    font-family: 'Courier New', monospace;
                    font-size: 13px;
                    color: var(--text-dim);
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }
                @media (max-width: 650px) {
                    .profile-steamid { justify-content: center; }
                }
                .profile-steamid button {
                    background: rgba(255, 255, 255, 0.05);
                    border: 1px solid var(--border);
                    color: var(--text-dim);
                    padding: 4px 8px;
                    border-radius: 6px;
                    font-size: 11px;
                    cursor: pointer;
                    transition: 0.2s;
                }
                .profile-steamid button:hover {
                    border-color: var(--lp-blue);
                    color: #fff;
                }
                .profile-meta-badge {
                    background: rgba(var(--lp-blue-rgb), 0.05);
                    border: 1px solid rgba(var(--lp-blue-rgb), 0.3);
                    padding: 15px 25px;
                    border-radius: 10px;
                    text-align: center;
                    min-width: 140px;
                }
                @media (max-width: 650px) {
                    .profile-meta-badge { width: 100%; box-sizing: border-box; }
                }
                .profile-meta-label {
                    font-size: 10px;
                    color: var(--lp-blue);
                    text-transform: uppercase;
                    letter-spacing: 1.5px;
                    font-weight: 900;
                    margin-bottom: 4px;
                }
                .profile-meta-value {
                    font-size: 14px;
                    color: #fff;
                    font-weight: 700;
                }
                .profile-section {
                    background: var(--surface);
                    border: 1px solid var(--border);
                    border-radius: 12px;
                    padding: 30px;
                    backdrop-filter: blur(16px);
                    margin-bottom: 20px;
                }
                .section-title {
                    font-family: 'Montserrat', sans-serif;
                    font-size: 18px;
                    font-weight: 900;
                    color: var(--lp-blue);
                    margin: 0 0 20px 0;
                    text-transform: uppercase;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }
                .section-title i {
                    font-size: 20px;
                }
                .link-status {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 20px;
                    background: rgba(var(--lp-blue-rgb), 0.05);
                    border: 1px solid var(--lp-blue);
                    border-radius: 8px;
                    margin-bottom: 15px;
                }
                .link-status.linked {
                    background: rgba(0, 200, 83, 0.05);
                    border-color: #00c853;
                }
                .link-info {
                    display: flex;
                    align-items: center;
                    gap: 15px;
                    flex: 1;
                }
                .link-icon {
                    font-size: 24px;
                    color: var(--lp-blue);
                }
                .link-icon.linked {
                    color: #00c853;
                }
                .link-details h3 {
                    margin: 0 0 5px 0;
                    color: #fff;
                    font-size: 14px;
                }
                .link-details p {
                    margin: 0;
                    color: var(--text-dim);
                    font-size: 12px;
                }
                .link-action {
                    display: flex;
                    gap: 10px;
                }
                .btn-link {
                    background: var(--lp-blue);
                    color: #fff;
                    border: none;
                    padding: 10px 20px;
                    border-radius: 6px;
                    font-weight: 900;
                    font-size: 12px;
                    cursor: pointer;
                    text-transform: uppercase;
                    transition: 0.2s;
                }
                .btn-link:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 5px 15px rgba(var(--lp-blue-rgb), 0.3);
                }
                .btn-link.copied {
                    background: #00c853 !important;
                    border-color: #00c853 !important;
                }
                .connected-avatar {
                    width: 40px;
                    height: 40px;
                    border-radius: 8px;
                    overflow: hidden;
                    border: 1px solid var(--border);
                }
                .connected-avatar img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                }
                .api-warning {
                    background: rgba(255, 152, 0, 0.1);
                    border: 1px solid #ff9800;
                    color: #ffb74d;
                    padding: 15px;
                    border-radius: 8px;
                    font-size: 12px;
                    margin-bottom: 20px;
                }
                .discord-flash {
                    padding: 14px 16px;
                    border-radius: 8px;
                    font-size: 13px;
                    margin-bottom: 20px;
                    border: 1px solid var(--border);
                    transition: opacity 0.55s ease, transform 0.55s ease;
                }
                .discord-flash.discord-flash--hiding {
                    opacity: 0;
                    transform: translateY(-6px);
                    pointer-events: none;
                }
                .discord-flash--ok {
                    background: rgba(0, 200, 83, 0.1);
                    border-color: #00c853;
                    color: #b9f6ca;
                }
                .discord-flash--err {
                    background: rgba(255, 82, 82, 0.08);
                    border-color: #ff5252;
                    color: #ffcdd2;
                }
                .btn-link-secondary {
                    background: rgba(255, 255, 255, 0.08);
                    color: var(--text-dim);
                    border: 1px solid var(--border);
                }
                .btn-link-secondary:hover {
                    border-color: #ff5252;
                    color: #ff8a80;
                    box-shadow: none;
                    transform: translateY(-1px);
                }
                .discord-unlink-confirming {
                    border-color: #ff9800 !important;
                    color: #ffb74d !important;
                    white-space: normal;
                    text-align: center;
                    max-width: 200px;
                    line-height: 1.3;
                }
                @media (max-width: 600px) {
                    .profile-header {
                        flex-direction: column;
                        align-items: center;
                        text-align: center;
                        padding: 25px;
                    }
                    .profile-meta {
                        grid-template-columns: 1fr;
                    }
                    .profile-section {
                        padding: 20px;
                    }
                    .link-status {
                        flex-direction: column;
                        text-align: center;
                        gap: 15px;
                    }
                    .link-action {
                        justify-content: center;
                        width: 100%;
                    }
                }
            </style>

            <div class="profile-header">
                <div class="profile-main-info">
                    <div class="profile-avatar">
                        <img src="${steamProfile.avatarmedium}" alt="Steam Avatar" onerror="this.src='https://avatars.steamcontent.com/steamcommunity/public/images/avatars/base_default.jpg'">
                    </div>
                    <div class="profile-details">
                        <h2 class="profile-name">${steamProfile.personaname}</h2>
                        <div class="profile-steamid">
                            <span class="tx-steamid" style="font-size:12px;">${targetSteamId}</span>
                            <button type="button" onclick="copySteamIDWithFeedback(event, '${targetSteamId}')" style="background:none; border:none; padding:0; cursor:pointer; color:var(--text-dim); transition: 0.2s;" title="Copy SteamID">
                                <i class="fa-solid fa-copy"></i>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="profile-meta-badge">
                    <div class="profile-meta-label">Account Created</div>
                    <div class="profile-meta-value">${steamProfile.timecreated ? new Date(steamProfile.timecreated * 1000).toLocaleDateString() : 'N/A'}</div>
                </div>
            </div>

            ${isOwner && discordFlash ? `<div id="discord-flash-banner" class="discord-flash discord-flash--${discordFlash.ok ? "ok" : "err"}" role="status">${esc(discordFlash.text)}</div>` : ""}

            ${isOwner && !env.STEAM_API_KEY ? `<div class="api-warning">⚠️ Steam API Key not configured. Some profile data may be unavailable. Please set STEAM_API_KEY in your Cloudflare environment variables.</div>` : ''}

            ${isOwner ? `
            <div class="profile-section">
                <h3 class="section-title">
                    <i class="fa-brands fa-discord"></i> Discord Integration
                </h3>
                ${
                    discordAccount?.id
                        ? `
                <div class="link-status linked">
                    <div class="link-info">
                        <div class="connected-avatar" style="width:48px;height:48px;border-radius:50%;border:2px solid #00c853;">
                            <img src="${discordAvatarSrc}" alt="">
                        </div>
                        <div class="link-details">
                            <h3>${discordDisplayName}</h3>
                            <p>Discord linked · <span style="font-family:monospace;font-size:11px;">${discordIdEsc}</span></p>
                        </div>
                    </div>
                    <div class="link-action">
                        <form id="discord-unlink-form" action="/auth/discord/unlink" method="POST" style="margin:0">
                            <button type="button" id="discord-unlink-btn" class="btn-link btn-link-secondary">UNLINK</button>
                        </form>
                    </div>
                </div>
                `
                        : `
                <div class="link-status">
                    <div class="link-info">
                        <div class="link-icon"><i class="fa-brands fa-discord"></i></div>
                        <div class="link-details">
                            <h3>Discord Account</h3>
                            <p>Link your Discord account to access exclusive features</p>
                        </div>
                    </div>
                    <div class="link-action">
                        <a href="/auth/discord" class="btn-link" style="text-decoration:none;display:inline-block;line-height:normal;box-sizing:border-box;">LINK</a>
                    </div>
                </div>
                `
                }
            </div>
            ${isOwner ? `
            <div class="profile-section">
                <h3 class="section-title">
                    <i class="fa-solid fa-users"></i> Referral Program
                </h3>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:20px;">
                    <div class="profile-meta-badge" style="background:rgba(0,200,83,0.05); border-color:rgba(0,200,83,0.3);">
                        <div class="profile-meta-label" style="color:#00c853;">Total Referrals</div>
                        <div class="profile-meta-value">${refStats.total_referrals} Users</div>
                    </div>
                    <div class="profile-meta-badge" style="background:rgba(255,215,0,0.05); border-color:rgba(255,215,0,0.3);">
                        <div class="profile-meta-label" style="color:#ffd700;">Earned Credit</div>
                        <div class="profile-meta-value">$${refStats.earned_credit.toFixed(2)}</div>
                    </div>
                </div>

                <div style="background:rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius:8px; padding:20px;">
                    <h4 style="margin:0 0 10px 0; color:#fff; font-size:14px; text-transform:uppercase;">Your Referral Code</h4>
                    <p style="margin:0 0 15px 0; color:var(--text-dim); font-size:12px;">Share this code with friends. They get 10% off their first purchase, and you earn $1.00!</p>
                    <div style="display:flex; gap:10px;">
                        <div style="flex:1; background:rgba(0,0,0,0.3); border:1px solid var(--border); padding:10px; border-radius:6px; font-family:monospace; color:var(--lp-blue); font-weight:bold; font-size:14px;">
                            ${displayRefCode}
                        </div>
                        <button class="btn-link" onclick="copyRefCode('${displayRefCode}', this)">COPY</button>
                    </div>
                </div>

                ${refHistory.length > 0 ? `
                <div style="margin-top:20px;">
                    <h4 style="margin:0 0 10px 0; color:#fff; font-size:12px; text-transform:uppercase; opacity:0.6;">Recent Referral Rewards</h4>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        ${refHistory.slice(0, 5).map(h => `
                            <div style="display:flex; justify-content:space-between; align-items:center; background:rgba(255,255,255,0.02); padding:8px 12px; border-radius:4px; font-size:11px;">
                                <span style="color:var(--text-dim);">Referred <b style="color:#fff;">${h.buyer_steamid.slice(0, 8)}...</b></span>
                                <span style="color:#00c853; font-weight:bold;">+$${h.amount.toFixed(2)}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>
                ` : ''}
            </div>

            <div class="profile-section">
                <h3 class="section-title">
                    <i class="fa-solid fa-receipt"></i> Purchase History
                </h3>
                ${purchaseHistory.length === 0 ? `
                    <p style="text-align:center; color:var(--text-dim); font-size:13px; padding:20px 0;">No purchases found.</p>
                ` : `
                    <div style="display:flex; flex-direction:column; gap:10px;">
                        ${purchaseHistory.map(p => `
                            <div style="display:flex; justify-content:space-between; align-items:center; background:rgba(255,255,255,0.03); border:1px solid var(--border); padding:15px; border-radius:8px;">
                                <div style="display:flex; flex-direction:column; gap:2px;">
                                    <span style="font-weight:bold; color:#fff; font-size:14px;">${esc(p.package)}</span>
                                    <span style="color:var(--text-dim); font-size:11px;">${new Date(p.date).toLocaleDateString()}</span>
                                </div>
                                <span style="font-weight:900; color:var(--lp-blue); font-size:14px;">$${p.amount}</span>
                            </div>
                        `).join('')}
                    </div>
                `}
            </div>
            ` : ''}

            ` : ''}

            <script>
                function copySteamIDWithFeedback(ev, sid) {
                    ev.preventDefault();
                    if (!sid) return;
                    
                    const btn = ev.currentTarget;
                    const originalIcon = btn.innerHTML;
                    const originalColor = btn.style.color;
                    
                    navigator.clipboard.writeText(sid).then(() => {
                        btn.innerHTML = '<i class="fa-solid fa-check"></i>';
                        btn.style.color = '#00c853';
                        
                        setTimeout(() => {
                            btn.innerHTML = originalIcon;
                            btn.style.color = originalColor;
                        }, 1500);
                    });
                }

                function showToast(msg) {
                    const t = document.getElementById('toast');
                    if (!t) return;
                    t.innerText = msg;
                    t.classList.add('show');
                    setTimeout(() => t.classList.remove('show'), 2000);
                }

                function copyRefCode(text, btn) {
                    if (!text) return;
                    navigator.clipboard.writeText(text).then(() => {
                        const originalText = btn.innerText;
                        btn.innerText = "COPIED!";
                        btn.classList.add('copied');
                        setTimeout(() => { 
                            btn.innerText = originalText; 
                            btn.classList.remove('copied'); 
                        }, 2000);
                        if (typeof showToast === 'function') showToast('Referral Code Copied');
                    });
                }

                function copyAndNotify(ev, text, label) {
                    if (ev.ctrlKey || ev.metaKey || ev.button === 1) return; // Allow new tab
                    if (ev.target.tagName === 'A') ev.preventDefault();
                    if (!text) return;
                    navigator.clipboard.writeText(text).then(() => {
                        showToast(label + ' Copied');
                    });
                }

                (function setupDiscordUnlink() {
                    const btn = document.getElementById("discord-unlink-btn");
                    if (!btn) return;
                    const labelUnlink = "UNLINK";
                    const labelConfirm = "Are you sure? Click again to confirm unlink";
                    let resetTimer;
                    btn.addEventListener("click", function () {
                        if (!this.dataset.awaitingConfirm) {
                            this.dataset.awaitingConfirm = "1";
                            this.textContent = labelConfirm;
                            this.classList.add("discord-unlink-confirming");
                            clearTimeout(resetTimer);
                            resetTimer = setTimeout(() => {
                                delete btn.dataset.awaitingConfirm;
                                btn.textContent = labelUnlink;
                                btn.classList.remove("discord-unlink-confirming");
                            }, 8000);
                            return;
                        }
                        clearTimeout(resetTimer);
                        this.closest("form").submit();
                    });
                })();

                (function autoHideDiscordFlash() {
                    const el = document.getElementById("discord-flash-banner");
                    if (!el) return;

                    function stripDiscordQueryFlags() {
                        try {
                            const u = new URL(window.location.href);
                            let changed = false;
                            ["discord_linked", "discord_unlinked", "discord_error"].forEach(function (k) {
                                if (u.searchParams.has(k)) {
                                    u.searchParams.delete(k);
                                    changed = true;
                                }
                            });
                            if (!changed) return;
                            const q = u.searchParams.toString();
                            window.history.replaceState({}, "", u.pathname + (q ? "?" + q : "") + u.hash);
                        } catch (e) { /* ignore */ }
                    }

                    window.setTimeout(function () {
                        stripDiscordQueryFlags();
                        el.classList.add("discord-flash--hiding");
                        function removeBanner() {
                            if (el.parentNode) el.remove();
                        }
                        el.addEventListener("transitionend", removeBanner, { once: true });
                        window.setTimeout(removeBanner, 900);
                    }, 3200);
                })();
            </script>
            `;

            let finalHtml = `
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <title>${pageTitle}</title>
                ${sharedHead}
            </head>
            <body>
                <div class="container">
                    ${getHeader(subHeaderTitle)}
                    ${bodyContent}
                </div>
                ${isEmbed ? "" : sharedFooter}
            </body>
            </html>
            `;

            const responseHeaders = {
                "Content-Type": "text/html;charset=UTF-8",
                "X-Content-Type-Options": "nosniff",
                "Referrer-Policy": "strict-origin-when-cross-origin",
                "Access-Control-Allow-Origin": "*",
                ...buildSecurityHeaders(isEmbed)
            };

            return new Response(finalHtml, { headers: responseHeaders });
        }

        if (path === "/rules") {
            pageTitle = "LifePunch | Official Rules";
            subHeaderTitle = "RULES & CONDUCT";
            if (isSbox) bodyClass = "sbox-rules";

            const escAttr = (value) =>
                String(value ?? "")
                    .replace(/&/g, "&amp;")
                    .replace(/"/g, "&quot;")
                    .replace(/</g, "&lt;");

            const renderWebRuleLine = (id, html, ruleGroup = "", numLabel = "", copyPrefix = "") => {
                const groupAttr = ruleGroup ? ` data-rule-group="${ruleGroup}"` : "";
                const prefixAttr = copyPrefix ? ` data-copy-prefix="${escAttr(copyPrefix)}"` : "";
                const numMarkup = numLabel ? `<span class="rule-num">${numLabel}</span>` : "";
                return `
            <div class="rule-line" id="${id}"${groupAttr}${prefixAttr}>
                ${numMarkup}
                <div class="rule-text">${html}</div>
                <div class="rule-actions">
                    <button type="button" class="action-btn rule-copy-btn" data-rule-id="${id}" data-tooltip="Copy Rule" title="Copy Text"><i class="fa-solid fa-copy"></i></button>
                    <button type="button" class="action-btn rule-share-btn" data-rule-id="${id}" data-tooltip="Share Link" title="Share Link"><i class="fa-solid fa-share-nodes"></i></button>
                </div>
            </div>`;
            };

            const createRule = (stream) => (id, html) => {
                const parsed = parseRuleSublist(html);
                if (!parsed) {
                    const numLabel = stream.next();
                    return renderWebRuleLine(id, html, "", numLabel);
                }

                const title = extractRuleTitle(parsed.intro);
                let out = "";
                if (parsed.intro) {
                    out += `<div class="rule-intro" data-rule-group="${id}">${parsed.intro}</div>`;
                }
                parsed.bullets.forEach((bullet, index) => {
                    const subId = `${id}-${index + 1}`;
                    const numLabel = stream.next();
                    out += renderWebRuleLine(subId, bullet, id, numLabel, title);
                });
                return out;
            };

            bodyContent = `
          <style>
              .intro-text { background: rgba(var(--lp-blue-rgb), 0.07); border: 1px solid rgba(var(--lp-blue-rgb), 0.35); padding: 25px; border-radius: 10px; margin-bottom: 25px; font-size: 14px; line-height: 1.6; color: #fff; text-align: center; }
              
              .search-wrapper { position: sticky; top: 10px; z-index: 100; margin-bottom: 30px; }
              
              .search-container {
                position: relative;
                width: 100%;
                background: rgba(0, 0, 0, 0.85); 
                border: 1px solid rgba(var(--lp-blue-rgb), 0.35); 
                border-radius: 8px;
                backdrop-filter: blur(10px);
                box-shadow: 0 4px 30px rgba(0, 0, 0, 0.4);
                display: flex;
                align-items: center;
              }

              #search { 
                  width: 100%;
                  padding: 18px 18px 18px 45px; 
                  background: transparent; 
                  border: none;
                  color: #fff; 
                  font-family: inherit; outline: none; box-sizing: border-box; 
                  font-weight: 600;
                  caret-color: transparent; 
              }

              .custom-cursor {
                position: absolute;
                left: 18px;
                color: var(--lp-blue);
                font-weight: 900;
                font-size: 18px;
                pointer-events: none;
                animation: blink 1s step-end infinite;
              }

              @keyframes blink {
                0%, 100% { opacity: 1; }
                50% { opacity: 0; }
              }

              #search::placeholder {
                color: rgba(255,255,255,0.4);
                transition: 0.2s;
              }

              #search:focus::placeholder {
                opacity: 0;
              }

              mark.search-highlight { 
                  background: var(--lp-blue); color: #fff; 
                  border-radius: 3px; 
                  padding: 1px 3px; 
                  box-shadow: 0 0 8px rgba(var(--lp-blue-rgb), 0.25);
              }

              .category {
                  margin-bottom: 10px;
                  border: 1px solid var(--border);
                  border-radius: 10px;
                  background: var(--surface);
                  overflow: hidden;
                  transition: 0.3s;
              }
              .cat-btn {
                  width: 100%;
                  padding: 18px 25px;
                  background: transparent;
                  border: none;
                  color: #fff;
                  text-align: left;
                  font-family: 'Montserrat', sans-serif;
                  font-size: 16px;
                  font-weight: 700;
                  cursor: pointer;
                  display: flex;
                  align-items: center;
                  text-transform: uppercase;
                  gap: 20px;
              }
              .cat-btn .btn-label, .sub-btn .btn-label { flex: 1; min-width: 0; }
              .sub-cat {
                  margin: 10px 20px;
                  border: 1px solid var(--border);
                  border-radius: 8px;
                  background: var(--surface-inset);
                  overflow: hidden;
              }
              .sub-btn {
                  width: 100%;
                  padding: 12px 20px;
                  background: var(--card-header);
                  border: none;
                  color: #fff;
                  text-align: left;
                  font-weight: 600;
                  cursor: pointer;
                  display: flex;
                  align-items: center;
                  font-size: 14px;
              }
              .icon-box { width: 35px; height: 35px; background: rgba(var(--lp-blue-rgb),0.12); border-radius: 6px; display: flex; align-items: center; justify-content: center; color: var(--lp-blue); font-size: 18px; flex-shrink: 0; }
              .chevron { margin-left: auto; color: var(--text-dim); transition: transform 0.45s cubic-bezier(0.4, 0, 0.2, 1), color 0.35s ease; }
              .active > .chevron { transform: rotate(180deg); color: var(--lp-blue); }
              
              .content-wrapper {
                  display: grid;
                  grid-template-rows: 0fr;
                  transition: grid-template-rows 0.5s cubic-bezier(0.4, 0, 0.2, 1);
                  overflow: hidden;
              }
              #rules-root .content-wrapper:not(.open):not(.search-open) {
                  grid-template-rows: 0fr !important;
                  border-top: none !important;
              }
              .content-wrapper.open { grid-template-rows: 1fr; border-top: 1px solid var(--border); background: var(--surface-inset); }
              .content { min-height: 0; overflow: hidden; }
              .content-inner {
                  padding: 20px 25px 24px;
                  opacity: 1;
                  background: var(--surface-inset);
                  transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1);
              }
              .content-wrapper:not(.open):not(.search-open) > .content > .content-inner {
                  opacity: 0;
              }
              .sub-cat .content-inner {
                  padding: 16px 20px 18px;
              }
              
              .rule-line { 
                  margin-bottom: 10px; font-size: 14px; border-left: 2px solid var(--lp-blue); 
                  padding: 8px 15px; color: #fff; display: flex; justify-content: space-between; 
                  align-items: flex-start; gap: 12px;
                  border-radius: 0 4px 4px 0;
              }
              .rule-intro {
                  margin-bottom: 4px;
                  font-size: 14px;
                  padding: 6px 15px 2px 15px;
                  color: #fff;
              }
              .rule-intro b { color: var(--lp-blue); }
              .rule-line:hover { background: rgba(255,255,255,0.02); }
              .rule-line:target { background: rgba(var(--lp-blue-rgb), 0.15); border-left: 4px solid var(--lp-blue); }
              .rule-num {
                  flex-shrink: 0;
                  min-width: 4.25rem;
                  color: #6b8499;
                  font-weight: 600;
                  font-size: 11px;
                  font-variant-numeric: tabular-nums;
                  letter-spacing: 0.03em;
                  line-height: 1.5;
              }
              .rule-text { flex: 1; padding-right: 20px; min-width: 0; line-height: 1.5; }
              .rule-actions { display: flex; gap: 8px; opacity: 0.4; flex-shrink: 0; align-self: flex-start; margin-top: 1px; transition: opacity 0.3s; }
              .rule-line:hover .rule-actions { opacity: 1; }
              @media (max-width: 650px) {
                  .cat-btn { padding: 15px 16px; font-size: 14px; gap: 12px; }
                  .icon-box { width: 30px; height: 30px; font-size: 15px; }
                  .sub-cat { margin: 8px 10px; }
                  .sub-btn { padding: 12px 14px; font-size: 13px; }
                  .content-inner { padding: 14px 12px 16px; }
                  .sub-cat .content-inner { padding: 12px 10px 14px; }
                  .rule-line { flex-wrap: wrap; padding: 8px 10px; gap: 8px; }
                  .rule-num { min-width: auto; }
                  .rule-text { padding-right: 0; flex-basis: 100%; }
                  .rule-actions { opacity: 0.8; margin-left: auto; }
              }
              .action-btn { 
                  background: transparent; border: 1px solid var(--border); color: var(--text-dim); 
                  cursor: pointer; padding: 6px; border-radius: 4px; font-size: 12px; transition: 0.2s;
                  position: relative;
              }
              .action-btn:hover { border-color: var(--lp-blue); color: #fff; background: var(--lp-blue); }
              
              /* Tooltip */
              .action-btn::after {
                  content: attr(data-tooltip);
                  position: absolute;
                  bottom: 125%;
                  left: 50%;
                  transform: translateX(-50%);
                  background: var(--lp-blue);
                  color: #fff;
                  padding: 5px 10px;
                  border-radius: 4px;
                  font-size: 10px;
                  font-weight: bold;
                  text-transform: uppercase;
                  white-space: nowrap;
                  opacity: 0;
                  visibility: hidden;
                  transition: 0.2s;
                  z-index: 1000;
                  pointer-events: none;
                  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
              }
              .action-btn:hover::after {
                  opacity: 1;
                  visibility: visible;
              }

              .rule-line b { color: var(--lp-blue); }
              .rule-text > b + b { display: block; margin-top: 12px; }
              .rule-text ul.rule-sublist { margin: 6px 0 0 0; padding-left: 20px; list-style: disc; }
              .rule-text b + ul.rule-sublist { margin-top: 2px; }
              .rule-text ul.rule-sublist li { margin-bottom: 6px; line-height: 1.5; }
              .sub-title { color: var(--lp-blue); font-weight: 800; text-transform: uppercase; margin: 15px 0 10px 0; font-size: 12px; letter-spacing: 1px; }
              .sub-title-emoji { margin-right: 0.35em; text-decoration: none; }
              .sub-title--underline { text-decoration: underline; }
              .important { color: #ff4d4d; font-weight: bold; margin-top: 15px; display: block;}
              .guide-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 10px; }
              .guide-item { background: var(--card-header); padding: 5px 10px; border-radius: 4px; font-size: 12px; display: flex; justify-content: space-between; }
              
              .searching .category.search-match, .searching .sub-cat.search-match { animation: slideUpFade 0.3s ease forwards; }
              #rules-root.search-mode .category:not(.search-match),
              #rules-root.search-mode .sub-cat:not(.search-match) {
                  display: none !important;
              }
              #rules-root.search-mode .content-wrapper {
                  grid-template-rows: 0fr !important;
                  border-top: none !important;
              }
              #rules-root.search-mode .category.search-match > .content-wrapper.search-open,
              #rules-root.search-mode .sub-cat.search-match > .content-wrapper.search-open {
                  grid-template-rows: 1fr !important;
              }
              #rules-root.search-mode .category.search-match > .content-wrapper.search-open {
                  border-top: 1px solid var(--border);
              }
              #rules-root.search-mode .rule-line:not(.search-match),
              #rules-root.search-mode .rule-intro:not(.search-match) {
                  display: none !important;
              }
              #rules-root.search-mode .sub-title:not(.search-match),
              #rules-root.search-mode .guide-grid:not(.search-match),
              #rules-root.search-mode .guide-item:not(.search-match) {
                  display: none !important;
              }
              #rules-root.search-mode .content-wrapper:not(.search-open) > .content > .content-inner {
                  opacity: 0;
              }
              #rules-root.search-mode .content-wrapper.search-open > .content > .content-inner {
                  opacity: 1;
              }
              @keyframes slideUpFade { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

              body.sbox-rules .container { padding: 16px 18px 24px; animation: none !important; opacity: 1 !important; transform: none !important; }
              body.sbox-rules header { margin-bottom: 8px !important; padding-bottom: 0; }
              body.sbox-rules .logo { width: 96px; margin-bottom: 10px; animation: none !important; }
              body.sbox-rules, body.sbox-rules .cat-btn { font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
              body.sbox-rules h1 { font-size: 36px; letter-spacing: -1.5px; font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; font-weight: 800; }
              body.sbox-rules .sub-h { font-size: 12px; letter-spacing: 1.5px; margin-bottom: 10px; }
              body.sbox-rules .intro-text { padding: 14px 18px; margin-bottom: 14px; font-size: 13px; line-height: 1.5; }
              body.sbox-rules .search-wrapper { margin-bottom: 16px; }
              body.sbox-rules #search { padding: 12px 12px 12px 40px; font-size: 14px; }
              body.sbox-rules .custom-cursor { left: 16px; font-size: 16px; }
              body.sbox-rules .cat-btn { padding: 14px 20px; font-size: 15px; gap: 16px; }
              body.sbox-rules .icon-box { width: 34px; height: 34px; font-size: 16px; }
              body.sbox-rules .category { margin-bottom: 9px; }
              body.sbox-rules .sbox-tab-banner {
                  margin-bottom: 14px;
                  padding: 0;
                  color: rgba(255, 255, 255, 0.85);
                  font-size: 13px;
                  font-weight: 600;
                  line-height: 1.5;
                  text-align: center;
              }
              body.sbox-rules .sbox-tab-banner strong { color: var(--lp-blue); }
          </style>

          ${isSbox ? `
          <div class="sbox-tab-banner" role="note">
              To leave this screen, click a <strong>different tab</strong> on the <strong>left vertical menu</strong>, and then press <strong>Tab</strong>.
          </div>
          ` : ""}

          <div class="intro-text">
              Below you will find our official rules and guidelines. Please read them carefully to ensure a fair and fun environment for everyone. Click the icons next to a rule to share it.
          </div>

          <div class="search-wrapper">
              <div class="search-container">
                  <div class="custom-cursor">></div>
                  <input type="text" id="search" placeholder="SEARCH RULES..."${isSbox ? ' autocomplete="off"' : ""}>
              </div>
          </div>

          <div id="rules-root">
              ${renderWebRulesRoot(createRule)}
          </div>
          <!-- rules-ui-build: collapsed-by-default-v3 -->

          <script>
              const rulesRoot = document.getElementById('rules-root');
              const searchInput = document.getElementById('search');
              const isSboxRulesPage = document.body.classList.contains("sbox-rules");
              var sboxPasteWaiters = [];

              if (isSboxRulesPage) {
                  window.addEventListener("message", function (e) {
                      if (!e.data || e.data.type !== "lifepunch:clipboard-read-result") return;
                      var text = e.data.text == null ? "" : String(e.data.text);
                      while (sboxPasteWaiters.length) {
                          sboxPasteWaiters.shift()(text);
                      }
                  });
              }

              function notifySboxClipboardWrite(text) {
                  var payload = { type: "lifepunch:clipboard-write", text: String(text) };
                  try {
                      if (window.top && window.top !== window) window.top.postMessage(payload, "*");
                      if (window.parent && window.parent !== window) window.parent.postMessage(payload, "*");
                  } catch (err) {}
              }

              function requestSboxClipboardRead() {
                  return new Promise(function (resolve, reject) {
                      var done = false;
                      var timer = setTimeout(function () {
                          if (done) return;
                          done = true;
                          reject(new Error("Clipboard read timeout"));
                      }, 300);
                      sboxPasteWaiters.push(function (text) {
                          if (done) return;
                          done = true;
                          clearTimeout(timer);
                          resolve(text);
                      });
                      try {
                          var payload = { type: "lifepunch:clipboard-read" };
                          if (window.top && window.top !== window) window.top.postMessage(payload, "*");
                          if (window.parent && window.parent !== window) window.parent.postMessage(payload, "*");
                      } catch (err) {
                          clearTimeout(timer);
                          reject(err);
                      }
                  });
              }

              function insertTextAtCursor(input, text) {
                  if (!input || text == null) return;
                  var start = input.selectionStart == null ? input.value.length : input.selectionStart;
                  var end = input.selectionEnd == null ? input.value.length : input.selectionEnd;
                  input.value = input.value.slice(0, start) + text + input.value.slice(end);
                  var pos = start + text.length;
                  input.setSelectionRange(pos, pos);
                  input.dispatchEvent(new Event("input", { bubbles: true }));
              }

              function readTextFromClipboard() {
                  if (navigator.clipboard && typeof navigator.clipboard.readText === "function") {
                      return navigator.clipboard.readText().catch(function () {
                          if (isSboxRulesPage) return requestSboxClipboardRead();
                          throw new Error("Clipboard read failed");
                      });
                  }
                  if (isSboxRulesPage) return requestSboxClipboardRead();
                  return Promise.reject(new Error("Clipboard read unavailable"));
              }

              (function collapseRulesAccordionsImmediately() {
                  if (!rulesRoot) return;
                  rulesRoot.querySelectorAll(".category[data-default-open]").forEach((cat) => {
                      cat.removeAttribute("data-default-open");
                  });
                  rulesRoot.querySelectorAll(".cat-btn, .sub-btn").forEach((btn) => btn.classList.remove("active"));
                  rulesRoot.querySelectorAll(".content-wrapper").forEach((wrapper) => {
                      wrapper.classList.remove("open", "search-open");
                  });
              })();

              function legacyCopyToClipboard(text) {
                  return new Promise(function (resolve, reject) {
                      var ta = document.createElement("textarea");
                      ta.value = text;
                      ta.setAttribute("readonly", "");
                      ta.style.cssText = isSboxRulesPage
                          ? "position:fixed;top:50%;left:50%;width:2px;height:2px;opacity:0.01;z-index:9999;"
                          : "position:fixed;left:-9999px;top:0;opacity:0";
                      document.body.appendChild(ta);
                      ta.focus({ preventScroll: true });
                      ta.select();
                      ta.setSelectionRange(0, text.length);
                      var ok = false;
                      try { ok = document.execCommand("copy"); } catch (e) { ok = false; }
                      document.body.removeChild(ta);
                      if (ok) resolve();
                      else reject(new Error("Copy failed"));
                  });
              }

              function copyTextToClipboard(text) {
                  if (text == null || text === "") return Promise.reject(new Error("Nothing to copy"));
                  var chain = legacyCopyToClipboard(text);
                  if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {
                      chain = chain.catch(function () {
                          return navigator.clipboard.writeText(text);
                      });
                  }
                  return chain.then(function () {
                      if (isSboxRulesPage) notifySboxClipboardWrite(text);
                  });
              }

              function buildRuleCopyText(el) {
                  if (!el) return "";
                  var numEl = el.querySelector(".rule-num");
                  var bodyEl = el.querySelector(".rule-text");
                  var num = numEl ? numEl.textContent.trim() : "";
                  var body = bodyEl ? bodyEl.innerText.trim() : "";
                  var prefix = el.getAttribute("data-copy-prefix") || "";
                  if (num && prefix && body) return num + " — " + prefix + " — " + body;
                  if (num && body) return num + " — " + body;
                  if (prefix && body) return prefix + " — " + body;
                  return body;
              }

              function copyRuleText(id) {
                  var el = document.getElementById(id);
                  if (!el) return;
                  var text = buildRuleCopyText(el);
                  copyTextToClipboard(text).then(function () {
                      showFeedback(id, "fa-check");
                  }).catch(function () {
                      showFeedback(id, "fa-triangle-exclamation");
                  });
              }

              function shareRuleLink(id) {
                  var url = "https://lifepunch.co/rules#" + id;
                  copyTextToClipboard(url).then(function () {
                      showFeedback(id, "fa-link");
                  }).catch(function () {
                      showFeedback(id, "fa-triangle-exclamation");
                  });
              }

              function showFeedback(id, iconClass) {
                  var el = document.getElementById(id);
                  if (!el) return;
                  var btn = el.querySelector(".rule-copy-btn") || el.querySelector(".action-btn");
                  if (!btn) return;
                  var originalIcon = btn.innerHTML;
                  btn.innerHTML = '<i class="fa-solid ' + iconClass + '"></i>';
                  btn.style.color = "var(--lp-blue)";
                  setTimeout(function () { 
                      btn.innerHTML = originalIcon; 
                      btn.style.color = "";
                  }, 1500);
              }

              document.getElementById("rules-root").addEventListener("click", function (e) {
                  var copyBtn = e.target.closest(".rule-copy-btn");
                  if (copyBtn) {
                      e.preventDefault();
                      copyRuleText(copyBtn.getAttribute("data-rule-id"));
                      return;
                  }
                  var shareBtn = e.target.closest(".rule-share-btn");
                  if (shareBtn) {
                      e.preventDefault();
                      shareRuleLink(shareBtn.getAttribute("data-rule-id"));
                  }
              });

              function openRulesHashTarget() {
                  if (!window.location.hash) return;
                  const id = window.location.hash.substring(1);
                  if (!id) return;
                  const target = document.getElementById(id);
                  if (!target) return;
                  let parent = target.parentElement;
                  while (parent && parent !== document.body) {
                      if (parent.classList.contains('content-wrapper')) {
                          parent.classList.add('open');
                          const btn = parent.previousElementSibling;
                          if (btn) btn.classList.add('active');
                      }
                      parent = parent.parentElement;
                  }
                  setTimeout(() => target.scrollIntoView({ behavior: 'smooth', block: 'center' }), 500);
              }

              function initRulesPageState() {
                  if (!rulesRoot) return;
                  if (searchInput) searchInput.value = "";
                  clearSearchState();
                  resetAllAccordionState(rulesRoot);
                  openRulesHashTarget();
              }

              window.addEventListener('load', initRulesPageState);
              window.addEventListener('pageshow', initRulesPageState);

              if (isSboxRulesPage && searchInput) {
                  var searchOpenedByPointer = false;
                  searchInput.addEventListener("pointerdown", function () {
                      searchOpenedByPointer = true;
                  });
                  searchInput.addEventListener("focus", function () {
                      if (!searchOpenedByPointer) {
                          searchInput.blur();
                      }
                      searchOpenedByPointer = false;
                  });
                  searchInput.addEventListener("keydown", function (e) {
                      if (!e.ctrlKey && !e.metaKey) return;
                      var key = e.key.toLowerCase();
                      if (key === "c" || key === "x") {
                          var start = searchInput.selectionStart;
                          var end = searchInput.selectionEnd;
                          if (start == null || end == null || start === end) return;
                          var selected = searchInput.value.slice(start, end);
                          copyTextToClipboard(selected).catch(function () {});
                          if (key === "x") {
                              e.preventDefault();
                              searchInput.value = searchInput.value.slice(0, start) + searchInput.value.slice(end);
                              searchInput.setSelectionRange(start, start);
                              searchInput.dispatchEvent(new Event("input", { bubbles: true }));
                          }
                          return;
                      }
                      if (key === "v") {
                          e.preventDefault();
                          readTextFromClipboard().then(function (clip) {
                              insertTextAtCursor(searchInput, clip);
                          }).catch(function () {});
                      }
                  });
              }

              document.querySelectorAll('.cat-btn, .sub-btn').forEach(btn => {
                  btn.addEventListener('click', function(e) {
                      e.stopPropagation();
                      const wrapper = this.nextElementSibling;
                      if (rulesRoot && rulesRoot.classList.contains('search-mode')) {
                          this.classList.toggle('active');
                          wrapper.classList.toggle('search-open');
                          return;
                      }
                      this.classList.toggle('active');
                      wrapper.classList.toggle('open');
                  });
              });

              function removeHighlights(root) {
                  const marks = root.querySelectorAll('mark.search-highlight');
                  marks.forEach(mark => {
                      const parent = mark.parentNode;
                      parent.replaceChild(document.createTextNode(mark.textContent), mark);
                      parent.normalize();
                  });
              }

              function getSectionToggle(sectionEl) {
                  if (!sectionEl) return null;
                  for (const child of sectionEl.children) {
                      if (!child.classList.contains("cat-btn") && !child.classList.contains("sub-btn")) continue;
                      const wrapper = child.nextElementSibling;
                      if (wrapper && wrapper.classList.contains("content-wrapper")) {
                          return { btn: child, wrapper: wrapper };
                      }
                  }
                  return null;
              }

              function setAccordionOpen(sectionEl, open) {
                  const toggle = getSectionToggle(sectionEl);
                  if (!toggle) return;
                  toggle.btn.classList.toggle("active", open);
                  toggle.wrapper.classList.toggle("open", open);
              }

              function resetAllAccordionState(root) {
                  root.querySelectorAll(".cat-btn, .sub-btn").forEach((btn) => btn.classList.remove("active"));
                  root.querySelectorAll(".content-wrapper").forEach((wrapper) => {
                      wrapper.classList.remove("open", "search-open");
                  });
              }

              function setSearchAccordionOpen(sectionEl, open) {
                  const toggle = getSectionToggle(sectionEl);
                  if (!toggle) return;
                  toggle.btn.classList.toggle("active", open);
                  toggle.wrapper.classList.toggle("search-open", open);
              }

              function applyHighlights(root, term) {
                  if (!term || !root) return;
                  const safeTerm = term.replace(/[.*+?^\${}()|[\\]\\\\]/g, '\\\\$&');
                  const regex = new RegExp("(" + safeTerm + ")", "gi");
                  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
                  const textNodes = [];
                  let node;
                  
                  while ((node = walker.nextNode())) {
                      if (['SCRIPT', 'STYLE', 'MARK'].includes(node.parentNode.tagName)) continue;
                      if (node.parentElement && node.parentElement.closest(".cat-btn, .sub-btn")) continue;
                      if (node.nodeValue.trim() !== '') {
                          textNodes.push(node);
                      }
                  }
                  textNodes.forEach(textNode => {
                      const text = textNode.nodeValue;
                      if (regex.test(text)) {
                          const fragment = document.createDocumentFragment();
                          let lastIndex = 0;
                          
                          text.replace(regex, (match, p1, offset) => {
                              fragment.appendChild(document.createTextNode(text.slice(lastIndex, offset)));
                              const mark = document.createElement('mark');
                              mark.className = 'search-highlight';
                              mark.textContent = match;
                              fragment.appendChild(mark);
                              lastIndex = offset + match.length;
                          });
                          
                          fragment.appendChild(document.createTextNode(text.slice(lastIndex)));
                          const parent = textNode.parentNode;
                          parent.replaceChild(fragment, textNode);
                      }
                  });
              }

              function applyHighlightsToMatches(term) {
                  rulesRoot.querySelectorAll(".rule-line.search-match .rule-text, .rule-line.search-match .rule-num, .rule-intro.search-match").forEach((el) => {
                      applyHighlights(el, term);
                  });
              }

              function normalizeSearchDashes(value) {
                  // Em/en dashes and spaced " - " only — not hyphens in words like "english-speaking".
                  value = value.replace(/ *[–—] */g, " — ");
                  value = value.replace(/ - /g, " — ");
                  return value;
              }

              function normalizeSearchTerm(term) {
                  let value = String(term || "").toLowerCase();
                  while (value.endsWith(".")) value = value.slice(0, -1);
                  value = normalizeSearchDashes(value);
                  value = value.replace(/ +/g, " ").trim();
                  return value;
              }

              function getIntroSearchText(intro) {
                  return intro.textContent.trim().toLowerCase();
              }

              function ruleIntroMatchesTerm(intro, term) {
                  if (!term) return false;
                  const normalizedTerm = normalizeSearchTerm(term);
                  if (!normalizedTerm) return false;
                  return getIntroSearchText(intro).indexOf(normalizedTerm) !== -1;
              }
                  
              function getRuleLineNumber(line) {
                  const numEl = line.querySelector(".rule-num");
                  return numEl ? numEl.textContent.trim().toLowerCase() : "";
              }

              function getRuleLineSearchText(line) {
                  let value = buildRuleCopyText(line).toLowerCase();
                  value = normalizeSearchDashes(value);
                  value = value.replace(/ +/g, " ").trim();
                  return value;
              }

              function isRuleNumberSearch(term) {
                  const value = normalizeSearchTerm(term);
                  if (!value) return false;
                  var parts = value.split(".");
                  if (parts.length < 2) return false;
                  for (var i = 0; i < parts.length; i++) {
                      if (!/^[0-9]+$/.test(parts[i])) return false;
                  }
                  return true;
              }

              function isDigitsOnlySearch(term) {
                  const value = normalizeSearchTerm(term);
                  return !!value && /^[0-9]+$/.test(value);
              }

              function getMinSearchLength(term) {
                  const normalizedTerm = normalizeSearchTerm(term);
                  if (!normalizedTerm) return 3;
                  if (isRuleNumberSearch(normalizedTerm) || isDigitsOnlySearch(normalizedTerm)) return 1;
                  return 3;
              }

              function ruleNumberMatchesDigitsOnly(num, term) {
                  if (!num || !term) return false;
                  if (num === term) return true;
                  if (num.indexOf(term + ".") === 0) return true;
                  if (term.length >= 2) {
                      return num.split(".").some((segment) => segment === term);
                  }
                  return false;
              }

              function categoryNumberMatchesTerm(sectionEl, term) {
                  if (!term || term.length !== 1 || !/^[0-9]$/.test(term)) return false;
                  const toggle = getSectionToggle(sectionEl);
                  if (!toggle || !toggle.btn) return false;
                  const text = toggle.btn.textContent.trim();
                  const match = text.match(/^([0-9]+)[.]/);
                  return !!(match && match[1] === term);
              }

              function ruleNumberMatchesLine(line, term) {
                  const num = getRuleLineNumber(line);
                  if (!num) return false;
                  return num === term || num.indexOf(term + ".") === 0;
              }

              function ruleLineMatchesTerm(line, term) {
                  if (!term) return false;
                  const normalizedTerm = normalizeSearchTerm(term);
                  if (!normalizedTerm) return false;
                  if (isRuleNumberSearch(normalizedTerm)) {
                      return ruleNumberMatchesLine(line, normalizedTerm);
                  }
                  const num = getRuleLineNumber(line);
                  const ruleTxtEl = line.querySelector(".rule-text");
                  const body = (ruleTxtEl ? ruleTxtEl.textContent : "").trim().toLowerCase();
                  if (isDigitsOnlySearch(normalizedTerm)) {
                      if (ruleNumberMatchesDigitsOnly(num, normalizedTerm)) return true;
                      if (normalizedTerm.length >= 2 && body.indexOf(normalizedTerm) !== -1) return true;
                      return false;
                  }
                  return getRuleLineSearchText(line).indexOf(normalizedTerm) !== -1;
              }

              function getSectionButtonText(sectionEl) {
                  const toggle = getSectionToggle(sectionEl);
                  if (!toggle || !toggle.btn) return "";
                  return toggle.btn.textContent.trim().toLowerCase();
              }

              function sectionLabelMatchesTerm(sectionEl, term) {
                  if (!term) return false;
                  const normalizedTerm = normalizeSearchTerm(term);
                  if (!normalizedTerm || isRuleNumberSearch(normalizedTerm) || isDigitsOnlySearch(normalizedTerm)) return false;
                  return getSectionButtonText(sectionEl).indexOf(normalizedTerm) !== -1;
              }

              function elementTextMatchesTerm(el, term) {
                  if (!term || !el) return false;
                  const normalizedTerm = normalizeSearchTerm(term);
                  if (!normalizedTerm || isRuleNumberSearch(normalizedTerm) || isDigitsOnlySearch(normalizedTerm)) return false;
                  return el.textContent.trim().toLowerCase().indexOf(normalizedTerm) !== -1;
              }

              function syncGuideHeaderForGrid(grid) {
                  if (!grid || !grid.classList.contains("guide-grid")) return;
                  const title = grid.previousElementSibling;
                  if (title && title.classList.contains("sub-title")) {
                      title.classList.add("search-match");
                  }
              }

              function trackSectionParents(el, visibleCats, visibleSubs) {
                  const sub = el.closest('.sub-cat');
                  if (sub) {
                      visibleSubs.add(sub);
                      const cat = sub.closest('.category');
                      if (cat) visibleCats.add(cat);
                  } else {
                      const cat = el.closest('.category');
                      if (cat) visibleCats.add(cat);
                  }
              }

              function trackSectionLabel(sectionEl, visibleCats, visibleSubs) {
                  if (sectionEl.classList.contains('sub-cat')) {
                      visibleSubs.add(sectionEl);
                      const cat = sectionEl.closest('.category');
                      if (cat) visibleCats.add(cat);
                  } else if (sectionEl.classList.contains('category')) {
                      visibleCats.add(sectionEl);
                  }
              }

              function clearSearchState() {
                  if (!rulesRoot) return;
                  rulesRoot.classList.remove('searching');
                  rulesRoot.classList.remove('search-mode');
                  removeHighlights(rulesRoot);
                  rulesRoot.querySelectorAll('.category, .sub-cat').forEach((section) => {
                      section.classList.remove('search-match');
                      section.style.removeProperty('display');
                  });
                  rulesRoot.querySelectorAll('.rule-line').forEach((line) => {
                      line.classList.remove('search-match');
                      line.style.removeProperty('display');
                  });
                  rulesRoot.querySelectorAll('.rule-intro').forEach((intro) => {
                      intro.classList.remove('search-match');
                      intro.style.removeProperty('display');
                  });
                  rulesRoot.querySelectorAll('.sub-title, .guide-grid, .guide-item').forEach((el) => {
                      el.classList.remove('search-match');
                      el.style.removeProperty('display');
                  });
                  rulesRoot.querySelectorAll('.content-wrapper').forEach((wrapper) => {
                      wrapper.classList.remove('search-open');
                  });
              }

              function resetSearchUiToDefault() {
                  clearSearchState();
                  resetAllAccordionState(rulesRoot);
              }

              let debounceTimer;

              if (rulesRoot && searchInput) searchInput.addEventListener('input', function(e) {
                  const term = e.target.value.trim().toLowerCase();
                  
                  clearTimeout(debounceTimer);
                  debounceTimer = setTimeout(() => {
                      if (term.length < getMinSearchLength(term)) {
                          resetSearchUiToDefault();
                          return;
                      }

                      clearSearchState();
                      resetAllAccordionState(rulesRoot);
                      rulesRoot.classList.add('searching');
                      rulesRoot.classList.add('search-mode');

                      const visibleCats = new Set();
                      const visibleSubs = new Set();
                      let firstMatch = null;

                      rulesRoot.querySelectorAll('.rule-line').forEach((line) => {
                          line.classList.remove('search-match');
                      });
                      rulesRoot.querySelectorAll('.rule-intro').forEach((intro) => {
                          intro.classList.remove('search-match');
                      });
                      rulesRoot.querySelectorAll('.category, .sub-cat').forEach((section) => {
                          section.classList.remove('search-match');
                      });
                      rulesRoot.querySelectorAll('.sub-title, .guide-grid, .guide-item').forEach((el) => {
                          el.classList.remove('search-match');
                      });

                      const introTitleMatchGroups = new Set();

                      rulesRoot.querySelectorAll('.rule-intro[data-rule-group]').forEach((intro) => {
                          if (!ruleIntroMatchesTerm(intro, term)) return;
                          intro.classList.add('search-match');
                          introTitleMatchGroups.add(intro.dataset.ruleGroup);
                          if (!firstMatch) firstMatch = intro;
                          trackSectionParents(intro, visibleCats, visibleSubs);
                      });

                      rulesRoot.querySelectorAll('.rule-line').forEach((line) => {
                          if (!ruleLineMatchesTerm(line, term)) return;
                          line.classList.add('search-match');
                          if (!firstMatch) firstMatch = line;
                          trackSectionParents(line, visibleCats, visibleSubs);
                      });

                      rulesRoot.querySelectorAll('.rule-intro[data-rule-group]').forEach((intro) => {
                          if (intro.classList.contains('search-match')) return;
                          const group = intro.dataset.ruleGroup;
                          const hasVisible = Array.from(
                              rulesRoot.querySelectorAll('.rule-line[data-rule-group="' + group + '"]')
                          ).some((line) => line.classList.contains('search-match'));
                          if (!hasVisible) return;
                          intro.classList.add('search-match');
                          if (!firstMatch) firstMatch = intro;
                          trackSectionParents(intro, visibleCats, visibleSubs);
                      });

                      introTitleMatchGroups.forEach((group) => {
                          rulesRoot.querySelectorAll('.rule-line[data-rule-group="' + group + '"]').forEach((line) => {
                              if (line.classList.contains('search-match')) return;
                              line.classList.add('search-match');
                              trackSectionParents(line, visibleCats, visibleSubs);
                          });
                      });

                      rulesRoot.querySelectorAll('.sub-cat').forEach((sub) => {
                          if (!sectionLabelMatchesTerm(sub, term)) return;
                          trackSectionLabel(sub, visibleCats, visibleSubs);
                      });
                      rulesRoot.querySelectorAll('.category').forEach((cat) => {
                          if (!sectionLabelMatchesTerm(cat, term)) return;
                          trackSectionLabel(cat, visibleCats, visibleSubs);
                      });

                      const normalizedSearchTerm = normalizeSearchTerm(term);
                      if (isDigitsOnlySearch(normalizedSearchTerm) && normalizedSearchTerm.length === 1) {
                          rulesRoot.querySelectorAll('.category').forEach((cat) => {
                              if (!categoryNumberMatchesTerm(cat, normalizedSearchTerm)) return;
                              trackSectionLabel(cat, visibleCats, visibleSubs);
                          });
                      }

                      rulesRoot.querySelectorAll('.guide-item').forEach((item) => {
                          if (!elementTextMatchesTerm(item, term)) return;
                          item.classList.add('search-match');
                          const grid = item.closest('.guide-grid');
                          if (grid) {
                              grid.classList.add('search-match');
                              syncGuideHeaderForGrid(grid);
                          }
                          if (!firstMatch) firstMatch = item;
                          trackSectionParents(item, visibleCats, visibleSubs);
                      });

                      rulesRoot.querySelectorAll('.sub-title').forEach((title) => {
                          if (!elementTextMatchesTerm(title, term)) return;
                          title.classList.add('search-match');
                          const next = title.nextElementSibling;
                          if (next && next.classList.contains('guide-grid')) {
                              next.classList.add('search-match');
                              next.querySelectorAll('.guide-item').forEach((item) => {
                                  item.classList.add('search-match');
                              });
                          }
                          if (!firstMatch) firstMatch = title;
                          trackSectionParents(title, visibleCats, visibleSubs);
                      });

                      visibleSubs.forEach((sub) => {
                          sub.classList.add('search-match');
                          setSearchAccordionOpen(sub, true);
                      });
                      visibleCats.forEach((cat) => {
                          cat.classList.add('search-match');
                          setSearchAccordionOpen(cat, true);
                      });

                      applyHighlightsToMatches(term);

                      if (firstMatch) {
                          setTimeout(() => {
                              firstMatch.scrollIntoView({ behavior: 'smooth', block: 'center' });
                          }, 150);
                      }
                  }, 60);
              });
          </script>
        `;
        } else if (path === "/rewards") {
            pageTitle = "LifePunch | Rewards";
            subHeaderTitle = "UNLOCK BONUSES";

            let drDiscordLinked = false;
            let drRewardClaimed = false;
            let drWeekendClaimed = false;
            let drGiveawayEntered = false;
            let entryCount = 0;
            let entriesWithData = [];

            const monthKey = new Date().toISOString().slice(0, 7);

            // Eastern Time Check (Friday 6 PM - Sunday Midnight)
            const getET = (d) => new Date(d.toLocaleString("en-US", {timeZone: "America/New_York"}));
            const nowET = getET(new Date());
            const dayET = nowET.getDay(); // 0=Sun, 5=Fri, 6=Sat
            const hourET = nowET.getHours();

            let isWeekend = false;
            if (dayET === 5 && hourET >= 18) isWeekend = true; // Fri 6pm+
            if (dayET === 6 || dayET === 0) isWeekend = true; // Sat/Sun

            // Calculate Friday ID for the weekend
            let friDate = new Date(nowET);
            if (dayET === 0) friDate.setDate(nowET.getDate() - 2);
            else if (dayET === 6) friDate.setDate(nowET.getDate() - 1);
            else if (dayET === 5 && hourET >= 18) friDate.setDate(nowET.getDate());
            else {
                // Not in a weekend window yet, but we'll find the *upcoming* Friday for the ID
                let daysToFri = (5 - dayET + 7) % 7;
                if (daysToFri === 0 && hourET >= 18) daysToFri = 7; 
                friDate.setDate(nowET.getDate() + daysToFri);
            }
            const weekendId = friDate.toISOString().split('T')[0];

            // Calculate Next Start for Countdown (Friday 18:00 ET)
            let nextStart = new Date(nowET);
            let daysToNextFri = (5 - dayET + 7) % 7;
            if (daysToNextFri === 0 && hourET >= 18) daysToNextFri = 7;
            nextStart.setDate(nowET.getDate() + daysToNextFri);
            nextStart.setHours(18, 0, 0, 0);
            const nextStartTs = nextStart.getTime();

            if (steamid && linksKv) {
                const linkRow = await linksKv.get(`link:steam:${steamid}`);
                if (linkRow) {
                    try {
                        const o = JSON.parse(linkRow);
                        if (o?.id) drDiscordLinked = true;
                    } catch {
                        /* ignore */
                    }
                }
                const claimedRow = await linksKv.get(`reward_claimed:discord:${steamid}`) || await linksKv.get(`discord_reward_claimed:${steamid}`);
                drRewardClaimed = Boolean(claimedRow);

                const wClaimed = await linksKv.get(`claimed_weekend:${weekendId}:${steamid}`);
                drWeekendClaimed = Boolean(wClaimed);

                const giveawayEntry = await linksKv.get(`giveaway:entry:${monthKey}:${steamid}`);
                drGiveawayEntered = Boolean(giveawayEntry);
            }

            // Fetch all entries for the current month
            if (linksKv) {
                const entries = await linksKv.list({ prefix: `giveaway:entry:${monthKey}:` });
                entryCount = entries.keys.length;
                
                // Fetch entry data
                const displayLimit = 15;
                const entryPromises = entries.keys.slice(0, displayLimit).map(async (k) => {
                    const raw = await linksKv.get(k.name);
                    const steamid = k.name.split(':').pop();
                    if (raw) {
                        try { 
                            const data = JSON.parse(raw);
                            return { ...data, steamid }; 
                        } catch {}
                    }
                    return null;
                });
                entriesWithData = (await Promise.all(entryPromises)).filter(Boolean);
            }

            const drJustClaimed = url.searchParams.get("reward_claimed");
            let dPageFlash = null;

            if (drJustClaimed === "1" || drJustClaimed === "weekend" || drJustClaimed === "giveaway") {
                dPageFlash = {
                    ok: true,
                    text: drJustClaimed === "weekend"
                        ? "Weekend Bonus claimed! $10,000 has been credited automatically."
                        : drJustClaimed === "giveaway"
                        ? "You have successfully entered the Monthly $100,000 Giveaway!"
                        : "Reward claimed! $10,000 has been credited automatically."
                };
            } else if (url.searchParams.get("discord_error") || url.searchParams.get("weekend_error") || url.searchParams.get("error")) {
                let raw = url.searchParams.get("discord_error") || url.searchParams.get("weekend_error") || url.searchParams.get("error");
                try {
                    raw = decodeURIComponent(raw).replace(/\+/g, " ");
                } catch {
                    raw = "Something went wrong.";
                }

                const errMap = {
                    already_claimed: "You’ve already claimed this reward.",
                    discord_not_linked: "Link Discord on your Profile first, then try again.",
                    not_weekend: "The Weekend Bonus is only available on Saturday and Sunday!",
                    not_in_discord_server_join_first: "That Discord account isn’t in our Discord server yet. Join the LifePunch Discord, then use Claim again—we verify membership when you claim.",
                    wrong_discord_account_use_linked_account: "Sign into Discord with the same account you linked on your Profile, then try again.",
                    could_not_read_guild_list: "Discord didn’t return your server list. Try again in a moment.",
                    guild_id_not_configured: "Server verification isn’t configured (missing DISCORD_GUILD_ID). Contact staff.",
                    webhook_failed: "We couldn’t notify staff in Discord. Try again shortly.",
                    claim_failed: "Couldn’t complete the claim. Try again or open a ticket.",
                    token_exchange_failed: "Discord sign-in failed. Try Claim again.",
                    discord_user_fetch_failed: "Couldn’t read your Discord profile. Try again."
                };
                dPageFlash = { ok: false, text: errMap[raw] || raw };
            }

            bodyContent = `
            <style>
                .reward-info-box { 
                    background: rgba(var(--lp-blue-rgb), 0.1); 
                    border: 1px solid var(--lp-blue); 
                    padding: 20px; 
                    border-radius: 12px; 
                    margin-bottom: 30px; 
                    text-align: center; 
                    color: #fff; 
                    font-size: 14px; 
                    font-weight: 600;
                    backdrop-filter: blur(10px);
                }
                .reward-item-card { 
                    background: var(--surface); 
                    border: 1px solid var(--border); 
                    border-radius: 12px; 
                    padding: 30px; 
                    backdrop-filter: blur(16px); 
                    margin-bottom: 20px; 
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    gap: 20px;
                }
                .reward-item-info h3 { 
                    margin: 0 0 5px 0;
                    color: var(--lp-blue); 
                    font-family: 'Montserrat', sans-serif; 
                    font-size: 18px; 
                    text-transform: uppercase; 
                }
                .reward-item-info p { 
                    margin: 0;
                    color: var(--text-dim); 
                    font-size: 14px; 
                }
                .reward-btn { 
                    background: var(--lp-blue);
                    color: #fff; 
                    padding: 12px 25px; 
                    border-radius: 6px; 
                    text-decoration: none; 
                    font-weight: 900; 
                    font-size: 12px;
                    text-transform: uppercase;
                    transition: 0.3s; 
                    border: none;
                    cursor: pointer;
                    white-space: nowrap;
                }
                .reward-btn:hover { background: #005bb5; transform: translateY(-2px); }
                .reward-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
                
                .reward-claimed-tag {
                    color: #00c853;
                    font-weight: 900;
                    font-size: 12px;
                    text-transform: uppercase;
                    display: flex;
                    align-items: center;
                    gap: 5px;
                }
                
                .reward-page-flash {
                    padding: 14px 16px;
                    border-radius: 8px;
                    font-size: 13px;
                    margin-bottom: 20px;
                    border: 1px solid var(--border);
                    transition: opacity 0.55s ease, transform 0.55s ease;
                }
                .reward-page-flash.reward-page-flash--hiding {
                    opacity: 0;
                    transform: translateY(-6px);
                    pointer-events: none;
                }
                .reward-page-flash--ok { background: rgba(0, 200, 83, 0.1); border-color: #00c853; color: #b9f6ca; text-align: center; }
                .reward-page-flash--err { background: rgba(255, 82, 82, 0.08); border-color: #ff5252; color: #ffcdd2; text-align: left; }

                @media (max-width: 600px) {
                    .reward-item-card { flex-direction: column; text-align: center; }
                }
            </style>

            ${
                !steamid 
                ? `<div class="reward-info-box">You must be logged into Steam and authorize your Discord for rewards.</div>`
                : !drDiscordLinked
                ? `<div class="reward-info-box">You must authorize your Discord for rewards (this is done through your profile).</div>`
                : ``
            }

            ${
                dPageFlash
                    ? `<div id="reward-page-flash" class="reward-page-flash reward-page-flash--${dPageFlash.ok ? "ok" : "err"}" role="status">${esc(dPageFlash.text)}</div>`
                    : ""
            }

            <div class="reward-item-card">
                <div class="reward-item-info">
                    <h3>Join Discord Reward</h3>
                    <p>Link your Discord and join our community server to claim a one-time $10,000 bonus.</p>
                </div>
                <div class="reward-item-action">
                    ${
                        !steamid || !drDiscordLinked
                        ? `<button class="reward-btn" disabled>CLAIM REWARD</button>`
                        : drRewardClaimed
                        ? `<div class="reward-claimed-tag"><i class="fa-solid fa-circle-check"></i> CLAIMED</div>`
                        : `<a href="/auth/discord/claim-verify" class="reward-btn">CLAIM REWARD</a>`
                    }
                </div>
            </div>

            <div class="reward-item-card" ${!isWeekend ? 'style="opacity: 0.7; filter: grayscale(0.5);"' : ''}>
                <div class="reward-item-info">
                    <h3>Weekend Bonus</h3>
                    <p>Claim a $10,000 bonus once every weekend (Fri 6pm - Sun Night)!</p>
                </div>
                <div class="reward-item-action">
                    ${
                        !steamid || !drDiscordLinked
                        ? `<button class="reward-btn" disabled>CLAIM REWARD</button>`
                        : drWeekendClaimed
                        ? `<div class="reward-claimed-tag"><i class="fa-solid fa-circle-check"></i> CLAIMED</div>`
                        : !isWeekend
                        ? `<button id="weekend-timer" class="reward-btn" style="background: #444; cursor: not-allowed; font-family: monospace; min-width: 140px;" disabled>00:00:00</button>`
                        : `<a href="/rewards/claim-weekend" class="reward-btn">CLAIM REWARD</a>`
                    }
                </div>
            </div>

            <div class="reward-item-card">
                <div class="reward-item-info">
                    <h3>Monthly $100,000 Giveaway</h3>
                    <p>Enter the monthly drawing to win $100,000, EVIP Rank, and Builder+! Winner is drawn automatically.</p>
                </div>
                <div class="reward-item-action">
                    ${
                        !steamid
                        ? `<button class="reward-btn" disabled>LOGIN TO ENTER</button>`
                        : drGiveawayEntered
                        ? `<div class="reward-claimed-tag"><i class="fa-solid fa-circle-check"></i> ENTERED</div>`
                        : `<form action="/rewards/giveaway-enter" method="POST"><button type="submit" class="reward-btn">CLAIM ENTRY</button></form>`
                    }
                </div>
            </div>
            
            <div class="reward-info-box">
                <h4>Giveaway Status</h4>
                <p>Ends in: <span id="giveaway-timer" style="color: var(--lp-blue); font-family: monospace; font-weight: 900;">Loading...</span></p>
                <p>${entryCount} people have entered this month!</p>
                <div style="display: flex; gap: 5px; justify-content: center; flex-wrap: wrap;">
                    ${(Array.isArray(entriesWithData) ? entriesWithData : []).map(e => `<a href="/profile/${e.steamid}" title="${esc(e.name)}"><img src="${e.avatar}" style="width: 32px; height: 32px; border-radius: 4px; border: 1px solid var(--border);"></a>`).join('')}
                </div>
                <p style="margin-top: 15px;">Last Month's Winner: <b>None (First Month!)</b></p>
            </div>
            
            <script>
                // Giveaway Timer
                (function() {
                    function update() {
                        const el = document.getElementById('giveaway-timer');
                        if (!el) return;
                        const lastDay = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0, 23, 59, 59);
                        const diff = lastDay - new Date();
                        if (diff <= 0) { el.innerText = "DRAWING SOON"; return; }
                        const d = Math.floor(diff / 86400000);
                        const h = Math.floor((diff / 3600000) % 24);
                        const m = Math.floor((diff / 60000) % 60);
                        const s = Math.floor((diff / 1000) % 60);
                        el.innerText = d + "d " + h + "h " + m + "m " + s + "s";
                    }
                    setInterval(update, 1000);
                    update();
                })();

                // Weekend Timer
                (function() {
                    const targetTs = ${nextStartTs};
                    function update() {
                        const el = document.getElementById('weekend-timer');
                        if (!el) return;
                        const diff = targetTs - Date.now();
                        if (diff <= 0) {
                            el.innerText = "ACTIVE";
                            el.style.background = "var(--lp-blue)";
                            el.style.cursor = "pointer";
                            return;
                        }
                        const h = Math.floor(diff / 3600000);
                        const m = Math.floor((diff / 60000) % 60);
                        const s = Math.floor((diff / 1000) % 60);
                        const pad = (n) => n.toString().padStart(2, '0');
                        el.innerText = pad(h) + ":" + pad(m) + ":" + pad(s);
                    }
                    setInterval(update, 1000);
                    update();
                })();
            </script>            `;
        } else if (path === "/discord") {
            pageTitle = "LifePunch | Discord";
            subHeaderTitle = "JOIN OUR COMMUNITY";

            bodyContent = `
            <style>
                .discord-card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 40px; text-align: center; backdrop-filter: blur(16px); }
                .discord-icon { font-size: 80px; color: #5865F2; margin-bottom: 20px; }
                .discord-title { font-family: 'Montserrat', sans-serif; font-size: 32px; font-weight: 900; color: #fff; margin-bottom: 15px; }
                .discord-desc { color: var(--text-dim); margin-bottom: 30px; font-size: 16px; }
                .discord-btn { 
                    display: inline-block; background: #5865F2; color: #fff; padding: 18px 30px; 
                    border-radius: 8px; text-decoration: none; font-weight: 900; font-family: 'Montserrat', sans-serif;
                    margin: 10px; transition: 0.3s; border: none; cursor: pointer;
                }
                .discord-btn:hover { background: #4752C4; transform: translateY(-2px); }
                .copy-btn { 
                    background: rgba(255,255,255,0.05); color: #fff; padding: 18px 30px; 
                    border-radius: 8px; border: 1px solid var(--border); font-weight: 900; cursor: pointer;
                    transition: 0.3s; font-family: 'Montserrat', sans-serif; font-size: 14px;
                }
                .copy-btn:hover {
                    background: var(--lp-blue); border-color: var(--lp-blue);
                    transform: translateY(-2px);
                }
                .copy-btn.copied {
                    background: #00c853; border-color: #00c853;
                }
            </style>
            <div class="discord-card">
                <i class="fa-brands fa-discord discord-icon"></i>
                <div class="discord-title">JOIN THE COMMUNITY</div>
                <p class="discord-desc">Stay updated, report rulebreakers, and chat with the community!</p>
                <a href="https://discord.gg/lifepunch" target="_blank" class="discord-btn">JOIN SERVER</a>
                <button class="copy-btn" onclick="copyInvite(this)">COPY INVITE LINK</button>
            </div>
            
            <script>
                function copyInvite(btn) {
                    navigator.clipboard.writeText("https://discord.gg/lifepunch");
                    const originalText = btn.innerText;
                    btn.innerText = "COPIED!";
                    btn.classList.add('copied');
                    setTimeout(() => { 
                        btn.innerText = originalText; 
                        btn.classList.remove('copied');
                    }, 1500);
                }
            </script>
            `;
        } else if (path === "/tos") {
            pageTitle = "LifePunch | Terms of Service";
            subHeaderTitle = "TERMS OF SERVICE";

            bodyContent = `
          <style>
              .tos-container { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 40px; backdrop-filter: blur(16px); margin-top: 10px; text-align: left; }
              .tos-section { margin-bottom: 30px; }
              .tos-section h2 { color: var(--lp-blue); font-family: 'Montserrat', sans-serif; font-size: 16px; text-transform: uppercase; border-bottom: 1px solid var(--border); padding-bottom: 10px; margin-bottom: 15px; }
              .tos-section h3 { color: var(--text-main); font-family: 'Montserrat', sans-serif; font-size: 13px; text-transform: uppercase; letter-spacing: .04em; margin: 18px 0 8px; }
              .tos-section p, .tos-section li { font-size: 14px; color: var(--text-main); border-left: 2px solid var(--lp-blue); padding-left: 15px; line-height: 1.6; }
              .tos-section ul, .tos-section ol { margin: 10px 0; padding-left: 22px; }
              .tos-section li { margin-bottom: 6px; }
              .effective-date { font-style: italic; margin-bottom: 6px; color: var(--text-muted); }
              .tos-entity { color: var(--text-muted); font-size: 13px; line-height: 1.6; margin-bottom: 18px; }
              .tos-notice { border: 1px solid var(--lp-blue); border-radius: 8px; padding: 14px 16px; margin-bottom: 26px; font-size: 13px; color: var(--text-main); line-height: 1.6; background: rgba(0,0,0,0.15); }
          </style>

          <div class="tos-container">
              <p class="effective-date">Last Updated: July 3, 2026</p>
              <p class="tos-entity">These Terms of Service ("Terms") are a binding agreement between you and <strong>Peak Performance Products LLC</strong>, a New Jersey limited liability company that operates the <strong>LIFEPUNCH&trade;</strong> brand, servers, website, and related services ("LifePunch," "we," "us," or "our").</p>

              <div class="tos-notice"><strong>PLEASE READ CAREFULLY.</strong> These Terms include a <strong>binding individual arbitration provision and class-action waiver</strong> (Section 16), <strong>disclaimers of warranties and limitations of our liability</strong> (Sections 13&ndash;14), and a <strong>final-sale / no-chargeback purchase policy</strong> (Section 7) that affect your legal rights. If you do not agree, do not access or use LifePunch services.</div>

              <div class="tos-section">
                  <h2>1. Acceptance of Terms</h2>
                  <p>By accessing or using LifePunch services &mdash; including our game servers, website at lifepunch.co, store, Discord, and related platforms (collectively, the "Services") &mdash; you agree to be bound by these Terms and the practices described in Section 3 (Privacy &amp; Data). If you use the Services on behalf of another person or organization, you represent that you are authorized to accept these Terms on their behalf.</p>
                  <p>If you do not agree to these Terms, you must immediately cease all use of the Services. Your continued use constitutes a legally binding acceptance of these Terms and of any future modifications made in accordance with Section 18.</p>
              </div>

              <div class="tos-section">
                  <h2>2. Eligibility &amp; Accounts</h2>
                  <p>You must be at least <strong>13 years old</strong> (or 16 in jurisdictions that require it) to use the Services. If you are under the age of majority where you live, you represent that a parent or legal guardian has reviewed and agreed to these Terms on your behalf. We do not knowingly collect personal information from children under 13; if you believe a child under 13 has provided us information, contact legal@lifepunch.co and we will delete it.</p>
                  <p>Access to the Services may require linking third-party accounts, including <strong>Steam</strong> and <strong>Discord</strong>. You are responsible for all activity that occurs through your linked accounts, for keeping your credentials secure, and for any purchases or in-game actions taken under them. You agree to provide accurate information and to notify us promptly of any unauthorized use. We may refuse, suspend, or terminate access at our discretion as described in these Terms.</p>
              </div>

              <div class="tos-section">
                  <h2>3. Privacy &amp; Data</h2>
                  <p>To operate the Services we collect and process limited data, including: your <strong>Steam ID and public Steam profile</strong>, your <strong>Discord ID</strong> and related linking data, <strong>purchase and transaction records</strong> processed by our payment provider (Stripe), reward/referral activity, and technical data such as IP address and request logs handled by our infrastructure provider (Cloudflare) for security, fraud prevention, and reliability.</p>
                  <p>We use this data to provide and secure the Services, fulfill purchases and perks, prevent abuse and fraud, and communicate with you. We share data only with service providers acting on our behalf (such as Steam, Discord, Stripe, and Cloudflare), or where required by law or to protect our rights. We do not sell your personal information. Data is processed in the United States; by using the Services you consent to this processing and transfer. To request access to or deletion of your data, contact legal@lifepunch.co; we will honor verified requests to the extent required by applicable law.</p>
              </div>

              <div class="tos-section">
                  <h2>4. Community Rules &amp; Conduct</h2>
                  <p>Access to LifePunch is a privilege, not a right. All users must comply with our server rules, community guidelines, and staff directives, which are incorporated into these Terms by reference and may be updated at any time. Staff interpretations of the rules are final. "Roleplay" standards are enforced to protect community integrity; conduct such as "FailRP" or "Metagaming" may result in immediate administrative action without prior warning.</p>
                  <p>You agree not to: harass, threaten, or defame others; use cheats, exploits, macros, or unauthorized third-party software; exploit bugs or economy flaws; disrupt or attempt to gain unauthorized access to the Services; buy, sell, or transfer accounts, virtual items, or credit outside the Services; impersonate staff; post illegal, infringing, or sexually exploitative content; or advertise or recruit for competing servers. We may issue warnings, mutes, kicks, temporary or permanent bans, and may remove or reset virtual items, ranks, or credit, in our sole discretion and without notice or refund.</p>
              </div>

              <div class="tos-section">
                  <h2>5. Virtual Goods, Ranks &amp; Store Credit</h2>
                  <p>Any financial contributions, referral rewards, or "Store Credit" earned or used on LifePunch are payments for a <strong>limited, revocable, non-transferable license</strong> to access specific virtual items, ranks, or "perks" within the LifePunch ecosystem. These items, including Store Credit, have <strong>no real-world monetary value</strong>, are not your property, and cannot be sold, transferred, redeemed, or "cashed out" for real-world currency or assets.</p>
                  <h3>Work in Progress &amp; Roadmap</h3>
                  <p>You acknowledge that LifePunch is a live, evolving service. Some virtual goods, ranks, or perks may include features that are in development ("Work in Progress" or "WIP"). A purchase provides access to the item's current, "As Available" features; missing or upcoming features do not constitute a failure of service or grounds for a refund. We may modify, rebalance, suspend, or remove any virtual item, perk, or administrative power at any time without notice or refund.</p>
              </div>

              <div class="tos-section">
                  <h2>6. Payments, Subscriptions &amp; Referrals</h2>
                  <p>Payments are processed by our third-party payment processor, <strong>Stripe</strong>. By purchasing, you agree to Stripe's terms and authorize the charge, plus any applicable taxes, to your selected payment method. We do not store full card details.</p>
                  <h3>Subscriptions</h3>
                  <p>VIP and EVIP are <strong>recurring monthly subscriptions</strong>. By subscribing, you authorize LifePunch (through Stripe) to charge your payment method the then-current price each billing cycle until you cancel. You may cancel at any time; cancellation stops future renewals but does not refund the current or any prior billing period, and perks generally remain active through the end of the paid period. We may change subscription prices or features on a going-forward basis, with reasonable notice via the site or Discord.</p>
                  <h3>Store Credit &amp; Referrals</h3>
                  <p>Referral rewards and Store Credit are provided at our sole discretion as a community benefit. We may reduce, revoke, or withhold any rewards, credit, or related perks if we determine, in our sole judgment, that the system has been abused &mdash; for example through self-referral, multiple accounts, exploitation, or fraudulent activity. Credit is non-transferable, has no cash value, and cannot be cashed out.</p>
              </div>

              <div class="tos-section">
                  <h2>7. Refunds &amp; Chargebacks</h2>
                  <p><strong>All sales are final.</strong> By completing a purchase or applying credit, you waive any right to a refund except where a refund is required by applicable law. Because purchases unlock digital items and perks immediately, you consent to immediate delivery and acknowledge that this may extinguish any statutory right of withdrawal where the law permits such waiver.</p>
                  <p>Verbal or written statements by staff members or community leads regarding refunds do not override these written Terms. Only a formal written notice from our billing/legal contact (legal@lifepunch.co) can authorize an exception to this policy.</p>
                  <p><strong>Chargebacks and payment disputes.</strong> If you initiate a chargeback, reversal, or payment dispute instead of contacting us first, we may immediately suspend or permanently ban your accounts, revoke all virtual items and credit, and pursue recovery of the disputed amounts plus any fees and reasonable costs, including through collections. We encourage you to contact us first at legal@lifepunch.co to resolve any billing concern.</p>
              </div>

              <div class="tos-section">
                  <h2>8. Service Availability, Changes &amp; Virtual-Item Risk</h2>
                  <p>The Services are provided on an "as available" basis. We may add, modify, suspend, wipe, reset, or discontinue any part of the Services &mdash; including servers, maps, economies, ranks, perks, or virtual items &mdash; at any time, with or without notice. We do not guarantee that any specific perk, job, item, or administrative power will be available at all times or remain unchanged.</p>
                  <p>You accept the risk that server downtime, data loss, resets, wipes, or discontinuation may result in the loss of virtual items, credit, or progress, and that we are not liable for any such loss, to the maximum extent permitted by law.</p>
              </div>

              <div class="tos-section">
                  <h2>9. User Content &amp; Feedback</h2>
                  <p>You retain ownership of content you submit to the Services (such as chat, roleplay text, names, and media) ("User Content"), but you grant LifePunch a worldwide, non-exclusive, royalty-free, sublicensable license to host, store, reproduce, display, and use that content to operate, moderate, and promote the Services. You are solely responsible for your User Content and represent that you have the rights to submit it. We may remove or moderate User Content at our discretion.</p>
                  <p>If you send us suggestions, ideas, or feedback, you grant us a perpetual, irrevocable, royalty-free right to use them for any purpose without obligation or compensation to you.</p>
              </div>

              <div class="tos-section">
                  <h2>10. Intellectual Property</h2>
                  <p>All original content created by LifePunch &mdash; including the <strong>LIFEPUNCH&trade;</strong> name and logo, custom code, addons, weapons, entities, UI design, artwork, and branding &mdash; is the exclusive property of Peak Performance Products LLC and is protected by intellectual-property laws. You are granted a limited, revocable, non-exclusive license to view and interact with this content for personal, non-commercial use only.</p>
                  <p>You may not copy, redistribute, resell, sublicense, publicly perform, reverse engineer, scrape, or create derivative works from our proprietary content except as expressly authorized in writing. Any unauthorized replication of LifePunch's unique site layout, code, or proprietary assets &mdash; including for use in "clone" servers &mdash; is strictly prohibited and may be met with enforcement, including DMCA action and litigation. Where server owners receive our content, their permitted use is governed by a separate license/EULA; absent that, no resale or redistribution is permitted.</p>
              </div>

              <div class="tos-section">
                  <h2>11. Third-Party Services &amp; Non-Affiliation</h2>
                  <p>The Services rely on and interoperate with third parties, including <strong>Steam / Valve</strong>, <strong>Discord</strong>, <strong>Stripe</strong>, <strong>Cloudflare</strong>, the <strong>s&amp;box</strong> engine (Facepunch), and the <strong>DXRP</strong> gamemode/platform (Dxura). Your use of those services is subject to their own terms, and we are not responsible for them.</p>
                  <p>LifePunch is an independent community and is <strong>not affiliated with, endorsed by, or sponsored by</strong> Dxura, Facepunch, Valve, Discord, Stripe, or Cloudflare. All third-party names, marks, and assets remain the property of their respective owners and are referenced only nominatively to describe interoperability.</p>
              </div>

              <div class="tos-section">
                  <h2>12. DMCA &amp; Copyright</h2>
                  <p>We respect intellectual-property rights and respond to valid notices under the Digital Millennium Copyright Act. If you believe content on our site infringes your copyright, send our Copyright Agent (<strong>dmca@lifepunch.co</strong>): (1) a description of the copyrighted work; (2) the location of the material on our site; (3) your contact information; (4) a statement of good-faith belief that the use is unauthorized; (5) a statement, under penalty of perjury, that the information is accurate and that you are authorized to act; and (6) your physical or electronic signature.</p>
                  <p>If your content was removed and you believe it was in error, you may submit a counter-notice to the same address with the corresponding statutory information. We maintain a policy of terminating, in appropriate circumstances, the access of users who are repeat infringers.</p>
              </div>

              <div class="tos-section">
                  <h2>13. Disclaimer of Warranties</h2>
                  <p>LIFEPUNCH SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE," WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND. TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE EXPRESSLY DISCLAIM ALL WARRANTIES, WHETHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.</p>
                  <p>WE DO NOT WARRANT THAT THE SERVICES WILL BE UNINTERRUPTED, SECURE, ERROR-FREE, OR FREE OF DATA LOSS, OR THAT ANY SPECIFIC PERK, JOB, ITEM, OR ADMINISTRATIVE POWER WILL BE AVAILABLE OR REMAIN UNCHANGED. SOME JURISDICTIONS DO NOT ALLOW CERTAIN WARRANTY EXCLUSIONS, SO SOME OF THESE EXCLUSIONS MAY NOT APPLY TO YOU.</p>
              </div>

              <div class="tos-section">
                  <h2>14. Limitation of Liability</h2>
                  <p>TO THE MAXIMUM EXTENT PERMITTED BY LAW, LIFEPUNCH AND PEAK PERFORMANCE PRODUCTS LLC, AND OUR OWNERS, STAFF, AND CONTRACTORS, SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, EXEMPLARY, OR PUNITIVE DAMAGES, OR FOR ANY LOSS OF PROFITS, DATA, GOODWILL, OR VIRTUAL ITEMS, ARISING FROM OR RELATED TO YOUR USE OF THE SERVICES, INCLUDING SERVER DOWNTIME, LOSS OF VIRTUAL ASSETS, OR SECURITY INCIDENTS.</p>
                  <p>OUR TOTAL LIABILITY TO YOU FOR ALL CLAIMS ARISING OUT OF OR RELATED TO THE SERVICES SHALL NOT EXCEED THE GREATER OF (a) THE TOTAL AMOUNTS YOU PAID TO LIFEPUNCH IN THE SIX (6) MONTHS PRECEDING THE EVENT GIVING RISE TO THE CLAIM, OR (b) ONE HUNDRED U.S. DOLLARS (USD 100). THESE LIMITATIONS APPLY EVEN IF A REMEDY FAILS OF ITS ESSENTIAL PURPOSE. SOME JURISDICTIONS DO NOT ALLOW CERTAIN LIMITATIONS, SO SOME MAY NOT APPLY TO YOU.</p>
              </div>

              <div class="tos-section">
                  <h2>15. Indemnification</h2>
                  <p>You agree to indemnify, defend, and hold harmless LifePunch, Peak Performance Products LLC, and our owners, staff, and contractors from and against any claims, damages, liabilities, losses, and expenses (including reasonable attorneys' fees) arising out of or related to your use of the Services, your User Content, your violation of these Terms or our rules, or your violation of any law or the rights of a third party.</p>
              </div>

              <div class="tos-section">
                  <h2>16. Dispute Resolution, Arbitration &amp; Governing Law</h2>
                  <p>These Terms are governed by the laws of the <strong>State of New Jersey</strong>, USA, without regard to its conflict-of-laws principles.</p>
                  <h3>Informal Resolution</h3>
                  <p>Before starting any formal proceeding, you agree to first contact us at legal@lifepunch.co and attempt in good faith to resolve the dispute for at least 30 days.</p>
                  <h3>Binding Arbitration</h3>
                  <p>Except as carved out below, any dispute arising out of or relating to these Terms or the Services shall be resolved by <strong>final and binding individual arbitration</strong> administered by the American Arbitration Association (AAA) under its Consumer Arbitration Rules, seated in New Jersey (or conducted remotely), before a single arbitrator. The Federal Arbitration Act governs the interpretation and enforcement of this provision. <strong>Carve-outs:</strong> either party may bring an individual claim in small-claims court, and we may seek injunctive relief in court to protect our intellectual property or stop misuse of the Services.</p>
                  <h3>Class-Action &amp; Jury Waiver</h3>
                  <p>You and LifePunch agree that disputes will be brought only in an <strong>individual capacity</strong>, and not as a plaintiff or class member in any purported class, consolidated, or representative proceeding. <strong>You and LifePunch waive any right to a jury trial and to class-wide arbitration.</strong> If the class-action waiver is found unenforceable as to a particular claim, that claim shall proceed in court, but the remainder of this Section still applies.</p>
                  <h3>Venue &amp; Time Limit</h3>
                  <p>For any dispute not subject to arbitration, you agree to the exclusive jurisdiction and venue of the state and federal courts located in the State of New Jersey. Any claim must be brought within <strong>one (1) year</strong> after it arises, to the extent permitted by law, or it is permanently barred.</p>
              </div>

              <div class="tos-section">
                  <h2>17. Suspension &amp; Termination</h2>
                  <p>We may suspend or terminate your access to the Services at any time, with or without notice, for any reason, including violation of these Terms or our rules. You may stop using the Services at any time. Upon termination, your licenses to virtual items, ranks, and credit end immediately, no refunds are owed, and any outstanding obligations survive. Sections that by their nature should survive termination (including Sections 5&ndash;16 and 18) will survive.</p>
              </div>

              <div class="tos-section">
                  <h2>18. Changes to These Terms</h2>
                  <p>We may update these Terms from time to time. When we do, we will revise the "Last Updated" date above, and material changes will be communicated through the site or our Discord. Your continued use of the Services after changes take effect constitutes acceptance of the revised Terms. If you do not agree, you must stop using the Services.</p>
              </div>

              <div class="tos-section">
                  <h2>19. Miscellaneous</h2>
                  <p>These Terms, together with the rules and policies referenced herein, are the entire agreement between you and LifePunch regarding the Services and supersede prior agreements. If any provision is held unenforceable, the remaining provisions remain in effect and the unenforceable provision will be modified to the minimum extent necessary. Our failure to enforce any provision is not a waiver. You may not assign these Terms without our consent; we may assign them, including in connection with a merger, acquisition, or sale of assets. We are not liable for delays or failures caused by events beyond our reasonable control (force majeure). Section headings are for convenience only.</p>
              </div>

              <div class="tos-section">
                  <h2>20. Contact</h2>
                  <p>Legal &amp; billing: <strong>legal@lifepunch.co</strong>. Copyright / DMCA: <strong>dmca@lifepunch.co</strong>. General support: our official <a href="https://discord.gg/lifepunch" target="_blank" rel="noopener">community Discord</a> or the support ticket system. Entity: Peak Performance Products LLC (New Jersey, USA), operator of the LIFEPUNCH&trade; brand.</p>
              </div>

          </div>
          </div>
        `;
        } else if (path === "/store" || path === "/donate") {
            pageTitle = "LifePunch | Store & Donations";
            subHeaderTitle = "SUPPORT THE COMMUNITY";

            let transactionHistory = [];
            let discordAccount = null;
            let userCredit = "0.00";

            if (steamid && linksKv) {
                const [rawTx, rawDiscord, rawCredit] = await Promise.all([
                    linksKv.get(`tx:${steamid}`),
                    linksKv.get(`link:steam:${steamid}`),
                    linksKv.get(`user:credit:${steamid}`)
                ]);

                if (rawTx) {
                    try { transactionHistory = JSON.parse(rawTx); } catch { transactionHistory = []; }
                }

                if (rawDiscord) {
                    try { discordAccount = JSON.parse(rawDiscord); } catch { discordAccount = null; }
                }

                if (rawCredit) {
                    userCredit = parseFloat(rawCredit).toFixed(2);
                }
            }

            bodyContent = `
          <style>
              .store-intro { 
                  background: rgba(var(--lp-blue-rgb),0.08); border: 1px solid var(--lp-blue); 
                  padding: 25px; border-radius: 10px; margin-bottom: 30px; font-size: 14px; 
                  line-height: 1.8; color: #fff; text-align: center;
                  backdrop-filter: blur(10px);
              }
              .store-layout {
                  display: grid;
                  grid-template-columns: 1fr 1fr;
                  gap: 20px;
                  margin-bottom: 30px;
              }
              @media (max-width: 800px) {
                  .store-layout { grid-template-columns: 1fr; }
              }
              .store-box {
                  background: var(--surface);
                  border: 1px solid var(--border);
                  border-radius: 12px;
                  padding: 30px;
                  backdrop-filter: blur(16px);
                  display: flex;
                  flex-direction: column;
              }
              .box-title {
                  font-family: 'Montserrat', sans-serif;
                  font-size: 18px;
                  font-weight: 900;
                  color: var(--lp-blue);
                  margin-bottom: 20px;
                  text-transform: uppercase;
                  display: flex;
                  align-items: center;
                  gap: 10px;
              }
              /* Transaction History Styles */
              .tx-list { list-style: none; padding: 0; margin: 0; }
              .tx-item {
                  background: rgba(255,255,255,0.03);
                  border: 1px solid var(--border);
                  border-radius: 8px;
                  padding: 15px;
                  margin-bottom: 10px;
                  font-size: 13px;
              }
              .tx-header { display: flex; justify-content: space-between; margin-bottom: 5px; }
              .tx-package { font-weight: bold; color: #fff; }
              .tx-amount { color: var(--lp-blue); font-weight: 900; }
              .tx-meta { display: flex; justify-content: space-between; color: var(--text-dim); font-size: 11px; }
              .no-tx { text-align: center; color: var(--text-dim); padding: 40px 0; font-size: 14px; }
              
              /* Purchase Flow Styles */
              .step-container { flex: 1; display: flex; flex-direction: column; }
              .package-selector { display: flex; flex-direction: column; gap: 10px; margin-bottom: 20px; }
              .package-option {
                  background: rgba(255,255,255,0.05);
                  border: 1px solid var(--border);
                  padding: 15px;
                  border-radius: 8px;
                  cursor: pointer;
                  transition: 0.2s;
                  display: flex;
                  justify-content: space-between;
                  align-items: center;
              }
              .package-option:hover { border-color: var(--lp-blue); background: rgba(var(--lp-blue-rgb), 0.05); }
              .package-option.selected { border-color: var(--lp-blue); background: rgba(var(--lp-blue-rgb), 0.1); box-shadow: 0 0 15px rgba(var(--lp-blue-rgb), 0.2); }
              .option-info b { display: block; font-size: 16px; color: #fff; }
              .option-info span { font-size: 12px; color: var(--text-dim); }
              .option-price { font-weight: 900; color: var(--lp-blue); }
              
              /* Hide number input spinners */
              input::-webkit-outer-spin-button,
              input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
              input[type=number] { -moz-appearance: textfield; }

              .perks-display {
                  background: rgba(var(--lp-blue-rgb), 0.05);
                  border: 1px solid rgba(var(--lp-blue-rgb), 0.2);
                  border-radius: 8px;
                  padding: 20px;
                  margin-bottom: 20px;
                  font-size: 13px;
                  flex: 1;
              }
              .perks-display ul { list-style: none; padding: 0; margin: 0; }
              .perks-display li { padding: 5px 0; display: flex; align-items: center; gap: 8px; }
              .perks-display li::before { content: "✓"; color: var(--lp-blue); font-weight: bold; }
              
              .finalize-info {
                  background: rgba(255,255,255,0.03);
                  border-radius: 8px;
                  padding: 20px;
                  margin-bottom: 20px;
              }
              .info-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14px; }
              .info-label { color: var(--text-dim); }
              .info-value { color: #fff; font-weight: bold; }
              
              .lp-input-wrapper { margin-top: 10px; }
              .lp-input {
                  width: 100%; padding: 12px; background: rgba(0,0,0,0.3); border: 1px solid var(--border);
                  color: #fff; border-radius: 6px; font-family: inherit; font-weight: bold; margin-top: 5px;
              }

              .btn-row { display: flex; gap: 10px; margin-top: auto; }
              .btn-store {
                  flex: 1; padding: 15px; border-radius: 6px; font-weight: 900; text-transform: uppercase;
                  cursor: pointer; transition: 0.2s; border: none; font-family: 'Montserrat', sans-serif;
              }
              .btn-next { background: var(--lp-blue); color: #fff; }
              .btn-next:hover { background: #005bb5; transform: translateY(-2px); }
              .btn-back { background: transparent; border: 1px solid var(--border); color: var(--text-dim); }
              .btn-back:hover { border-color: #fff; color: #fff; }
              
              .success-overlay {
                  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                  background: rgba(0, 0, 0, 0.95); z-index: 1000;
                  display: none; align-items: center; justify-content: center;
                  text-align: center; backdrop-filter: blur(10px);
              }
              .success-content { padding: 40px; }
              .success-icon { font-size: 80px; color: #00c853; margin-bottom: 20px; }
              .success-title { font-family: 'Montserrat', sans-serif; font-size: 32px; font-weight: 900; color: #fff; margin-bottom: 10px; }
          </style>

          <div class="success-overlay" id="success-msg">
            <div class="success-content">
                <i class="fa-solid fa-circle-check success-icon"></i>
                <div class="success-title">THANK YOU!</div>
                <p style="color: var(--text-dim); margin-bottom: 30px;">Your purchase was successful. Your perks will be applied shortly.</p>
                <button class="btn-store btn-next" style="max-width: 200px;" onclick="window.location.href='/store'">BACK TO STORE</button>
            </div>
          </div>

          <div class="store-intro">
              Support LifePunch with a monthly VIP or EVIP subscription and unlock exclusive perks! Your subscription helps keep our servers running and funds new features. Billed monthly through Stripe — cancel anytime.
          </div>

          ${!steamid ? `
          <div class="store-box" style="background: rgba(1, 122, 239, 0.07); border: 1px solid rgba(1, 122, 239, 0.35); padding: 20px; border-radius: 12px; margin-bottom: 30px; text-align: center; color: #fff; font-size: 14px; font-weight: 600; backdrop-filter: blur(10px);">
              You must be logged into Steam and authorize your Discord to use the Store.
          </div>

          <div class="store-box">
              <div class="box-title" style="justify-content: center; margin-bottom: 25px;"><i class="fa-solid fa-cart-shopping"></i> Available Packages</div>
              <div class="package-preview" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px;">
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">VIP - $10.00/mo</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Builder Status</li>
                              <li>Prop Limit +300</li>
                              <li>Queue Skip</li>
                              <li>Minigame Starts (DXRP WIP)</li>
                              <li>Exclusive Jobs (DXRP WIP)</li>
                          </ul>
                      </div>
                  </div>
                  
                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px;">
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">EVIP - $25.00/mo</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Builder+ Status</li>
                              <li>Prop Limit +600</li>
                              <li>Queue Skip </li>
                              <li>Minigame Starts (DXRP WIP)</li>
                              <li>Exclusive Jobs (DXRP WIP)</li>
                          </ul>
                      </div>
                  </div>

                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px; opacity: 0.5; filter: grayscale(1); cursor: not-allowed; position: relative; overflow: hidden;">
                      <div style="position: absolute; top: 10px; right: -35px; background: #666; color: #fff; padding: 5px 40px; transform: rotate(45deg); font-size: 10px; font-weight: 900; letter-spacing: 1px; box-shadow: 0 2px 10px rgba(0,0,0,0.5); z-index: 10;">WIP</div>
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">$LP - Work In Progress</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Universal Currency</li>
                              <li>Works on All Servers</li>
                              <li>Never Expires</li>
                              <li>In-game Store Purchases</li>
                          </ul>
                      </div>
                  </div>
              </div>
          </div>
          ` : !discordAccount ? `
          <div class="store-box" style="background: rgba(1, 122, 239, 0.07); border: 1px solid rgba(1, 122, 239, 0.35); padding: 20px; border-radius: 12px; margin-bottom: 30px; text-align: center; color: #fff; font-size: 14px; font-weight: 600; backdrop-filter: blur(10px);">
              You must authorize your Discord to use the Store. (this is done through your profile).
          </div>

          <div class="store-box">
              <div class="box-title" style="justify-content: center; margin-bottom: 25px;"><i class="fa-solid fa-cart-shopping"></i> Available Packages</div>
              <div class="package-preview" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px;">
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">VIP - $10.00/mo</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Builder Status</li>
                              <li>Prop Limit +300</li>
                              <li>Queue Skip</li>
                              <li>Minigame Starts (DXRP WIP)</li>
                              <li>Exclusive Jobs (DXRP WIP)</li>
                          </ul>
                      </div>
                  </div>
                  
                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px;">
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">EVIP - $25.00/mo</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Builder+ Status</li>
                              <li>Prop Limit +600</li>
                              <li>Queue Skip </li>
                              <li>Minigame Starts (DXRP WIP)</li>
                              <li>Exclusive Jobs (DXRP WIP)</li>
                          </ul>
                      </div>
                  </div>

                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px; opacity: 0.5; filter: grayscale(1); cursor: not-allowed; position: relative; overflow: hidden;">
                      <div style="position: absolute; top: 10px; right: -35px; background: #666; color: #fff; padding: 5px 40px; transform: rotate(45deg); font-size: 10px; font-weight: 900; letter-spacing: 1px; box-shadow: 0 2px 10px rgba(0,0,0,0.5); z-index: 10;">WIP</div>
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">$LP - Work In Progress</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Universal Currency</li>
                              <li>Works on All Servers</li>
                              <li>Never Expires</li>
                              <li>In-game Store Purchases</li>
                          </ul>
                      </div>
                  </div>
              </div>
          </div>
          ` : `
          <div class="store-layout">
              <div class="store-box">
                  <div class="box-title"><i class="fa-solid fa-clock-rotate-left"></i> My Transactions</div>
                  ${transactionHistory.length === 0 ? `
                      <div class="no-tx">No past transactions found.</div>
                  ` : `
                      <div class="tx-list">
                          ${transactionHistory.map(tx => `
                              <div class="tx-item">
                                  <div class="tx-header">
                                      <span class="tx-package">${esc(tx.package)}</span>
                                      <span class="tx-amount">$${tx.amount}</span>
                                  </div>
                                  <div class="tx-meta">
                                      <span>ID: ${esc(tx.id.slice(0, 12))}...</span>
                                      <span>${new Date(tx.date).toLocaleDateString()}</span>
                                  </div>
                              </div>
                          `).join('')}
                      </div>
                  `}
              </div>

              <div class="store-box" id="purchase-box">
                  <div id="step-1" class="step-container">
                      <div class="box-title"><i class="fa-solid fa-cart-shopping"></i> Select Package</div>
                      <div class="package-selector">
                          <div class="package-option" onclick="selectPkg('VIP', 10.00)">
                              <div class="option-info"><b>VIP</b><span>Standard rank · billed monthly</span></div>
                              <div class="option-price">$10.00/mo</div>
                          </div>
                          <div class="package-option selected" onclick="selectPkg('EVIP', 25.00)">
                              <div class="option-info"><b>EVIP</b><span>Premium rank · billed monthly</span></div>
                              <div class="option-price">$25.00/mo</div>
                          </div>
                          <div class="package-option" style="opacity: 0.5; filter: grayscale(1); cursor: not-allowed; position: relative; overflow: hidden;" onclick="return false;">
                              <div style="position: absolute; top: 10px; right: -35px; background: #666; color: #fff; padding: 5px 40px; transform: rotate(45deg); font-size: 10px; font-weight: 900; letter-spacing: 1px; box-shadow: 0 2px 10px rgba(0,0,0,0.5); z-index: 10;">WIP</div>
                              <div class="option-info"><b>$LP - Work In Progress</b><span>In-game Currency</span></div>
                              <div class="option-price">--</div>
                          </div>
                      </div>
                      <div id="lp-custom-amount" class="lp-input-wrapper" style="display:none; margin-bottom: 20px;">
                          <label style="font-size:11px; color:var(--text-dim); font-weight:bold;">CUSTOM AMOUNT ($USD)</label>
                          <input type="number" id="lp-val" class="lp-input" value="5" min="5" step="1" oninput="updateLPPrice()">
                      </div>
                      <div class="perks-display">
                          <ul id="perks-list">
                              </ul>
                      </div>
                      <button class="btn-store btn-next" onclick="goToStep(2)">Next <i class="fa-solid fa-arrow-right"></i></button>
                  </div>

                  <div id="step-2" class="step-container" style="display:none;">
                      <div class="box-title"><i class="fa-solid fa-check-double"></i> Finalize</div>
                      <div class="finalize-info">
                          <div class="info-row">
                              <span class="info-label">Account:</span>
                              <span class="info-value" style="font-family:monospace;">${steamid}</span>
                          </div>
                          <div class="info-row">
                              <span class="info-label">Package:</span>
                              <span id="final-pkg" class="info-value">EVIP</span>
                          </div>

                          <div class="referral-section" id="referral-section" style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
                              <label style="font-size:11px; color:var(--text-dim); font-weight:bold; text-transform:uppercase;">Referral Code</label>
                              <div style="display:flex; gap:10px; margin-top:5px;">
                                  <input type="text" id="referral-input" class="lp-input" style="margin-top:0;" placeholder="Enter code for 10% off">
                                  <button class="btn-store btn-next" style="padding:10px; width:auto; font-size:11px;" onclick="validateReferral()">Apply</button>
                              </div>
                              <div id="referral-msg" style="font-size:11px; margin-top:5px; font-weight:bold;"></div>
                          </div>

                          ${parseFloat(userCredit) > 0 ? `
                          <div class="credit-section" id="credit-section" style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
                              <div class="info-row">
                                  <span class="info-label">Available Credit:</span>
                                  <span class="info-value" style="color:#00c853;">$${userCredit}</span>
                              </div>
                              <div style="display:flex; gap:10px; margin-top:5px;">
                                  <input type="number" id="credit-input" class="lp-input" style="margin-top:0;" placeholder="Amount to use" max="${userCredit}" step="0.01">
                                  <button class="btn-store btn-next" style="padding:10px; width:auto; font-size:11px;" onclick="applyCredit()">Use Credit</button>
                              </div>
                              <div id="credit-msg" style="font-size:11px; margin-top:5px; font-weight:bold;"></div>
                          </div>
                          ` : ''}

                          <div class="info-row" style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
                              <span class="info-label" style="font-size:18px;">Total:</span>
                              <span id="final-price" class="info-value" style="font-size:18px; color:var(--lp-blue);">$25.00/mo</span>
                          </div>
                      </div>
                      <div class="btn-row">
                          <button class="btn-store btn-back" onclick="goToStep(1)">Back</button>
                          <button id="pay-btn" class="btn-store btn-next" onclick="startCheckout()">Subscribe Securely</button>
                      </div>
                  </div>
                  </div>
                  </div>
                  `}

                  <script>
                  let selectedPkgName = "EVIP";
                  let selectedPkgPrice = 25.00;
                  let currentReferral = null;
                  let appliedCredit = 0.00;
                  const availableCredit = ${userCredit};

                  const perks = {
                  "VIP": ["Builder Status", "Prop Limit +300", "Queue Skip", "Minigame Starts (DXRP WIP)", "Exclusive Jobs (DXRP WIP)"],
                  "EVIP": ["Builder+ Status", "Prop Limit +600", "Queue Skip", "Minigame Starts (DXRP WIP)", "Exclusive Jobs (DXRP WIP)"],
                  "$LP": ["Universal Currency", "Works on All Servers", "Never Expires", "In-game Store Purchases"]
              };

              function isMonthlyRankPkg(name) {
                  return name === "VIP" || name === "EVIP";
              }

              function formatStorePrice(amount, name) {
                  const suffix = isMonthlyRankPkg(name) ? "/mo" : "";
                  return "$" + amount.toFixed(2) + suffix;
              }

              function syncCheckoutExtras() {
                  const monthly = isMonthlyRankPkg(selectedPkgName);
                  const referralSection = document.getElementById("referral-section");
                  const creditSection = document.getElementById("credit-section");
                  if (referralSection) referralSection.style.display = monthly ? "none" : "block";
                  if (creditSection) creditSection.style.display = monthly ? "none" : "block";
                  if (monthly) {
                      currentReferral = null;
                      appliedCredit = 0.00;
                      const referralInput = document.getElementById("referral-input");
                      const referralMsg = document.getElementById("referral-msg");
                      const creditInput = document.getElementById("credit-input");
                      const creditMsg = document.getElementById("credit-msg");
                      if (referralInput) referralInput.value = "";
                      if (referralMsg) referralMsg.innerText = "";
                      if (creditInput) creditInput.value = "";
                      if (creditMsg) creditMsg.innerText = "";
                  }
                  const payBtn = document.getElementById("pay-btn");
                  if (payBtn) payBtn.innerText = monthly ? "Subscribe Securely" : "Pay Securely";
              }

              function selectPkg(name, price) {
                  selectedPkgName = name;
                  selectedPkgPrice = price;
                  
                  document.querySelectorAll('.package-option').forEach(opt => {
                      const pkgName = opt.querySelector('b').innerText;
                      opt.classList.toggle('selected', pkgName === name);
                  });

                  document.getElementById('lp-custom-amount').style.display = (name === '$LP') ? 'block' : 'none';
                  syncCheckoutExtras();
                  updatePerks();
              }

              function updateLPPrice() {
                  if (selectedPkgName === '$LP') {
                      selectedPkgPrice = parseFloat(document.getElementById('lp-val').value) || 5.00;
                  }
              }

              function applyCredit() {
                  const input = document.getElementById('credit-input');
                  const msg = document.getElementById('credit-msg');
                  const val = parseFloat(input.value) || 0;

                  if (val < 0) return;
                  if (val > availableCredit) {
                      msg.innerText = "Insufficient credit.";
                      msg.style.color = "#ff4d4d";
                      return;
                  }

                  appliedCredit = val;
                  msg.innerText = "Credit applied: $" + val.toFixed(2);
                  msg.style.color = "#00c853";
                  updatePriceUI();
              }

              function updatePriceUI() {
                  const finalPriceEl = document.getElementById('final-price');
                  let price = selectedPkgPrice;

                  if (currentReferral) {
                      price = price * 0.9;
                  }

                  price = Math.max(0, price - appliedCredit);

                  if (currentReferral || appliedCredit > 0) {
                      finalPriceEl.innerHTML = '<span style="text-decoration: line-through; color: var(--text-dim); font-size: 14px; margin-right: 8px;">' + formatStorePrice(selectedPkgPrice, selectedPkgName) + '</span>' +
                                             '<span style="color: #00c853;">' + formatStorePrice(price, selectedPkgName) + '</span>';
                  } else {
                      finalPriceEl.innerText = formatStorePrice(price, selectedPkgName);
                  }
                  document.getElementById('final-pkg').innerText = selectedPkgName;
              }

              async function validateReferral() {
                  const code = document.getElementById('referral-input').value.trim();
                  const msgEl = document.getElementById('referral-msg');

                  if (!code) {
                      msgEl.innerText = "";
                      currentReferral = null;
                      updatePriceUI();
                      return;
                  }

                  msgEl.style.color = "var(--text-dim)";
                  msgEl.innerText = "Validating...";

                  try {
                      const res = await fetch('/api/validate-referral', {
                          method: 'POST',
                          headers: { 'Content-Type': 'application/json' },
                          body: JSON.stringify({ referralCode: code, buyerSteamId: "${steamid}" })
                      });
                      const data = await res.json();

                      if (data.valid) {
                          msgEl.style.color = "#00c853";
                          msgEl.innerText = data.message;
                          currentReferral = code;
                      } else {
                          msgEl.style.color = "#ff4d4d";
                          msgEl.innerText = data.message;
                          currentReferral = null;
                      }
                      updatePriceUI();
                  } catch (e) {
                      msgEl.style.color = "#ff4d4d";
                      msgEl.innerText = "Validation failed.";
                      currentReferral = null;
                      updatePriceUI();
                  }
              }

              function updatePerks() {
                  const list = document.getElementById('perks-list');
                  list.innerHTML = perks[selectedPkgName].map(p => \`<li>\${p}</li>\`).join('');
              }

              async function refreshTransactions() {
                  try {
                      const res = await fetch('/api/my-transactions');
                      const txs = await res.json();
                      const container = document.querySelector('.tx-list') || document.querySelector('.no-tx');
                      if (!container) return;

                      if (txs.length === 0) {
                          container.outerHTML = '<div class="no-tx">No past transactions found.</div>';
                          return;
                      }

                      const html = txs.map(tx => \`
                          <div class="tx-item">
                              <div class="tx-header">
                                  <span class="tx-package">\${tx.package}</span>
                                  <span class="tx-amount">$\${tx.amount}</span>
                              </div>
                              <div class="tx-meta">
                                  <span>ID: \${tx.id.slice(0, 12)}...</span>
                                  <span>\${new Date(tx.date).toLocaleDateString()}</span>
                              </div>
                          </div>
                      \`).join('');

                      if (container.classList.contains('no-tx')) {
                          container.outerHTML = \`<div class="tx-list">\${html}</div>\`;
                      } else {
                          container.innerHTML = html;
                      }
                  } catch (e) { console.error("Failed to refresh transactions", e); }
              }

              function goToStep(step) {
                  document.getElementById('step-1').style.display = (step === 1) ? 'flex' : 'none';
                  document.getElementById('step-2').style.display = (step === 2) ? 'flex' : 'none';
                  if (step === 2) {
                      syncCheckoutExtras();
                      updatePriceUI();
                  }
              }

              async function startCheckout() {
                  const btn = document.getElementById('pay-btn');
                  const oldText = btn.innerText;
                  btn.innerText = "REDIRECTING...";
                  btn.disabled = true;

                  try {
                      const res = await fetch('/create-checkout-session', {
                          method: 'POST',
                          headers: { 'Content-Type': 'application/json' },
                          body: JSON.stringify({
                               packageName: selectedPkgName === '$LP' ? '$LP (' + selectedPkgPrice + ')' : selectedPkgName,
                               price: selectedPkgPrice,
                               steamid: "${steamid}",
                               referralCode: currentReferral,
                               creditUsed: appliedCredit
                           })
                      });
                      const data = await res.json();
                      
                      if (data.url) {
                          window.location.href = data.url;
                      } else if (data.success) {
                          // Handle $0.00 checkout
                          window.location.href = "/store?success=1";
                      } else {
                          // Show the real error message from the server/Stripe
                          throw new Error(data.error || "Stripe session creation failed");
                      }
                  } catch (e) {
                      alert("⚠️ Checkout Error: " + e.message);
                      btn.innerText = oldText;
                      btn.disabled = false;
                  }
              }

              window.addEventListener('load', () => {
                  syncCheckoutExtras();
                  updatePerks();
                  
                  const urlParams = new URLSearchParams(window.location.search);
                  if (urlParams.has('success')) {
                      document.getElementById('success-msg').style.display = 'flex';
                      
                      // Auto-refresh transactions every 4 seconds to catch the webhook update
                      const pollInterval = setInterval(refreshTransactions, 4000);
                      
                      // Clear interval if user leaves or after 2 minutes
                      setTimeout(() => clearInterval(pollInterval), 120000);
                  }
              });
          </script>
        `;
        } else {
            // Home Page
            subHeaderTitle = "HOME";
            let serverData = [];
            try {
                const serverRes = await fetch("https://api.dxrp.net/v1/public/servers");
                serverData = await serverRes.json();
                console.log("Server List Received:", JSON.stringify(serverData));
            } catch (e) {
                console.error("Failed to fetch server data:", e);
            }

            const isLifePunchServer = (s) =>
                s && (s.network === "LifePunch" || (s.name && s.name.includes("LifePunch Official")));
            const s1 = serverData.find(
                (s) => isLifePunchServer(s) && s.name && s.name.includes("70p") && !/DEVELOPMENT/i.test(s.name)
            );
            const s2 = serverData.find(
                (s) => isLifePunchServer(s) && s.name && /DEVELOPMENT/i.test(s.name)
            );
            const c1 = s1?.playerCount ?? 0;
            const c2 = s2?.playerCount ?? 0;

            bodyContent = `
            <style>
                .top-disclaimer { text-align: center; color: var(--text-dim); margin-bottom: 30px; font-size: 14px; text-transform: uppercase; font-weight: bold; letter-spacing: 1px; }
                .server-card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 30px; display: flex; align-items: center; justify-content: space-between; gap: 15px; flex-wrap: wrap; margin-bottom: 15px; }
                .server-card:last-child { margin-bottom: 0; }
                @media (max-width: 700px) {
                    .server-card { padding: 20px; }
                    .server-card .copy-btn { width: 100%; padding: 14px; }
                }
                .server-info h3 { margin: 0; color: #fff; font-family: 'Montserrat', sans-serif; font-size: 18px; }
                .server-info p { margin: 5px 0 0; color: var(--lp-blue); font-weight: bold; font-size: 11px; text-transform: uppercase; }
                .copy-btn { background: var(--lp-blue); color: #fff; border: none; padding: 12px 25px; border-radius: 6px; font-weight: 900; cursor: pointer; transition: 0.3s; white-space: nowrap; }
                .copy-btn:hover { transform: scale(1.05); filter: brightness(1.2); }
                .copy-btn.copied { background: #00c853; }
                .btn-link.copied { background: #00c853; border-color: #00c853; color: #fff; }
                </style>
            
            <div class="top-disclaimer">LifePunch s&box Server List</div>
            
            <div class="server-card">
                <div class="server-info">
                    <h3>LifePunch Official | 70p | DXRP</h3>
                    <p>${c1}/70 players</p>
                </div>
                <button type="button" class="copy-btn" data-connect="90285428148008983">COPY IP</button>
            </div>

            <div class="server-card">
                <div class="server-info">
                    <h3>LifePunch Official | DEVELOPMENT SERVER</h3>
                    <p>${c2}/70 players</p>
                </div>
                <button type="button" class="copy-btn" data-connect="90286578983366679">COPY IP</button>
            </div>

            <script>
                function legacyCopyToClipboard(text) {
                    return new Promise(function (resolve, reject) {
                        var ta = document.createElement("textarea");
                        ta.value = text;
                        ta.setAttribute("readonly", "");
                        ta.style.cssText = "position:fixed;left:-9999px;top:0;opacity:0";
                        document.body.appendChild(ta);
                        ta.focus();
                        ta.select();
                        ta.setSelectionRange(0, text.length);
                        var ok = false;
                        try { ok = document.execCommand("copy"); } catch (e) { ok = false; }
                        document.body.removeChild(ta);
                        if (ok) resolve();
                        else reject(new Error("Copy failed"));
                    });
                }
                function copyTextToClipboard(text) {
                    if (text == null || text === "") return Promise.reject(new Error("Nothing to copy"));
                    if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {
                        return navigator.clipboard.writeText(text).catch(function () {
                            return legacyCopyToClipboard(text);
                        });
                    }
                    return legacyCopyToClipboard(text);
                }
                function copyConnect(btn) {
                    var id = btn.getAttribute("data-connect");
                    if (!id) return;
                    var text = "connect " + id;
                    var label = btn.innerText;
                    copyTextToClipboard(text).then(function () {
                        btn.innerText = "COPIED!";
                        btn.classList.add("copied");
                        setTimeout(function () {
                            btn.innerText = label;
                            btn.classList.remove("copied");
                        }, 2000);
                    }).catch(function () {
                        btn.innerText = "COPY FAILED";
                        btn.classList.remove("copied");
                        setTimeout(function () { btn.innerText = label; }, 2000);
                    });
                }
                document.querySelectorAll(".copy-btn[data-connect]").forEach(function (btn) {
                    btn.addEventListener("click", function () { copyConnect(btn); });
                });
            </script>
          `;        }

        // Final HTML Generation
        let finalHtml = `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>${pageTitle}</title>
            ${sharedHead}
        </head>
        <body${bodyClass ? ` class="${bodyClass}"` : ""}>
            <div class="container">
                ${getHeader(subHeaderTitle)}
                ${bodyContent}
            </div>
            ${isEmbed ? "" : sharedFooter}
        </body>
        </html>
      `;

        const responseHeaders = {
            "Content-Type": "text/html;charset=UTF-8",
            "X-Content-Type-Options": "nosniff",
            "Referrer-Policy": "strict-origin-when-cross-origin",
            "Access-Control-Allow-Origin": "*",
            ...buildSecurityHeaders(isEmbed)
        };

        if (path === "/rules" || path === "/rules/raw") {
            responseHeaders["Cache-Control"] = "public, max-age=120, stale-while-revalidate=600";
        }

        return new Response(finalHtml, { headers: responseHeaders });
    },

    async email(message, env, ctx) {
        const from = (message.from || "unknown").toLowerCase().trim();
        const to = (message.to || "unknown").toLowerCase().trim();
        const subject = (message.headers.get("Subject") || "(No Subject)").trim();
        
        const processEmail = async () => {
            let body = "";
            try {
                const response = new Response(message.raw);
                const rawText = await response.text();
                const normalizedText = rawText.replace(/\r\n/g, "\n");

                const decodeB64 = (str) => {
                    try {
                        const bin = atob(str.replace(/\s/g, ""));
                        return new TextDecoder().decode(Uint8Array.from(bin, m => m.charCodeAt(0)));
                    } catch (e) { return str; }
                };

                // 1. GATHER BOUNDARIES (Header + Aggressive Scan)
                let boundaries = new Set();
                const contentType = message.headers.get("Content-Type") || "";
                const bMatch = contentType.match(/boundary=(?:"([^"]+)"|([^;\s]+))/i);
                if (bMatch) boundaries.add(bMatch[1] || bMatch[2]);
                
                // Scan for boundary-like patterns (lines starting with --)
                const scanner = normalizedText.split("\n");
                for (let line of scanner) {
                    if (line.startsWith("--") && line.length > 5) {
                        let b = line.substring(2);
                        if (b.endsWith("--")) b = b.slice(0, -2);
                        boundaries.add(b);
                    }
                }

                // 2. EXTRACT CONTENT
                let bestPart = "";
                let foundPlain = false;

                if (boundaries.size > 0) {
                    for (let boundary of boundaries) {
                        const parts = normalizedText.split("--" + boundary);
                        for (let part of parts) {
                            const lowPart = part.toLowerCase();
                            // Check for content parts
                            if (lowPart.includes("content-type:")) {
                                // Find body (after any double newline)
                                const bodyIdx = part.search(/\n\s*\n/);
                                if (bodyIdx !== -1) {
                                    let partHeaders = part.substring(0, bodyIdx).toLowerCase();
                                    let partBody = part.substring(bodyIdx).trim();
                                    
                                    // Clean up trailing boundaries
                                    for (let b2 of boundaries) {
                                        if (partBody.includes("--" + b2)) {
                                            partBody = partBody.split("--" + b2)[0].trim();
                                        }
                                    }

                                    const decoded = partHeaders.includes("base64") ? decodeB64(partBody) : partBody;
                                    
                                    if (lowPart.includes("text/plain")) {
                                        bestPart = decoded;
                                        foundPlain = true;
                                        break; 
                                    } else if (!foundPlain && lowPart.includes("text/html")) {
                                        bestPart = decoded;
                                    }
                                }
                            }
                        }
                        if (foundPlain) break;
                    }
                }

                // 3. FAIL-SAFE FALLBACK
                if (!bestPart) {
                    const bodyIdx = normalizedText.search(/\n\s*\n/);
                    const rawBody = bodyIdx !== -1 ? normalizedText.substring(bodyIdx).trim() : normalizedText;
                    const isB64 = (message.headers.get("Content-Transfer-Encoding") || "").toLowerCase().includes("base64");
                    bestPart = isB64 ? decodeB64(rawBody) : rawBody;
                }

                // 4. CLEANUP (Final Strip of any leaked MIME headers)
                body = bestPart;
                // Aggressively strip any lines that look like internal MIME headers
                const lines = body.split("\n");
                body = lines.filter(line => {
                    const l = line.toLowerCase().trim();
                    return !l.startsWith("content-type:") && 
                           !l.startsWith("content-transfer-encoding:") && 
                           !l.startsWith("content-id:") &&
                           !l.startsWith("content-disposition:");
                }).join("\n").trim();

                // Final HTML/Space cleanup
                body = body.replace(/<style[\s\S]*?<\/style>/gi, ""); 
                body = body.replace(/<[^>]+>/g, "\n"); 
                body = body.replace(/&nbsp;/g, " ");
                body = body.replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
                body = body.replace(/\n{3,}/g, "\n\n").trim();

            } catch (err) {
                body = "[Processing Error: " + err.message + "]";
            }

            try {
                await env.DB.prepare(
                    "INSERT INTO emails (msg_from, msg_to, subject, body, is_read, is_deleted) VALUES (?, ?, ?, ?, 0, 0)"
                ).bind(from, to, subject, body).run();
            } catch (dbErr) {
                try {
                    await env.DB.prepare(
                        "INSERT INTO emails (msg_from, msg_to, subject, body, is_read) VALUES (?, ?, ?, ?, 0)"
                    ).bind(from, to, subject, body).run();
                } catch (fallbackErr) {
                    await env.DB.prepare(
                        "INSERT INTO emails (msg_from, msg_to, subject, body, is_read) VALUES (?, ?, ?, ?, 1)"
                    ).bind("SYSTEM", "ADMIN", "Email Receive Error", `Failed: ${fallbackErr.message}`).run();
                }
            }
        };

        ctx.waitUntil(processEmail());
    }
};