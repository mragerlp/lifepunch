# -*- coding: utf-8 -*-
"""Chrome-only Cavelux port — titles, nav/footer brand, meta/canonical/og, domain strings.
Method body copy stays verbatim. noindex stays on. Version bump in title suffix.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION = "v3.50"
OLD = "https://collaborativevalueloop.com"
NEW = "https://cavelux.ai"
OLD_HOST = "collaborativevalueloop.com"
NEW_HOST = "cavelux.ai"
OLD_MAIL = "hello@collaborativevalueloop.com"
NEW_MAIL = "hello@cavelux.ai"

PAGES = {
    "index.html": {
        "title": f"Cavelux — AI Systems Integration · {VERSION}",
        "og_title": "Cavelux — AI Systems Integration",
        "path": "/",
    },
    "system/index.html": {
        "title": f"System — Cavelux · {VERSION}",
        "og_title": "Cavelux System",
        "path": "/system/",
    },
    "work/index.html": {
        "title": f"Work — Cavelux · {VERSION}",
        "og_title": "Cavelux Work",
        "path": "/work/",
    },
    "about/index.html": {
        "title": f"About — Cavelux · {VERSION}",
        "og_title": "Cavelux About",
        "path": "/about/",
    },
    "legal/index.html": {
        "title": f"Legal — Cavelux · {VERSION}",
        "og_title": "Cavelux Legal",
        "path": "/legal/",
    },
}


def swap_chrome(html: str, meta: dict) -> str:
    # Titles
    html = re.sub(r"<title>.*?</title>", f"<title>{meta['title']}</title>", html, count=1)

    # og:site_name + og:title
    html = re.sub(
        r'<meta property="og:site_name" content="[^"]*"\s*/?>',
        '<meta property="og:site_name" content="Cavelux" />',
        html,
    )
    html = re.sub(
        r'<meta property="og:title" content="[^"]*"\s*/?>',
        f'<meta property="og:title" content="{meta["og_title"]}" />',
        html,
    )
    html = re.sub(
        r'<meta name="twitter:title" content="[^"]*"\s*/?>',
        f'<meta name="twitter:title" content="{meta["og_title"]}" />',
        html,
    )

    # canonical + og:url + og:image host + twitter:image host
    html = html.replace(OLD, NEW)
    html = html.replace(OLD_HOST, NEW_HOST)

    # Explicit canonical/path (after host swap, fix path if needed)
    html = re.sub(
        r'<link rel="canonical" href="[^"]*"\s*/?>',
        f'<link rel="canonical" href="{NEW}{meta["path"]}" />',
        html,
    )
    html = re.sub(
        r'<meta property="og:url" content="[^"]*"\s*/?>',
        f'<meta property="og:url" content="{NEW}{meta["path"]}" />',
        html,
    )

    # Meta description opener only when the ruled phrase appears
    html = re.sub(
        r'(content=")Collaborative Value Loop designs',
        r'\1Cavelux installs the Collaborative Value Loop',
        html,
    )

    # Nav + footer brand word (big) — subtitle "Collaborative Value Loop" stays
    html = re.sub(
        r'(<span class="nav-brand-word">)CVL(</span>)',
        r"\1CAVELUX\2",
        html,
    )
    html = re.sub(
        r'aria-label="Collaborative Value Loop home"',
        'aria-label="Cavelux home"',
        html,
    )

    # Footer copy + url (host already swapped for footer-url text)
    html = re.sub(
        r'(<div class="footer-copy">)[^<]*(</div>)',
        r"\1© 2026 Cavelux\2",
        html,
        count=1,
    )
    # Also catch mangled copyright (c 2026 ...)
    html = re.sub(
        r'(<div class="footer-copy">)c 2026 [^<]*(</div>)',
        r"\1© 2026 Cavelux\2",
        html,
        count=1,
    )

    # Contact chrome → new mailbox (not method body)
    html = html.replace(OLD_MAIL, NEW_MAIL)
    # Undo any accidental body-copy host swap inside prose that said collaborativevalueloop.com
    # (legal page intentionally references domain — keep as cavelux.ai after host swap)

    # Guarantee noindex remains
    if 'name="robots"' not in html:
        html = html.replace(
            "</title>",
            '</title>\n  <meta name="robots" content="noindex, nofollow, noarchive" />',
            1,
        )

    return html


def main() -> None:
    for rel, meta in PAGES.items():
        path = ROOT / rel
        if not path.exists():
            raise SystemExit(f"missing {path}")
        original = path.read_text(encoding="utf-8")
        updated = swap_chrome(original, meta)
        path.write_text(updated, encoding="utf-8")
        print(f"OK {rel} -> {meta['title']}")

    # Sensor: noindex still present on all pages
    for rel in PAGES:
        t = (ROOT / rel).read_text(encoding="utf-8")
        assert "noindex" in t, rel
        assert "cavelux.ai" in t, rel
        assert "CAVELUX" in t, rel
        assert "Collaborative Value Loop" in t, rel  # subtitle / method name retained
        assert OLD not in t, f"old absolute URL remains in {rel}"
        assert OLD_HOST not in t, f"old host remains in {rel}"
    print(f"SENSOR_OK version={VERSION}")


if __name__ == "__main__":
    main()
