#!/usr/bin/env python3
"""Resolve dated and undated IEEE 1800 references and replay their behavioral checks."""

import argparse
import base64
import binascii
from datetime import date
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import run_vpi_extended_attributes as helpers
import suite_results


CHECKER = "tools/run_normative_reference_editions.py"
PROFILE = "normative-reference-editions"
DATED = "ch36/test_normative_dated_vpi_edition"
UNDATED = "ch6/test_normative_undated_binary64"
CASES = {case: suite_results.ROOT / "tests" / f"{case}.sv" for case in (DATED, UNDATED)}
FIXTURES = CASES[UNDATED].parent / "normative_reference_editions"
SOURCE_INDEX = suite_results.ROOT / "coverage/requirement-source-index.json"


def checker_digest() -> str:
    digests = (helpers.digest(suite_results.ROOT / CHECKER), helpers.checker_digest(),
               helpers.digest(SOURCE_INDEX))
    return hashlib.sha256("".join(digests).encode()).hexdigest()


def read_citations(pdf: Path, pdftotext: Path) -> dict:
    inventory = json.loads(SOURCE_INDEX.read_text())
    if helpers.digest(pdf) != inventory["pdf_sha256"]:
        raise ValueError("the IEEE 1800-2023 PDF differs from the inventoried copy")
    section = inventory["sections"]["2"]
    first, last = str(section["start"][0]), str(section["end"][0] - 1)
    extracted = subprocess.run([pdftotext, "-f", first, "-l", last, "-layout", pdf, "-"],
                               capture_output=True, check=True, text=True, timeout=60).stdout
    text = extracted.split("2. Normative references\n", 1)[1]
    if "For dated references" not in text or "For undated references" not in text:
        raise ValueError("cannot locate the two edition-selection rules")
    ieee = re.findall(r"^IEEE Std (\d+(?:\.\d+)?)™?(?:-(\d{4}))?,", text, re.M)
    undated_numbers = sorted(number for number, year in ieee if not year)
    verilog = [f"{number}-{year}" for number, year in ieee if number == "1364" and year]
    fips = re.search(r"^FIPS (180-\d+) \(August (\d{4})\),", text, re.M)
    if fips is None or undated_numbers != ["1003.1", "754"] or "1364-1995" not in verilog:
        raise ValueError("unexpected dated or undated reference citations")
    return {"undated": [f"IEEE {number}" for number in undated_numbers],
            "verilog": verilog, "fips": f"{fips[1]} ({fips[2]}-08)",
            "pdf_sha256": inventory["pdf_sha256"], "section_sha256": section["sha256"]}


def resolve(catalog: list[dict], series: str, as_of: str, pin: str | None = None) -> tuple[str, list[str]]:
    cutoff = date.fromisoformat(as_of)
    published = [row for row in catalog if row["series"] == series and row["published"]
                 and date.fromisoformat(row["published"]) <= cutoff]
    editions = [row for row in published if row["kind"] == "edition"]
    if pin is not None:
        named = [row for row in editions if row["id"] == pin]
        if len(named) != 1:
            raise ValueError(f"cannot identify the cited {series} edition {pin}")
        return named[0]["id"], []
    latest = max(row["published"] for row in editions)
    (edition,) = (row["id"] for row in editions if row["published"] == latest)
    updates = [row for row in published if row["base"] == edition and row["kind"] in {"amendment", "corrigendum"}]
    return edition, [row["id"] for row in sorted(updates, key=lambda row: row["published"])]


def ghost_trial(tools: dict, profile: dict, work: Path, source: Path, *flags) -> dict:
    result = helpers.execute([tools["ghost"], *profile["arguments"], *flags, "-top", source.stem, source],
                             work, env={**os.environ, **profile["environment"]})
    return {"exit": result.returncode,
            "completed": any(line.startswith(profile["trailer"]) for line in result.stdout.splitlines()),
            "output": run_ghost.normalize(result.stdout, profile).splitlines()}


def dated_trials(tools: dict, include: Path, profile: dict, work: Path, references: dict, snapshot: dict) -> dict:
    catalog, cutoff = snapshot["publications"], snapshot["reviewed_through"]
    verilog, = (edition for edition in references["verilog"] if edition == "1364-1995")
    selected, _ = resolve(catalog, "IEEE 1364", cutoff, verilog)
    later, _ = resolve(catalog, "IEEE 1364", cutoff)
    fips, updates = resolve(catalog, "FIPS 180", cutoff, references["fips"])
    fips_later, _ = resolve(catalog, "FIPS 180", cutoff)
    _, alternative_updates = resolve(catalog, "FIPS 180", "2005-01-01")
    sample = subprocess.run([tools["openssl"], "dgst", "-sha1", "-binary"], input=b"abc",
                            cwd=work, capture_output=True, check=True, timeout=60).stdout
    lines = [
        f"IEEE 1364 pin={selected} newest={later}",
        f"FIPS 180 pin={fips} updates={';'.join(updates) or '-'}",
        f"FIPS 180 later={fips_later} available-update={';'.join(alternative_updates)}",
        f"sha1 abc={sample.hex()}",
    ]

    test = CASES[DATED]
    trials = {}
    includes = [f"-I{include}", *(f"-I{include / name}" for name in profile["include_subdirs"])]
    linkage = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    for edition in (selected, later):
        library = work / f"{edition}.so"
        macro = edition.replace("-", "v")
        helpers.build([tools["cc"], "-shared", "-fPIC", *linkage, *includes, "-DFROM_REFERENCE_CATALOG",
                       f"-DVPI_COMPATIBILITY_VERSION_{macro}=1", test.with_suffix(".c"), "-o", library], work)
        trials[edition] = ghost_trial(tools, profile, work, test, "--lib", library)
        lines.extend(f"{edition} {line}" for line in trials[edition]["output"])

    expected = suite_results.expected_output(test).splitlines()
    checks = {
        "dated_matrix_matches": lines == (FIXTURES / "dated.expected").read_text().splitlines(),
        "selected_edition_matches": trials[selected] == {"exit": 0, "completed": True, "output": expected},
        "newer_edition_changes_live_vpi_object_types": (
            later != selected and trials[later]["exit"] == 0 and trials[later]["completed"]
            and trials[later]["output"][1:] != expected[1:]),
    }
    return {"checks": checks, "trials": trials, "output": lines, "pass": all(checks.values())}


def posix_round_trip(tools: dict, work: Path) -> dict:
    original = bytes(range(96))
    source = work / "original.bin"
    source.write_bytes(original)
    lengths = []
    results = {}
    for mode, flags in (("historical", []), ("base64", ["-m"])):
        encoded = subprocess.run([tools["uuencode"], *flags, source.name, "payload.bin"],
                                 capture_output=True, check=True, cwd=work, timeout=30).stdout
        header, *body, trailer = encoded.splitlines()
        recovered = work / f"{mode}.bin"
        subprocess.run([tools["uudecode"], "-o", recovered], input=encoded, capture_output=True,
                       check=True, cwd=work, timeout=30)
        if mode == "historical":
            if not header.startswith(b"begin ") or trailer != b"end" or body[-1] not in (b" ", b"`"):
                raise ValueError("unexpected historical uuencode framing")
            chunks = [binascii.a2b_uu(line) for line in body[:-1]]
            lengths = [len(chunk) for chunk in chunks]
            independently_decoded = b"".join(chunks)
        else:
            if not header.startswith(b"begin-base64 ") or trailer != b"====":
                raise ValueError("unexpected Base64 uuencode framing")
            independently_decoded = base64.b64decode(b"".join(body), validate=True)
        results[mode] = {"match": independently_decoded == recovered.read_bytes() == original,
                         "octets": len(independently_decoded)}
    return {"historical_lengths": lengths, "decoded": results, "sha256": hashlib.sha256(original).hexdigest()}


def undated_trials(tools: dict, profile: dict, work: Path, references: dict, snapshot: dict) -> dict:
    catalog, date_checked = snapshot["publications"], snapshot["reviewed_through"]
    lines, current = [], set()
    cutoffs = {
        "IEEE 754": ("2017-01-01", date_checked),
        "IEEE 1003.1": ("1993-01-01", "1995-01-01", "2014-01-01", "2017-01-01", "2019-01-01", date_checked),
    }
    for series in reversed(references["undated"]):
        for cutoff in cutoffs[series]:
            edition, updates = resolve(catalog, series, cutoff)
            lines.append(f"{series} {cutoff} base={edition} updates={';'.join(updates) or '-'}")
            if cutoff == date_checked:
                current.update([edition, *updates])
    projects = [row["id"] for row in catalog if row["kind"].endswith("-project")]
    lines.extend(f"project excluded={project}" for project in projects if project not in current)

    source = CASES[UNDATED]
    expected = suite_results.expected_output(source).splitlines()
    ghost = ghost_trial(tools, profile, work, source)
    image = work / "binary64.vvp"
    compile_result = helpers.execute([tools["iverilog"], "-g2012", "-s", source.stem, "-o", image, source], work)
    if compile_result.returncode:
        raise ValueError(f"Icarus could not build the binary64 fixture: {compile_result.stderr.strip()}")
    ran = helpers.execute([tools["vvp"], image], work)
    output = [line for line in ran.stdout.splitlines() if "$finish called at" not in line]
    binary64 = ghost == {"exit": 0, "completed": True, "output": expected} and ran.returncode == 0 and output == expected
    lines.append(f"binary64 ghost/icarus={'match' if binary64 else 'different'}")

    posix = posix_round_trip(tools, work)
    lengths = "/".join(map(str, posix["historical_lengths"]))
    lines.append(f"uuencode historical lengths={lengths} decoded={posix['decoded']['historical']['octets']}")
    lines.append(f"uuencode base64 decoded={posix['decoded']['base64']['octets']}")
    checks = {
        "undated_matrix_matches": lines == (FIXTURES / "undated.expected").read_text().splitlines(),
        "native_binary64_matches": binary64,
        "native_uuencode_and_independent_decoder_match": all(row["match"] for row in posix["decoded"].values()),
    }
    return {"checks": checks, "output": lines, "ghost": ghost, "icarus": {"exit": ran.returncode, "output": output},
            "posix": posix, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--iverilog", default="iverilog")
    parser.add_argument("--vvp", default="vvp")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    paths = {name: shutil.which(executable) for name, executable in {
        "ghost": args.ghost, "iverilog": args.iverilog, "vvp": args.vvp,
        "cc": os.environ.get("CC", "cc"), "openssl": "openssl",
        "pdftotext": "pdftotext", "uuencode": "uuencode", "uudecode": "uudecode",
    }.items()}
    missing = [name for name, executable in paths.items() if not executable]
    if missing:
        parser.error("missing required tools: " + ", ".join(missing))
    tools = {name: Path(executable).absolute() for name, executable in paths.items()}
    pdf, include = args.pdf.resolve(), args.include.resolve()

    def provenance():
        return {"checker_sha256": checker_digest(), "inputs": suite_results.fingerprints(CASES.values()),
                "runtime_profile_sha256": helpers.digest(args.profile), "pdf_sha256": helpers.digest(pdf),
                "artifact_sha256": {**{name: helpers.digest(path) for name, path in tools.items()},
                                    "ghost_headers": helpers.headers_digest(include)}}

    try:
        before = provenance()
        profile = json.loads(args.profile.read_bytes())
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        snapshot = json.loads((FIXTURES / "publishers.json").read_bytes())
        references = read_citations(pdf, tools["pdftotext"])
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            results = {
                DATED: dated_trials(tools, include, profile, work, references, snapshot),
                UNDATED: undated_trials(tools, profile, work, references, snapshot),
            }
        if before != provenance():
            raise ValueError("qualification inputs changed during the run")
    except (IndexError, KeyError, OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(2, f"normative-reference qualification stopped: {error}\n")
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": before["checker_sha256"],
        "runtime_profile_sha256": before["runtime_profile_sha256"], "artifact_sha256": before["artifact_sha256"],
        "references": references, "publisher_snapshot": snapshot["reviewed_through"],
        "tests": {case: {"inputs_sha256": before["inputs"][case], **result} for case, result in results.items()},
    }, indent=2) + "\n")
    for case, result in results.items():
        for name, passed in result["checks"].items():
            print(f"{'PASS' if passed else 'FAIL'} {case}: {name}")
    return int(not all(result["pass"] for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
