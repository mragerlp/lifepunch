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
                open: true,
                rules: [
                    { id: "en-only", html: "<b>English Only</b> — We're an English-speaking community. Please keep all roleplay in English." },
                    { id: "no-cheat", html: "<b>No Cheating</b> — Using third-party software, cheats, macros, or autoclickers will result in a permanent ban." },
                    { id: "no-exploit", html: "<b>No Exploiting</b> — Exploiting maps, items, or tools for an unfair advantage is not allowed (drug creation and gun shops are excluded). You may not base outside the map; the rock boundary is the limit." },
                    { id: "no-mic-spam", html: "<b>No Mic or Text Spam</b> — Intentionally disrupting roleplay through your microphone or chat spam is not allowed." },
                    { id: "no-staff-impersonation", html: "<b>No Staff Impersonation</b> — Impersonating staff will result in a permanent ban." },
                    { id: "no-lie-staff", html: "<b>Do Not Lie to Staff</b> — False reporting or deleting ticket evidence is punishable." },
                    { id: "no-staff-baiting", html: "<b>No Staff Baiting</b> — Saying you will break a rule counts as breaking that rule." },
                    { id: "no-minimodding", html: "<b>No Minimodding</b> — Do not threaten others with reports. Submit reports properly and move on." },
                    { id: "admin-final-say", html: "<b>Admin Final Say</b> — Do not argue with staff about rules or punishments. Staff always have the final say in situations not listed." },
                    { id: "no-begging", html: "<b>No Begging</b> — Soliciting real money or real-life items is not allowed." },
                    { id: "no-bullying", html: "<b>No Bullying</b> — Targeting or harassing players outside of roleplay is never tolerated." },
                    { id: "no-politics", html: "<b>No Politics/War/Religion</b> — Political arguments are not allowed. Jokes are fine; arguments are not." },
                    { id: "no-racism", html: "<b>No Racism/Homophobia</b> — There is zero tolerance for racism or homophobia. Violations will result in a permanent ban." },
                    { id: "no-nsfw", html: "<b>No Sexual/NSFW Content</b> — All media must remain PG-rated. This includes ERP and pornographic content." },
                    { id: "no-doxing", html: "<b>No Doxing</b> — Posting real-life pictures of someone without permission will result in a permanent ban." },
                    { id: "no-cybercrime", html: "<b>Cybercrime Threats</b> — Threatening DDoS attacks or doxing will result in a permanent ban." },
                    { id: "no-advertising", html: "<b>No Advertising</b> — Only official DXRP or S&box links are allowed." },
                    { id: "no-irl-illegal", html: "<b>No IRL Illegal Activity</b> — Encouraging illegal real-life activity will result in a permanent ban." }
                ]
            },
            {
                num: 2,
                title: "Basic RP Rules",
                icon: "fa-lightbulb",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 2A: RDM / RDA",
                        webBtn: "🔺 RDM / RDA",
                        rules: [
                            { id: "rdm-definition", html: "<b>RDM Definition</b> —  Random Deathmatch: Killing or arresting without a valid RP reason." },
                            { id: "rdm-reason", html: "<b>RDM Reasoning</b> —  Disrespect/threats aren't reasons to kill. Taking damage/stealing are." },
                            { id: "rdm-kos", html: "<b>KOS Line</b> — Crossing a clearly marked KOS line is not considered RDM." },
                            { id: "rdm-kos2", html: "<b>KOS Line Boundaries</b> — KOS lines are general markers for where KOS begins. Once a KOS line is placed, that entire base is considered KOS." },
                            { id: "rdm-warnings", html: "<b>Warnings</b> — You can kill someone after warning them 3 times in chat to step away." },
                            { id: "rdm-police", html: "<b>Police</b> — You can be killed by the person you're trying to arrest if the situation escalates." },
                            { id: "rdm-mayor", html: "<b>Mayor</b> — Killing the Mayor requires a valid RP reason (PD raid, mug, kidnap/hostage)." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2B: NLR (New Life Rule)",
                        webBtn: "🔺 NLR (New Life Rule)",
                        rules: [
                            { id: "nlr-definition", html: "<b>NLR Definition</b> — New Life Rule: You can remember past events, but can't act on them." },
                            { id: "nlr-trigger", html: "<b>NLR Trigger</b> — Applies on death, job change, and jail release (unless escaped)." },
                            { id: "nlr-raid", html: "<b>Raid</b> — You may not return to a raid after death. You must wait until the raid is completed to return to your base as a defender." },
                            { id: "nlr-revive", html: "<b>Revives</b> — Revived players may continue their raid/scenario." },
                            { id: "nlr-hitman", html: "<b>Hitmen</b> — Hitmen cannot re-attempt failed hits (Hit is failed upon death)." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2C: Fail RP",
                        webBtn: "🔺 Fail RP",
                        rules: [
                            {
                                id: "fail-rp",
                                html: "<b>Fail RP Logic</b> — Actions that break character, violate the established setting's logic, or disregard server rules, resulting in poor-quality, unrealistic, or disruptive play."
                            },
                            {
                                id: "fail-rp-examples",
                                html: `<b>Examples</b><ul class="rule-sublist"><li>Stealing your base mate's valuables and then starting a new base</li><li>Mugging someone with a partner, then killing that partner</li><li>Police working with thieves or gangsters</li><li>Door camping or blocking doors</li></ul>`
                            }
                        ]
                    }
                ]
            },
            {
                num: 3,
                title: "Common Sense & Behavior",
                icon: "fa-brain",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 3A: BASIC GUIDELINES",
                        webBtn: "🔹 Basic Guidelines",
                        rules: [
                            { id: "fearrp", html: "<b>FearRP</b> — Not enforced, but value your life reasonably." },
                            { id: "gov-raid", html: "<b>Government Raid</b> — Government cannot raid with Criminals (except Hitman)." },
                            { id: "no-suicide-rp", html: "<b>No Suicide RP</b> — No suicide to avoid RP scenarios (kidnaps, mugs)." },
                            { id: "job-arrest", html: "<b>Job Arrest</b> — Government cannot raid/arrest just because of someone's Job." },
                            { id: "job-desc", html: "<b>Job Description</b> — Must follow job descriptions (Medics heal, Merchants/Dealers sell, Cops protect)." },
                            { id: "merchant-deny", html: "<b>Merchant Deny</b> — Denying Merchant service for non-RP reasons is forbidden (e.g., denying gun sales to a potential raider)." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 3B: CONDUCT RULES",
                        webBtn: "🔹 Conduct Rules",
                        rules: [
                            { id: "no-job-change", html: "<b>No Job Change</b> — No changing jobs during active RP." },
                            { id: "demote-reasons", html: "<b>Demote Reasons</b> — Valid demote reasons include being AFK for 30+ minutes, not doing your job, and police corruption." },
                            { id: "no-vigilante", html: "<b>No Vigilante</b> — Do not punish rulebreakers yourself (AOS/KOS/Propblock)." },
                            { id: "scamming", html: "<b>Scamming</b> — Merchants cannot scam." }
                        ]
                    }
                ]
            },
            {
                num: 4,
                title: "Building Rules",
                icon: "fa-hammer",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 4A: PROP & WIRE",
                        webBtn: "🔐 Prop & Wire",
                        rules: [
                            { id: "spawn-build", html: "<b>Spawn Build</b> — No building in spawn. No prop climbing, flying, or blocking." },
                            { id: "wire-abuse", html: "<b>Wire Abuse</b> — Wire abuse is not allowed, including auto-stealing money, loud sounds, stealing shipments, and using wire to annoy other players." },
                            { id: "prop-permission", html: "<b>Property Respect</b> — You may not place props on, build into, or occupy another player's property or base without permission." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4B: FADING DOORS",
                        webBtn: "🚪 Fading Doors",
                        rules: [
                            { id: "fd-limit", html: "<b>Fading Door Limit</b> — Max 2 fading doors to get access to your raidables." },
                            { id: "fd-utility", html: "<b>Fading Door Utility</b> — Utility doors (one-way exits, peeks) are allowed." },
                            { id: "fd-airlocks", html: "<b>Fading Door Airlocks</b> — Airlocks must be identifiable and distinct (color/material)." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4C: BASE LAYOUT & FAIRNESS",
                        webBtn: "🏠 Base Layout & Fairness",
                        rules: [
                            { id: "base-reachable", html: "<b>Base Reachable</b> — Bases must be reachable/accessible at all times." },
                            { id: "base-entrance", html: "<b>Base Entrance</b> — Min/Max 1 entrance. Unused map doors must be blocked." },
                            { id: "base-crouch", html: "<b>Base Jump/Crouch</b> — Raiders must never be forced to crouch or jump at any time inside/outside OR to gain access to a base." },
                            { id: "base-mazes", html: "<b>Base Mazes</b> — No Mazes. A maze is defined as more than 1×180° turn OR 2×90° turns OR multiple disorienting/excessive pathways used to artificially extend raid duration. Artificial raid hallways/airlocks start at your KoS sign & must not exceed 25 total 1×1 props (1000 units) excluding natural map layouts." },
                            { id: "base-kos-line", html: "<b>Base KOS Line</b> — KOS zones must start at a base's purchasable front/fading door or at the start of an airlock. KOS lines must have a text sign that says 'KOS past'." },
                            { id: "base-shooting", html: "<b>Base Shooting</b> — Raiders must be able to clearly see you and shoot back. Cannot use tiny hitboxes for unfair advantage." },
                            { id: "base-crowbar", html: "<b>Base Crowbar</b> — Bases must be crowbar-raidable (no code-only)." },
                            { id: "base-damage", html: "<b>Base Damage</b> — Bases cannot damage players." },
                            { id: "base-movement", html: "<b>Base Movement</b> — No slowing/impeding movement." },
                            { id: "base-entrances", html: "<b>Base Entrances</b> — Entrances must be reasonably easy to find, visible & distinct from surrounding walls; minimum 2×2 standing area (80×80 units)." },
                            { id: "base-walkways", html: "<b>Base Walkways</b> — Walkways must be at least 1×1 prop (40 units) wide (includes ramps)." },
                            { id: "base-no-collide", html: "<b>Base No Collide</b> — No-collide props must not be confusing for raiders; they should be visually distinct." },
                            { id: "entity-ladders", html: "<b>Entity Ladders</b> — Bases must not require the use of entity ladders at any time." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4D: PLACEMENT & MAP RULES",
                        webBtn: "🗺 Placement & Map Rules",
                        rules: [
                            { id: "public-space", html: "<b>Public Space</b> — Do not take up excessive public space." },
                                                        { id: "pd-building", html: "<b>PD Building</b> — Do not build in PD if not Government." },
                            { id: "blocking-off", html: "<b>Blocking Off</b> — Do not block weed drop-off, ATMs, trash cans, recycler." },
                            { id: "drop-offs", html: "<b>Drop-Offs</b> — Weed drop-off must be fully walkable." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 4E: SPECIAL BUILDING RESTRICTIONS",
                        webBtn: "🚧 Special Building Restrictions",
                        rules: [
                            { id: "special-doors", html: "Only buy doors you intend to use." },
                            { id: "no-skybases", html: "No skybases or excessive aerial builds." },
                            { id: "drop-connection", html: "Max 1 connection to a drug drop-off location." },
                            { id: "decorative-aerial", html: "Decorative aerial builds allowed." },
                            { id: "no-blackout", html: "No blackout bases." },
                            { id: "kos-understandable", html: "KOS zones must be understandable and never deceptive." }
                        ]
                    }
                ]
            },
            {
                num: 5,
                title: "Job Specific Rules",
                icon: "fa-briefcase",
                subcategories: [
                    {
                        rawTitle: "SUB-CATEGORY 5A: MAYOR & CP",
                        webBtn: "👑 Mayor & CP",
                        rules: [
                            {
                                id: "mayor-base",
                                html: `<b>Mayor</b><ul class="rule-sublist"><li>The Mayor must base in the PD.</li><li>Gun licenses may include a fee, but the Mayor is not obligated to provide them to criminals.</li><li>The Mayor may build outside the PD only for government or roleplay use, such as checkpoints or toll booths.</li><li>Major law changes must be announced before enforcement.</li></ul>`
                            },
                            {
                                id: "police-base",
                                html: `<b>Police</b><ul class="rule-sublist"><li>Police must base in the PD and allow all government members to base and roleplay with them.</li><li>Follow the command hierarchy.</li><li>Attempt to arrest before killing, unless the suspect has a weapon drawn.</li></ul>`
                            },
                            {
                                id: "laws",
                                html: `<b>Laws</b><ul class="rule-sublist"><li>Laws must be reasonable and must not contradict server rules.</li><li>You cannot make things said in text/voice chat illegal (i.e. Police Disrespect).</li><li>AoS laws are allowed; KOS laws are not.</li><li>Laws may not target specific individuals or jobs.</li></ul>`
                            },
                            {
                                id: "arrests",
                                html: `<b>Arrests</b><ul class="rule-sublist"><li>Arrests may only be made against lawbreakers.</li><li>You may not arrest innocent players, even if bribed.</li></ul>`
                            },
                            {
                                id: "lockdowns",
                                html: `<b>Lockdowns</b><ul class="rule-sublist"><li>Lockdowns may only be used outdoors.</li><li>You may arrest during a lockdown, but KOS is not allowed.</li><li>A valid reason is required, such as a bank raid or active shooting.</li></ul>`
                            },
                            {
                                id: "corruption",
                                html: `<b>Corruption</b><ul class="rule-sublist"><li>Corruption is allowed in roleplay, but not against other government members.</li><li>Bribes are allowed.</li><li>Helping criminals raid the PD or killing government members is forbidden.</li></ul>`
                            },
                            {
                                id: "warrants",
                                html: `<b>Warrants</b><ul class="rule-sublist"><li>Warrants require valid roleplay evidence.</li><li>You must witness illegal activity.</li><li>Metagaming is not allowed.</li><li>Warrants expire on death, jail, or successful raid defense.</li></ul>`
                            },
                            {
                                id: "checkpoints",
                                html: `<b>Checkpoints and Tolls</b><ul class="rule-sublist"><li>Checkpoints and toll booths must not block spawn-area entrances or exits, and must not extend raid duration.</li><li>Tolls may not exceed $50.</li><li>A maximum of two checkpoints or toll booths is allowed.</li></ul>`
                            },
                            {
                                id: "searches",
                                html: `<b>Searches</b><ul class="rule-sublist"><li>Searches require a roleplay reason, such as nearby gunshots or loitering near a drug drop-off.</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 5B: CIVILIAN",
                        webBtn: "👨‍🔧 Civilian",
                        rules: [
                            {
                                id: "gun-dealer",
                                html: `<b>Gun Dealer</b><ul class="rule-sublist"><li>Gun Dealers must intend to sell weapons.</li><li>They may not base with another Gun Dealer.</li><li>They may defend a criminal base.</li><li>They must sell individual weapons, not only shipments.</li></ul>`
                            },
                            {
                                id: "medic",
                                html: `<b>Medic</b><ul class="rule-sublist"><li>Only one Medic is allowed per raid party.</li></ul>`
                            },
                            {
                                id: "theatre-manager",
                                html: `<b>Theatre Manager</b><ul class="rule-sublist"><li>The Theatre Manager must base in the Theatre.</li></ul>`
                            }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 5C: CRIMINAL",
                        webBtn: "🔫 Criminal",
                        rules: [
                            {
                                id: "hitman",
                                html: `<b>Hitman</b><ul class="rule-sublist"><li>Hitmen may not metagame hits.</li><li>Only Hitmen may perform hits.</li><li>A valid roleplay reason is not required unless the target is the Mayor.</li><li>Hitmen may only raid active target locations, and only one Hitman is allowed per raid.</li></ul>`
                            }
                        ]
                    }
                ]
            },
            {
                num: 6,
                title: "Raiding & Mugging",
                icon: "fa-bomb",
                blocks: [
                    { type: "heading", raw: "RAID RULES", web: "Raid Rules", underline: true },
                    {
                        type: "rules",
                        rules: [
                            { id: "raid-guidelines", html: "<b>Raiding Guidelines</b> — A raid starts when a prybar is out, a base member is damaged, or when a weapon is drawn on the property. A raid ends when no raiders remain inside or on the property." },
                            { id: "mid-raid", html: "<b>Mid-Raid</b> — No props can be moved, changed, deleted or added during raids. You can use an entity ladder to get into a flawed/open base." },
                            { id: "pd-raid", html: "<b>Police Raid</b> — Ends when all Police attending raid die. Returning to a Police raid after death breaks NLR." }
                        ]
                    },
                    {
                        type: "guide",
                        rawHeading: "RAID GUIDE (✅ Can Raid)",
                        webHeading: "Raid Guide (✅ Can Raid)",
                        items: [
                            "Medic (1 per raid)",
                            "Drug Dealer",
                            "Gangster",
                            "Mob Boss",
                            "Hitman (Hit required on raid target)",
                            "Thief"
                        ]
                    },
                    { type: "heading", raw: "MUGGING RULES", web: "Mugging Rules", underline: true },
                    {
                        type: "rules",
                        rules: [
                            { id: "mug-limit", html: "<b>$ Limit</b> — Max mug $1,000. Must type mug warning. 10s response time required." },
                            { id: "mug-cooldown", html: "<b>Cooldown</b> — There is a 5-minute cooldown between mugs. Don't mug the same person repeatedly." },
                            { id: "mug-defense", html: "<b>Defense</b> — A victim of a mugging/kidnapping is always allowed to defend themselves without warning." },
                            { id: "mug-shipments", html: "<b>Shipments</b> — Can mug shipments/guns if you see someone collect it; same warning rules apply." }
                        ]
                    },
                    {
                        type: "guide",
                        rawHeading: "MUG GUIDE (✅ Can Mug)",
                        webHeading: "Mug Guide (✅ Can Mug)",
                        items: ["Hobo", "Drug Dealer", "Gangster", "Mob Boss", "Thief"]
                    }
                ]
            },
            {
                num: 7,
                title: "Minging / Trolling",
                icon: "fa-mask",
                rules: [
                    {
                        id: "minging-prohibited",
                        html: `<b>Prohibited</b> — The following actions are considered minging or trolling:<ul class="rule-sublist"><li>Baiting RDM or RDA</li><li>Excessive trolling</li><li>Preventing others from building</li><li>Preventing new players from learning</li><li>Repeatedly raiding someone with no valuables</li><li>Kidnapping without a roleplay reason</li><li>Disobeying staff or reasonable requests</li></ul>`
                    }
                ]
            },
            {
                num: 8,
                title: "Cooldowns & Reporting",
                icon: "fa-clock",
                blocks: [
                    { type: "heading", raw: "COOLDOWNS", web: "Cooldowns" },
                    {
                        type: "rules",
                        rules: [
                            {
                                id: "cooldowns",
                                html: `<b>Cooldowns</b> — The following timers apply between repeated actions.<ul class="rule-sublist"><li>You may not spam-mug, spam-hit, or spam-raid the same person after successful attempts. Space things out and RP with other people or it could be considered harassment.</li><li>Mugging: 5 minutes between mugs</li><li>Hits: 15 minute cooldown for placing hits on the same person</li><li>Raiding the same base after a failed attempt: 10 minutes</li><li>Raiding the same base after a successful attempt: 25 minutes</li><li>PD raid: 10 minutes</li><li>Mayor: 10-minute grace period before they can be raided or killed after they're elected</li><li>Mayor kidnapping: 30 minutes</li><li>No raiding for 10 minutes after a server crash</li></ul>`
                            }
                        ]
                    },
                    { type: "heading", raw: "REPORTING RULES", web: "Reporting Rules" },
                    {
                        type: "rules",
                        rules: [
                            {
                                id: "report-respect",
                                html: `<b>Reporting</b> — When submitting a report:<ul class="rule-sublist"><li>Be respectful</li><li>Do not spam reports</li><li>Provide proof (Medal, OBS, or Steam)</li></ul>`
                            },
                            { id: "report-lying", html: "<b>Report Lying</b> — Lying to staff results in a PERMANENT ban." },
                            { id: "report-use", html: "<b>Report Use</b> — Use @ or /Staff in-game. EVIPs can jail in severe cases." }
                        ]
                    }
                ]
            }
        ];

        const renderRawRulesList = (rules) =>
            (rules || []).map((r) => `<li>${r.html}</li>`).join("\n                            ");

        const renderRawSubcategory = (sub) => `
                        <h4>${sub.rawTitle}</h4>
                        <ul>
                            ${renderRawRulesList(sub.rules)}
                        </ul>`;

        const renderRawGuide = (block) => `
                        <h4>${block.rawHeading}</h4>
                        <ul>
                            ${block.items.map((item) => `<li>${item} — ✅</li>`).join("\n                            ")}
                        </ul>`;

        const renderRawBlock = (block) => {
            if (block.type === "heading") return `<h4${block.underline ? ' class="rule-heading-underline"' : ""}>${block.raw}</h4>`;
            if (block.type === "rules") return `<ul>\n                            ${renderRawRulesList(block.rules)}\n                        </ul>`;
            if (block.type === "guide") return renderRawGuide(block);
            if (block.type === "cooldowns") {
                return `<ul>\n                            ${block.rawItems.map((item) => `<li>${item}</li>`).join("\n                            ")}\n                        </ul>`;
            }
            return "";
        };

        const renderRawCategoryBody = (cat) => {
            let html = "";
            if (cat.rules) {
                html += `<ul>\n                            ${renderRawRulesList(cat.rules)}\n                        </ul>`;
                if (cat.footer) html += cat.footer;
            }
            if (cat.subcategories) html += cat.subcategories.map(renderRawSubcategory).join("");
            if (cat.blocks) html += cat.blocks.map(renderRawBlock).join("");
            return html;
        };

        const renderRawRulesDocument = () => `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
                <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@900&family=Inter:wght@400;600&display=swap" rel="stylesheet">
                <style>
                    :root { --lp-blue: #0076E3; --bg: #02040a; --surface: rgba(255, 255, 255, 0.05); --border: rgba(255, 255, 255, 0.1); }
                    body { font-family: 'Inter', sans-serif; background: var(--bg); color: #fff; margin: 0; padding: 20px; line-height: 1.6; }
                    .header { text-align: center; margin-bottom: 30px; }
                    .header h1 { font-family: 'Montserrat', sans-serif; font-size: 32px; text-transform: uppercase; margin: 0; color: var(--lp-blue); }
                    .header p { color: #a0a8b5; font-size: 14px; }
                    details { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; margin-bottom: 10px; overflow: hidden; }
                    summary { padding: 15px 20px; cursor: pointer; font-weight: bold; list-style: none; display: flex; justify-content: space-between; align-items: center; text-transform: uppercase; font-size: 14px; letter-spacing: 1px; }
                    summary::-webkit-details-marker { display: none; }
                    summary::after { content: '➔'; color: var(--lp-blue); transition: 0.3s; }
                    details[open] summary::after { transform: rotate(90deg); }
                    details[open] summary { border-bottom: 1px solid var(--border); background: rgba(0, 118, 227, 0.1); }
                    .content { padding: 20px; font-size: 14px; color: #f0f2f5; }
                    .content ul { list-style: none; padding: 0; margin: 0; }
                    .content li { margin-bottom: 12px; padding-left: 15px; border-left: 2px solid var(--lp-blue); }
                    .content li ul.rule-sublist { list-style: disc; margin: 0; padding-left: 20px; }
                    .content li ul.rule-sublist li { border-left: none; padding-left: 0; margin-bottom: 6px; }
                    .content li b + ul.rule-sublist { margin-top: 2px; }
                    .content b { color: var(--lp-blue); }
                    .content h4.rule-heading-underline { text-decoration: underline; }
                    .important { color: #ff4d4d; font-weight: bold; margin-top: 15px; display: block; }
                    .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid var(--border); color: #a0a8b5; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>LifePunch Rules</h1>
                    <p>Official s&box DXRP Guidelines</p>
                </div>
                ${LP_RULES.map((cat) => `
                <details${cat.open ? " open" : ""}>
                    <summary>${cat.num}. ${cat.title}</summary>
                    <div class="content">${renderRawCategoryBody(cat)}</div>
                </details>`).join("")}
                <div class="footer">
                    Searchable rules available at lifepunch.co/rules<br>
                    &copy; 2026 LifePunch Network
                </div>
            </body>
            </html>`;

        const renderWebRulesList = (rules, rule) =>
            (rules || []).map((r) => rule(r.id, r.html)).join("\n                          ");

        const renderWebSubcategory = (sub, rule) => `
                          <div class="sub-cat">
                              <button class="sub-btn">${sub.webBtn} <i class="fa-solid fa-chevron-down chevron"></i></button>
                              <div class="content-wrapper"><div class="content">
                                  ${renderWebRulesList(sub.rules, rule)}
                              </div></div>
                          </div>`;

        const renderWebGuide = (block) => `
                          <div class="sub-title">${block.webHeading}</div>
                          <div class="guide-grid">
                              ${block.items.map((item) => `<div class="guide-item">${item}<span>✅</span></div>`).join("\n                              ")}
                          </div>`;

        const renderWebBlock = (block, rule) => {
            if (block.type === "heading") return `<div class="sub-title${block.underline ? " sub-title--underline" : ""}">${block.web}</div>`;
            if (block.type === "rules") return renderWebRulesList(block.rules, rule);
            if (block.type === "guide") return renderWebGuide(block);
            if (block.type === "cooldowns") return rule(block.webRule.id, block.webRule.html);
            return "";
        };

        const renderWebCategoryBody = (cat, rule) => {
            let html = "";
            if (cat.rules) {
                html += renderWebRulesList(cat.rules, rule);
                if (cat.footer) html += cat.footer;
            }
            if (cat.subcategories) html += cat.subcategories.map((sub) => renderWebSubcategory(sub, rule)).join("");
            if (cat.blocks) html += cat.blocks.map((block) => renderWebBlock(block, rule)).join("");
            return html;
        };

        const renderWebRulesRoot = (rule) =>
            LP_RULES.map((cat) => `
              <div class="category">
                  <button class="cat-btn">
                      <div class="icon-box"><i class="fa-solid ${cat.icon}"></i></div>
                      ${cat.title}
                      <i class="fa-solid fa-chevron-down chevron"></i>
                  </button>
                  <div class="content-wrapper">
                      <div class="content">
                          ${renderWebCategoryBody(cat, rule)}
                      </div>
                  </div>
              </div>`).join("");


        const STORE_PACKAGES = Object.freeze({
            VIP: { label: "VIP", price: 10.00 },
            EVIP: { label: "EVIP", price: 25.00 }
        });

        const resolveStorePackage = (packageName) => {
            const key = String(packageName ?? "").trim().toUpperCase();
            return STORE_PACKAGES[key] ? { key, ...STORE_PACKAGES[key] } : null;
        };

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
        let subHeaderTitle = "WELCOME TO THE PUNCH"; // Default subheader

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
                    "Set-Cookie": "lp_session=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Lax"
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
                const claimedId = originalParams.get("openid.claimed_id") || "";
                const authSteamId = claimedId.split("/").pop();
                if (!/^\d{17}$/.test(authSteamId)) {
                    return new Response("Authentication Failed.", { status: 401 });
                }
                
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
                        "Set-Cookie": `lp_session=${newSessionToken}; Path=/; Max-Age=2592000; HttpOnly; Secure; SameSite=Lax`
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

            const rewardsHook =
                (env.DISCORD_REWARDS_WEBHOOK_URL || "").trim() ||
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
                headers: { "Content-Type": "text/html;charset=UTF-8" }
            });
        }

        // --- STRIPE & DISCORD HELPERS ---
        
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
                if (!steamid) {
                    return new Response(JSON.stringify({ error: "Authentication required" }), { status: 401, headers: { 'Content-Type': 'application/json' } });
                }

                const { packageName: requestedPackageName, referralCode, creditUsed } = await request.json();
                const storePackage = resolveStorePackage(requestedPackageName);
                if (!storePackage) {
                    return new Response(JSON.stringify({ error: "Invalid package selection" }), { status: 400, headers: { 'Content-Type': 'application/json' } });
                }

                const packageName = storePackage.label;
                let finalPrice = storePackage.price;
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

            const eventId = event.id ? String(event.id) : "";
            const processedStripeEventKey = eventId ? `stripe:event:${eventId}` : "";
            if (linksKv && processedStripeEventKey) {
                const existingEventState = await linksKv.get(processedStripeEventKey);
                if (existingEventState) {
                    return new Response(JSON.stringify({ received: true, duplicate: true }), {
                        headers: { "Content-Type": "application/json" }
                    });
                }

                await linksKv.put(processedStripeEventKey, "processing", { expirationTtl: 86400 });
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

            if (linksKv && processedStripeEventKey) {
                await linksKv.put(processedStripeEventKey, "completed", { expirationTtl: 7776000 });
            }

            return new Response(JSON.stringify({ received: true }), {
                headers: { "Content-Type": "application/json" }
            });
        }

        // --- SHARED CSS AND HTML HEAD ---
        const sharedHead = `
        <meta charset="UTF-8">
        <meta name="view-transition" content="same-origin">
        <link rel="icon" type="image/png" href="https://i.imgur.com/WTosTpq.png">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@700;900&family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            :root { 
                --lp-blue: #0076E3; 
                --bg: #02040a; 
                --surface: rgba(255, 255, 255, 0.04); 
                --card-header: rgba(255, 255, 255, 0.07);
                --border: rgba(255, 255, 255, 0.12);
                --text-main: #f0f2f5;
                --text-dim: #a0a8b5;
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
                background: rgba(255, 255, 255, 0.02);
            }
            ::-webkit-scrollbar-thumb {
                background: var(--lp-blue);
                border-radius: 10px;
                border: 2px solid var(--bg);
            }
            ::-webkit-scrollbar-thumb:hover {
                background: #3399ff;
            }
            * {
                scrollbar-width: thin;
                scrollbar-color: var(--lp-blue) rgba(255, 255, 255, 0.02);
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
                    radial-gradient(at 80% 50%, rgba(0, 118, 227, 0.25) 0px, transparent 50%),
                    radial-gradient(at 20% 80%, rgba(0, 70, 160, 0.3) 0px, transparent 55%),
                    radial-gradient(at 50% 10%, rgba(0, 118, 227, 0.15) 0px, transparent 40%),
                    radial-gradient(at 100% 0%, rgba(0, 118, 227, 0.1) 0px, transparent 40%);
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
                filter: drop-shadow(0 0 20px rgba(0, 118, 227, 0.8)); 
                animation: logoStrobe 3s ease-in-out infinite;
            }
            @keyframes logoStrobe {
                0% { filter: drop-shadow(0 0 15px rgba(0, 118, 227, 0.5)); opacity: 0.85; }
                50% { filter: drop-shadow(0 0 35px rgba(0, 118, 227, 1)); opacity: 1; }
                100% { filter: drop-shadow(0 0 15px rgba(0, 118, 227, 0.5)); opacity: 0.85; }
            }
            h1 { 
                font-family: 'Montserrat', sans-serif;
                font-weight: 900; 
                color: #fff; 
                text-transform: uppercase; 
                letter-spacing: -2px; 
                margin: 0; 
                font-size: 48px; 
                text-shadow: 0 0 20px rgba(0, 118, 227, 0.4);
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
                background: rgba(255, 255, 255, 0.05); 
                padding: 10px 18px; 
                border-radius: 6px; 
                font-size: 11px; 
                margin: 5px; 
                display: inline-block;
                border: 1px solid var(--border); 
                transition: 0.2s; 
                font-weight: bold; 
                backdrop-filter: blur(10px) saturate(150%);
            }
            .links a:hover { 
                background: var(--lp-blue);
                border-color: rgba(255,255,255,0.4); 
                transform: translateY(-2px); 
                box-shadow: 0 5px 15px rgba(0, 118, 227, 0.3);
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
        </style>
        `;

        const getHeader = (subTitle) => {
            const currentPath = path + url.search;
            const returnParam = encodeURIComponent(currentPath);
            
            return `
        <header style="${isSbox ? 'margin-bottom: 20px;' : ''}">
            ${isSbox ? '' : `
            <div style="position: absolute; top: 10px; right: 20px; z-index: 100;">
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
            <img src="https://assets.lifepunch.co/logo.png" class="logo">

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
                        "Access-Control-Allow-Headers": "Content-Type, X-LifePunch-Sync-Secret",
                        "Access-Control-Max-Age": "86400",
                    }
                });
            }
            if (request.method === "POST") {
                try {
                    if (!isAllowedOrigin) {
                        return new Response(JSON.stringify({ success: false, error: "origin_not_allowed" }), {
                            status: 403,
                            headers: {
                                'Content-Type': 'application/json',
                                "Access-Control-Allow-Origin": corsOrigin
                            }
                        });
                    }

                    const configuredSecret = (env.DXRP_TOKEN_SYNC_SECRET || "").trim();
                    if (!configuredSecret) {
                        return new Response(JSON.stringify({ success: false, error: "sync_secret_not_configured" }), {
                            status: 503,
                            headers: {
                                'Content-Type': 'application/json',
                                "Access-Control-Allow-Origin": corsOrigin
                            }
                        });
                    }

                    const body = await request.json();
                    const providedSecret = (request.headers.get("X-LifePunch-Sync-Secret") || body.secret || "").trim();
                    if (providedSecret !== configuredSecret) {
                        return new Response(JSON.stringify({ success: false, error: "unauthorized" }), {
                            status: 401,
                            headers: {
                                'Content-Type': 'application/json',
                                "Access-Control-Allow-Origin": corsOrigin
                            }
                        });
                    }

                    const { token } = body;
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
                    .admin-card:hover { border-color: var(--lp-blue); transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,118,227,0.2); }
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
                    .btn-save:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 118, 227, 0.3); }
                </style>

                <div class="settings-grid">
                    ${lastErr ? `<div class="error-banner"><i class="fa-solid fa-triangle-exclamation"></i> CRITICAL: ${esc(lastErr)}</div>` : ''}
                    
                    <div class="settings-card">
                        <div class="card-title">DXRP Automation Bridge</div>
                        <p style="font-size: 12px; color: var(--text-dim); margin-bottom: 25px;">Paste your Bearer Token from DXRP DevTools here. This token is required for **automatic** store and reward payouts.</p>
                        
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
                </div>

                <script>
                    const lastTokenUpdate = ${await linksKv.get("config:dxrp_token_timestamp") || Date.now()};

                    function updateTokenTimer() {
                        const timerEl = document.getElementById('token-timer');
                        if (!timerEl) return;

                        const now = Date.now();
                        const expiry = lastTokenUpdate + (24 * 60 * 60 * 1000); // 24 Hours
                        const diff = expiry - now;

                        if (diff <= 0) {
                            timerEl.innerHTML = '⚠️ TOKEN EXPIRED - REFRESH NOW';
                            timerEl.style.color = '#ff5252';
                            return;
                        }

                        const hours = Math.floor(diff / (1000 * 60 * 60));
                        const mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                        const secs = Math.floor((diff % (1000 * 60)) / 1000);
                        
                        const pad = (n) => n.toString().padStart(2, '0');
                        timerEl.innerHTML = 'TOKEN EXPIRES IN: ' + pad(hours) + ':' + pad(mins) + ':' + pad(secs);
                        
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
                        if (data.ok) alert('Success! Found player: ' + data.name + ' (Balance: $' + data.balance + ')');
                        else alert('Failed: ' + data.error);
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
                    .nav-item.active { background: rgba(0, 118, 227, 0.1); color: var(--lp-blue); }
                    .nav-item.active .count-badge { background: var(--lp-blue); color: #fff; }

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
                        box-shadow: 0 4px 15px rgba(0, 118, 227, 0.3); transition: 0.3s;
                    }
                    .compose-btn-large:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0, 118, 227, 0.4); }

                    .inbox-table-container { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
                    .inbox-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
                    .inbox-table th, .inbox-table td { padding: 15px; text-align: left; border-bottom: 1px solid var(--border); font-size: 13px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
                    .inbox-table th { background: var(--card-header); color: var(--lp-blue); text-transform: uppercase; font-family: 'Montserrat', sans-serif; font-size: 10px; letter-spacing: 1px; }
                    .inbox-table tr:hover { background: rgba(255,255,255,0.02); cursor: pointer; }
                    
                    .unread { font-weight: 800; color: #fff; background: rgba(0, 118, 227, 0.03); }
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
                    .btn-send:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,118,227,0.4); }
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
                    .form-input:focus { border-color: var(--lp-blue); box-shadow: 0 0 0 3px rgba(0, 118, 227, 0.1); }
                    .form-textarea { min-height: 180px; resize: vertical; line-height: 1.6; }
                    .btn-send { background: var(--lp-blue); color: #fff; border: none; padding: 14px 30px; border-radius: 8px; font-weight: 900; cursor: pointer; text-transform: uppercase; font-size: 12px; letter-spacing: 1px; transition: 0.3s; }
                    .btn-send:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 118, 227, 0.4); filter: brightness(1.1); }
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
                    const player = await getDxrpPlayer(steamid);
                    if (player) {
                        return new Response(JSON.stringify({ ok: true, name: player.name || "Unknown", balance: player.balance || 0 }));
                    }
                    return new Response(JSON.stringify({ ok: false, error: "Player not found or Token invalid" }));
                } catch (e) {
                    return new Response(JSON.stringify({ ok: false, error: e.message }));
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
                                    color: 0x0076E3,
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
                            content: "<@1179604826997411924> ⚠️ **DXRP Token Expiry Warning**\nYour token is about to expire in 1 hour. Please visit dxrp.net and click your **Update Token** bookmark to refresh it!"
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
                    .admin-search:focus { border-color: var(--lp-blue); box-shadow: 0 0 10px rgba(0,118,227,0.2); }
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
                        box-shadow: 0 10px 30px rgba(0, 118, 227, 0.4); z-index: 9999;
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
                    
                    .type-badge { background: rgba(0, 118, 227, 0.1); color: var(--lp-blue); padding: 4px 8px; border-radius: 4px; font-size: 10px; font-weight: 900; text-transform: uppercase; border: 1px solid rgba(0, 118, 227, 0.3); }
                    
                    #toast {
                        position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%) translateY(100px);
                        background: var(--lp-blue); color: #fff; padding: 12px 24px; border-radius: 50px;
                        font-weight: 900; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
                        box-shadow: 0 10px 30px rgba(0, 118, 227, 0.4); z-index: 9999;
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
            <html>
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
            return new Response(finalHtml, { headers: { "Content-Type": "text/html;charset=UTF-8" } });
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
                    box-shadow: 0 0 20px rgba(0, 118, 227, 0.2);
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
                    background: rgba(0, 118, 227, 0.05);
                    border: 1px solid rgba(0, 118, 227, 0.3);
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
                    background: rgba(0, 118, 227, 0.05);
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
                    box-shadow: 0 5px 15px rgba(0, 118, 227, 0.3);
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
            <html>
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
                "Access-Control-Allow-Origin": "*"
            };

            if (!isEmbed) {
                responseHeaders["X-Frame-Options"] = "DENY";
            }
            return new Response(finalHtml, { headers: responseHeaders });
        }

        if (path === "/rules") {
            pageTitle = "LifePunch | Official Rules";
            subHeaderTitle = "RULES & CONDUCT";

            const rule = (id, html) => {
                const hasSublist = html.includes("rule-sublist");
                return `
            <div class="rule-line${hasSublist ? " rule-line--with-sublist" : ""}" id="${id}">
                <div class="rule-text">${html}</div>
                <div class="rule-actions">
                    <button class="action-btn" data-tooltip="Copy Rule" onclick="copyRuleText('${id}')" title="Copy Text"><i class="fa-solid fa-copy"></i></button>
                    <button class="action-btn" data-tooltip="Share Link" onclick="shareRuleLink('${id}')" title="Share Link"><i class="fa-solid fa-share-nodes"></i></button>
                </div>
            </div>`;
            };

            bodyContent = `
          <style>
              .intro-text { background: rgba(0,118,227,0.1); border: 1px solid var(--lp-blue); padding: 25px; border-radius: 10px; margin-bottom: 25px; font-size: 14px; line-height: 1.6; color: #fff; text-align: center; }
              
              .search-wrapper { position: sticky; top: 10px; z-index: 100; margin-bottom: 30px; position: relative; }
              
              .search-container {
                position: relative;
                width: 100%;
                background: rgba(2, 4, 10, 0.85); 
                border: 1px solid var(--lp-blue); 
                border-radius: 8px;
                box-shadow: 0 4px 30px rgba(0, 0, 0, 0.4);
              }

              .search-container::before {
                content: '>';
                position: absolute;
                left: 18px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--lp-blue);
                font-weight: 900;
                font-size: 18px;
                pointer-events: none;
                animation: blink 1s step-end infinite;
                z-index: 1;
              }

              #search { 
                  display: block;
                  width: 100%;
                  padding: 18px 18px 18px 45px; 
                  background: transparent; 
                  border: none;
                  color: #fff; 
                  font-family: inherit; outline: none; box-sizing: border-box; 
                  font-weight: 600;
                  caret-color: transparent; 
              }

              @keyframes blink {
                0%, 100% { opacity: 1; }
                50% { opacity: 0; }
              }

              #search::placeholder {
                color: rgba(255,255,255,0.4);
                transition: 0.2s;
              }

              #search:focus::placeholder,
              #search:not(:placeholder-shown)::placeholder {
                opacity: 0;
              }

              mark.search-highlight { 
                  background: var(--lp-blue); color: #fff; 
                  border-radius: 3px; 
                  padding: 1px 3px; 
                  box-shadow: 0 0 10px rgba(0, 118, 227, 0.6);
              }

              .category { margin-bottom: 10px; border: 1px solid var(--border); border-radius: 10px; background: var(--surface); overflow: hidden; backdrop-filter: blur(16px); transition: 0.3s; }
              .cat-btn { width: 100%; padding: 18px 25px; background: transparent; border: none; color: #fff; text-align: left; font-family: 'Montserrat', sans-serif; font-size: 16px; font-weight: 700; cursor: pointer; display: flex; align-items: center; text-transform: uppercase; gap: 20px; }
              .cat-btn .btn-label, .sub-btn .btn-label { flex: 1; min-width: 0; }
              .sub-cat { margin: 10px 20px; border: 1px solid rgba(255,255,255,0.05); border-radius: 8px; background: rgba(255,255,255,0.02); overflow: hidden; }
              .sub-btn { width: 100%; padding: 12px 20px; background: rgba(0, 118, 227, 0.05); border: none; color: #fff; text-align: left; font-weight: 600; cursor: pointer; display: flex; align-items: center; font-size: 14px; }
              .icon-box { width: 35px; height: 35px; background: rgba(0,118,227,0.2); border-radius: 6px; display: flex; align-items: center; justify-content: center; color: var(--lp-blue); font-size: 18px; flex-shrink: 0; }
              .chevron { margin-left: auto; color: var(--text-dim); transition: 0.4s; }
              .active > .chevron { transform: rotate(180deg); color: var(--lp-blue); }
              
              .content-wrapper { display: grid; grid-template-rows: 0fr; transition: 0.5s cubic-bezier(0.4, 0, 0.2, 1); overflow: hidden; }
              .content-wrapper.open { grid-template-rows: 1fr; border-top: 1px solid var(--border); }
              .content { min-height: 0; overflow: hidden; padding: 0 25px; visibility: hidden; transition: 0.5s; }
              .content-wrapper:not(.open) > .content { padding: 0; }
              .content-wrapper.open > .content { padding: 20px; visibility: visible; }
              
              .rule-line { 
                  margin-bottom: 10px; font-size: 14px; border-left: 2px solid transparent; 
                  padding: 8px 15px; color: #fff; display: none; justify-content: space-between; 
                  align-items: center; transition: background 0.3s;
                  border-radius: 0 4px 4px 0;
              }
              .content-wrapper.open .rule-line { display: flex; border-left-color: var(--lp-blue); }
              .rule-line--with-sublist { align-items: flex-start; }
              .rule-line--with-sublist .rule-actions { padding-top: 2px; }
              .content-wrapper:not(.open) .rule-line,
              .content-wrapper:not(.open) .rule-line:target { display: none; border-left: none; margin: 0; padding: 0; }
              .rule-line:hover { background: rgba(255,255,255,0.03); }
              .content-wrapper.open .rule-line:target { background: rgba(0, 118, 227, 0.15); border-left: 4px solid #fff; }
              .rule-text { flex: 1; padding-right: 20px; }
              .rule-actions { display: flex; gap: 8px; opacity: 0.4; transition: 0.3s; }
              .rule-line:hover .rule-actions { opacity: 1; }
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
              .rule-text ul.rule-sublist { margin: 6px 0 0 0; padding-left: 20px; list-style: disc; display: block; width: 100%; }
              .rule-text b + ul.rule-sublist { margin-top: 2px; }
              .rule-text ul.rule-sublist li { margin-bottom: 6px; line-height: 1.5; }
              .sub-title { color: var(--lp-blue); font-weight: 800; text-transform: uppercase; margin: 15px 0 10px 0; font-size: 12px; letter-spacing: 1px; }
              .sub-title--underline { text-decoration: underline; }
              .important { color: #ff4d4d; font-weight: bold; margin-top: 15px; display: block;}
              .guide-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 10px; }
              .guide-item { background: rgba(255,255,255,0.05); padding: 5px 10px; border-radius: 4px; font-size: 12px; display: flex; justify-content: space-between; }
              
              .searching .category, .searching .sub-cat { animation: slideUpFade 0.3s ease forwards; }
              @keyframes slideUpFade { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
          </style>

          <div class="intro-text">
              Below you will find our official rules and guidelines. Please read them carefully to ensure a fair and fun environment for everyone. Click the icons next to a rule to share it.
          </div>

          <div class="search-wrapper">
              <div class="search-container">
                  <input type="text" id="search" placeholder="SEARCH RULES..." autocomplete="off" spellcheck="false">
              </div>
          </div>

          <div id="rules-root">
              ${renderWebRulesRoot(rule)}
          </div>

          <script>
              function copyRuleText(id) {
                  const el = document.getElementById(id);
                  const text = el.querySelector('.rule-text').innerText;
                  navigator.clipboard.writeText(text);
                  showFeedback(id, 'fa-check');
              }

              function shareRuleLink(id) {
                  const url = window.location.origin + window.location.pathname + '#' + id;
                  navigator.clipboard.writeText(url);
                  showFeedback(id, 'fa-link');
              }

              function showFeedback(id, iconClass) {
                  const btn = document.querySelector(\`#\${id} .action-btn\`);
                  const originalIcon = btn.innerHTML;
                  btn.innerHTML = \`<i class="fa-solid \${iconClass}"></i>\`;
                  btn.style.color = 'var(--lp-blue)';
                  setTimeout(() => { 
                      btn.innerHTML = originalIcon; 
                      btn.style.color = '';
                  }, 1500);
              }

              window.addEventListener('load', () => {
                  if (window.location.hash) {
                      const id = window.location.hash.substring(1);
                      const target = document.getElementById(id);
                      if (target) {
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
                  }
              });

              document.querySelectorAll('.cat-btn, .sub-btn').forEach(btn => {
                  btn.addEventListener('click', function(e) {
                      e.stopPropagation();
                      const wrapper = this.nextElementSibling;
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

              function shouldSkipHighlightNode(node) {
                  const parent = node.parentNode;
                  if (!parent) return true;
                  if (['SCRIPT', 'STYLE', 'MARK', 'INPUT', 'TEXTAREA'].includes(parent.tagName)) return true;
                  if (parent.closest('.search-wrapper, .search-container, #search')) return true;
                  return false;
              }

              function applyHighlights(root, term) {
                  if (!term) return;
                  const safeTerm = term.replace(/[.*+?^\${}()|[\\]\\\\]/g, '\\\\$&');
                  const regex = new RegExp("(" + safeTerm + ")", "gi");
                  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
                  const textNodes = [];
                  let node;
                  
                  while ((node = walker.nextNode())) {
                      if (shouldSkipHighlightNode(node)) continue;
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
                          if (parent.matches('.cat-btn, .sub-btn')) {
                              const wrapper = document.createElement('span');
                              wrapper.className = 'btn-label';
                              wrapper.appendChild(fragment);
                              parent.replaceChild(wrapper, textNode);
                          } else {
                              parent.replaceChild(fragment, textNode);
                          }
                      }
                  });
              }

              let debounceTimer;
              const searchInput = document.getElementById('search');
              const rulesRoot = document.getElementById('rules-root');

              searchInput.addEventListener('input', function(e) {
                  const term = e.target.value.trim().toLowerCase();
                  
                  clearTimeout(debounceTimer);
                  debounceTimer = setTimeout(() => {
                      const categories = document.querySelectorAll('.category');
                      const subCategories = document.querySelectorAll('.sub-cat');
                      const ruleLines = document.querySelectorAll('.rule-line');
                      
                      if (term.length < 3) {
                          rulesRoot.classList.remove('searching');
                          removeHighlights(rulesRoot);
                          
                          // Reset everything to default
                          categories.forEach(cat => {
                              cat.style.display = 'block';
                              cat.querySelector('.cat-btn').classList.remove('active');
                              cat.querySelector('.content-wrapper').classList.remove('open');
                          });
                          subCategories.forEach(sub => {
                              sub.style.display = 'block';
                              sub.querySelector('.sub-btn').classList.remove('active');
                              sub.querySelector('.content-wrapper').classList.remove('open');
                          });
                          ruleLines.forEach(line => line.style.removeProperty('display'));
                          return;
                      }

                      rulesRoot.classList.add('searching');
                      removeHighlights(rulesRoot);

                      // Track what needs to be shown
                      const visibleCats = new Set();
                      const visibleSubs = new Set();

                      // Check every rule
                      ruleLines.forEach(line => {
                          const ruleTxtEl = line.querySelector('.rule-text');
                          const text = (ruleTxtEl ? ruleTxtEl.textContent : '').toLowerCase();
                          
                          if (text.indexOf(term) !== -1) {
                              line.style.display = 'flex';
                              
                              // Track parents
                              let sub = line.closest('.sub-cat');
                              if (sub) {
                                  visibleSubs.add(sub);
                                  let cat = sub.closest('.category');
                                  if (cat) visibleCats.add(cat);
                              } else {
                                  let cat = line.closest('.category');
                                  if (cat) visibleCats.add(cat);
                              }
                          } else {
                              line.style.display = 'none';
                          }
                      });

                      // Also check sub-category and category buttons (headers)
                      subCategories.forEach(sub => {
                          const btn = sub.querySelector('.sub-btn');
                          const btnText = (btn ? btn.textContent : '').toLowerCase();
                          if (btnText.indexOf(term) !== -1) {
                              visibleSubs.add(sub);
                              let cat = sub.closest('.category');
                              if (cat) visibleCats.add(cat);
                              // If header matches, show its rules
                              sub.querySelectorAll('.rule-line').forEach(l => l.style.display = 'flex');
                          }
                      });

                      categories.forEach(cat => {
                          const btn = cat.querySelector('.cat-btn');
                          const btnText = (btn ? btn.textContent : '').toLowerCase();
                          if (btnText.indexOf(term) !== -1) {
                              visibleCats.add(cat);
                              // If main header matches, show everything inside
                              cat.querySelectorAll('.rule-line').forEach(l => l.style.display = 'flex');
                              cat.querySelectorAll('.sub-cat').forEach(s => {
                                  visibleSubs.add(s);
                                  s.style.display = 'block';
                              });
                          }
                      });

                      // Apply visibility and open states
                      categories.forEach(cat => {
                          if (visibleCats.has(cat)) {
                              cat.style.display = 'block';
                              cat.querySelector('.cat-btn').classList.add('active');
                              cat.querySelector('.content-wrapper').classList.add('open');
                          } else {
                              cat.style.display = 'none';
                          }
                      });

                      subCategories.forEach(sub => {
                          if (visibleSubs.has(sub)) {
                              sub.style.display = 'block';
                              sub.querySelector('.sub-btn').classList.add('active');
                              sub.querySelector('.content-wrapper').classList.add('open');
                          } else {
                              sub.style.display = 'none';
                          }
                      });

                      applyHighlights(rulesRoot, term);
                  }, 60);
              });
          </script>
        `;
        } else if (path === "/rewards") {
            pageTitle = "LifePunch | Rewards";
            subHeaderTitle = "UNLOCk BONUSES";

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
                    background: rgba(0, 118, 227, 0.1); 
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
                <a href="https://discord.gg/lifepunchco" target="_blank" class="discord-btn">JOIN SERVER</a>
                <button class="copy-btn" onclick="copyInvite(this)">COPY INVITE LINK</button>
            </div>
            
            <script>
                function copyInvite(btn) {
                    navigator.clipboard.writeText("https://discord.gg/lifepunchco");
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
              .tos-section p, .tos-section li { font-size: 14px; color: var(--text-main); border-left: 2px solid var(--lp-blue); padding-left: 15px; line-height: 1.6; }
              .tos-section ol { list-style-position: inside; }
              .effective-date { font-style: italic; margin-bottom: 20px; color: var(--text-muted); }
          </style>

          <div class="tos-container">
              <p class="effective-date">Last Updated: May 11, 2026</p>

              <div class="tos-section">
                  <h2>1. Acceptance of Terms</h2>
                  <p>By accessing or using LifePunch services, including our servers, website, and related platforms, you agree to be bound by these Terms of Service and our Privacy Policy. If you are under the age of 13 (or 16 in certain jurisdictions), you represent that you have obtained parental consent to use these services.</p>
                  <p>If you do not agree to these Terms, you must immediately cease all use of LifePunch services. Continued use constitutes a legally binding agreement to these terms and any future modifications.</p>
              </div>
              
              <div class="tos-section">
                  <h2>2. User Conduct & Rule Compliance</h2>
                  <p>Access to LifePunch is a privilege, not a right. All users must comply with server-specific rules, community guidelines, and staff directives. We reserve the right, at our sole discretion, to terminate or suspend access to any user for any reason, including but not limited to: toxicity, harassment, exploitation of bugs, or disruption of the community environment.</p>
                  <p>Staff interpretations of rules are final. "Roleplay" standards are enforced to maintain community integrity; "FailRP" or "Metagaming" may result in immediate administrative action without prior warning.</p>
              </div>
              
              <div class="tos-section">
                  <h2>3. Virtual Goods, Credits & Referrals</h2>
                  <p>Any financial contributions, referral rewards, or "Store Credit" earned or used on LifePunch are considered payments for a limited, revocable, non-transferable license to use specific virtual items, ranks, or "perks" within the LifePunch ecosystem. These items, including "Store Credit," have no real-world monetary value and cannot be traded for "real world" currency or assets.</p>
                  <p><strong>WIP & Roadmap:</strong> You acknowledge that LifePunch is a live, evolving service. Some virtual goods, ranks, or 'perks' may include features currently in development ('Work in Progress' or 'WIP'). The purchase of a rank provides access to the rank's current 'As Available' features; missing or upcoming features do not constitute a failure of service or grounds for a refund.</p>
                  <p><strong>Store Credit & Referrals:</strong> Referral rewards and Store Credit are provided at our sole discretion as a community benefit. We reserve the right to revoke any rewards, credits, or related perks if we determine, in our sole judgment, that the system has been abused (e.g., self-referral, exploitation, or fraudulent activity). Credit is non-transferable and cannot be "cashed out."</p>
                  <p><strong>Refund Policy:</strong> All transactions are final. By completing a purchase or applying credit, you waive any right to a refund unless required by local consumer law. Verbal or written statements made by staff members or community leads regarding refunds do not override these written Terms. Only a formal notice from our billing department/legal email can authorize an exception to the 'No Refund' policy. Attempting to circumvent this via "chargebacks" through payment processors will result in a permanent ban and potential legal or collection action to recover lost funds and fees.</p>
              </div>

              <div class="tos-section">
                  <h2>4. Disclaimer of Warranties & Limitation of Liability</h2>
                  <p>LIFEPUNCH SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE." WE EXPRESSLY DISCLAIM ALL WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED. WE DO NOT WARRANT THAT ANY SPECIFIC PERK, JOB, OR ADMINISTRATIVE POWER WILL BE AVAILABLE AT ALL TIMES OR REMAIN UNCHANGED. WE RESERVE THE RIGHT TO MODIFY, REMOVE, OR DELAY THE IMPLEMENTATION OF ANY VIRTUAL FEATURE WITHOUT NOTICE AND WITHOUT PROVIDING A REFUND.</p>
                  <p>LIFEPUNCH SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES ARISING FROM YOUR USE OF THE SERVICE, INCLUDING BUT NOT LIMITED TO SERVER DOWNTIME, LOSS OF VIRTUAL ASSETS, OR DATA BREACHES.</p>
                  <p>In no event shall our total liability to you for all damages exceed the amount paid by you to LifePunch in the six (6) months preceding the claim.</p>
              </div>
              
              <div class="tos-section">
                  <h2>5. Intellectual Property</h2>
                  <p>All original content created by LifePunch—including logos, custom code, UI design, and branding—is the exclusive property of LifePunch. You are granted a limited license to view and interact with this content for personal, non-commercial use only.</p>
                  <p>Third-party assets (such as those from s&box or DXRP) remain the property of their respective owners. Any unauthorized replication of LifePunch’s unique site layout or proprietary assets for use in "clone" servers is strictly prohibited and will be met with legal action.</p>
              </div>

              <div class="tos-section">
                  <h2>6. DMCA & Copyright Agent</h2>
                  <p>If you believe your work has been used in a way that constitutes copyright infringement, please provide our Copyright Agent (<strong>dmca@lifepunch.co</strong>) with: (1) a description of the work; (2) the location on our site; (3) your contact info; and (4) a statement of good faith belief that the use is unauthorized.</p>
              </div>

              <div class="tos-section">
                  <h2>7. Governing Law & Dispute Resolution</h2>
                  <p>These Terms are governed by the laws of the State of Michigan, USA. You agree that any legal action arising out of these Terms shall be filed exclusively in the courts of Wayne County, Michigan. You hereby waive any right to a class action lawsuit or class-wide arbitration.</p>
              </div>

              <div class="tos-section">
                  <h2>8. Contact</h2>
                  <p>For legal inquiries, contact: <strong>legal@lifepunch.co</strong>. For general support, please use our official community discord or support ticket system.</p>
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
                  background: rgba(0,118,227,0.08); border: 1px solid var(--lp-blue); 
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
              .package-option:hover { border-color: var(--lp-blue); background: rgba(0, 118, 227, 0.05); }
              .package-option.selected { border-color: var(--lp-blue); background: rgba(0, 118, 227, 0.1); box-shadow: 0 0 15px rgba(0, 118, 227, 0.2); }
              .option-info b { display: block; font-size: 16px; color: #fff; }
              .option-info span { font-size: 12px; color: var(--text-dim); }
              .option-price { font-weight: 900; color: var(--lp-blue); }
              
              /* Hide number input spinners */
              input::-webkit-outer-spin-button,
              input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
              input[type=number] { -moz-appearance: textfield; }

              .perks-display {
                  background: rgba(0, 118, 227, 0.05);
                  border: 1px solid rgba(0, 118, 227, 0.2);
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
                  background: rgba(2, 4, 10, 0.95); z-index: 1000;
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
              Support LifePunch and unlock exclusive perks! Your purchases help keep our servers running and allow us to add new features. All donations are non-refundable but carry immense value.
          </div>

          ${!steamid ? `
          <div class="store-box" style="background: rgba(0, 118, 227, 0.1); border: 1px solid var(--lp-blue); padding: 20px; border-radius: 12px; margin-bottom: 30px; text-align: center; color: #fff; font-size: 14px; font-weight: 600; backdrop-filter: blur(10px);">
              You must be logged into Steam and authorize your Discord to use the Store.
          </div>

          <div class="store-box">
              <div class="box-title" style="justify-content: center; margin-bottom: 25px;"><i class="fa-solid fa-cart-shopping"></i> Available Packages</div>
              <div class="package-preview" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px;">
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">VIP - $10.00</div>
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
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">EVIP - $25.00</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Builder+ Status</li>
                              <li>Prop Limit +600</li>
                              <li>Moderation Powers (DXRP WIP)</li>
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
          <div class="store-box" style="background: rgba(0, 118, 227, 0.1); border: 1px solid var(--lp-blue); padding: 20px; border-radius: 12px; margin-bottom: 30px; text-align: center; color: #fff; font-size: 14px; font-weight: 600; backdrop-filter: blur(10px);">
              You must authorize your Discord to use the Store. (this is done through your profile).
          </div>

          <div class="store-box">
              <div class="box-title" style="justify-content: center; margin-bottom: 25px;"><i class="fa-solid fa-cart-shopping"></i> Available Packages</div>
              <div class="package-preview" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                  <div class="preview-card" style="background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 8px; padding: 20px;">
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">VIP - $10.00</div>
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
                      <div class="box-title" style="font-size:16px; margin-bottom:15px; justify-content: center;">EVIP - $25.00</div>
                      <div class="perks-display" style="background:transparent; border:none; padding:0;">
                          <ul style="margin:0;">
                              <li>Builder+ Status</li>
                              <li>Prop Limit +600</li>
                              <li>Moderation Powers (DXRP WIP)</li>
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
                              <div class="option-info"><b>VIP</b><span>Standard Rank</span></div>
                              <div class="option-price">$10.00</div>
                          </div>
                          <div class="package-option selected" onclick="selectPkg('EVIP', 25.00)">
                              <div class="option-info"><b>EVIP</b><span>Premium Rank</span></div>
                              <div class="option-price">$25.00</div>
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

                          <div class="referral-section" style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
                              <label style="font-size:11px; color:var(--text-dim); font-weight:bold; text-transform:uppercase;">Referral Code</label>
                              <div style="display:flex; gap:10px; margin-top:5px;">
                                  <input type="text" id="referral-input" class="lp-input" style="margin-top:0;" placeholder="Enter code for 10% off">
                                  <button class="btn-store btn-next" style="padding:10px; width:auto; font-size:11px;" onclick="validateReferral()">Apply</button>
                              </div>
                              <div id="referral-msg" style="font-size:11px; margin-top:5px; font-weight:bold;"></div>
                          </div>

                          ${parseFloat(userCredit) > 0 ? `
                          <div class="credit-section" style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
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
                              <span id="final-price" class="info-value" style="font-size:18px; color:var(--lp-blue);">$25.00</span>
                          </div>
                      </div>
                      <div class="btn-row">
                          <button class="btn-store btn-back" onclick="goToStep(1)">Back</button>
                          <button id="pay-btn" class="btn-store btn-next" onclick="startCheckout()">Pay Securely</button>
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
                  "EVIP": ["Builder+ Status", "Prop Limit +600", "Moderation Powers (DXRP WIP)", "Queue Skip", "Minigame Starts (DXRP WIP)", "Exclusive Jobs (DXRP WIP)"],
                  "$LP": ["Universal Currency", "Works on All Servers", "Never Expires", "In-game Store Purchases"]
              };

              function selectPkg(name, price) {
                  selectedPkgName = name;
                  selectedPkgPrice = price;
                  
                  document.querySelectorAll('.package-option').forEach(opt => {
                      const pkgName = opt.querySelector('b').innerText;
                      opt.classList.toggle('selected', pkgName === name);
                  });

                  document.getElementById('lp-custom-amount').style.display = (name === '$LP') ? 'block' : 'none';
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
                      finalPriceEl.innerHTML = '<span style="text-decoration: line-through; color: var(--text-dim); font-size: 14px; margin-right: 8px;">$' + selectedPkgPrice.toFixed(2) + '</span>' +
                                             '<span style="color: #00c853;">$' + price.toFixed(2) + '</span>';
                  } else {
                      finalPriceEl.innerText = '$' + selectedPkgPrice.toFixed(2);
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
            let serverData = [];
            try {
                const serverRes = await fetch("https://api.dxrp.net/v1/public/servers");
                serverData = await serverRes.json();
                console.log("Server List Received:", JSON.stringify(serverData));
            } catch (e) {
                console.error("Failed to fetch server data:", e);
            }

            const s1 = serverData.find(s => s.name && s.name.includes("LifePunch #1"));
            const s2 = serverData.find(s => s.name && s.name.includes("LifePunch #2"));

            bodyContent = `
            <style>
                .top-disclaimer { text-align: center; color: var(--text-dim); margin-bottom: 30px; font-size: 14px; text-transform: uppercase; font-weight: bold; letter-spacing: 1px; }
                .server-card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 30px; display: flex; align-items: center; justify-content: space-between; backdrop-filter: blur(16px); margin-bottom: 15px; }
                .server-card:last-child { margin-bottom: 0; }
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
                    <p>DXRP | ${s1 ? `${s1.playerCount || 0}/70` : "Offline"} Players </p>
                </div>
                <button class="copy-btn" onclick="copyIP('connect 90285428148008983', this)">COPY IP</button>
            </div>

            <div class="server-card">
                <div class="server-info">
                    <h3>LifePunch Official | 70p | DarkRP OG</h3>
                    <p>DarkRP OG | ${s2 ? `${s2.playerCount || 0}/40` : "Offline"} Players</p>
                </div>
                <button class="copy-btn" onclick="copyIP('connect 1692541414016496', this)">COPY IP</button>
            </div>

            <script>
                function copyIP(text, btn) {
                    navigator.clipboard.writeText(text);
                    btn.innerText = "COPIED!";
                    btn.classList.add('copied');
                    setTimeout(() => { btn.innerText = "COPY IP"; btn.classList.remove('copied'); }, 2000);
                }
            </script>
          `;        }

        // Final HTML Generation
        let finalHtml = `
        <!DOCTYPE html>
        <html>
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
            "Access-Control-Allow-Origin": "*"
        };

        if (isEmbed) {
            responseHeaders["Content-Security-Policy"] = "frame-ancestors *;";
        } else {
            responseHeaders["X-Frame-Options"] = "DENY";
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