#!/usr/bin/env python3
"""Import the supplied standard's section inventory without distributing its text.

Usage: python3 tools/import_standard_sections.py PATH_TO_STANDARD_DIRECTORY --check
       python3 tools/import_standard_sections.py PATH_TO_STANDARD_DIRECTORY --update

The external clause_headings.json omits root headings and 8.23, and mistakes
five numeric examples for headings. Reconcile it with the PDF text's table of
contents, root headings and page ranges. This imports investigation units, NOT
behavior requirements. Human review must still decompose each unit's own text.
"""

import argparse
import hashlib
import json
import re
from pathlib import Path

import behavior_coverage as coverage


def build(directory: Path) -> dict:
    pdf = directory / "IEEE_Std_1800-2023_SystemVerilog.pdf"
    index = directory / "clause_headings.json"
    pages = (directory / "out/lrm_pdftotext_layout.txt").read_text().split("\f")
    toc = "\n".join(pages[9:26])
    toc_rows = {}
    for line in toc.splitlines():
        m = re.match(r"^\s*((?:\d+|[A-Q])(?:\.\d+)*)\.?\s+(.+?)\.{2,}\s*(\d+)\s*$", line)
        if m:
            number, title, printed = m.groups()
            toc_rows[number] = {"title": title.strip(), "pdf_page": int(printed) + 1}
    roots = {}
    for number in range(1, 42):
        row = toc_rows[str(number)]
        assert f"{number}. {row['title']}" in pages[row["pdf_page"] - 1]
        roots[str(number)] = {**row, "kind": "normative"}
    for n, page in enumerate(pages, 1):
        m = re.search(r"(?m)^Annex ([A-Q])\n\((normative|informative)\)\n\n([^\n]+)", page)
        if m:
            letter, kind, title = m.groups()
            roots[letter] = {"title": title, "pdf_page": n, "kind": kind}
    assert set(roots) == {str(n) for n in range(1, 42)} | set("ABCDEFGHIJKLMNOPQ")
    headings = json.loads(index.read_text())["clauses"]
    sections, rejected = dict(roots), []
    for number, row in headings.items():
        if not re.fullmatch(r"(?:[1-9]|[1-3][0-9]|4[01]|[A-Q])(?:\.[1-9][0-9]*)+", number):
            rejected.append(number)
            continue
        root = roots[number.split(".")[0]]
        end = min((r["pdf_page"] for r in roots.values() if r["pdf_page"] > root["pdf_page"]),
                  default=len(pages))
        assert root["pdf_page"] <= row["page"] < end, number
        sections[number] = {"title": row["title"], "pdf_page": row["page"], "kind": root["kind"]}
    restored = []
    for number, row in toc_rows.items():
        if number not in sections:
            assert number == "8.23", f"review unexpected heading missing from index: {number}"
            assert f"{number} {row['title']}" in pages[row["pdf_page"] - 1]
            sections[number] = {**row, "kind": "normative"}
            restored.append(number)
    assert set(rejected) == {"0.0", "1.0", "2.0", "9.0", "2394.26331"}
    assert len(sections) == 1740  # Reconciled supplied edition, including 58 roots.
    return {"schema": 1, "standard": "IEEE 1800-2023", "source": {
        "pdf": pdf.name, "pdf_pages": len(pages) - (not pages[-1].strip()),
        "pdf_sha256": hashlib.sha256(pdf.read_bytes()).hexdigest(),
        "heading_index_sha256": hashlib.sha256(index.read_bytes()).hexdigest(),
        "rejected_numeric_examples": sorted(rejected), "restored_headings": restored,
        "note": "Titles/pages only; no normative body text is distributed. Parent introductions "
                "are independent investigation units. Annex C is marked normative in its body "
                "heading (PDF page 1222), despite the informative label in 1.8 and the TOC. "
                "Clause 41 is deprecated (PDF page 1171), but retained in the inventory."},
        "sections": [{"id": number, **sections[number], "review": "unreviewed"}
                     for number in sorted(sections, key=coverage.section_key)]}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("directory", type=Path)
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--update", action="store_true")
    args = ap.parse_args()
    data = build(args.directory)
    target = coverage.DATA / "standard-sections.json"
    if target.is_file():
        old = json.loads(target.read_text())
        annotations = {s["id"]: {k: v for k, v in s.items()
                                  if k not in ("id", "title", "pdf_page", "kind")}
                       for s in old["sections"]}
        for section in data["sections"]:
            section.update(annotations.get(section["id"], {}))
    text = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    if args.check:
        return 0 if target.is_file() and target.read_text() == text else 1
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text)
    print(f"wrote {target}: {len(data['sections'])} investigation units")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
