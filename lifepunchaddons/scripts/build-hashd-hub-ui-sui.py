"""One-off generator: LpHashdPanel layout -> hashd-hub-ui.sui for Sbox UI Designer."""
import json
from pathlib import Path

def layout_flex(w, h, direction="Row", gap=0, padding=None, anchor="TopLeft"):
    p = padding or {"Left": 0, "Top": 0, "Right": 0, "Bottom": 0, "IsZero": True, "IsUniform": True}
    align = "Stretch" if direction == "Column" else "Center"
    return {
        "Mode": "Flex", "X": 0, "Y": 0, "Width": w, "Height": h,
        "Anchor": anchor, "PivotX": 0, "PivotY": 0, "ZIndex": 0,
        "FlexDirection": direction, "JustifyContent": "FlexStart", "AlignItems": align,
        "FlexWrap": "NoWrap", "Gap": gap,
        "Margin": {"Left": 0, "Top": 0, "Right": 0, "Bottom": 0, "IsZero": True, "IsUniform": True},
        "Padding": p,
    }

def style(cls, bg=None, border=None, border_w=0, radius=0, opacity=1, pointer="All", overflow="Visible", visibility="Visible"):
    s = {
        "Visibility": visibility, "PointerEvents": pointer, "Overflow": overflow,
        "Opacity": opacity, "BorderRadius": radius, "BorderWidth": border_w, "ClassName": cls,
    }
    if bg:
        s["BackgroundColor"] = bg
    if border:
        s["BorderColor"] = border
    return s

def el(eid, name, typ, parent, children=None, w=100, h=100, layout=None, sty=None, props=None, notes=None, hidden=False):
    item = {
        "Id": eid, "Name": name, "Type": typ, "ParentId": parent,
        "Children": children or [],
        "Flags": {"IsVariable": False, "Locked": False, "HiddenInDesigner": hidden},
        "Layout": layout or layout_flex(w, h),
        "Style": sty or style(name.lower().replace(" ", "-")),
        "Props": props or {},
    }
    if notes:
        item["Notes"] = notes
    return item

elements = {}
order = []

def add(e):
    elements[e["Id"]] = e
    order.append(e["Id"])

SHELL_W, SHELL_H = 1080, 660
SIDEBAR_W = 72
WORK_W = SHELL_W - SIDEBAR_W
PAD = {"Left": 18, "Top": 16, "Right": 18, "Bottom": 18, "IsZero": False, "IsUniform": False}

add(el(
    "root", "Root", "Canvas", None, ["shell"], SHELL_W, SHELL_H,
    layout={
        "Mode": "Absolute", "X": 0, "Y": 0, "Width": SHELL_W, "Height": SHELL_H,
        "Anchor": "TopLeft", "PivotX": 0, "PivotY": 0, "ZIndex": 0,
        "FlexDirection": "Row", "JustifyContent": "FlexStart", "AlignItems": "Stretch",
        "FlexWrap": "NoWrap", "Gap": 0,
        "Margin": {"Left": 0, "Top": 0, "Right": 0, "Bottom": 0, "IsZero": True, "IsUniform": True},
        "Padding": {"Left": 0, "Top": 0, "Right": 0, "Bottom": 0, "IsZero": True, "IsUniform": True},
    },
    sty=style("lp-bitcoin-ops lp-ui-accent-hashd lp-ui-size-l hashd-chrome-root", pointer="None"),
    notes="Port target: LpHashdPanel.razor — canvas = lp-ui-size-l shell (1080x660).",
))

add(el("shell", "Shell", "VerticalBox", "root", ["pin_gate", "hub_body", "source_footer"],
     SHELL_W, SHELL_H, layout=layout_flex(SHELL_W, SHELL_H, "Column", anchor="TopLeft"),
     sty=style("shell", "#000000", "#374151", 1, 22, overflow="Hidden"),
     notes="1080x660 = lp-ui-size-l"))

# PIN gate (collapsed — Razor @if ShowPinGate; unhide in designer to edit)
add(el("pin_gate", "PinGate", "VerticalBox", "shell", ["pin_header", "pin_body"], SHELL_W, 420,
     layout=layout_flex(SHELL_W, 420, "Column"), sty=style("pin-gate", "#000000", visibility="Collapsed"),
     notes="Secure Boot — HiddenInDesigner + Collapsed. Unhide to edit; collapse hub_body.", hidden=True))
add(el("pin_header", "PinHeader", "HorizontalBox", "pin_gate", ["pin_brand", "pin_close"], SHELL_W, 74,
     layout=layout_flex(SHELL_W, 74, "Row", gap=14, padding={"Left": 20, "Top": 16, "Right": 20, "Bottom": 16, "IsZero": False, "IsUniform": False}),
     sty=style("pin-header", "#15181f", border="#374151", border_w=1)))
add(el("pin_brand", "PinBrand", "HorizontalBox", "pin_header", ["pin_brand_mark", "pin_brand_copy"], 420, 42,
     layout=layout_flex(420, 42, "Row", gap=12), sty=style("pin-brand")))
add(el("pin_brand_mark", "PinBrandMark", "Image", "pin_brand", [], 42, 42, layout=layout_flex(42, 42, "Row"), sty=style("brand-mark"),
     props={"ImagePath": "addons/lifepunch/bitcoinmining/ui/hashd/btc.png", "FitMode": "Contain"}))
add(el("pin_brand_copy", "PinBrandCopy", "VerticalBox", "pin_brand", ["pin_title", "pin_sub"], 280, 42,
     layout=layout_flex(280, 42, "Column", gap=2), sty=style("pin-brand-copy")))
add(el("pin_title", "PinTitle", "Text", "pin_brand_copy", [], 280, 18,
     props={"Text": "SECURE BOOT", "FontSize": 16, "FontWeight": "Bold", "Color": "#f8f9fc"}))
add(el("pin_sub", "PinSub", "Text", "pin_brand_copy", [], 280, 14,
     props={"Text": "Create a 4-digit hub PIN", "FontSize": 12, "Color": "#9ca3af"}))
add(el("pin_close", "PinClose", "Button", "pin_header", [], 34, 34, layout=layout_flex(34, 34, "Row"),
     sty=style("lp-ui-chrome-btn close", radius=8), props={"ButtonText": "✕", "Color": "#e4002b"}))
add(el("pin_body", "PinBody", "VerticalBox", "pin_gate", ["pin_dots", "pin_pad"], SHELL_W, 320,
     layout=layout_flex(SHELL_W, 320, "Column", gap=18, padding={"Left": 24, "Top": 28, "Right": 24, "Bottom": 32, "IsZero": False, "IsUniform": False}),
     sty=style("pin-body")))
add(el("pin_dots", "PinDots", "HorizontalBox", "pin_body", ["pd1", "pd2", "pd3", "pd4"], 200, 14,
     layout=layout_flex(200, 14, "Row", gap=12), sty=style("pin-dots")))
for i, pid in enumerate(["pd1", "pd2", "pd3", "pd4"], 1):
    filled = i <= 2
    add(el(pid, f"PinDot{i}", "Panel", "pin_dots", [], 14, 14, layout=layout_flex(14, 14, "Row"),
         sty=style("pin-dot filled" if filled else "pin-dot", "#e87d3e" if filled else None, radius=999)))
pin_keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "clr", "0", "ok"]
pin_key_ids = [f"pk_{k}" for k in pin_keys]
add(el("pin_pad", "PinPad", "HorizontalBox", "pin_body", pin_key_ids, 280, 200,
     layout=layout_flex(280, 200, "Row", gap=10), sty=style("pin-pad")))
for k, kid in zip(pin_keys, pin_key_ids):
    label = "⌫" if k == "clr" else ("✓" if k == "ok" else k)
    cls = "pin-key ok" if k == "ok" else ("pin-key clr" if k == "clr" else "pin-key")
    bg = "#e87d3e" if k == "ok" else "#12151a"
    add(el(kid, f"PinKey{k}", "Button", "pin_pad", [], 78, 52, layout=layout_flex(78, 52, "Row"),
         sty=style(cls, bg, "#374151", 1, 14),
         props={"ButtonText": label, "FontSize": 18, "FontWeight": "Bold", "Color": "#12100c" if k == "ok" else "#f8f9fc"}))

# Hub main
add(el("hub_body", "HubBody", "VerticalBox", "shell", ["hub_main"], SHELL_W, SHELL_H - 36,
     layout=layout_flex(SHELL_W, SHELL_H - 36, "Column"), sty=style("hub-body")))
add(el("hub_main", "HubMain", "HorizontalBox", "hub_body", ["sidebar", "workspace"], SHELL_W, SHELL_H - 36,
     layout=layout_flex(SHELL_W, SHELL_H - 36, "Row"), sty=style("hub-main")))

nav_ids = ["nav_overview", "nav_wallet", "nav_racks", "nav_settings"]
add(el("sidebar", "Sidebar", "VerticalBox", "hub_main", ["sidebar_brand", "sidebar_nav", "sidebar_foot"], SIDEBAR_W, SHELL_H - 36,
     layout=layout_flex(SIDEBAR_W, SHELL_H - 36, "Column", padding={"Left": 10, "Top": 16, "Right": 10, "Bottom": 14, "IsZero": False, "IsUniform": False}),
     sty=style("sidebar", "#15181f", border="#374151", border_w=1)))
add(el("sidebar_brand", "SidebarBrand", "Panel", "sidebar", ["sidebar_mark"], 46, 46, layout=layout_flex(46, 46, "Row"),
     sty=style("sidebar-brand hex-mark", "rgba(232,125,62,0.14)", "rgba(232,125,62,0.35)", 1, 14)))
add(el("sidebar_mark", "SidebarMark", "Image", "sidebar_brand", [], 30, 30, layout=layout_flex(30, 30, "Row"), sty=style("brand-mark"),
     props={"ImagePath": "addons/lifepunch/bitcoinmining/ui/hashd/btc.png", "FitMode": "Contain"}))
add(el("sidebar_nav", "SidebarNav", "VerticalBox", "sidebar", nav_ids, 46, 260,
     layout=layout_flex(46, 260, "Column", gap=8), sty=style("sidebar-nav")))
for nid, name, sym, active, tip in [
    ("nav_overview", "NavOverview", "⌂", True, "Overview"),
    ("nav_wallet", "NavWallet", "$", False, "Wallet"),
    ("nav_racks", "NavRacks", "▦", False, "Servers"),
    ("nav_settings", "NavSettings", "⚙", False, "Settings"),
]:
    add(el(nid, name, "Button", "sidebar_nav", [], 46, 46, layout=layout_flex(46, 46, "Row"),
         sty=style("sidebar-btn active" if active else "sidebar-btn", "#e87d3e" if active else None, radius=14),
         props={"ButtonText": sym, "FontSize": 18, "Color": "#ffffff" if active else "#6f7785"}, notes=tip))
add(el("sidebar_foot", "SidebarFoot", "VerticalBox", "sidebar", ["sidebar_avatar"], 46, 50,
     layout=layout_flex(46, 50, "Column"), sty=style("sidebar-foot")))
add(el("sidebar_avatar", "SidebarAvatar", "Text", "sidebar_foot", [], 38, 38, layout=layout_flex(38, 38, "Row"),
     sty=style("sidebar-avatar", "#22262e", radius=999),
     props={"Text": "O", "FontSize": 13, "FontWeight": "Bold", "Color": "#f8f9fc", "TextAlign": "Center"}))

add(el("workspace", "Workspace", "VerticalBox", "hub_main", ["hub_header", "workspace_body"], WORK_W, SHELL_H - 36,
     layout=layout_flex(WORK_W, SHELL_H - 36, "Column"), sty=style("workspace")))
add(el("hub_header", "HubHeader", "HorizontalBox", "workspace", ["hub_title", "header_widgets"], WORK_W, 68,
     layout=layout_flex(WORK_W, 68, "Row", gap=16, padding={"Left": 22, "Top": 14, "Right": 22, "Bottom": 12, "IsZero": False, "IsUniform": False}),
     sty=style("page-header hub-header", border="#374151", border_w=1)))
add(el("hub_title", "HubTitle", "Text", "hub_header", [], 220, 28, layout=layout_flex(220, 28, "Row"), sty=style("lp-ui-panel-title hub-title"),
     props={"Text": "◈ Bitcoin Ops", "FontSize": 16, "FontWeight": "Bold", "Color": "#e87d3e"}))
add(el("header_widgets", "HeaderWidgets", "HorizontalBox", "hub_header", ["chip_wallet", "chip_date", "chip_notif", "btn_close"], 420, 36,
     layout=layout_flex(420, 36, "Row", gap=8), sty=style("header-widgets")))
add(el("chip_wallet", "WalletChip", "Button", "header_widgets", [], 120, 36, layout=layout_flex(120, 36, "Row"),
     sty=style("header-chip wallet-chip", "#12151a", "#374151", 1, 999),
     props={"ButtonText": "0.0000 BTC", "FontSize": 12, "FontWeight": "SemiBold", "Color": "#eceef3"}))
add(el("chip_date", "DateChip", "Panel", "header_widgets", ["chip_date_text"], 110, 36, layout=layout_flex(110, 36, "Row"),
     sty=style("header-chip date-chip", "#12151a", "#374151", 1, 999)))
add(el("chip_date_text", "DateChipText", "Text", "chip_date", [], 100, 20,
     props={"Text": "June, 2026", "FontSize": 12, "FontWeight": "SemiBold", "Color": "#eceef3"}))
add(el("chip_notif", "NotifChip", "Button", "header_widgets", [], 36, 36, layout=layout_flex(36, 36, "Row"),
     sty=style("header-chip notif-chip", "#12151a", "#374151", 1, 999), props={"ButtonText": "🔔", "FontSize": 14}))
add(el("btn_close", "BtnClose", "Button", "header_widgets", [], 34, 34, layout=layout_flex(34, 34, "Row"),
     sty=style("lp-ui-chrome-btn close", radius=8), props={"ButtonText": "✕", "Color": "#e4002b"}))

add(el("workspace_body", "WorkspaceBody", "VerticalBox", "workspace", ["main_panel"], WORK_W, SHELL_H - 104,
     layout=layout_flex(WORK_W, SHELL_H - 104, "Column"), sty=style("workspace-body")))
add(el("main_panel", "MainPanel", "VerticalBox", "workspace_body",
     ["pane_overview", "pane_wallet", "pane_racks", "pane_settings"], WORK_W, SHELL_H - 104,
     layout=layout_flex(WORK_W, SHELL_H - 104, "Column", gap=12), sty=style("main-panel"),
     notes="All tabs visible in designer; Razor shows one pane at a time."))

# Overview
add(el("pane_overview", "PaneOverview", "VerticalBox", "main_panel", ["ov_intro", "ov_split"], WORK_W - 36, 280,
     layout=layout_flex(WORK_W - 36, 280, "Column", gap=14, padding=PAD), sty=style("pane overview")))
add(el("ov_intro", "OverviewIntro", "Text", "pane_overview", [], WORK_W - 72, 60, layout=layout_flex(WORK_W - 72, 60, "Row"),
     sty=style("lp-ui-intro", "rgba(232,125,62,0.12)", "rgba(232,125,62,0.35)", 1, 10),
     props={"Text": "Manage linked GPU racks, wallet payout, and hub power from this panel. Place racks near the hub and they auto-link on spawn.",
            "FontSize": 13, "Color": "#ffffff", "TextAlign": "Center", "TextSizeMode": "AutoHeightWrap", "AutoWrapText": True, "WrapTextAt": WORK_W - 100}))
add(el("ov_split", "OverviewSplit", "HorizontalBox", "pane_overview", ["ov_panel_miners", "ov_panel_status"], WORK_W - 72, 200,
     layout=layout_flex(WORK_W - 72, 200, "Row", gap=18), sty=style("lp-ui-split")))
add(el("ov_panel_miners", "PanelMiners", "VerticalBox", "ov_split", ["ov_miners_title", "ov_miners_empty"], 360, 200,
     layout=layout_flex(360, 200, "Column", padding={"Left": 22, "Top": 22, "Right": 22, "Bottom": 22, "IsZero": False, "IsUniform": False}),
     sty=style("lp-ui-panel", "#1a1d23", "#374151", 1, 12)))
add(el("ov_miners_title", "MinersTitle", "Text", "ov_panel_miners", [], 300, 20, sty=style("lp-ui-panel-title"),
     props={"Text": "▦ ACTIVE MINERS", "FontSize": 16, "FontWeight": "Bold", "Color": "#e87d3e"}))
add(el("ov_miners_empty", "MinersEmpty", "Text", "ov_panel_miners", [], 300, 80, sty=style("lp-ui-empty"),
     props={"Text": "Place GPU racks near this hub — they auto-link on spawn.", "FontSize": 13, "Color": "#9ca3af", "TextAlign": "Center"}))
add(el("ov_panel_status", "PanelStatus", "VerticalBox", "ov_split", ["ov_status_title", "ov_info", "ov_perks", "ov_btn_row"], 360, 200,
     layout=layout_flex(360, 200, "Column", gap=8, padding={"Left": 22, "Top": 22, "Right": 22, "Bottom": 22, "IsZero": False, "IsUniform": False}),
     sty=style("lp-ui-panel", "#1a1d23", "#374151", 1, 12)))
add(el("ov_status_title", "StatusTitle", "Text", "ov_panel_status", [], 300, 20, sty=style("lp-ui-panel-title"),
     props={"Text": "◷ HUB STATUS", "FontSize": 16, "FontWeight": "Bold", "Color": "#e87d3e"}))
info_rows = [("ir1", "Total mined", "0.000000 BTC"), ("ir2", "USD value", "$0.00"), ("ir3", "Hash rate", "0.0 TH/s"),
             ("ir4", "Hub power", "Off · --°C"), ("ir5", "Load / draw", "0% · 0W")]
info_ids = [r[0] for r in info_rows]
add(el("ov_info", "HubInfo", "VerticalBox", "ov_panel_status", info_ids, 316, 100, layout=layout_flex(316, 100, "Column", gap=6), sty=style("lp-ui-info")))
for rid, label, val in info_rows:
    add(el(rid, f"InfoRow{rid}", "HorizontalBox", "ov_info", [f"{rid}_l", f"{rid}_v"], 316, 18, layout=layout_flex(316, 18, "Row"), sty=style("lp-ui-info-row")))
    add(el(f"{rid}_l", f"InfoLabel{rid}", "Text", rid, [], 140, 16, props={"Text": label, "FontSize": 12, "Color": "#9ca3af"}))
    add(el(f"{rid}_v", f"InfoValue{rid}", "Text", rid, [], 160, 16, props={"Text": val, "FontSize": 12, "FontWeight": "SemiBold", "Color": "#eceef3"}))
add(el("ov_perks", "HubPerks", "VerticalBox", "ov_panel_status", ["perk1", "perk2", "perk3"], 316, 54,
     layout=layout_flex(316, 54, "Column", gap=4), sty=style("lp-ui-perks")))
for i, txt in enumerate(["0 linked racks", "0 mining now", "Wallet 0.0000 BTC ready to cash out"], 1):
    add(el(f"perk{i}", f"Perk{i}", "Text", "ov_perks", [], 316, 14, props={"Text": txt, "FontSize": 11, "Color": "#9ca3af"}))
add(el("ov_btn_row", "OverviewBtnRow", "HorizontalBox", "ov_panel_status", ["btn_manage", "btn_wallet_ov"], 316, 36,
     layout=layout_flex(316, 36, "Row", gap=8), sty=style("lp-ui-btn-row")))
add(el("btn_manage", "BtnManageRacks", "Button", "ov_btn_row", [], 140, 36, sty=style("lp-ui-btn-primary", "#e87d3e", radius=999),
     props={"ButtonText": "Manage racks", "FontSize": 13, "FontWeight": "Bold", "Color": "#12100c"}))
add(el("btn_wallet_ov", "BtnWalletGhost", "Button", "ov_btn_row", [], 100, 36, sty=style("lp-ui-btn-ghost", radius=999),
     props={"ButtonText": "Wallet", "FontSize": 13, "Color": "#d5dbe7"}))

# Wallet pane
add(el("pane_wallet", "PaneWallet", "VerticalBox", "main_panel", ["wal_title", "wal_intro", "wal_info", "wal_btns"], WORK_W - 36, 220,
     layout=layout_flex(WORK_W - 36, 220, "Column", gap=10, padding=PAD),
     sty=style("pane wallet lp-ui-panel", "#1a1d23", "#374151", 1, 12, visibility="Collapsed"),
     notes="Wallet tab — collapse others when editing this pane.", hidden=True))
add(el("wal_title", "WalletTitle", "Text", "pane_wallet", [], 400, 20, props={"Text": "$ WALLET PAYOUT", "FontSize": 16, "FontWeight": "Bold", "Color": "#e87d3e"}))
add(el("wal_intro", "WalletIntro", "Text", "pane_wallet", [], WORK_W - 80, 40, sty=style("lp-ui-intro wallet-intro"),
     props={"Text": "Cash out linked rack balances to your DXRP wallet.", "FontSize": 12, "Color": "#9ca3af"}))
wal_info_ids = ["wi1", "wi2", "wi3", "wi4"]
add(el("wal_info", "WalletInfo", "VerticalBox", "pane_wallet", wal_info_ids, 400, 80, layout=layout_flex(400, 80, "Column", gap=6), sty=style("lp-ui-info")))
for wid, label, val in [("wi1", "Rack BTC total", "0.000000 BTC"), ("wi2", "USD value", "$0.00"), ("wi3", "Exchange rate", "$65000 / BTC"), ("wi4", "Your cash", "$0")]:
    add(el(wid, wid.upper(), "HorizontalBox", "wal_info", [f"{wid}_l", f"{wid}_v"], 400, 16, layout=layout_flex(400, 16, "Row")))
    add(el(f"{wid}_l", f"{wid}L", "Text", wid, [], 160, 14, props={"Text": label, "FontSize": 12, "Color": "#9ca3af"}))
    add(el(f"{wid}_v", f"{wid}V", "Text", wid, [], 200, 14, props={"Text": val, "FontSize": 12, "FontWeight": "SemiBold", "Color": "#e87d3e" if "BTC" in val else "#eceef3"}))
add(el("wal_btns", "WalletBtns", "HorizontalBox", "pane_wallet", ["wal_sell", "wal_crt"], 400, 36, layout=layout_flex(400, 36, "Row", gap=8), sty=style("lp-ui-btn-row")))
add(el("wal_sell", "WalSell", "Button", "wal_btns", [], 160, 36, sty=style("lp-ui-btn-primary", "#e87d3e", radius=999), props={"ButtonText": "Sell all rack BTC", "Color": "#12100c"}))
add(el("wal_crt", "WalCrt", "Button", "wal_btns", [], 160, 36, sty=style("lp-ui-btn-ghost", radius=999), props={"ButtonText": "Open CRT terminal"}))

# Racks pane
add(el("pane_racks", "PaneRacks", "VerticalBox", "main_panel", ["rack_title", "rack_intro", "rack_empty"], WORK_W - 36, 160,
     layout=layout_flex(WORK_W - 36, 160, "Column", gap=8, padding=PAD),
     sty=style("pane racks lp-ui-panel", "#1a1d23", "#374151", 1, 12, visibility="Collapsed"), hidden=True))
add(el("rack_title", "RackTitle", "Text", "pane_racks", [], 400, 20, props={"Text": "▦ GPU RACKS", "FontSize": 16, "FontWeight": "Bold", "Color": "#e87d3e"}))
add(el("rack_intro", "RackIntro", "Text", "pane_racks", [], 400, 16, props={"Text": "0 linked · terminal index matches list order", "FontSize": 12, "Color": "#9ca3af"}))
add(el("rack_empty", "RackEmpty", "Text", "pane_racks", [], 400, 60, sty=style("lp-ui-empty"),
     props={"Text": "Place GPU racks near this hub — they auto-link on spawn.", "FontSize": 13, "Color": "#9ca3af"}))

# Settings pane
add(el("pane_settings", "PaneSettings", "VerticalBox", "main_panel", ["set_title", "set_scale", "set_power", "set_security"], WORK_W - 36, 260,
     layout=layout_flex(WORK_W - 36, 260, "Column", gap=10, padding=PAD),
     sty=style("pane settings-pane", visibility="Collapsed"), hidden=True))
add(el("set_title", "SettingsTitle", "Text", "pane_settings", [], 400, 20, props={"Text": "⚙ SETTINGS", "FontSize": 16, "FontWeight": "Bold", "Color": "#e87d3e"}))
add(el("set_scale", "SettingsScaleGroup", "VerticalBox", "pane_settings", ["set_scale_label", "set_scale_hint", "set_scale_row"], WORK_W - 72, 90,
     layout=layout_flex(WORK_W - 72, 90, "Column", gap=6, padding={"Left": 18, "Top": 16, "Right": 18, "Bottom": 16, "IsZero": False, "IsUniform": False}),
     sty=style("settings-group", "#12151a", "#374151", 1, 16)))
add(el("set_scale_label", "ScaleLabel", "Text", "set_scale", [], 300, 16, props={"Text": "UI Scale", "FontSize": 13, "FontWeight": "Bold", "Color": "#f8f9fc"}))
add(el("set_scale_hint", "ScaleHint", "Text", "set_scale", [], 300, 28, props={"Text": "Resize the hub admin window.", "FontSize": 12, "Color": "#9ca3af"}))
add(el("set_scale_row", "ScaleRow", "HorizontalBox", "set_scale", ["sz_s", "sz_m", "sz_l", "sz_xl"], 300, 34, layout=layout_flex(300, 34, "Row", gap=8), sty=style("panel-size-row")))
for sid, lbl, active in [("sz_s", "S", False), ("sz_m", "M", False), ("sz_l", "L", True), ("sz_xl", "XL", False)]:
    add(el(sid, f"Size{lbl}", "Button", "set_scale_row", [], 60, 34,
         sty=style("panel-size-opt active" if active else "panel-size-opt", "#e87d3e" if active else None, radius=999),
         props={"ButtonText": lbl, "FontSize": 12, "FontWeight": "Bold", "Color": "#12100c" if active else "#9aa6ba"}))
add(el("set_power", "SettingsPowerGroup", "VerticalBox", "pane_settings", ["set_power_label", "set_power_hint", "set_power_row"], WORK_W - 72, 90,
     layout=layout_flex(WORK_W - 72, 90, "Column", gap=6, padding={"Left": 18, "Top": 16, "Right": 18, "Bottom": 16, "IsZero": False, "IsUniform": False}),
     sty=style("settings-group", "#12151a", "#374151", 1, 16)))
add(el("set_power_label", "PowerLabel", "Text", "set_power", [], 300, 16, props={"Text": "Hub Power", "FontSize": 13, "FontWeight": "Bold", "Color": "#f8f9fc"}))
add(el("set_power_hint", "PowerHint", "Text", "set_power", [], 300, 28, props={"Text": "Turn the HASHD hub on or off.", "FontSize": 12, "Color": "#9ca3af"}))
add(el("set_power_row", "PowerRow", "HorizontalBox", "set_power", ["pwr_on", "pwr_off"], 300, 34, layout=layout_flex(300, 34, "Row", gap=8), sty=style("split-actions")))
add(el("pwr_on", "PowerOn", "Button", "set_power_row", [], 100, 34, sty=style("pill active", "#e87d3e", radius=999), props={"ButtonText": "Power on", "Color": "#12100c"}))
add(el("pwr_off", "PowerOff", "Button", "set_power_row", [], 100, 34, sty=style("pill", radius=999), props={"ButtonText": "Power off", "Color": "#c7d0df"}))
add(el("set_security", "SettingsSecurityGroup", "VerticalBox", "pane_settings", ["set_sec_label", "set_sec_hint"], WORK_W - 72, 70,
     layout=layout_flex(WORK_W - 72, 70, "Column", gap=6, padding={"Left": 18, "Top": 16, "Right": 18, "Bottom": 16, "IsZero": False, "IsUniform": False}),
     sty=style("settings-group", "#12151a", "#374151", 1, 16)))
add(el("set_sec_label", "SecLabel", "Text", "set_security", [], 300, 16, props={"Text": "Security", "FontSize": 13, "FontWeight": "Bold", "Color": "#f8f9fc"}))
add(el("set_sec_hint", "SecHint", "Text", "set_security", [], 300, 32, props={"Text": "Set your PIN on first hub USE via Secure Boot.", "FontSize": 12, "Color": "#9ca3af"}))

add(el("source_footer", "SourceFooter", "Text", "shell", [], SHELL_W, 36, layout=layout_flex(SHELL_W, 36, "Row"),
     sty=style("lp-source-footer", "#0c0a08", border="#374151", border_w=1),
     props={"Text": "LIFEPUNCH™ · lifepunch.co", "FontSize": 11, "Color": "#e87d3e", "TextAlign": "Center"}))

doc = {
    "Document": {
        "SchemaVersion": 1,
        "DocumentId": "sui_hashd_hub_ui_lp01",
        "Name": "hashd-hub-ui",
        "CreatedWith": "Sbox UI Designer",
        "DesignerVersion": "0.1.0",
        "Canvas": {
            "BaseWidth": SHELL_W, "BaseHeight": SHELL_H, "ScaleMode": "FixedResolution",
            "SafeArea": {"Enabled": False, "Left": 0, "Top": 0, "Right": 0, "Bottom": 0},
            "BackgroundPreview": {"Type": "Color", "Color": "#101010", "ImagePath": None},
            "PreviewWidth": 0, "PreviewHeight": 0,
        },
        "Settings": {
            "AutoPreview": True, "PreviewDebounceMs": 350, "SnapToGrid": True, "GridSize": 8,
            "ShowRulers": True, "ShowAnchors": True, "ShowSafeArea": False, "ShowGrid": True,
            "ShowAlignmentGuides": True, "ShowLayoutBounds": True, "CanvasZoom": 0.55,
            "CanvasPanX": 0, "CanvasPanY": 0,
        },
        "Output": {
            "Configured": True,
            "RootFolder": "Code/_sui_scratch/hashd_hub_ui",
            "Namespace": "LifePunch.DXRP.Addons.Bitcoin",
            "ClassName": "HashdHubUiLayout",
            "GenerateRazor": True, "GenerateScss": True,
            "GenerateGeneratedCs": False, "GenerateUserCsIfMissing": False,
            "GenerateCustomScssIfMissing": True,
        },
        "Elements": [elements[i] for i in order],
        "Events": [], "Animations": [], "Bindings": [],
        "Manifest": {"GeneratedFiles": []},
    },
    "__references": [],
    "__version": 0,
}

out = Path(__file__).resolve().parents[1] / "Assets/addons/lifepunch/bitcoinmining/ui/sui/hashd-hub-ui.sui"
out.write_text(json.dumps(doc, indent=2), encoding="utf-8")
print(f"Wrote {len(order)} elements -> {out}")
