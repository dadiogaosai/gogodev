#!/usr/bin/env python3
"""PreToolUse guard: in Go projects, symbol-shaped Grep calls must go through gopls.

Semantic-only rule: text-shaped patterns (strings, spaces, regex syntax beyond a
bare identifier) always pass. Only patterns that look like symbol hunts are
denied — and only when gopls is actually available; otherwise the call passes
with a steering note. Non-Go projects are never touched.
"""
import json
import os
import re
import shutil
import sys


def allow(context=None):
    if context:
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "additionalContext": context,
            }
        }))
    sys.exit(0)


def deny(reason, context):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
            "additionalContext": context,
        }
    }))
    sys.exit(0)


def in_go_project(start):
    path = os.path.abspath(start)
    if os.path.isfile(path):
        path = os.path.dirname(path)
    while True:
        if os.path.isfile(os.path.join(path, "go.mod")):
            return True
        parent = os.path.dirname(path)
        if parent == path:
            return False
        path = parent


GO_KEYWORD_HUNT = re.compile(r"^\\?b?\(?(func|type|var|const|interface|struct)\b")
BARE_IDENT = re.compile(r"^(\\b)?[A-Za-z_][A-Za-z0-9_]*(\\b)?$")
CALL_HUNT = re.compile(r"^(\\b)?[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)?\\?\($")


def is_symbol_hunt(pattern):
    if GO_KEYWORD_HUNT.match(pattern):
        return True
    if CALL_HUNT.match(pattern):
        return True
    m = BARE_IDENT.match(pattern)
    if m:
        ident = pattern.replace("\\b", "")
        # Mixed case is the signature of a Go symbol name (CamelCase exports,
        # mixedCase locals). ALL-CAPS reads as a comment marker or env var
        # (TODO, FIXME, MY_ENV) and all-lowercase as prose or a config key —
        # both as likely text as code, so they pass.
        return bool(re.search(r"[A-Z]", ident) and re.search(r"[a-z]", ident))
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        allow()

    tool_input = data.get("tool_input") or {}
    pattern = tool_input.get("pattern") or ""
    search_path = tool_input.get("path") or data.get("cwd") or os.getcwd()

    if not pattern or not in_go_project(search_path):
        allow()

    if not is_symbol_hunt(pattern):
        allow()

    gopls_hint = (
        "This is a Go project and the pattern looks like a symbol hunt. Use gopls for "
        "compiler-grade answers instead of grep approximations:\n"
        f"- locate the symbol: gopls workspace_symbol '{pattern.replace(chr(92) + 'b', '')}'\n"
        "- then, with its file:line:col — gopls references <pos> | gopls definition <pos> | "
        "gopls implementation <pos>\n"
        "(see the go-semantic-search skill). "
        "Plain-text searches (quoted strings, comments, TODOs) are still fine via Grep — "
        "rephrase the pattern with its surrounding text if this was one."
    )

    if shutil.which("gopls"):
        deny(
            "Symbol-shaped search in a Go project — use gopls instead of grep.",
            gopls_hint,
        )
    else:
        allow(
            "Note: this symbol search in a Go project would be more accurate via gopls, "
            "but gopls is not installed on this machine. Suggest running /gogodev:setup "
            "to install it. Proceeding with grep for now — treat results as approximate "
            "(name collisions, missed interface/embedded relationships)."
        )


if __name__ == "__main__":
    main()
