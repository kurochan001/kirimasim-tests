"""Check the parsed declarators and initializer restrictions of non-ANSI tasks."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


FIXTURES = Path(__file__).resolve().parent.parent / "tests/ch13"
DECLARATORS = FIXTURES / "test_non_ansi_task_argument_list_preserves_each_declarator.sv"
INITIALIZER = FIXTURES / "test_illegal_default_argument_in_non_ansi_declaration.sv"
SUBROUTINE_FORMS = FIXTURES / "test_subroutine_task_and_function_forms.sv"


@unittest.skipUnless(os.environ.get("SLANG_EXECUTABLE"), "set SLANG_EXECUTABLE to run Slang")
class SlangSubroutineSyntax(unittest.TestCase):
    def task_ports(self, fixture, directory):
        result = self.run_slang(
            fixture, directory, "--parse-only", "--cst-json", "syntax.json",
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        data = json.loads((Path(directory) / "syntax.json").read_text(encoding="utf-8"))
        module = data["syntaxTrees"][0]["root"]["members"][0]
        task = next(node for node in module["members"] if node["kind"] == "TaskDeclaration")
        return [node["declarators"] for node in task["items"] if node["kind"] == "PortDeclaration"]

    def run_slang(self, fixture, directory, *options):
        executable = Path(os.environ["SLANG_EXECUTABLE"]).resolve()
        return subprocess.run(
            [str(executable), "--std=1800-2023", *options, str(fixture)],
            cwd=directory, capture_output=True, text=True, timeout=90,
        )

    def subroutine_forms(self, directory):
        result = self.run_slang(SUBROUTINE_FORMS, directory, "--ast-json", "subroutines.json")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        data = json.loads((Path(directory) / "subroutines.json").read_text(encoding="utf-8"))
        definitions, calls = {}, []
        todo = [data]
        while todo:
            node = todo.pop()
            if isinstance(node, dict):
                if node.get("kind") == "Subroutine":
                    definitions[node["name"]] = node["subroutineKind"]
                if node.get("kind") == "Call":
                    calls.append(node["subroutine"].rsplit(" ", 1)[-1])
                todo.extend(node.values())
            elif isinstance(node, list):
                todo.extend(node)
        return definitions, {name: calls.count(name) for name in definitions}

    def test_tasks_and_functions_have_distinct_subroutine_kinds(self):
        with tempfile.TemporaryDirectory() as directory:
            definitions, calls = self.subroutine_forms(directory)
        self.assertEqual(definitions, {"adjust": "Function", "inner": "Task", "outer": "Task", "tick": "Task"})
        self.assertEqual(calls, {"adjust": 2, "inner": 1, "outer": 1, "tick": 2})

    def test_non_ansi_task_ports_keep_separate_dimensions_and_initializer(self):
        with tempfile.TemporaryDirectory() as directory:
            ports = self.task_ports(DECLARATORS, directory)
            tokens = ["Declarator", "Comma", "Declarator", "Comma", "Declarator", "Comma", "Declarator"]
            self.assertEqual([node["kind"] for node in ports[0]], tokens)
            self.assertEqual(
                [(node["name"]["text"], len(node.get("dimensions", []))) for node in ports[0][::2]],
                [("first_value", 0), ("pair", 1), ("matrix", 2), ("last_value", 0)],
            )
            initialized_port = self.task_ports(INITIALIZER, directory)[1][0]
            self.assertEqual(initialized_port["name"]["text"], "b")
            initializer = initialized_port["initializer"]
            self.assertEqual(initializer["kind"], "EqualsValueClause")
            self.assertEqual(initializer["expr"]["literal"]["text"], "3")

            control = self.run_slang(DECLARATORS, directory)
            self.assertEqual(control.returncode, 0, control.stdout + control.stderr)
            restricted = self.run_slang(INITIALIZER, directory)
            self.assertGreater(restricted.returncode, 0, restricted.stdout + restricted.stderr)
            self.assertRegex(restricted.stderr, r"\.sv:29:\d+: error: .*cannot contain an initializer")
