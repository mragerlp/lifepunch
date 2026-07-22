from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
files = list(root.glob("**/index.html")) + [root / "404.html"]

old_css = """      .nav {
        z-index: 200;
        background: #000;
      }
      .nav-inner {
        position: relative;
        flex-wrap: nowrap;
        z-index: 210;
      }
      .nav-brand,
      .nav-toggle {
        position: relative;
        z-index: 220;
      }
      /* Scrim hides page; menu itself is a short dropdown (no scroll) */
      body.nav-menu-open::before {
        content: "";
        position: fixed;
        inset: 0;
        top: var(--cvl-nav-h);
        z-index: 180;
        background: #000;
      }
      .nav-links.is-open {
        display: flex !important;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        text-align: center;
        position: fixed;
        left: 0;
        right: 0;
        top: var(--cvl-nav-h);
        bottom: auto;
        width: 100%;
        height: auto;
        min-height: 0;
        max-height: none;
        z-index: 195;
        margin: 0;
        padding: 0.85rem 1.25rem 1.05rem;
        gap: 0.55rem;
        background: #000;
        border: none;
        border-bottom: 1px solid rgba(146, 250, 17, 0.22);
        box-sizing: border-box;
        overflow: visible;
      }"""

new_css = """      .nav {
        z-index: 200;
        background: #000;
        /* backdrop-filter creates a containing block — traps position:fixed
           menu inside the sticky header. On mobile that + scroll-lock = black void. */
        backdrop-filter: none !important;
        -webkit-backdrop-filter: none !important;
      }
      .nav-inner {
        position: relative;
        flex-wrap: nowrap;
        z-index: 210;
      }
      .nav-brand,
      .nav-toggle {
        position: relative;
        z-index: 220;
      }
      /* Full-viewport scrim; menu is a real viewport-fixed panel under the bar */
      body.nav-menu-open::before {
        content: "";
        position: fixed;
        inset: 0;
        top: 0;
        z-index: 180;
        background: #000;
      }
      .nav-links.is-open {
        display: flex !important;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        text-align: center;
        position: fixed !important;
        left: 0 !important;
        right: 0 !important;
        top: var(--cvl-nav-h) !important;
        bottom: 0 !important;
        width: 100% !important;
        height: auto !important;
        min-height: 0;
        max-height: none;
        z-index: 230 !important;
        margin: 0;
        padding: 1.25rem 1.25rem 2rem;
        gap: 0.65rem;
        background: #000;
        border: none;
        border-bottom: none;
        box-sizing: border-box;
        overflow-y: auto;
        -webkit-overflow-scrolling: touch;
        color: var(--cvl-lime);
      }"""

old_lock = """      body.nav-menu-open {
        overflow: hidden;
        touch-action: none;
      }
      body.nav-menu-open .nav {
        background: #000;
        border-bottom-color: rgba(146, 250, 17, 0.22);
      }"""

new_lock = """      body.nav-menu-open {
        position: fixed;
        left: 0;
        right: 0;
        width: 100%;
        overflow: hidden;
        touch-action: none;
      }
      body.nav-menu-open .nav {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        width: 100%;
        z-index: 240;
        background: #000;
        border-bottom-color: rgba(146, 250, 17, 0.22);
      }"""

old_js = r"""      if (toggle && menu) {
        var navEl = document.querySelector(".nav");
        function syncNavHeight() {
          if (!navEl) return;
          document.documentElement.style.setProperty(
            "--cvl-nav-h",
            navEl.getBoundingClientRect().height + "px"
          );
        }
        syncNavHeight();
        window.addEventListener("resize", syncNavHeight);
        toggle.addEventListener("click", function () {
          syncNavHeight();
          var open = menu.classList.toggle("is-open");
          if (cta) cta.classList.toggle("is-open", open);
          toggle.setAttribute("aria-expanded", open ? "true" : "false");
          toggle.textContent = open ? "Close" : "Menu";
          document.body.classList.toggle("nav-menu-open", open);
        });
      }
      if (toggle && menu) {
        menu.querySelectorAll("a").forEach(function (a) {
          a.addEventListener("click", function () {
            menu.classList.remove("is-open");
            if (cta) cta.classList.remove("is-open");
            toggle.setAttribute("aria-expanded", "false");
            toggle.textContent = "Menu";
            document.body.classList.remove("nav-menu-open");
          });
        });
      }"""

new_js = r"""      if (toggle && menu) {
        var navEl = document.querySelector(".nav");
        var lockY = 0;
        function syncNavHeight() {
          if (!navEl) return;
          document.documentElement.style.setProperty(
            "--cvl-nav-h",
            Math.ceil(navEl.getBoundingClientRect().height) + "px"
          );
        }
        function setMenuOpen(open) {
          if (open) {
            lockY = window.scrollY || window.pageYOffset || 0;
            syncNavHeight();
            menu.classList.add("is-open");
            if (cta) cta.classList.add("is-open");
            toggle.setAttribute("aria-expanded", "true");
            toggle.textContent = "Close";
            document.body.classList.add("nav-menu-open");
            document.body.style.top = "-" + lockY + "px";
          } else {
            menu.classList.remove("is-open");
            if (cta) cta.classList.remove("is-open");
            toggle.setAttribute("aria-expanded", "false");
            toggle.textContent = "Menu";
            document.body.classList.remove("nav-menu-open");
            document.body.style.top = "";
            window.scrollTo(0, lockY);
          }
        }
        syncNavHeight();
        window.addEventListener("resize", syncNavHeight);
        toggle.addEventListener("click", function () {
          setMenuOpen(!menu.classList.contains("is-open"));
        });
        menu.querySelectorAll("a").forEach(function (a) {
          a.addEventListener("click", function () {
            setMenuOpen(false);
          });
        });
      }"""

old_abs = """      .nav-links.is-open {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        position: absolute;
        left: 0;
        right: 0;
        top: 100%;
        background: var(--cvl-bg);
        border-bottom: 1px solid var(--cvl-border);
        padding: 1rem 1.25rem 1.25rem;
        gap: 0.85rem;
      }"""

new_abs = """      /* open-state layout owned by the mobile drawer block (viewport-fixed). */"""

for f in files:
    t = f.read_text(encoding="utf-8")
    orig = t
    hits = []
    for name, old, new in [
        ("css", old_css, new_css),
        ("lock", old_lock, new_lock),
        ("js", old_js, new_js),
        ("abs", old_abs, new_abs),
    ]:
        if old in t:
            t = t.replace(old, new)
            hits.append(name)
        else:
            hits.append("MISS:" + name)
    if t != orig:
        f.write_text(t, encoding="utf-8")
        print("PATCHED", f.relative_to(root), hits)
    else:
        print("NOCHANGE", f.relative_to(root), hits)
