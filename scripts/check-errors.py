# Assert api_error() turns gateway/proxy bodies into one readable line.
import importlib.util
from pathlib import Path

spec = importlib.util.spec_from_file_location("peditx_ai", Path(__file__).resolve().parents[1] / "src" / "peditx_ai.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

HTML = "<!DOCTYPE html><html><head><title>Not Found</title></head><body><h1>The page you requested was not found.</h1></body></html>"
cases = [
    ("HTML 404", mod.api_error("API request failed", 404, HTML),
     lambda m: m.startswith("API request failed (404)") and "<" not in m and "Not Found" in m and len(m) < 200),
    ("JSON 401", mod.api_error("API request failed", 401, '{"error":{"message":"Incorrect API key provided"}}'),
     lambda m: "Incorrect API key provided" in m and "check the API key" in m),
    ("HTML 502", mod.api_error("API request failed", 502, "<html><h1>502 Bad Gateway</h1></html>"),
     lambda m: "502" in m and "gateway unreachable" in m and len(m.splitlines()) == 1),
    ("no hint for unknown code", mod.api_error("API request failed", 418, "teapot"),
     lambda m: m == "API request failed (418): teapot"),
    ("long body truncated", mod.api_error("API request failed", 400, "x" * 5000),
     lambda m: len(m) < 400),
]

bad = 0
for name, out, ok in cases:
    if not ok(out):
        bad += 1
        print(f"FAIL {name} -> {out!r}")
print(f"{bad} failed" if bad else f"all {len(cases)} error checks passed")
raise SystemExit(1 if bad else 0)
