#!/usr/bin/env python3
import json
from pathlib import Path
from parser import read_values

ROOT = Path(__file__).resolve().parents[1]

def load(path):
    with path.open(encoding="utf-8") as f: return json.load(f)

def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")

def build_amnezia(routes):
    data = load(ROOT / "template/amnezia.template.json")
    if not isinstance(data, list): raise ValueError("Amnezia template root must be an array")
    existing = {x.get("hostname") for x in data if isinstance(x, dict)}
    for value, _ in routes:
        if value not in existing:
            data.append({"hostname": value, "ip": "", "ips": []})
            existing.add(value)
    return data

def build_windscribe(routes):
    data = load(ROOT / "template/windscribe.template.json")
    if not isinstance(data, dict): raise ValueError("Windscribe template root must be an object")
    entries = data.get("networkRoutes")
    if not isinstance(entries, list): raise ValueError("Windscribe template must contain a networkRoutes array")
    existing = {x.get("name") for x in entries if isinstance(x, dict)}
    for value, kind in routes:
        if value not in existing:
            entries.append({"active": True, "name": value, "type": kind})
            existing.add(value)
    return data

def main():
    routes = read_values(ROOT / "input")
    amz, wind = build_amnezia(routes), build_windscribe(routes)
    save(ROOT / "dist/amnezia-routes.json", amz)
    save(ROOT / "dist/windscribe-routes.json", wind)
    print(f"Parsed routes: {len(routes)}")
    print(f"Amnezia entries: {len(amz)}")
    print(f"Windscribe networkRoutes: {len(wind['networkRoutes'])}")

if __name__ == "__main__": main()
