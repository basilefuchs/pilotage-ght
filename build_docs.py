#!/usr/bin/env python3
"""Régénère docs/data/index.json à partir des fiches indicateurs_pmsi/ et scripts_r/."""
from __future__ import annotations
import datetime as dt
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
FICHES_DIR = ROOT / "indicateurs_pmsi"
SCRIPTS_DIR = ROOT / "scripts_r"
OUT = ROOT / "docs" / "data" / "index.json"

CATEGORY_LABELS = {
    "01_activite_production": "Activité & production",
    "02_casemix_patientele": "Casemix & patientèle",
    "03_vulnerabilite_sociale": "Vulnérabilité sociale",
    "04_efficience_capacitaire": "Efficience capacitaire",
    "05_qualite_securite": "Qualité & sécurité",
    "06_pertinence_pratiques": "Pertinence des pratiques",
    "07_parcours_continuite": "Parcours & continuité",
    "08_readmissions_evitables": "Réadmissions évitables",
    "09_territoire_attractivite": "Territoire & attractivité",
    "10_financement_valorisation": "Financement & valorisation",
}

TITLE_RE = re.compile(r"^#\s+(.+?)\s*$", re.MULTILINE)
# Flag de vérification humaine, en tête de fiche : <!-- verifie: AAAA-MM-JJ nom -->
VERIF_RE = re.compile(r"<!--\s*verifie:\s*(\d{4}-\d{2}-\d{2})(?:\s+([^>]+?))?\s*-->")


def extract_verification(text: str) -> dict | None:
    head = "\n".join(text.splitlines()[:5])
    m = VERIF_RE.search(head)
    if not m:
        return None
    return {"date": m.group(1), "by": m.group(2).strip() if m.group(2) else None}


def last_commit_date(rel_path: str) -> str | None:
    out = subprocess.run(
        ["git", "-C", str(ROOT), "log", "-1", "--format=%cs", "--", rel_path],
        capture_output=True, text=True,
    ).stdout.strip()
    return out or None


def check_verification(rel_path: str, verified: dict | None) -> dict | None:
    """Invalide la vérification si la fiche a été commitée après la date du flag.

    Granularité au jour : une modification commitée le jour même de la
    vérification n'est pas détectée."""
    if not verified:
        return None
    commit_date = last_commit_date(rel_path)
    if commit_date and commit_date > verified["date"]:
        print(f"⚠ {rel_path} modifiée le {commit_date} après vérification "
              f"du {verified['date']} — pastille retirée")
        return None
    return verified


def extract_title(text: str, fallback: str) -> str:
    m = TITLE_RE.search(text)
    return m.group(1).strip() if m else fallback


def extract_excerpt(text: str) -> str:
    seen_title = False
    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue
        if not seen_title and line.startswith("#"):
            seen_title = True
            continue
        if line.startswith("#") or line.startswith("---") or line.startswith("<!--"):
            continue
        return line if len(line) <= 220 else line[:217] + "…"
    return ""


def main() -> None:
    files = sorted(FICHES_DIR.rglob("*.md"))
    entries = []
    for f in files:
        rel = f.relative_to(ROOT).as_posix()
        parts = rel.split("/")
        category = parts[1]
        base = f.stem
        text = f.read_text(encoding="utf-8")
        r_rel = f"scripts_r/{category}/{base}.R"
        has_r = (ROOT / r_rel).exists()
        entries.append({
            "id": rel[:-3],
            "title": extract_title(text, base),
            "category": category,
            "category_label": CATEGORY_LABELS.get(category, category),
            "path_md": rel,
            "path_r": r_rel if has_r else None,
            "verified": check_verification(rel, extract_verification(text)),
            "excerpt": extract_excerpt(text),
            "text": text,
        })

    OUT.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "entries": entries,
    }
    OUT.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {len(entries)} entries → {OUT.relative_to(ROOT)}")
    print(f"  with R script: {sum(1 for e in entries if e['path_r'])}")
    print(f"  with human verification: {sum(1 for e in entries if e['verified'])}")


if __name__ == "__main__":
    main()
