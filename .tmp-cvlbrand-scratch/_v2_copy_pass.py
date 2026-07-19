import pathlib
import sys

ROOT = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
EM = "\u2014"
CLOSER = f"Secure your vision {EM} and your time {EM} from the black hole."
OLD_SUB = "One conversation to scope it. No generic pitch."

def edit(page, fn):
    p = ROOT / page
    s = p.read_text(encoding="utf-8")
    n = fn(s)
    assert n != s, f"no change applied on {page}"
    p.write_text(n, encoding="utf-8")
    print(page, "OK")

# ---- 1. Signature closer on 4 pages ----
for page in ["index.html", "system/index.html", "work/index.html", "about/index.html"]:
    def swap(s):
        assert OLD_SUB in s, "closer target missing"
        return s.replace(OLD_SUB, CLOSER)
    edit(page, swap)

# ---- 2. /system strips + CSS + knowledge deliverable ----
def system_edits(s):
    # CSS for the two strips, appended after the #system.block rules
    css_anchor = """    #system.block {
      padding: clamp(2.25rem, 3.5vw, 3.25rem) 0;
      scroll-margin-top: 4.5rem;
    }"""
    assert css_anchor in s
    strip_css = css_anchor + """

    /* V2 strips \u2014 tooling layer + black hole (quiet bands under the loop) */
    .v2-strip {
      padding: clamp(2rem, 3vw, 2.75rem) 0;
    }
    .v2-strip .v2-strip-body {
      margin: 0;
      max-width: 46rem;
      font-size: clamp(1rem, 1.4vw, 1.15rem);
      line-height: 1.65;
      color: var(--cvl-ink-dim);
    }"""
    s = s.replace(css_anchor, strip_css)

    # Strips between #system </section> and final-cta
    anchor = """    </section>
    <section class="final-cta" id="discuss">"""
    assert s.count(anchor) == 1
    strips = """    </section>
<section class="block v2-strip" id="tooling">
      <div class="wrap">
        <p class="section-label">The tooling layer</p>
        <p class="v2-strip-body">Every agent in your workflow gets extended with a custom-built MCP server, molded to your operation \u2014 each agent boots with the exact tools your vision requires, grounded at every step.</p>
      </div>
    </section>
    <section class="block v2-strip" id="blackhole">
      <div class="wrap">
        <p class="section-label">The black hole</p>
        <p class="v2-strip-body">The black hole every business hits with modern AI: endless tokens and endless hours burned digging for context before the real building starts. The method exists so you never enter it.</p>
      </div>
    </section>
    <section class="final-cta" id="discuss">"""
    s = s.replace(anchor, strips)

    # Knowledge deliverables append
    k_anchor = """            { cls: "str", t: "  > Clear rules for what is stored, where, how long" },"""
    assert s.count(k_anchor) == 1
    s = s.replace(k_anchor, k_anchor + """
            { cls: "str", t: "  > Custom MCP tooling per agent" },""")
    return s

edit("system/index.html", system_edits)

# ---- 3. /work agent-duty security sentence ----
def work_edits(s):
    old = """LIFEPUNCH is my live game community \u2014 the environment where this method runs under real pressure.
              It proves the method. It is not what I sell."""
    assert old in s
    new = """LIFEPUNCH is my live game community \u2014 the environment where this method runs under real pressure.
              AI agents handle research, planning, coding, documentation, task handoffs, testing discipline,
              project organization, and the cybersecurity that locks the whole operation.
              It proves the method. It is not what I sell."""
    return s.replace(old, new)

edit("work/index.html", work_edits)

print("phase 2 python pass done")
