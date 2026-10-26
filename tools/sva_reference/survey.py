"""Reproducible M3 inventory and generation-before-comparison boundary.

The broad candidate search intentionally retains the handoff's text-search
false positives. Semantic exclusions use comment/string-free tokens and are
separate from implementation gaps; a parse failure is never called a match.
"""

from collections import Counter
from dataclasses import asdict
import difflib
import hashlib
import json
from pathlib import Path
import re

from . import m3
from .module import parse_module
from .pilots import PILOTS, ROOT
from .source import tokens


def candidates(root=ROOT, *, include_sampled=False):
    rows = []
    for path in sorted((root / "tests").rglob("test_*.sv")):
        source = path.read_text()
        header = re.search(r"/\*(.*?)\*/", source, re.S)
        header = header[1] if header else ""
        oracle = re.search(r"^:oracle:\s*(.*)$", header, re.M)
        if not oracle or oracle[1].split() != ["spec"]:
            continue
        body = source[source.index("*/") + 2:] if "*/" in source else source
        pattern = r"\b(assert|assume|cover)\s+(property|sequence)\b|\bsequence\b|\$(past|rose|fell|stable|changed)\b|\bexpect\s*\("
        if include_sampled:
            pattern += r"|\$sampled\b"
        if not re.search(pattern, body):
            continue
        rows.append({"test": path.relative_to(root).as_posix(), "chapter": path.parent.name,
                     "source_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                     "illegal": ":should_fail_because:" in header, "body": body, "header": header})
    return rows


def recursion(body):
    definitions = {match[1]: match[2] for match in re.finditer(r"\bproperty\s+(\w+)\b(.*?)endproperty", body, re.S)}
    edges = {name: {other for other in definitions if re.search(r"\b" + other + r"\b", text[text.find(";") + 1:])}
             for name, text in definitions.items()}
    def visit(name, active):
        return name in active or any(visit(other, active | {name}) for other in edges[name])
    return any(visit(name, set()) for name in definitions)


def classify(row, audits):
    test, body, header = row["test"], row["body"], row["header"]
    if row["illegal"]:
        return "excluded_illegal", "illegal design; expected rejection is outside the evaluator", []
    if Path(test).stem in PILOTS:
        return "pilot", "already covered by M2", []
    if test in audits:
        return "v1", "source/dependency/report audit registered", []
    words = [token.text for token in tokens(body) if not token.text.startswith('"')]
    joined = " ".join(words)
    def excluded(reason, evidence):
        return "out_of_scope", reason, evidence
    if ":vpi_c:" in header:
        return excluded("VPI coverage/assertion API is outside v1", [":vpi_c:"])
    coverage_api = sorted({word for word in words if word.startswith("$coverage_") or word == "$get_coverage"})
    if coverage_api:
        return excluded("tool coverage database/API behavior is outside v1", coverage_api)
    if "checker" in words:
        return excluded("checker contexts are outside v1", ["checker"])
    sampled = sorted({word for word in words if word in {"$past", "$rose", "$fell", "$stable", "$changed", "$sampled", "$global_clock", "$future_gclk", "$past_gclk", "$rising_gclk", "$falling_gclk", "$steady_gclk", "$changing_gclk"}})
    if sampled:
        return excluded("sampled/global-clock functions are outside v1", sampled)
    inference = sorted(set(words) & {"$inferred_clock", "$inferred_disable"})
    if inference:
        return excluded("context-inferred event/disable arguments are outside the v1 expression-argument subset", inference)
    control = sorted({word for word in words if word.startswith("$assert")})
    if control:
        return excluded("assertion action/control and nonvacuity tasks are outside v1", control)
    methods = sorted(set(re.findall(r"\.\s*(triggered|matched)\b", joined)))
    if methods:
        return excluded("sequence triggered/matched methods are outside v1", methods)
    if "expect" in words:
        return excluded("procedural expect statements are outside v1", ["expect"])
    aborts = sorted(set(words) & {"accept_on", "reject_on", "sync_accept_on", "sync_reject_on"})
    if aborts:
        return excluded("accept/reject abort operators are outside v1", aborts)
    if not re.search(r"\b(?:assert|assume|cover)\s+(?:property|sequence)\b", joined):
        return "not_concurrent", "text-search candidate has no concurrent directive to evaluate", []
    if recursion(joined):
        return excluded("recursive properties are outside v1", ["cyclic named-property references"])
    decls = re.findall(r"\b(?:sequence|property)\s+\w+\b.*?\bend(?:sequence|property)\b", joined, re.S)
    if any(re.search(r"\blocal\s+(?:input|output|inout)\b|;\s*(?:int|integer|logic|bit|byte)\s+(?:\[[^]]+\]\s*)?\w+", declaration) for declaration in decls):
        return excluded("SVA local variables/local formal arguments are outside v1", ["local declaration/formal in SVA body"])
    if any(re.search(r"\bevent\s+\w+", declaration) for declaration in decls):
        return excluded("event formal/actual arguments are outside the v1 expression/signal subset", ["event formal"])
    clocks = sorted(set(re.findall(r"@\s*\(\s*(?:posedge|negedge)\s+([\w.]+)", joined)))
    if len(clocks) > 1:
        return excluded("multiple clock signals/alignment contexts are outside v1", clocks)
    if "restrict" in words:
        return excluded("file also tests restrict property, outside the four v1 directive kinds", ["restrict property"])
    if re.search(r"\b(?:input|output)\s+#", joined):
        return excluded("clocking skew requires values sampled away from the assertion tick", ["clocking input/output skew"])
    if re.search(r"\bassert\s+(?:#|final)", joined):
        return excluded("file includes deferred immediate assertions, outside v1", ["assert #/final"])
    if "specify" in words:
        return excluded("mixed specify/clocking-delay output is not determined solely by assertion-tick samples", ["specify", "clocking/procedural cycle delay"])
    if "program" in words:
        return excluded("program/Active feedback from assertion actions requires event-region simulation beyond v1", ["program", "action-to-process feedback"])
    try:
        module = parse_module(body)
        if not module.directives:
            return "not_concurrent", "no module-level concurrent directives", []
        reason = "parsed v1 constructs lack a registered input/report adapter"
    except ValueError as exc:
        reason = str(exc)
        if "procedural assertion context" in reason:
            return excluded("procedural concurrent assertions are outside v1", [reason])
        if "expected ')'" in reason and "got ','" in reason:
            return excluded("sequence match items/calls are outside the v1 sequence subset", [reason])
    return "in_scope_unhandled", reason, []


def inventory(root=ROOT):
    audits = json.loads(m3.MANIFEST.read_text())
    rows = []
    for candidate in candidates(root):
        status, reason, evidence = classify(candidate, audits)
        rows.append({key: value for key, value in candidate.items() if key not in {"body", "header"}} |
                    {"status": status, "reason": reason, "evidence": evidence})
    return rows


def compare(test, generated):
    path = ROOT / test
    source = path.read_text()
    metadata = re.search(r"^:expected_stdout:\s*@([^\s]+)\s*$", source, re.M)
    if not metadata:
        raise ValueError("M3 input requires an expected file in its metadata")
    expected_path = path.parent / metadata[1]
    if expected_path.resolve().parent != path.parent.resolve():
        raise ValueError("expected file must be adjacent to the source")
    expected = expected_path.read_text()
    return {"status": "match" if expected == generated.output else "mismatch",
            "diff": "".join(difflib.unified_diff(expected.splitlines(True), generated.output.splitlines(True), fromfile=metadata[1], tofile=generated.name + ".actual")),
            "expected_sha256": hashlib.sha256(expected.encode()).hexdigest()}


def run(*, refresh=False, iverilog_bin=None, emit_only=False, output_dir=None):
    rows = inventory()
    generated = {}
    for row in rows:
        if row["status"] == "v1":
            try:
                result = m3.generate(row["test"], refresh=refresh, iverilog_bin=iverilog_bin)
                generated[row["test"]] = result
                row.update({"ticks": result.ticks, "actions": len(result.events), "actual_sha256": hashlib.sha256(result.output.encode()).hexdigest(), "status": "generated"})
            except (ValueError, OSError) as exc:
                row.update({"status": "in_scope_error", "reason": str(exc)})
    # Compare only after every selected output has been independently produced.
    if not emit_only:
        judgments = json.loads((m3.HERE / "fixtures/m3_judgments.json").read_text())
        for row in rows:
            if row["test"] in generated:
                row.update(compare(row["test"], generated[row["test"]]))
                if row["test"] in judgments:
                    judgment = judgments[row["test"]]
                    hashes = {"source_sha256": row["source_sha256"], "expected_sha256": row["expected_sha256"], "actual_sha256": row["actual_sha256"]}
                    binding = judgment.get("correction", judgment)
                    row["judgment"] = judgment if all(binding.get(key) == value for key, value in hashes.items()) else {
                        "disposition": "stale_judgment_requires_review", "approval_required": True}
    result = {"schema": 1, "base_revision": "b0e9dda9fb7eb1b74fa54f4a15243412bb440f27", "scope": "spec-only broad assertion candidates; legal tests classified separately",
              "counts": dict(sorted(Counter(row["status"] for row in rows).items())), "tests": rows}
    if output_dir is not None:
        folder = Path(output_dir)
        folder.mkdir(parents=True, exist_ok=True)
        for test, item in generated.items():
            (folder / (item.name + ".actual")).write_text(item.output)
            (folder / (item.name + ".events.json")).write_text(json.dumps({"test": test, "attempts": item.attempts, "events": [asdict(event) for event in item.events]}, indent=2) + "\n")
        (folder / "inventory.json").write_text(json.dumps(result, indent=2) + "\n")
    return result
