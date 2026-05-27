import fs from "fs";
import path from "path";

const targetFile = process.argv[2] || "c:\\Users\\stute\\OneDrive\\Documents\\SeperationRules.txt";
const source = fs.readFileSync(targetFile, "utf8");

const catalogBlock = `
        // --- LIFE PUNCH RULES CATALOG (single source of truth) ---
        // Edit rule text here only — both /rules and /rules/raw render from this data.
        const LP_RULES = [
            {
                num: 1,
                title: "Serverwide Rules",
                icon: "fa-globe",
                open: true,
                rules: [
                    { id: "en-only", html: "<b>English Only</b> — English speaking community. RP in English." },
                    { id: "no-cheat", html: "<b>No Cheating</b> — 3rd party software, cheats, macros, or autoclickers result in a PERMANENT ban." },
                    { id: "no-exploit", html: "<b>No Exploiting</b> — Map, item, or tool exploits for unfair advantage. (Excludes drug creation/gunshops). You may not base outside of the map. The rocks are the barrier." },
                    { id: "no-mic-spam", html: "<b>No Mic Spam</b> — Purposely being disruptive to RP." },
                    { id: "no-staff-impersonation", html: "<b>No Staff Impersonation</b> — Results in a PERMANENT ban." },
                    { id: "no-lie-staff", html: "<b>Do Not Lie to Staff</b> — False reporting or deleting ticket evidence is punishable." },
                    { id: "no-staff-baiting", html: "<b>No Staff Baiting</b> — Saying you will break a rule = breaking a rule." },
                    { id: "no-minimodding", html: "<b>No Minimodding</b> — Don't threaten reports. Report properly and move on." },
                    { id: "admin-final-say", html: "<b>Admin Final Say</b> — Do not argue with staff about rules & punishments." },
                    { id: "no-begging", html: "<b>No Begging</b> — No solicitation of real money or IRL items." },
                    { id: "no-bullying", html: "<b>No Bullying</b> — Targeting/harassing outside of RP is never tolerated." },
                    { id: "no-politics", html: "<b>No Politics/War/Religion</b> — No political arguments. Jokes okay, arguments not." },
                    { id: "no-racism", html: "<b>No Racism/Homophobia</b> — Zero tolerance. Results in PERMANENT ban." },
                    { id: "no-nsfw", html: "<b>No Sexual/NSFW Content</b> — Media must stay PG. Includes ERP/Porn." },
                    { id: "no-doxing", html: "<b>No Doxing</b> — Posting IRL pictures without permission is a PERMANENT ban." },
                    { id: "no-cybercrime", html: "<b>Cybercrime Threats</b> — DDoS or Doxing threats result in a PERMANENT ban." },
                    { id: "no-advertising", html: "<b>No Advertising</b> — Only official DXRP or S&box links allowed." },
                    { id: "no-irl-illegal", html: "<b>No IRL Illegal Activity</b> — Encouraging illegal activity = Permanent ban." }
                ],
                footer: '<div class="important">❗ Staff always have final say in situations not listed!</div>'
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
                            { id: "rdm-kos", html: "<b>KOS Line</b> — Crossing a clearly marked KOS line is NOT RDM." },
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
                            { id: "nlr-raid", html: "<b>Raid</b> — You may not return to a raid after death." },
                            { id: "nlr-revive", html: "<b>Revives</b> — Revived players may continue their raid/scenario." },
                            { id: "nlr-hitman", html: "<b>Hitmen</b> — Hitmen cannot re-attempt failed hits (Hit is failed upon death)." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 2C: Fail RP",
                        webBtn: "🔺 Fail RP",
                        rules: [
                            { id: "fail-rp", html: "<b>Fail RP Logic</b> — Actions that break character, violate the established setting's logic, or disregard server rules, resulting in poor-quality, unrealistic, or disruptive play. Examples include stealing base mate valuables and starting a new base; mugging then killing your partner; police colluding with criminals; door camping/blocking; merchant scamming." }
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
                            { id: "demote-reasons", html: "<b>Demote Reasons</b> — AFK (30m+), not doing job, police corruption, scamming." },
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
                            { id: "wire-abuse", html: "<b>Wire Abuse</b> — No Wire abuse (auto-stealing money, loud sounds, stealing shipments)." },
                            { id: "prop-permission", html: "<b>Prop Permission</b> — No props in other players' property without permission." }
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
                            { id: "others-property", html: "<b>Other's Property</b> — Do not build into other people’s property." },
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
                            { id: "mayor-base", html: "<b>Mayor</b> — Must base in PD. Gun licenses: can charge fee, not obligated for criminals. Can build outside only for government or RP use (checkpoints/toll booths). Announce major law changes before enforcing." },
                            { id: "police-base", html: "<b>Police</b> — Must base in PD. Must allow all members of Government to base/RP with you. Follow hierarchy. Attempt to arrest before killing (unless weapon present)." },
                            { id: "laws", html: "<b>Laws</b> — Must be reasonable. Not contradict server rules. No text-only disrespect laws. AoS laws allowed; KoS laws not allowed. Laws cannot target specific individuals or jobs." },
                            { id: "arrests", html: "<b>Arrests</b> — Only for lawbreakers. Cannot arrest innocents (even if bribed)." },
                            { id: "lockdowns", html: "<b>Lockdowns</b> — Outdoors only. You may arrest, not KOS. Valid reason needed (Bank raid/shooting)." },
                            { id: "corruption", html: "<b>Corruption</b> — Allowed in RP. Not allowed against other government members. Bribes are okay. Helping criminals raid PD or killing Government is forbidden." },
                            { id: "warrants", html: "<b>Warrants</b> — Require valid RP evidence. Must SEE illegal activity. No metagaming. Expire on death, jail, or successful raid defense." },
                            { id: "checkpoints", html: "<b>Checkpoints and Tolls</b> — Must not block any spawn-area entrance/exits. Must not extend raid-durations. Tolls cannot exceed $50. 2 Checkpoints/Toll-booths MAX." },
                            { id: "searches", html: "<b>Searches</b> — Require RP reason (e.g., gunshots nearby, loitering near drug drop)." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 5B: CIVILIAN",
                        webBtn: "👨‍🔧 Civilian",
                        rules: [
                            { id: "gun-dealer", html: "<b>Gun Dealer</b> — Must intend to sell. Cannot base with another gun dealer. Can defend a criminal base. Must sell individual weapons (not only shipments)." },
                            { id: "medic", html: "<b>Medic</b> — Only 1 per raid party." },
                            { id: "theatre-manager", html: "<b>Theatre Manager</b> — Must base in the Theatre." }
                        ]
                    },
                    {
                        rawTitle: "SUB-CATEGORY 5C: CRIMINAL",
                        webBtn: "🔫 Criminal",
                        rules: [
                            { id: "hitman", html: "<b>Hitman</b> — No metagaming hits. Only Hitman can perform hits. Doesn't need a valid RP reason unless it is the Mayor. Hitman may only raid active target locations; max one Hitman per raid." }
                        ]
                    }
                ]
            },
            {
                num: 6,
                title: "Raiding & Mugging",
                icon: "fa-bomb",
                blocks: [
                    { type: "heading", raw: "BASIC RAID RULES", web: "Basic Raid Rules" },
                    {
                        type: "rules",
                        rules: [
                            { id: "raid-guidelines", html: "<b>Raiding Guidelines</b> — Raid starts: Prybar out, damaging base member, weapon out on property, refusal to leave property. Raid ends: No raiders remain inside or on property." },
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
                            "Thief",
                            "Government"
                        ]
                    },
                    { type: "heading", raw: "MUGGING RULES", web: "Mugging Rules" },
                    {
                        type: "rules",
                        rules: [
                            { id: "mug-limit", html: "<b>$ Limit</b> — Max mug $1,000. Must type mug warning. 10s response time required." },
                            { id: "mug-cooldown", html: "<b>Cooldown</b> — 5-minute cooldown per different target; 10-minute cooldown for the same person." },
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
                    { id: "minging-prohibited", html: "<b>Prohibited</b> — Baiting RDM/RDA, text/mic spam, excessive trolling, wire abuse to annoy players, preventing others from building, prop blocking, building in other people's bases, prop abuse (flying, climbing), preventing new players from learning, repeatedly raiding someone with no valuables, kidnapping without RP reason, disobeying staff or reasonable requests." }
                ]
            },
            {
                num: 8,
                title: "Cooldowns & Reporting",
                icon: "fa-clock",
                blocks: [
                    { type: "heading", raw: "COOLDOWNS", web: "Cooldowns" },
                    {
                        type: "cooldowns",
                        rawItems: [
                            "Mugging (different people): 5 minutes",
                            "Mugging (same person): 15 minutes",
                            "Hits (same person): 10 minutes",
                            "Raiding (same person): 30 minutes",
                            "PD Raid: 10 minutes",
                            "Mayor: 10 minute grace before they can be raided/killed after certain events",
                            "Mayor Kidnap: 20 minutes",
                            "No raiding for 10 minutes after server crash"
                        ],
                        webRule: { id: "cooldowns", html: "<b>Cooldowns</b> — Mugging: Different people - 5 minutes; Mugging: Same person - 15 minutes; Hits: Same person - 10 minutes; Raiding: Same person - 30 minutes; PD Raid: 10 minutes; Mayor: 10 minute grace before they can be raided or killed; Mayor Kidnap: 20 minutes; No raiding for 10m after server crash." }
                    },
                    { type: "heading", raw: "REPORTING RULES", web: "Reporting Rules" },
                    {
                        type: "rules",
                        rules: [
                            { id: "report-respect", html: "<b>Report Respect</b> — Be respectful. Do not spam reports. Provide proof (Medal/OBS/Steam)." },
                            { id: "report-lying", html: "<b>Report Lying</b> — Lying to staff results in a PERMANENT ban." },
                            { id: "report-use", html: "<b>Report Use</b> — Use @ or /Staff in-game. EVIPs can jail in severe cases." }
                        ]
                    }
                ]
            }
        ];

        const renderRawRulesList = (rules) =>
            (rules || []).map((r) => \`<li>\${r.html}</li>\`).join("\\n                            ");

        const renderRawSubcategory = (sub) => \`
                        <h4>\${sub.rawTitle}</h4>
                        <ul>
                            \${renderRawRulesList(sub.rules)}
                        </ul>\`;

        const renderRawGuide = (block) => \`
                        <h4>\${block.rawHeading}</h4>
                        <ul>
                            \${block.items.map((item) => \`<li>\${item} — ✅</li>\`).join("\\n                            ")}
                        </ul>\`;

        const renderRawBlock = (block) => {
            if (block.type === "heading") return \`<h4>\${block.raw}</h4>\`;
            if (block.type === "rules") return \`<ul>\\n                            \${renderRawRulesList(block.rules)}\\n                        </ul>\`;
            if (block.type === "guide") return renderRawGuide(block);
            if (block.type === "cooldowns") {
                return \`<ul>\\n                            \${block.rawItems.map((item) => \`<li>\${item}</li>\`).join("\\n                            ")}\\n                        </ul>\`;
            }
            return "";
        };

        const renderRawCategoryBody = (cat) => {
            let html = "";
            if (cat.rules) {
                html += \`<ul>\\n                            \${renderRawRulesList(cat.rules)}\\n                        </ul>\`;
                if (cat.footer) html += cat.footer;
            }
            if (cat.subcategories) html += cat.subcategories.map(renderRawSubcategory).join("");
            if (cat.blocks) html += cat.blocks.map(renderRawBlock).join("");
            return html;
        };

        const renderRawRulesDocument = () => \`
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
                    .content b { color: var(--lp-blue); }
                    .important { color: #ff4d4d; font-weight: bold; margin-top: 15px; display: block; }
                    .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid var(--border); color: #a0a8b5; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>LifePunch Rules</h1>
                    <p>Official s&box DXRP Guidelines</p>
                </div>
                \${LP_RULES.map((cat) => \`
                <details\${cat.open ? " open" : ""}>
                    <summary>\${cat.num}. \${cat.title}</summary>
                    <div class="content">\${renderRawCategoryBody(cat)}</div>
                </details>\`).join("")}
                <div class="footer">
                    Searchable rules available at lifepunch.co/rules<br>
                    &copy; 2026 LifePunch Network
                </div>
            </body>
            </html>\`;

        const renderWebRulesList = (rules, rule) =>
            (rules || []).map((r) => rule(r.id, r.html)).join("\\n                          ");

        const renderWebSubcategory = (sub, rule) => \`
                          <div class="sub-cat">
                              <button class="sub-btn">\${sub.webBtn} <i class="fa-solid fa-chevron-down chevron"></i></button>
                              <div class="content-wrapper"><div class="content">
                                  \${renderWebRulesList(sub.rules, rule)}
                              </div></div>
                          </div>\`;

        const renderWebGuide = (block) => \`
                          <div class="sub-title">\${block.webHeading}</div>
                          <div class="guide-grid">
                              \${block.items.map((item) => \`<div class="guide-item">\${item}<span>✅</span></div>\`).join("\\n                              ")}
                          </div>\`;

        const renderWebBlock = (block, rule) => {
            if (block.type === "heading") return \`<div class="sub-title">\${block.web}</div>\`;
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
            LP_RULES.map((cat) => \`
              <div class="category">
                  <button class="cat-btn">
                      <div class="icon-box"><i class="fa-solid \${cat.icon}"></i></div>
                      \${cat.title}
                      <i class="fa-solid fa-chevron-down chevron"></i>
                  </button>
                  <div class="content-wrapper">
                      <div class="content">
                          \${renderWebCategoryBody(cat, rule)}
                      </div>
                  </div>
              </div>\`).join("");
`;

const rawRouteReplacement = `        // Handle rules/raw for DXRP (High-Performance In-Game HTML)
        if (path === "/rules/raw") {
            return new Response(renderRawRulesDocument(), {
                headers: { "Content-Type": "text/html;charset=UTF-8" }
            });
        }`;

// Insert catalog after esc helper
const escAnchor = `                .replace(/'/g, "&#39;");`;
if (!source.includes(escAnchor)) {
    console.error("Could not find esc() anchor");
    process.exit(1);
}
if (source.includes("LP_RULES")) {
    console.log("Already patched — LP_RULES catalog found.");
    process.exit(0);
}
let patched = source.replace(escAnchor, escAnchor + catalogBlock);

// Replace /rules/raw block
const rawStart = patched.indexOf("        // Handle rules/raw for DXRP");
const rawEnd = patched.indexOf("        // --- STRIPE & DISCORD HELPERS ---");
if (rawStart === -1 || rawEnd === -1) {
    console.error("Could not find /rules/raw block boundaries");
    process.exit(1);
}
patched = patched.slice(0, rawStart) + rawRouteReplacement + "\n\n" + patched.slice(rawEnd);

// Replace rules-root inner content
const rulesRootStart = patched.indexOf('<div id="rules-root">');
const scriptAnchor = patched.indexOf("function copyRuleText(id)", rulesRootStart);
if (rulesRootStart === -1 || scriptAnchor === -1) {
    console.error("Could not find rules-root block");
    process.exit(1);
}
const rulesRootOpenEnd = patched.indexOf(">", rulesRootStart) + 1;
const rulesRootCloseStart = patched.lastIndexOf("</div>", scriptAnchor);
const rulesRootReplacement = `
              \${renderWebRulesRoot(rule)}
          `;
patched =
    patched.slice(0, rulesRootOpenEnd) +
    rulesRootReplacement +
    patched.slice(rulesRootCloseStart);

fs.writeFileSync(targetFile, patched, "utf8");
console.log("Patched:", targetFile);
console.log("Rule edits now live in LP_RULES near the top of fetch().");
