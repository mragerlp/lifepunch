from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")

old_close = """          if (menu) menu.classList.remove("is-open");
          if (cta) cta.classList.remove("is-open");
          if (toggle) {
            toggle.setAttribute("aria-expanded", "false");
            toggle.textContent = "Menu";
          }
          document.body.classList.remove("nav-menu-open");"""

new_close = """          if (typeof setMenuOpen === "function") setMenuOpen(false);
          else {
            if (menu) menu.classList.remove("is-open");
            if (cta) cta.classList.remove("is-open");
            if (toggle) {
              toggle.setAttribute("aria-expanded", "false");
              toggle.textContent = "Menu";
            }
            document.body.classList.remove("nav-menu-open");
            document.body.style.top = "";
          }"""

for f in root.glob("**/index.html"):
    t = f.read_text(encoding="utf-8")
    orig = t
    t = t.replace(
        '      if (toggle && menu) {\n        var navEl = document.querySelector(".nav");\n        var lockY = 0;\n        function syncNavHeight() {',
        '      var setMenuOpen = null;\n      if (toggle && menu) {\n        var navEl = document.querySelector(".nav");\n        var lockY = 0;\n        function syncNavHeight() {',
    )
    t = t.replace("        function setMenuOpen(open) {", "        setMenuOpen = function (open) {")
    if old_close in t:
        t = t.replace(old_close, new_close)
        print("close-patched", f.relative_to(root))
    else:
        print("close-miss", f.relative_to(root))
    if t != orig:
        f.write_text(t, encoding="utf-8")
        print("wrote", f.relative_to(root))
    else:
        print("nochange", f.relative_to(root))
