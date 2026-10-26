#!/usr/bin/env python3
"""Boundary sweeps and source-bound SVA-fragment formal checks.

The core evaluator is unchanged. Independent parametric RTL formulas live in
sva_formal_cases. Source binding uses Boolean-predicate abstraction: a proof
for every Boolean assignment includes valuations actually arising in a test,
but does not prove the predicate's arithmetic, scheduling or action code.
"""

import argparse
from collections import Counter
from dataclasses import asdict
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

import sva_formal_cases as specs
from sva_reference import formal, m3
from sva_reference.module import parse_module
from sva_reference.parser import Node, parse_sequence
from sva_reference.pilots import PILOTS, ROOT


HERE = Path(__file__).parent


def sha(data):
    return hashlib.sha256(data).hexdigest()


def canonical(node):
    predicates = {}
    def visit(part):
        if part.op == "bool":
            index = predicates.setdefault(part.args[0], len(predicates))
            return ("predicate", index)
        if part.op == "sequence" and part.args[0].op != "bool":
            return visit(part.args[0])
        return (part.op, part.value, tuple(visit(arg) for arg in part.args))
    return visit(node)


def skeleton(node):
    if node.op == "bool":
        return ("predicate",)
    if node.op == "sequence" and node.args[0].op != "bool":
        return skeleton(node.args[0])
    return node.op, node.value, tuple(skeleton(arg) for arg in node.args)


def predicate_binding(template, node):
    result = {}
    def match(left, right):
        while left.op == "sequence" and left.args[0].op != "bool":
            left = left.args[0]
        while right.op == "sequence" and right.args[0].op != "bool":
            right = right.args[0]
        if left.op == "bool":
            if right.op != "bool" or left.args[0].op != "name":
                return False
            name, actual = left.args[0].value, right.args[0]
            if name in result and result[name] != actual:
                return False
            result[name] = actual
            return True
        return (left.op == right.op and left.value == right.value and len(left.args) == len(right.args)
                and all(match(a,b) for a,b in zip(left.args,right.args)))
    return result if match(template,node) else None


def bindings(cases=None):
    cases = specs.catalogue() if cases is None else cases
    lookup = {}
    for case in cases:
        template = parse_sequence(case.expression)
        lookup.setdefault(skeleton(template), []).append((case,template))
    manifest = json.loads(m3.MANIFEST.read_text())
    tests = sorted({*manifest, *("tests/ch16/" + name + ".sv" for name in PILOTS)})
    matched, population, directives = [], [], []
    for test in tests:
        source = (ROOT / test).read_bytes()
        if manifest.get(test, {}).get("prepare") and sha(source) != manifest[test]["source_sha256"]:
            raise ValueError("source preparation audit is stale: " + test)
        population.append({"test": test, "source_sha256": sha(source)})
        module = parse_module(m3.source_view(source.decode(), manifest.get(test, {}).get("prepare")))
        for directive in module.directives:
            label = directive.source.label
            found = []
            def walk(node, path=()):
                if node.op == "sequence" and node.args[0].op != "bool":
                    walk(node.args[0],(*path,0))
                    return
                if node.op == "bool":
                    return
                matched_roles = {}
                for case,template in lookup.get(skeleton(node), []):
                    roles = predicate_binding(template,node)
                    if roles is not None:
                        matched_roles[case.name] = {name:repr(actual) for name,actual in sorted(roles.items())}
                names = sorted(matched_roles)
                if names:
                    item = {"test": test, "directive": label, "kind": directive.source.kind,
                            "subtree": list(path), "ast_sha256": sha(repr(node).encode()),
                            "cases": names, "predicates":matched_roles,"scope": "Boolean sequence fragment only"}
                    matched.append(item)
                    found.extend(names)
                for i, child in enumerate(node.args):
                    if child.op != "bool":
                        walk(child, (*path, i))
            walk(directive.spec.body)
            directives.append({"test": test, "directive": label, "kind": directive.source.kind,
                               "assertion":directive.source.expression,
                               "status": "fragment_bound" if found else "no_family_match",
                               "cases": sorted(set(found))})
    return {"population": population, "directives": directives, "fragments": matched}


def export(case, *, mutation=False):
    machine = formal.dfa(case.expression, case.signals)
    bits = max(1, (len(machine.counts)-1).bit_length())
    streaming = isinstance(case.reference, str)
    span = 1 if streaming else max(case.reference, default=0)
    lines = [f"module check_model(input clk); (* anyseq *) reg [{len(case.signals)-1}:0] letter;",
             f"reg [{bits-1}:0] state=0,following; reg [31:0] actual_count;",
             "always @* begin following=0; case(state)"]
    for state, row in enumerate(machine.transitions):
        lines.append(f"{state}: begin case(letter)")
        lines.extend(f"{letter}: following={target};" for letter,target in enumerate(row))
        lines.append("endcase end")
    lines.extend(["endcase end", "always @(posedge clk) state<=following;",
                  "always @* begin actual_count=0; case(state)"])
    lines.extend(f"{i}: actual_count=32'd{count};" for i,count in enumerate(machine.counts))
    lines.extend(["endcase end", f"reg [7:0] age=0; always @(posedge clk) if(age<{span+1}) age<=age+1;"])
    if streaming:
        lines.append(case.reference)
    else:
        for i,name in enumerate(case.signals):
            lines.append(f"reg [{max(span,1)-1}:0] h_{name}=0; always @(posedge clk) h_{name}<=(h_{name}<<1)|letter[{i}];")
        lines.append("reg [31:0] reference_count; always @* begin reference_count=0; case(age)")
        lines.extend(f"{age}: reference_count={expression};" for age,expression in sorted(case.reference.items()))
        lines.append("endcase end")
    target = "reference_count"
    if mutation:
        if case.family == "tie":
            target = "(reference_count!=0)"
        elif case.family in {"within", "repeat"}:
            target = "32'd0"
        else:
            raise ValueError("no mutation registered")
    cover = "reference_count>=2" if case.family == "tie" else "reference_count!=0"
    lines.extend([f"always @* begin assert(actual_count=={target}); assert(state<{len(machine.counts)});",
                  f"cover({cover}); end endmodule\n"])
    return "\n".join(lines), {"states": len(machine.counts), "depth": 16 if streaming else max(8,span+3)}


def hashes():
    result = {"sva_reference/" + name: digest for name,digest in formal.source_hashes().items()}
    for name in ["sva_formal_cases.py", "sva_formal_sweep.py"]:
        result[name] = sha((HERE / name).read_bytes())
    return result


def plan(case):
    tasks = [("bmc",False), ("prove",False)]
    if case.name in {"tie_1", "within_1_1", "repeat_0_0"}:
        tasks.extend([("cover",False), ("bmc",True)])
    return tasks


def validate(report):
    if report.get("schema") != 1 or report.get("source_hashes") != hashes():
        raise ValueError("stale expansion source bindings")
    if report.get("bindings") != bindings():
        raise ValueError("stale or incomplete suite-source bindings")
    cases = specs.catalogue()
    if report.get("models") != json.loads(json.dumps([asdict(case) for case in cases])):
        raise ValueError("expansion model definitions changed")
    expected = {formal.job_name(case.name,mode,mutant): (case,mode,mutant) for case in cases for mode,mutant in plan(case)}
    jobs = report.get("jobs", [])
    if len(jobs) != len(expected) or {j["case"] for j in jobs} != set(expected):
        raise ValueError("incomplete expansion task plan")
    for job in jobs:
        case, mode, mutant = expected[job["case"]]
        status = "FAIL" if mutant else "PASS"
        if (job["mode"],job["mutation"],job["status"],job["expected"],job["rc"]) != (mode,mutant,status,status,formal.RC[status]) or not job["ok"]:
            raise ValueError("unsuccessful expansion job")
        if (mutant or mode == "cover") and not job.get("traces"):
            raise ValueError("missing expansion witness")
        source, metadata = export(case,mutation=mutant)
        config = formal.sby_text(mode,metadata["depth"],report["timeout"])
        if job["model_sha256"] != sha(source.encode()) or job["sby_sha256"] != sha(config.encode()):
            raise ValueError("expansion model or configuration hash changed")
        if job["depth"] != metadata["depth"] or job["expression"] != case.expression or job["family"] != case.family or job["parameters"] != list(case.parameters):
            raise ValueError("expansion scope metadata changed")
    if not report.get("ok") or report.get("source_changed") or report.get("counts") != dict(Counter(j["status"] for j in jobs)):
        raise ValueError("inconsistent expansion result")
    return True


def run(folder, binary, *, emit_only=False, timeout=30):
    folder = Path(folder)
    if folder.exists() and any(folder.iterdir()):
        raise ValueError("output directory must be new or empty")
    folder.mkdir(parents=True,exist_ok=True)
    before, bound = hashes(), bindings()
    cases = specs.catalogue()
    jobs = []
    env = {"PATH": str(Path(binary).resolve().parent) + os.pathsep + os.defpath,
           "HOME": os.environ.get("HOME","/tmp"), "LANG":"C", "LC_ALL":"C"}
    versions = {}
    if not emit_only:
        for name,flag in [("sby","--version"),("yosys","--version"),("yices-smt2","--version"),("yosys-abc","-h")]:
            result = subprocess.run([str(Path(binary).resolve().parent/name),flag],env=env,capture_output=True,text=True,timeout=10)
            version = ((result.stdout+result.stderr).strip().splitlines() or ["unknown"])[0]
            versions[name] = version.split(", Release,")[0]+")" if ", Release," in version else version
    for case in cases:
        model, meta = export(case)
        if emit_only:
            (folder/(case.name+".sv")).write_text(model)
            continue
        for mode,mutant in plan(case):
            name = formal.job_name(case.name,mode,mutant)
            source = export(case,mutation=True)[0] if mutant else model
            result = formal.run_job(folder/name,source,mode=mode,depth=meta["depth"],expected="FAIL" if mutant else "PASS",
                                    binary=Path(binary).resolve(),env=env,timeout=timeout)
            jobs.append({"case":name,"mutation":mutant,"family":case.family,"parameters":list(case.parameters),
                         "expression":case.expression,"clause":case.clause,"states":meta["states"],**result})
            print(name+": "+result["status"],flush=True)
    changed = before != hashes() or bound != bindings()
    report = {"schema":1,"generated_at":datetime.now(timezone.utc).isoformat(),"source_hashes":before,
              "tool_versions":versions,"scope":"parametric two-state sequence fragments, not full SV tests or action behavior",
              "bindings":bound,"models":[asdict(case) for case in cases],"jobs":jobs,"emit_only":emit_only,"timeout":timeout,
              "source_changed":changed,"counts":dict(Counter(j["status"] for j in jobs)),
              "ok":not emit_only and not changed and all(j["ok"] for j in jobs)}
    (folder/"results.json").write_text(json.dumps(report,indent=2)+"\n")
    return report


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    destination=parser.add_mutually_exclusive_group(required=True)
    destination.add_argument("--output-dir",type=Path)
    destination.add_argument("--check-results",type=Path)
    parser.add_argument("--sby",type=Path)
    parser.add_argument("--emit-only",action="store_true")
    args=parser.parse_args()
    try:
        if args.check_results:
            validate(json.loads(args.check_results.read_text()))
            print("Expansion source bindings and complete task plan are current; solver not rerun.")
            return 0
        if not args.sby and not args.emit_only:
            parser.error("--sby is required for a solver run")
        result=run(args.output_dir,args.sby or Path("unused-sby"),emit_only=args.emit_only)
        print(json.dumps({"models":len(result["models"]),"counts":result["counts"],"ok":result["ok"]}))
        return 0 if (args.emit_only and not result["source_changed"]) or result["ok"] else 1
    except (ValueError,OSError,subprocess.SubprocessError) as exc:
        parser.exit(2,str(exc)+"\n")


if __name__=="__main__":
    raise SystemExit(main())
