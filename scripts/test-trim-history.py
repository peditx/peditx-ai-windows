#!/usr/bin/env python3
"""Self-check for trim_history. Run: PYTHONPATH=src python3 scripts/test-trim-history.py"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))
import peditx_ai as p

p.MAX_CONTEXT_CHARS = 400  # tiny budget so the test stays fast

def msg(role, text, **extra):
    return {"role": role, "content": text, **extra}

# 1. short history passes through untouched
short = [msg("user", "hi"), msg("assistant", "hello")]
out, dropped = p.trim_history(short)
assert out is short and dropped == 0, (out, dropped)

# 2. long history keeps the newest turns and prepends the note
old = [msg("user", f"old-{i} " + "x" * 50) for i in range(40)]
new = [msg("user", "latest question"), msg("assistant", "latest answer")]
out, dropped = p.trim_history(old + new)
assert dropped > 0 and out[0]["role"] == "user" and "trimmed" in out[0]["content"]
assert out[-2:] == new, "newest turns must survive"
assert len(out) > 1

# 3. never starts with a dangling tool result
toolchain = (
    [msg("user", f"pad-{i} " + "x" * 50) for i in range(30)]
    + [msg("user", "run it"),
       msg("assistant", "", tool_calls=[{"id": "c1", "function": {"name": "run_command", "arguments": "{}"}}]),
       msg("tool", "output " + "y" * 50, tool_call_id="c1")]
)
out, dropped = p.trim_history(toolchain)
assert dropped > 0 and out[1]["role"] != "tool", "cut must not orphan a tool result"
assert out[0]["role"] == "user"

# 4. a single oversized turn is left alone (the 30 MB guard still applies)
huge = [msg("user", "x" * 10_000)]
out, dropped = p.trim_history(huge)
assert out is huge and dropped == 0

print("all 4 trim_history checks passed")
