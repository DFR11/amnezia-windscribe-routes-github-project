#!/usr/bin/env python3
import ipaddress
import re
from pathlib import Path

LABEL = re.compile(r"^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$", re.I)

def classify_and_normalize(value):
    value = value.strip()
    if not value: raise ValueError("empty route")
    try:
        if "/" in value:
            network = ipaddress.ip_network(value, strict=False)
            if not isinstance(network, ipaddress.IPv4Network): raise ValueError("IPv6 is not supported")
            return str(network), 0
        address = ipaddress.ip_address(value)
        if not isinstance(address, ipaddress.IPv4Address): raise ValueError("IPv6 is not supported")
        return str(address), 0
    except ValueError as exc:
        if re.fullmatch(r"[0-9.]+(?:/[0-9]+)?", value): raise ValueError(str(exc)) from exc
    if any(x in value for x in ("://", "/", ":", "*", "?", "#", "@")):
        raise ValueError("domain must not contain URL scheme, path, port, wildcard, or credentials")
    domain = value.rstrip(".").encode("idna").decode("ascii").lower()
    labels = domain.split(".")
    if len(domain) > 253 or len(labels) < 2 or any(not LABEL.fullmatch(x) for x in labels):
        raise ValueError("invalid domain name")
    if labels[-1].isdigit(): raise ValueError("top-level domain must not be all numeric")
    return domain, 1

def read_values(input_dir):
    if not input_dir.exists(): raise FileNotFoundError(f"Input directory not found: {input_dir}")
    found = {}
    for path in sorted(input_dir.glob("*.txt")):
        for number, raw in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
            value = raw.split("#", 1)[0].strip()
            if not value: continue
            try: normalized, kind = classify_and_normalize(value)
            except ValueError as exc: raise ValueError(f"{path}:{number}: {value!r}: {exc}") from exc
            found[normalized] = kind
    return sorted(found.items(), key=lambda x: (x[1], x[0]))
