#!/usr/bin/env python3
"""Register VPI start callbacks before dispatch and compare their live handles."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import suite_results


CHECKER = "tools/run_ghost_vpi_start_callbacks.py"
CASE = "ch38/test_vpi_callbacks_at_thread_and_frame_start"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
PROFILES = {"thread": "ghost-vpi-thread-start", "frame": "ghost-vpi-frame-start"}
HANDLE = r"0x[0-9a-fA-F]+|\(nil\)"
REGISTER = re.compile(rf"VPI_REGISTER (600|603) ({HANDLE}) ([01])")
THREAD = re.compile(rf"VPI_START thread thread=({HANDLE}) type=([01])")
FRAME = re.compile(rf"VPI_START (callback|body) frame=({HANDLE}) thread=({HANDLE}) type=([01])"
                   r" argument=([01])/(-?\d+) local=([01])/(-?\d+)")
EXITED = re.compile(r"^Process \d+ exited with status = (-?\d+)(?: |$)")
LLDB_SCRIPT = """\
def register_before_dispatch(frame, location, internal_dict):
    thread = frame.GetThread()
    arch = thread.GetProcess().GetTarget().GetTriple().split("-")[0]
    registers = {
        "arm64": ("x1", "x2"), "arm64e": ("x1", "x2"), "aarch64": ("x1", "x2"),
        "x86_64": ("rsi", "rdx"),
    }
    if arch not in registers:
        return False
    object_register, reason_register = registers[arch]
    reference = frame.FindRegister(object_register).GetValueAsUnsigned()
    reason = frame.FindRegister(reason_register).GetValueAsUnsigned() & 0xffffffff
    if reason in (600, 603):
        result = frame.EvaluateExpression(
            f"((int (*)(void*,int))register_start_witness)((void*){reference},{reason})"
        )
        ok = result.GetError().Success() and result.GetValueAsUnsigned() == 1
        print(f"VPI_REGISTER {reason} {reference:#x} {int(ok)}", flush=True)
    return False
"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def parse_events(lines: list[str], ordinary: list[str]) -> list[dict]:
    identifiers = {"frame": {}, "thread": {}}
    events = []

    def identify(kind: str, value: str) -> int | None:
        reference = 0 if value == "(nil)" else int(value, 16)
        if reference == 0:
            return None
        known = identifiers[kind]
        return known.setdefault(reference, len(known) + 1)

    for line in lines:
        if match := REGISTER.fullmatch(line):
            kind = "thread" if match[1] == "600" else "frame"
            events.append({"event": "registered", "kind": kind, "object": identify(kind, match[2]),
                           "accepted": match[3] == "1"})
        elif match := THREAD.fullmatch(line):
            events.append({"event": "thread_callback", "thread": identify("thread", match[1]),
                           "typed": match[2] == "1"})
        elif match := FRAME.fullmatch(line):
            events.append({"event": f"frame_{match[1]}", "frame": identify("frame", match[2]),
                           "thread": identify("thread", match[3]), "typed": match[4] == "1",
                           "argument": int(match[6]) if match[5] == "1" else None,
                           "local": int(match[8]) if match[7] == "1" else None})
        elif line in ordinary or line.startswith("task body "):
            events.append({"event": "fixture", "line": line})
    return events


def registered_before(events: list[dict], position: int, kind: str, reference: int) -> bool:
    return sum(event == {"event": "registered", "kind": kind, "object": reference, "accepted": True}
               for event in events[:position]) == 1


def evaluate(events: list[dict], ordinary: list[str], execution_ok: bool) -> dict:
    fixture = [event["line"] for event in events if event["event"] == "fixture"]
    body_indices = [index for index, event in enumerate(events) if event["event"] == "frame_body"]
    fork = next((index for index, event in enumerate(events) if event.get("line") == "before fork"), -1)
    thread_observed, frame_observed = [], []
    body_valid = execution_ok and fixture == ordinary and len(body_indices) == 3
    for ordinal, body_index in enumerate(body_indices):
        body = events[body_index]
        thread, frame = body["thread"], body["frame"]
        in_branch = ordinal > 0
        body_valid &= body["typed"] and thread is not None and frame is not None
        if in_branch:
            exported = f"task body argument={body['argument']} local={body['local']}"
            body_valid &= (body_index + 1 < len(events)
                           and events[body_index + 1] == {"event": "fixture", "line": exported})
        else:
            body_valid &= body["argument"] is None and body["local"] is None and body_index < fork

        matching_threads = [i for i, event in enumerate(events)
                            if event["event"] == "thread_callback" and event["thread"] == thread
                            and event["typed"]]
        matching_frames = [i for i, event in enumerate(events)
                           if event["event"] == "frame_callback" and event["frame"] == frame
                           and event["thread"] == thread and event["typed"]]
        thread_seen = (len(matching_threads) == 1 and matching_threads[0] < body_index
                       and registered_before(events, matching_threads[0], "thread", thread))
        if in_branch:
            thread_seen &= bool(matching_threads) and matching_threads[0] > fork
        thread_observed.append({"thread": thread, "callback_before_body": thread_seen})
        if in_branch:
            event = events[matching_frames[0]] if len(matching_frames) == 1 else {}
            before_body = (len(matching_frames) == 1 and fork < matching_frames[0] < body_index
                           and registered_before(events, matching_frames[0], "frame", frame))
            initialized = before_body and (event["argument"], event["local"]) == (body["argument"], body["local"])
            frame_observed.append({"frame": frame, "thread": thread, "callback_before_body": before_body,
                                   "callback_argument": event.get("argument"), "callback_local": event.get("local"),
                                   "body_argument": body["argument"], "body_local": body["local"],
                                   "initialized": initialized})

    thread_valid = (len({entry["thread"] for entry in thread_observed}) == 3
                    and all(entry["callback_before_body"] for entry in thread_observed)
                    and sum(event["event"] == "thread_callback" for event in events) == 3)
    frame_valid = (len({entry["frame"] for entry in frame_observed}) == 2
                   and all(entry["initialized"] for entry in frame_observed))
    report = {}
    for kind, passed, details in (("thread", thread_valid, thread_observed), ("frame", frame_valid, frame_observed)):
        registrations = [event for event in events if event["event"] == "registered" and event["kind"] == kind]
        qualified = body_valid and bool(registrations) and all(event["accepted"] for event in registrations)
        report[kind] = {"qualified": qualified, "pass": qualified and passed, "observations": details}
    return report


def observe(tools: dict, fixture: Path, includes: list[Path], profile: dict, work: Path) -> dict:
    source = fixture.parent / suite_results.header(fixture)["vpi_c"].removeprefix("@")
    design = work / fixture.name
    shutil.copyfile(fixture, design)
    (work / "witness.py").write_text(LLDB_SCRIPT, encoding="utf-8")
    linker_options = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    library = work / "libtest.so"
    compiled = subprocess.run(
        [tools["compiler"], "-shared", "-fPIC", *linker_options, *[f"-I{d}" for d in includes],
         "-o", str(library), str(source)],
        cwd=work, capture_output=True, text=True, errors="replace", timeout=60,
    )
    if compiled.returncode != 0:
        raise ValueError("the VPI witness failed to compile")
    command = [
        tools["lldb"], "--batch", "--no-lldbinit", "-o", "settings set target.disable-aslr false",
        "-o", "command script import witness.py",
        "-o", "breakpoint set --skip-prologue false --name sukimasim::vpi::VPIInterface::triggerObjectLifetimeCallbacks",
        "-o", "breakpoint command add -F witness.register_before_dispatch 1",
        "-o", "run", "--", tools["simulator"], *profile["arguments"], "--lib", str(library),
        "-top", fixture.stem, design.name, "+trace_vpi_start",
    ]
    execution = subprocess.run(command, cwd=work, env={**os.environ, **profile["environment"]},
                               capture_output=True, text=True, errors="replace", timeout=90)
    lines = execution.stdout.splitlines()
    exits = [int(match[1]) for line in lines if (match := EXITED.match(line))]
    expected = suite_results.expected_output(fixture).splitlines()
    events = parse_events(lines, expected)
    results = evaluate(events, expected, execution.returncode == 0 and exits == [0])
    return {"debugger_exit": execution.returncode, "target_exits": exits, "events": events, "results": results}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--thread-json", type=Path, required=True)
    parser.add_argument("--frame-json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    tools = {"simulator": shutil.which(args.ghost), "lldb": shutil.which(args.lldb),
             "compiler": shutil.which(os.environ.get("CC", "cc"))}
    if not all(tools.values()):
        parser.error("Ghost, LLDB and a C compiler are required")
    tools = {name: str(Path(path).absolute()) for name, path in tools.items()}
    artifacts = {name: Path(path).resolve() for name, path in tools.items()}
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    include = args.include.resolve()
    dirs = [include, *(include / name for name in profile["include_subdirs"])]
    for name in ("sv_vpi_user.h", "vpi_user.h"):
        header = next((d / name for d in dirs if (d / name).is_file()), None)
        if header is None:
            parser.error(f"{name} is unavailable")
        artifacts[name] = header
    fingerprints = {name: digest(path) for name, path in artifacts.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    version = f"private build {fingerprints['simulator'][:12]}"
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation = observe(tools, fixture, dirs, profile, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (fingerprints != {name: digest(path) for name, path in artifacts.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("ghost") or profile_bytes != args.profile.read_bytes()
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"checker_sha256": checksum, "artifact_sha256": fingerprints,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(),
                     "debugger_version": suite_results.tool_version([tools["lldb"], "--version"])}
    for kind, path in (("thread", args.thread_json), ("frame", args.frame_json)):
        result = observation["results"][kind]
        if result["pass"]:
            status = ("pass", "")
        elif result["qualified"]:
            status = ("fail", f"the {kind} start callback observations differed")
        else:
            status = ("unsupported", f"the {kind} start callback could not be qualified")
        result["status"] = status[0]
        suite_results.write(path, "ghost", "Ghost", version, {CASE: status},
                            inputs=inputs, configuration={**configuration, "evidence_profile": PROFILES[kind]},
                            runner_sha256=runner)
        print(kind, result)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "ghost", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    return int(not all(result["pass"] for result in observation["results"].values()))


if __name__ == "__main__":
    raise SystemExit(main())
