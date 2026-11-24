"""Check which library resolves a bind target and the bound module."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SOURCES = {
    "lib.map": """
        library injectLib libraries/inject/*.sv;
        library targetLib libraries/target/*.sv;
    """,
    "main.sv": """
        module mapped_top;
          binder injected();
          target dut();
          target scope_target();

          initial $display("target native=%0d bound=%0d scope native=%0d bound=%0d",
                           dut.native_marker.ID, dut.attached.ID,
                           scope_target.native_marker.ID, scope_target.attached_scope.ID);
        endmodule

        config root_cfg;
          design work.mapped_top;
          instance mapped_top.injected use injectLib.inject_cfg:config;
          instance mapped_top.dut use targetLib.target_cfg:config;
          instance mapped_top.scope_target use injectLib.target;
        endconfig
    """,
    "libraries/inject/binder.sv": """
        module binder;
          bind mapped_top.dut marker attached();
          bind target marker attached_scope();
        endmodule

        module target;
          marker native_marker();
        endmodule

        module marker;
          localparam ID = 17;
        endmodule

        config inject_cfg;
          design injectLib.binder;
          default liblist injectLib;
        endconfig
    """,
    "libraries/target/device.sv": """
        module target;
          marker native_marker();
        endmodule

        module marker;
          localparam ID = 29;
        endmodule

        config target_cfg;
          design targetLib.target;
          default liblist targetLib;
        endconfig
    """,
}


def instance_sources(node: dict, path: str = ""):
    name = node["name"]
    full_name = f"{path}.{name}" if path else name
    body = node["body"]
    yield full_name, body["source_file"]
    for item in body.get("members", []):
        if item["kind"] == "Instance":
            yield from instance_sources(item, full_name)


class BindLibraryMapping(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        for name, source in SOURCES.items():
            path = self.directory / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(source, encoding="utf-8")

    @unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
    def test_execution_uses_binding_site_library(self):
        simulator = str(Path(os.environ["GHOST_SIMULATOR"]).resolve())
        result = subprocess.run(
            [
                simulator, "--quiet", "--lrm-strict", "--top", "root_cfg",
                "-v", "injectLib=libraries/inject/binder.sv",
                "-v", "targetLib=libraries/target/device.sv", "main.sv",
            ],
            cwd=self.directory, capture_output=True, text=True, timeout=90,
        )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        self.assertIn("target native=29 bound=17 scope native=17 bound=17",
                      result.stdout.splitlines())

    @unittest.skipUnless(os.environ.get("SLANG_EXECUTABLE"), "set SLANG_EXECUTABLE to run Slang")
    def test_scope_bind_selects_only_definition_from_binding_site_library(self):
        slang = str(Path(os.environ["SLANG_EXECUTABLE"]).resolve())
        result = subprocess.run(
            [
                slang, "--std=1800-2023", "--libmap", "lib.map", "--top", "root_cfg:config",
                "--ast-json", "design.json", "--ast-json-source-info", "main.sv",
            ],
            cwd=self.directory, capture_output=True, text=True, timeout=90,
        )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        ast = json.loads((self.directory / "design.json").read_text(encoding="utf-8"))
        roots = [item for item in ast["design"]["members"] if item["kind"] == "Instance"]
        self.assertEqual([item["name"] for item in roots], ["mapped_top"])
        actual = {
            name: (self.directory / file).resolve().relative_to(self.directory.resolve()).as_posix()
            for name, file in instance_sources(roots[0])
        }
        inject, target = "libraries/inject/binder.sv", "libraries/target/device.sv"
        self.assertEqual(actual, {
            "mapped_top": "main.sv",
            "mapped_top.injected": inject,
            "mapped_top.dut": target,
            "mapped_top.dut.native_marker": target,
            "mapped_top.dut.attached": inject,
            "mapped_top.scope_target": inject,
            "mapped_top.scope_target.native_marker": inject,
            "mapped_top.scope_target.attached_scope": inject,
        })
