"""Patch cornerman-rag for structured conversation logging + command intents."""
from __future__ import annotations

import os

HERE = os.path.dirname(os.path.abspath(__file__))
RELAY = os.path.join(HERE, "relay.py")
TALK = os.path.join(HERE, "talk.py")

RELAY_HOOK = '''
    try:
        import commands
        import conversation_log
        intent = commands.parse(text)
        conversation_log.log_turn(
            channel="vengeance-relay",
            user_text=text,
            intent=intent,
            agent=intent.get("agent"),
            project=intent.get("project"),
            stt="lifepunchnet",
            tags=["voice", "vengeance-relay"],
        )
    except Exception:
        pass
'''

TALK_HOOK = '''
        try:
            import commands
            import conversation_log
            intent = commands.parse(user_text)
            conversation_log.log_turn(
                channel="cornerman-local",
                user_text=user_text,
                ai_text=reply,
                intent=intent,
                agent=intent.get("agent") or "cornerman",
                project=intent.get("project"),
                stt="local-faster-whisper",
                tags=["voice", "cornerman-local"],
            )
        except Exception:
            pass
'''


def patch_relay(raw: str) -> tuple[str, bool]:
    marker = "channel=\"vengeance-relay\""
    if marker in raw:
        return raw, False
    needle = "    append_session_log(n, text)"
    if needle not in raw:
        return raw, False
    raw = raw.replace(
        needle,
        needle + RELAY_HOOK,
        1,
    )
    return raw, True


def patch_talk(raw: str) -> tuple[str, bool]:
    marker = 'channel="cornerman-local"'
    if marker in raw:
        return raw, False
    needle = '        history.append({"role": "assistant", "content": reply})'
    if needle not in raw:
        return raw, False
    raw = raw.replace(needle, TALK_HOOK + "\n" + needle, 1)
    return raw, True


def main() -> int:
    changed = []

    with open(RELAY, encoding="utf-8") as f:
        relay = f.read()
    relay, ok = patch_relay(relay)
    if ok:
        with open(RELAY, "w", encoding="utf-8", newline="\n") as f:
            f.write(relay)
        changed.append("relay.py")

    with open(TALK, encoding="utf-8") as f:
        talk = f.read()
    talk, ok = patch_talk(talk)
    if ok:
        with open(TALK, "w", encoding="utf-8", newline="\n") as f:
            f.write(talk)
        changed.append("talk.py")

    print("Patched:", ", ".join(changed) if changed else "already up to date")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
