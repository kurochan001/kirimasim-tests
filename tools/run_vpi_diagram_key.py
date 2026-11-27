#!/usr/bin/env python3
"""Check VPI diagram notation directly in the inventoried IEEE PDF."""

import argparse
from dataclasses import dataclass, replace
import hashlib
from itertools import groupby
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

import suite_results


CHECKER = "tools/run_vpi_diagram_key.py"
PROFILE = "ieee-vpi-diagram-key"
CASE = "ch37/test_vpi_diagram_access"
DEFINITION_CASE = "ch37/test_vpi_diagram_definition_symbols"
CASES = {key: suite_results.ROOT / "tests" / f"{key}.sv" for key in (CASE, DEFINITION_CASE)}
INVENTORY = suite_results.ROOT / "coverage" / "standard-sections.json"
SCALE = 2

# Regions are in PDF points on the pinned edition. Horizontal samples stay
# inside the straight part of each outline, away from its rounded corners.
LEGEND = {
    "object definition": ((96, 99), (98, 112)),
    "object reference": ((147, 151), (149, 166)),
    "class definition": ((187, 190), (192, 207)),
    "class reference": ((295, 299), (298, 314)),
    "unnamed group": ((335, 339), (337, 344)),
    "nested class": ((211, 214), (213, 229)),
    "nested definition": ((233, 237), (235, 250)),
    "nested reference": ((255, 259), (258, 272)),
}
ROLES = {
    ("solid", "bold"): "object-definition",
    ("solid", "regular"): "object-reference",
    ("dotted", "bold-italic"): "class-definition",
    ("dotted", "italic"): "class-reference",
    ("dotted", "none"): "anonymous-group",
}
DEFINITION_OUTPUT = ("object ", "class definition ", "named group nested=", "figure ", "outline contrast ")


@dataclass(frozen=True)
class Glyph:
    border: str
    typeface: str
    label: str
    runs: tuple[int, ...]

    @property
    def role(self) -> str:
        return ROLES.get((self.border, self.typeface), "invalid")

    def observation(self) -> dict:
        return {"border": self.border, "typeface": self.typeface, "role": self.role, "ink_runs": self.runs}


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checked_source() -> dict:
    inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    wanted = {"37.4.1", "37.3.1", "37.10", "37.15"}
    pages = {s["id"]: s["pdf_page"] for s in inventory["sections"] if s["id"] in wanted}
    if pages.keys() != wanted:
        raise ValueError("the VPI diagram pages are missing from the inventory")
    return {"pdf_sha256": inventory["source"]["pdf_sha256"], "pages": pages}


def checker_digest() -> str:
    source = json.dumps(checked_source(), sort_keys=True)
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER) + source).encode()).hexdigest()


def outline(image, x_bounds: tuple[int, int], y_bounds: tuple[int, int]) -> tuple[str, tuple[int, ...]]:
    width = SCALE * (x_bounds[1] - x_bounds[0])
    candidates = []
    for y in range(SCALE * y_bounds[0], SCALE * y_bounds[1] + 1):
        ink = (image.getpixel((x, y)) < 150 for x in range(SCALE * x_bounds[0], SCALE * x_bounds[1]))
        runs = tuple(len(list(run)) for dark, run in groupby(ink) if dark)
        candidates.append((sum(runs), runs))
    covered, runs = max(candidates)
    if max(runs, default=0) >= 0.8 * width:
        return "solid", runs
    if len(runs) >= 3 and 0.2 * width < covered < 0.8 * width:
        return "dotted", runs
    return "unknown", runs


def font_style(font: str) -> str:
    name = font.split("+", 1)[-1].lower()
    if "bold" in name and "italic" in name:
        return "bold-italic"
    if "bold" in name:
        return "bold"
    if "italic" in name:
        return "italic"
    return "regular"


def words_in(page, box: tuple[int, int, int, int]) -> list[dict]:
    words = page.crop(box).extract_words(extra_attrs=["fontname"])
    return sorted(words, key=lambda word: (round(word["top"], 1), word["x0"]))


def glyph(image, words: list[dict], x_bounds: tuple[int, int], y_bounds: tuple[int, int],
          label_bounds: tuple[int, int]) -> Glyph:
    labels = [word for word in words if label_bounds[0] <= word["top"] <= label_bounds[1]]
    styles = {font_style(word["fontname"]) for word in labels}
    typeface = next(iter(styles)) if len(styles) == 1 else "mixed" if styles else "none"
    border, runs = outline(image, x_bounds, y_bounds)
    return Glyph(border, typeface, " ".join(word["text"] for word in labels), runs)


def resolve_class(reference: Glyph, declarations: list[Glyph]) -> str | None:
    if reference.role != "class-reference" or not reference.label:
        return None
    matches = [entry.label for entry in declarations
               if entry.role == "class-definition" and entry.label == reference.label]
    return matches[0] if len(matches) == 1 else None


def render(image_module, poppler: Path, source: Path, index: int, work: Path):
    prefix = work / f"page-{index}"
    result = subprocess.run([poppler, "-r", "144", "-f", str(index), "-l", str(index),
                             "-singlefile", "-png", source, prefix],
                            capture_output=True, text=True, timeout=60)
    if result.returncode:
        raise ValueError(f"cannot render diagram page {index}: {result.stderr.strip()}")
    with image_module.open(prefix.with_suffix(".png")) as image:
        return image.convert("L")


def observe(pdf, images: dict) -> dict:
    legend_page, legend_image = images["37.4.1"]
    legend_words = words_in(pdf.pages[legend_page - 1], (118, 92, 213, 398))
    outlines = {name: glyph(legend_image, legend_words, (145, 183), border, text)
                for name, (border, text) in LEGEND.items()}
    if outline(legend_image, (145, 183), (280, 285))[0] != "dotted":
        raise ValueError("the bottom of the named class is missing")
    if outline(legend_image, (145, 183), (390, 394))[0] != "dotted":
        raise ValueError("the bottom of the unnamed class is missing")
    nested = [outlines[name].role for name in ("nested class", "nested definition", "nested reference")]
    anonymous_members = [word["text"] for word in legend_words if 346 <= word["top"] <= 385]
    if len(anonymous_members) != 2 or len(set(anonymous_members)) != 2:
        raise ValueError("the unnamed group needs two individually labelled members")

    figure_page, figure_image = images["37.3.1"]
    module_glyph = glyph(figure_image, words_in(pdf.pages[figure_page - 1], (180, 88, 270, 107)),
                         (204, 246), (84, 88), (89, 96))
    net_glyph = glyph(figure_image, words_in(pdf.pages[figure_page - 1], (325, 88, 420, 108)),
                      (347, 391), (84, 88), (89, 97))
    net_words = words_in(pdf.pages[figure_page - 1], (325, 118, 430, 190))
    kinds = []
    for identifier, token, meaning in (("vpiName", "str:", "string"),
                                       ("vpiVector", "bool:", "boolean"), ("vpiSize", "int:", "integer")):
        labels = [word for word in net_words if word["text"] == identifier]
        if len(labels) == 1 and any(word["text"] == token and abs(word["top"] - labels[0]["top"]) < 1
                                    for word in net_words):
            kinds.append(meaning)

    defined_page, defined_image = images["37.10"]
    read_words = words_in(pdf.pages[defined_page - 1], (164, 147, 265, 344))
    instance = glyph(defined_image, read_words, (186, 231), (145, 150), (151, 160))
    names = {"package", "interface", "program", "module"}
    members = [word["text"] for word in read_words if word["text"] in names]
    reference_page, reference_image = images["37.15"]
    reference = glyph(reference_image, words_in(pdf.pages[reference_page - 1], (104, 146, 198, 163)),
                      (125, 174), (145, 151), (149, 155))
    if instance.role != "class-definition":
        raise ValueError("the four instance objects do not have their named class definition")
    declarations = [instance, outlines["class definition"], outlines["unnamed group"]]
    resolved = resolve_class(reference, declarations)
    unnamed_targets = sum(
        resolve_class(replace(reference, label=label), declarations) is not None
        for label in ["", *anonymous_members])

    # Alter the measured stroke, then the measured typography in isolation.
    damaged = legend_image.copy()
    for x0, x1 in ((151, 156), (163, 168), (175, 180)):
        damaged.paste(255, (SCALE * x0, 96 * SCALE, SCALE * x1, 100 * SCALE))
    damaged_object = glyph(damaged, legend_words, (145, 183), *LEGEND["object definition"])
    changed_reference = replace(reference, typeface=instance.typeface)
    line_wrong = damaged_object.border == "dotted" and damaged_object.role == "invalid"
    type_wrong = changed_reference.role != reference.role and resolve_class(changed_reference, declarations) is None
    output = [f"{name} border={outlines[name].border} type={outlines[name].typeface}"
              for name in ("object definition", "object reference", "class definition", "class reference", "unnamed group")]
    output += [
        "named group nested=" + ",".join(nested),
        f"unnamed group members={len(anonymous_members)} named-targets={unnamed_targets}",
        f"figure module={module_glyph.role} net={net_glyph.role}",
        "figure net properties=" + ",".join(kinds),
        "instance definition members=" + ",".join(members),
        f"instance reference resolved={resolved}",
        f"outline contrast changed={outlines['object definition'].border}->{damaged_object.border} rejected={int(line_wrong)}",
        f"type contrast changed={reference.typeface}->{changed_reference.typeface} rejected={int(type_wrong)}",
    ]
    return {"output": output, "legend": {name: value.observation() for name, value in outlines.items()},
            "instance_definition": instance.observation(), "instance_reference": reference.observation()}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--pdftoppm", default="pdftoppm")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    try:
        import pdfplumber
        from PIL import Image, __version__ as pillow_version
    except ImportError:
        parser.error("pdfplumber and Pillow are required for diagram checks")
    executable = shutil.which(args.pdftoppm)
    if executable is None:
        parser.error("pdftoppm is required")
    poppler = Path(executable).resolve()
    source = args.pdf.resolve()
    provenance = checked_source()
    checksum, inputs = checker_digest(), suite_results.fingerprints(CASES.values())
    try:
        if digest(source) != provenance["pdf_sha256"]:
            raise ValueError("the PDF differs from the inventoried edition")
        poppler_hash = digest(poppler)
        with tempfile.TemporaryDirectory() as directory, pdfplumber.open(source) as pdf:
            images = {key: (index, render(Image, poppler, source, index, Path(directory)))
                      for key, index in provenance["pages"].items()}
            result = observe(pdf, images)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"diagram key qualification stopped: {error}\n")
    if (digest(source) != provenance["pdf_sha256"] or digest(poppler) != poppler_hash
            or checksum != checker_digest() or inputs != suite_results.fingerprints(CASES.values())):
        parser.exit(2, "diagram qualification inputs changed during the run\n")
    expected = CASES[CASE].parent / "vpi_diagram_key"
    definition = [line for line in result["output"] if line.startswith(DEFINITION_OUTPUT)]
    result["pass"] = result["output"] == (expected / "notation.expected").read_text(encoding="utf-8").splitlines()
    definition_pass = definition == (expected / "definition.expected").read_text(encoding="utf-8").splitlines()
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": checksum, "source": provenance,
        "renderer": {"version": suite_results.tool_version([str(poppler), "-v"]), "sha256": poppler_hash},
        "pdfplumber": pdfplumber.__version__, "pillow": pillow_version,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **result},
                  DEFINITION_CASE: {"inputs_sha256": inputs[DEFINITION_CASE], "output": definition,
                                    "pass": definition_pass}},
    }, indent=2) + "\n")
    passed = result["pass"] and definition_pass
    print("PASS diagram notation and object definitions" if passed else "\n".join(result["output"]))
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())
