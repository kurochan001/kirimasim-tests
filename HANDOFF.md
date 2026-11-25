# OpenCode handoff

[English](HANDOFF.md) / [日本語](HANDOFF.ja.md)

## Goal and status

Map all 12,332 entries in the IEEE 1800-2023 requirements ledger to tests that substantiate the applicable source rules. As of 2026-11-25, design coverage is **98.98% (12,206 of 12,332)**, with 126 requirements open. Execution evidence covers 11,192 requirements across all tools, including 6,455 reproducible with public tools. Consult the summary JSON for the latest values. [Summary JSON](coverage/behavior-summary.json) · [How to read the summary](docs/behavior-coverage-summary.en.md)

## Resume work

Open the repository root in OpenCode and point it to this file. Check the branch and worktree with `git status --short --branch` and `git log -1 --oneline`.

```sh
python3 - <<'PY'
import json
from pathlib import Path

ledger = json.loads(Path('coverage/behaviors.json').read_text())
for row in ledger['requirements']:
    if not row['checks']:
        print(row['id'], row['acceptance'])
PY
```

Use a requirement's `source_spans` to identify the section and block, then inspect an authorized copy of IEEE 1800-2023 and the existing files in `tests/chNN/`. Run new tests with the applicable runners and record the input fingerprint, observed differences, and acceptance checks before adding a mapping. When the standard permits several outcomes, confirm that the required preconditions and controls held and record the observation. [Requirements ledger](coverage/behaviors.json) · [Source index](coverage/requirement-source-index.json) · [Mapping procedure](docs/requirements-to-tests-method.en.md)

## Verification commands

```sh
python3 tools/lint_metadata.py tests/chNN/test_example.sv
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_catalog.py --check
python3 tools/suite_stats.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/documentation_languages.py --check
python3 -m unittest discover -s tools -p 'test_*.py'
```

After changing tests, regenerate the affected reports with their `--update` commands. After editing paired handwritten documents, run `python3 tools/documentation_languages.py --record`. Ghost replays require an accessible executable and strict runtime profile. Individual records identify the portions reproducible with public tools. [Evidence and replay instructions](coverage/README.en.md) · [CI workflow](.github/workflows/check.yml)

## Recent results and open candidates

- For the §4.3 reference scheduler, all three configurations matched the allowed traces on Icarus, Ghost, Verilator, and kirimasim. The configurations include a control and two cases with competing writes. [Qualification record](coverage/qualification/scheduler-reference-20261125.json)
- For §11.4.14.1 class streaming, Ghost returned `35` in the acyclic control. The separate process terminated with signal 11 after confirming the self-reference. The standard leaves the cyclic result undefined. [Qualification record](coverage/qualification/class-stream-cycle-20261125.json)
- For §36.12.3, a legacy VPI application read a memory in a Verilog-1995 partition. Icarus and Ghost both returned `29` and `61`. [Qualification record](coverage/qualification/vpi-legacy-partition-memory-20261125.json)
- Most open requirements concern Chapter 34 protection directives and Chapters 37 and 38 VPI. In a preliminary §25.9 Ghost strict run, a virtual interface worked in procedural event controls in an `initial` block and a task. The simulator rejected explicit sensitivity lists and a continuous assignment. Ghost accepted the `always_comb` case, leaving part of the ledger's acceptance condition without a qualifying result. [Clause coverage](docs/behavior-coverage.en.md)
