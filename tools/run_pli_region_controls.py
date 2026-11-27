#!/usr/bin/env python3
"""Check conceptual PLI control points and their observable SystemVerilog trace."""

import argparse
from collections import defaultdict, deque
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
from typing import Callable

import run_ghost
import suite_results


PROFILE = "pli-region-reference"
CHECKER = "tools/run_pli_region_controls.py"
PRIVATE_PROBE = "tools/probe_ghost_re_nba_regions.cpp"
CASES = {f"ch4/test_pli_region_controls_assertion_{mode}":
         suite_results.ROOT / "tests" / "ch4" / f"test_pli_region_controls_assertion_{mode}.sv"
         for mode in ("pass", "fail")}
DIAGNOSTIC_REQUIREMENTS = {
    "SV2023-4.4.2.5-EXTRACT-NO-OBSERVED-PLI",
    "SV2023-4.4.3.1-EXTRACT-PREPONED-NO-CURRENT-SLOT-EVENT",
    "SV2023-4.4.3.1-EXTRACT-PREPONED-NO-WRITE",
    "SV2023-4.4.3.5-EXTRACT-PREOBSERVED-NO-CURRENT-SLOT-EVENT",
    "SV2023-4.4.3.5-EXTRACT-PREOBSERVED-NO-WRITE",
}
DIAGNOSTIC_ANCHOR = "class RegionViolation("
REGIONS = (
    "preponed", "pre_active", "active", "inactive", "pre_nba", "nba", "post_nba",
    "pre_observed", "observed", "post_observed", "reactive", "re_inactive",
    "pre_re_nba", "re_nba", "post_re_nba", "pre_postponed", "postponed",
)
ACTIVE_SET = REGIONS[2:7]
REACTIVE_SET = REGIONS[10:15]
BEFORE_REACTIVE = REGIONS[2:10]
READ_ONLY = ("preponed", "pre_observed")


class RegionViolation(ValueError):
    def __init__(self, operation: str, region: str, target: str):
        super().__init__(f"{operation} at {region}: {target}")
        self.operation, self.region, self.target = operation, region, target


@dataclass(frozen=True)
class Event:
    action: Callable[[], None]
    pli: bool


class RegionQueue:
    def __init__(self, values: dict[str, int]):
        self.values = values
        self.events: dict[tuple[int, str], deque[Event]] = defaultdict(deque)
        self.time = 0
        self.region = ""
        self.pli = False

    def schedule(self, region: str, action: Callable[[], None], *, time: int | None = None, pli: bool = False):
        time = self.time if time is None else time
        if region == "observed" and pli:
            raise RegionViolation("callback", region, "PLI")
        if self.pli and time == self.time and (
                self.region == "pre_observed" or (self.region == "preponed" and region != "preponed")):
            raise RegionViolation("schedule", self.region, region)
        self.events[time, region].append(Event(action, pli))

    def write(self, target: str, value: int):
        if self.pli and self.region in READ_ONLY:
            raise RegionViolation("write", self.region, target)
        self.values[target] = value

    def pending(self, regions: tuple[str, ...]) -> bool:
        return any(self.events[self.time, region] for region in regions)

    def drain(self, regions: tuple[str, ...]):
        while (region := next((name for name in regions if self.events[self.time, name]), None)) is not None:
            self.region = region
            event = self.events[self.time, region].popleft()
            self.pli = event.pli
            event.action()
        self.region, self.pli = "", False

    def run_slot(self, time: int):
        self.time = time
        self.drain(("preponed", "pre_active"))
        while self.pending((*BEFORE_REACTIVE, *REACTIVE_SET, "pre_postponed")):
            self.drain(BEFORE_REACTIVE)
            self.drain(REACTIVE_SET)
            if not self.pending((*BEFORE_REACTIVE, *REACTIVE_SET)):
                self.drain(("pre_postponed",))
        self.drain(("postponed",))


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, PRIVATE_PROBE):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    digest.update(suite_results.runner_digest("ghost").encode())
    return digest.hexdigest()


def fixture_settings(path: Path) -> dict[str, int]:
    values = {key: int(value) for key, value in re.findall(
        r"(?m)^`define RC_(\w+) (\d+)$", path.read_text(encoding="utf-8"))}
    if set(values) != {"TICK", "INITIAL", "ACTIVE", "NBA", "RENBA", "PROPERTY"}:
        raise ValueError(f"incomplete region control fixture: {path.name}")
    return values


def reference_trace(settings: dict[str, int]) -> dict:
    tick, initial, active, nba, renba, compare = (settings[name] for name in
                                                   ("TICK", "INITIAL", "ACTIVE", "NBA", "RENBA", "PROPERTY"))
    model = RegionQueue(dict(level=initial, mirror=initial * 2, completed=0, p=0, back=0, triggered=0, mark=0))
    values = model.values
    output, controls, rejected = [], {}, {}
    order = []

    def sample(label: str, *variables: str):
        order.append(label)
        controls[label] = [values[name] for name in variables]

    def public(label: str, *variables: str):
        fields = " ".join(f"{name}={values[name]}" for name in variables)
        output.append(f"{label} t={model.time} {fields}")

    def try_forbidden(operation: str, region: str, target: str, action: Callable[[], None]):
        key = f"{region}:{operation}:{target}"
        try:
            action()
        except RegionViolation as error:
            rejected[key] = (error.operation, error.region, error.target) == (operation, region, target)
        else:
            rejected[key] = False

    def readonly(region: str, read_fields: tuple[str, ...]):
        sample(region, *read_fields)
        for name in ("level", "mirror"):
            try_forbidden("write", region, name, lambda: model.write(name, 1000))
        for destination in REGIONS:
            if (region, destination) == ("preponed", "preponed"):
                continue
            try_forbidden("schedule", region, destination,
                          lambda: model.schedule(destination, lambda: model.write("level", 1001)))
        model.schedule("active", lambda: sample(region + "_next_slot", "level", "mirror"), time=tick + 1)

    def blocking():
        public("active", "level")
        model.write("level", active)
        model.schedule("active", lambda: model.write("mirror", values["level"] * 2))

    def nba_feedback():
        model.write("mirror", values["level"] * 2)
        model.write("completed", values["level"] + 4)
        public("nba feedback", "level", "completed", "triggered")

    def nba_update():
        model.write("level", nba)
        model.schedule("active", nba_feedback)

    def property_action():
        public("property", "passed", "sample", "level", "mirror", "triggered")
        model.schedule("reactive", lambda: public("reactive", "p", "back"))

    def property_evaluate():
        model.write("triggered", 1)
        model.write("sample", controls["preponed"][0])
        model.write("passed", int(values["sample"] == compare))
        model.schedule("reactive", property_action)

    def re_inactive():
        public("re-inactive", "p", "back")
        # This separate Active event is pending while both Re-NBA control points run.
        model.schedule("active", lambda: sample("earlier_active_work", "p", "mark"))

    def re_nba_control(region: str, mark: int):
        sample(region, "p", "back", "mark")
        model.write("mark", mark)
        model.schedule("reactive", lambda: sample(region + "_feedback", "p", "back", "mark"))

    def active_feedback():
        model.write("back", values["p"])
        public("active feedback", "p", "back")

    def re_nba_update():
        model.write("p", renba)
        model.schedule("reactive", lambda: public("re-nba feedback", "p", "back"))
        model.schedule("active", active_feedback)

    schedule = (
        ("preponed", True, lambda: readonly("preponed", ("level", "mirror"))),
        ("pre_active", True, lambda: public("pre-active", "level", "mirror")),
        ("active", False, blocking),
        ("inactive", False, lambda: public("inactive", "level", "triggered")),
        ("pre_nba", True, lambda: public("pre-nba", "level", "mirror")),
        ("nba", False, nba_update),
        ("post_nba", True, lambda: sample("post_nba", "level", "completed")),
        ("pre_observed", True, lambda: readonly("pre_observed", ("level", "mirror", "completed", "triggered"))),
        ("observed", False, property_evaluate),
        ("post_observed", True, lambda: sample("post_observed", "triggered", "passed", "level")),
        ("re_inactive", False, re_inactive),
        ("pre_re_nba", True, lambda: re_nba_control("pre_re_nba", 31)),
        ("re_nba", False, re_nba_update),
        ("post_re_nba", True, lambda: re_nba_control("post_re_nba", 47)),
        ("pre_postponed", True, lambda: public("pre-postponed", "level", "p", "back")),
        ("postponed", True, lambda: public("postponed", "level", "p", "back")),
    )
    try_forbidden("callback", "observed", "PLI",
                  lambda: model.schedule("observed", lambda: model.write("triggered", 99), time=tick, pli=True))
    for region, pli, action in schedule:
        model.schedule(region, action, time=tick, pli=pli)
    model.run_slot(tick)
    model.run_slot(tick + 1)

    expected_controls = {
        "preponed": [initial, 2 * initial],
        "post_nba": [nba, nba + 4],
        "pre_observed": [nba, 2 * nba, nba + 4, 0],
        "post_observed": [1, int(initial == compare), nba],
        "pre_re_nba": [0, 0, 0],
        "pre_re_nba_feedback": [0, 0, 31],
        "post_re_nba": [renba, 0, 31],
        "post_re_nba_feedback": [renba, 0, 47],
        "earlier_active_work": [renba, 47],
        "preponed_next_slot": [nba, 2 * nba],
        "pre_observed_next_slot": [nba, 2 * nba],
    }
    return {"stdout": output, "controls": controls, "controls_in_order": order,
            "expected_controls": expected_controls, "rejected": rejected,
            "pass": (controls == expected_controls and order == list(expected_controls)
                     and len(rejected) == 38 and all(rejected.values()))}


def simulate(ghost: Path, profile: dict, library: Path, work: Path, fixture: Path,
             *, top: str | None = None) -> dict:
    sources, includes = suite_results.files(fixture)
    top = top or suite_results.top_module(fixture)
    command = [str(ghost), *profile["arguments"], "--lib", str(library),
               *[f"+incdir+{directory}" for directory in includes],
               *(["-top", top] if top else []), *map(str, sources), str(fixture)]
    run = subprocess.run(command, cwd=work, env={**os.environ, **profile["environment"]},
                         capture_output=True, text=True, errors="replace", timeout=25)
    return {"exit": run.returncode, "stdout": run_ghost.normalize(run.stdout, profile).splitlines()}


def inspect_private(ghost: Path, profile: dict, includes: Path, work: Path) -> dict:
    compiler = shutil.which(os.environ.get("CXX", "c++"))
    if compiler is None or not (includes / "sukimasim/scheduler/full_delta_scheduler.h").is_file():
        return {"status": "unavailable"}
    library = work / "private.so"
    link = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    build = subprocess.run([compiler, "-std=c++20", "-shared", "-fPIC", *link, f"-I{includes}",
                            str(suite_results.ROOT / PRIVATE_PROBE), "-o", str(library)],
                           cwd=work, capture_output=True, text=True, timeout=30)
    if build.returncode:
        return {"status": "build_failed", "exit": build.returncode}
    fixture = work / "private_regions.sv"
    fixture.write_text("module private_regions; initial begin $probe_re_nba_regions; $finish(0); end endmodule\n")
    run = simulate(ghost, profile, library, work, fixture, top="private_regions")
    leading = ["pre p=0", "reactive before p=0 mark=31", "update p=5",
               "post p=5 mark=31", "reactive after p=5 mark=47"]
    active = {"active from pre p=5 mark=47", "active from post p=5 mark=47"}
    output = run["stdout"]
    passed = run["exit"] == 0 and output[:5] == leading and len(output) == 7 and set(output[5:]) == active
    return {"status": "pass" if passed else "fail", "expected_prefix": leading,
            "expected_active_in_any_order": sorted(active), "actual": run}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True, type=Path)
    parser.add_argument("--include", required=True, type=Path, help="Ghost include root")
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    ghost, include = args.ghost.resolve(), args.include.resolve()
    header = include / "sukimasim/vpi/vpi_user.h"
    compiler = shutil.which(os.environ.get("CC", "cc"))
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if not (ghost.is_file() and header.is_file() and compiler and "--lrm-strict" in profile["arguments"]):
        parser.error("the Ghost executable, VPI headers, C compiler and strict profile are required")
    inputs = {case: suite_results.input_digest(fixture) for case, fixture in CASES.items()}
    checker, binary = checker_digest(), hashlib.sha256(ghost.read_bytes()).hexdigest()
    cases = {}
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        library = work / "public.so"
        c = next(iter(CASES.values())).parent / "pli_control_fixtures/region_trace.c"
        link = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
        build = subprocess.run([compiler, "-shared", "-fPIC", *link, f"-I{header.parent}",
                                str(c), "-o", str(library)], cwd=work, capture_output=True, text=True, timeout=30)
        if build.returncode:
            parser.exit(2, f"Public VPI test failed to build (exit {build.returncode}).\n")
        for case, fixture in CASES.items():
            settings = fixture_settings(fixture)
            reference = reference_trace(settings)
            expected = suite_results.expected_output(fixture).splitlines()
            actual = simulate(ghost, profile, library, work, fixture)
            cases[case] = {"inputs_sha256": inputs[case], "settings": settings, "reference": reference,
                           "native_public": actual, "native_public_matches": actual == {"exit": 0, "stdout": expected},
                           "pass": reference["pass"] and reference["stdout"] == expected}
        private = inspect_private(ghost, profile, include, work)
    if (checker != checker_digest() or binary != hashlib.sha256(ghost.read_bytes()).hexdigest()
            or profile_bytes != args.profile.read_bytes()
            or any(inputs[case] != suite_results.input_digest(fixture) for case, fixture in CASES.items())):
        parser.exit(2, "Tools or test inputs changed during the region check.\n")
    groups = {
        "active": ACTIVE_SET == ("active", "inactive", "pre_nba", "nba", "post_nba"),
        "reactive": REACTIVE_SET == ("reactive", "re_inactive", "pre_re_nba", "re_nba", "post_re_nba"),
    }
    record = {"profile": PROFILE, "checker_sha256": checker, "ghost_sha256": binary,
              "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(),
              "active_region_set": ACTIVE_SET, "reactive_region_set": REACTIVE_SET, "groups": groups,
              "private_full_delta_scheduler": private, "tests": cases}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    for case, result in cases.items():
        print(f"{case}: reference {'pass' if result['pass'] else 'fail'}, public trace match {result['native_public_matches']}")
    print(f"Standalone FullDeltaScheduler: {private['status']}")
    return int(not (all(groups.values()) and all(row["pass"] and row["native_public_matches"] for row in cases.values())))


if __name__ == "__main__":
    raise SystemExit(main())
