# S&BOX EDITOR LOADOUT — Red's harness + the s&box-knowledge organ (2026-07-19)

Sorting the s&box VS Code extensions into two categories. THE SPLIT MATTERS: most are editor-native (Red wears them, not MCP pellets); ONE holds extractable knowledge (the s&box Resource target).

## CATEGORY A — RED'S HARNESS LOADOUT (editor-native; install on Vengeance; NOT forks, NOT MCP)
Red-in-VS-Code inherits these by being in the harness. The MCP does not wrap them.
- **S&box Tools (Facepunch)** — official; .addon JSON validation + .NET debugger attach.
- **C# Dev Kit (Microsoft)** — C# syntax, .sln management, code navigation.
- **Slang** — HLSL/Slang shader IntelliSense (for custom shaders).
- **C# Razor** — s&box UI markup (HTML/Razor subset). *** KEY FOR UI WORK: s&box UI ports land in Razor. ***
- **Better Comments** — annotation coloring.
- **Error Lens** — inline diagnostics on the offending line.
- **GitHub Copilot** — AI pair-programmer (a body, editor-bound).
Action: install on Vengeance. No fork, no MCP-wrap. This is Red's kit.

## CATEGORY B — THE s&box-KNOWLEDGE ORGAN TARGET (the real pellet)
- **S&box API Tools (alexistb2904)** — snippets, auto-completions for ALL Sandbox types, hover-over API documentation.
- WHY IT MATTERS: it contains the s&box API TYPE DATA + DOCS. IF that data is extractable to a file/schema, it becomes the **s&box Resource** the CVL MCP serves = the brain's s&box air, readable by ANY agent (Green, Blue, non-VS-Code bodies), not just the one with the extension. This is how agents stop hallucinating s&box API (s&box is NOT in model training data).
- NEXT INVESTIGATION: can S&box API Tools' type-data/API-docs be extracted as a servable Resource? If yes = the code-side s&box slop-fix.

## THE COMPLETE s&box SLOP-FIX (both halves sourced)
- VISUAL reference -> the EYE (eye.js: reads reference UI at F12 depth, extracts exact tokens/motion).
- CODE reference -> the s&box API schema (from S&box API Tools data, served as MCP Resource).
- UI PORTS land in -> C# Razor (Red's harness extension).
Eye = sight (what to build). API schema = knowledge (how to build it in s&box). Razor = where it lands.

FROM: Fable (Jarvis), 2026-07-19.
