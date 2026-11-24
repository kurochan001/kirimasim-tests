"""Qualify library-map parsing and binding using Slang's elaborated AST."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


@unittest.skipUnless(os.environ.get("SLANG_EXECUTABLE"), "set SLANG_EXECUTABLE to run Slang")
class SlangLibraryMaps(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.slang = str(Path(os.environ["SLANG_EXECUTABLE"]).resolve())

    def write_files(self, files: dict[str, str]) -> None:
        for name, contents in files.items():
            path = self.directory / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(contents, encoding="utf-8")

    def elaborate(self, source: str, top: str, *options: str,
                  maps: tuple[str, ...] = ("lib.map",)) -> subprocess.CompletedProcess:
        map_options = []
        for name in maps:
            map_options.extend(("--libmap", name))
        return subprocess.run(
            [
                self.slang, "--std=1800-2023", *map_options,
                "--top", top, "--ast-json", "design.json", "--ast-json-source-info",
                *options, source,
            ],
            cwd=self.directory, capture_output=True, text=True, timeout=90,
        )

    def check_bindings(self, result: subprocess.CompletedProcess, top: str,
                       expected: dict[str, str]) -> dict:
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        ast = json.loads((self.directory / "design.json").read_text(encoding="utf-8"))
        root = next((item for item in ast["design"]["members"]
                     if item["kind"] == "Instance" and item["name"] == top), None)
        self.assertIsNotNone(root, f"missing top-level instance {top}")
        paths = {
            item["name"]: (self.directory / item["body"]["source_file"]).resolve()
            for item in root["body"]["members"] if item["kind"] == "Instance"
        }
        self.assertEqual(paths, {k: (self.directory / v).resolve() for k, v in expected.items()})
        return root

    def test_relative_paths_in_included_map(self):
        self.write_files({
            "lib.map": "include maps/nested.map;\nlibrary topLib ./root_top.sv;\n",
            "maps/nested.map": ";\nlibrary nestedLib units/.../depth?.sv, ../parent_cell.sv;\n",
            "maps/units/level1/level2/depth1.sv": "module depth_cell; endmodule\n",
            "parent_cell.sv": "module parent_cell; endmodule\n",
            "root_top.sv": """
                module map_test_top;
                  depth_cell left();
                  parent_cell right();
                endmodule
                config map_configuration;
                  design topLib.map_test_top;
                  default liblist nestedLib;
                endconfig
            """,
        })
        result = self.elaborate("root_top.sv", "topLib.map_configuration:config")
        self.check_bindings(result, "map_test_top", {
            "left": "maps/units/level1/level2/depth1.sv",
            "right": "parent_cell.sv",
        })

    def test_wildcards_match_empty_segments_and_require_one_character(self):
        self.write_files({
            "lib.map": "library selectedLib tree/.../cell?name*.sv;\n",
            "tree/cellAname.sv": "module shallow_cell; endmodule\n",
            "tree/child/deeper/cellBname_extra.sv": "module deep_cell; endmodule\n",
            # These malformed files must stay outside the library's path specification.
            "tree/cellname.sv": "unexpected file matched a missing character\n",
            "tree/child/cellABname.sv": "unexpected file matched two characters\n",
            "top.sv": """
                module wildcard_top;
                  shallow_cell shallow();
                  deep_cell deep();
                endmodule
                config wildcard_config;
                  design work.wildcard_top;
                  default liblist selectedLib;
                endconfig
            """,
        })
        result = self.elaborate("top.sv", "wildcard_config:config")
        self.check_bindings(result, "wildcard_top", {
            "shallow": "tree/cellAname.sv",
            "deep": "tree/child/deeper/cellBname_extra.sv",
        })

    def test_library_map_rejects_module_declaration(self):
        self.write_files({
            "lib.map": "library mappedLib mapped.sv;\n;\n",
            "mapped.sv": "module mapped_top; endmodule\n",
        })
        control = self.elaborate("mapped.sv", "mappedLib.mapped_top")
        self.assertEqual(control.returncode, 0, control.stdout + control.stderr)
        with (self.directory / "lib.map").open("a", encoding="utf-8") as library_map:
            library_map.write("module not_a_map_item; endmodule\n")
        result = self.elaborate("mapped.sv", "mappedLib.mapped_top")
        self.assertGreater(result.returncode, 0, result.stdout + result.stderr)
        self.assertRegex(result.stderr, r"lib\.map:3:\d+:\s+error:")

    def test_explicit_name_and_wildcard_take_priority_over_directory(self):
        self.write_files({
            "lib.map": """
                library broad inputs/;
                library maskLib inputs/*.sv;
                library explicitFile inputs/pick.sv;
            """,
            "inputs/pick.sv": "module chosen; endmodule\n",
            "inputs/wild.sv": "module wildsome; endmodule\n",
            "inputs/base.v": "module base_only; endmodule\n",
            "top.sv": """
                module priority_top;
                  chosen fixed_name();
                  wildsome masked();
                  base_only directory_only();
                endmodule
                config priority_config;
                  design work.priority_top;
                  default liblist broad;
                  instance priority_top.fixed_name use explicitFile.chosen;
                  instance priority_top.masked use maskLib.wildsome;
                endconfig
            """,
        })
        result = self.elaborate("top.sv", "priority_config:config")
        self.check_bindings(result, "priority_top", {
            "fixed_name": "inputs/pick.sv",
            "masked": "inputs/wild.sv",
            "directory_only": "inputs/base.v",
        })

    def test_map_configuration_and_per_library_include_directories(self):
        paths = (
            "library alphaLib src/first.sv, src/extra.sv -incdir alpha_inc, alpha_extra;\n"
            "library betaLib src/second.sv -incdir beta_inc;\n"
            ";\n"
        )
        self.write_files({
            "lib.map": """
                include maps/paths.map;
                ;
                config incdir_configuration;
                  design work.incdir_probe;
                  default liblist alphaLib betaLib;
                endconfig
            """,
            "maps/paths.map": paths,
            "maps/src/first.sv": """
                `include "shared.svh"
                module alpha_cell;
                  localparam int VALUE = `CELL_VALUE;
                endmodule
                `undef CELL_VALUE
            """,
            "maps/src/second.sv": """
                `include "shared.svh"
                module beta_cell;
                  localparam int VALUE = `CELL_VALUE;
                endmodule
                `undef CELL_VALUE
            """,
            "maps/src/extra.sv": """
                `include "extra.svh"
                module extra_cell;
                  localparam int VALUE = `EXTRA_VALUE;
                endmodule
                `undef EXTRA_VALUE
            """,
            "maps/alpha_inc/shared.svh": "`define CELL_VALUE 41\n",
            "maps/beta_inc/shared.svh": "`define CELL_VALUE 73\n",
            "maps/alpha_extra/extra.svh": "`define EXTRA_VALUE 85\n",
            "top.sv": """
                module incdir_probe;
                  alpha_cell alpha();
                  beta_cell beta();
                  extra_cell supplemental();
                endmodule
            """,
        })
        configuration = "incdir_configuration:config"
        complete = self.elaborate("top.sv", configuration)
        root = self.check_bindings(complete, "incdir_probe", {
            "alpha": "maps/src/first.sv",
            "beta": "maps/src/second.sv",
            "supplemental": "maps/src/extra.sv",
        })
        values = {}
        for member in root["body"]["members"]:
            if member["kind"] == "Instance":
                for parameter in member["body"]["members"]:
                    if parameter["kind"] == "Parameter" and parameter["name"] == "VALUE":
                        values[member["name"]] = int(parameter["value"])
        self.assertEqual(values, {"alpha": 41, "beta": 73, "supplemental": 85})

        map_path = self.directory / "maps/paths.map"
        map_path.write_text(paths.replace(", alpha_extra", ""), encoding="utf-8")
        missing = self.elaborate("top.sv", configuration)
        self.assertGreater(missing.returncode, 0, missing.stdout + missing.stderr)
        self.assertRegex(
            missing.stderr,
            r"(?im)^.*maps/src/extra\.sv:\d+:[^\n]*error[^\n]*extra\.svh[^\n]*no such file",
        )

    def test_equal_priority_in_distinct_libraries_is_an_error(self):
        self.write_files({
            "lib.map": "library firstLib same.sv;\n",
            "same.sv": "module one_cell; endmodule\n",
        })
        control = self.elaborate("same.sv", "firstLib.one_cell")
        self.assertEqual(control.returncode, 0, control.stdout + control.stderr)
        with (self.directory / "lib.map").open("a", encoding="utf-8") as library_map:
            library_map.write("library secondLib same.sv;\n")
        collision = self.elaborate("same.sv", "firstLib.one_cell")
        self.assertGreater(collision.returncode, 0, collision.stdout + collision.stderr)
        self.assertRegex(collision.stderr, r"same\.sv[^\n]*file matches multiple libraries")
        self.assertIn("firstLib", collision.stderr)
        self.assertIn("secondLib", collision.stderr)

    def test_library_order_and_command_line_override(self):
        self.write_files({
            "lib.map": "library firstLib first/*.sv;\nlibrary secondLib second/*.sv;\n",
            "first/adder.sv": "module same_cell; endmodule\n",
            "second/adder.sv": "module same_cell; endmodule\n",
            "top.sv": "module order_top; same_cell selected(); endmodule\n",
        })
        default = self.elaborate("top.sv", "order_top")
        self.check_bindings(default, "order_top", {"selected": "first/adder.sv"})
        override = self.elaborate("top.sv", "order_top", "-L", "secondLib", "-L", "firstLib")
        self.check_bindings(override, "order_top", {"selected": "second/adder.sv"})

    def test_map_file_order_and_selected_configuration(self):
        self.write_files({
            "first.map": "library firstLib first/selected.sv;\n",
            "second.map": "library secondLib second/selected.sv;\n",
            "first/selected.sv": "module same_choice; endmodule\n",
            "second/selected.sv": "module same_choice; endmodule\n",
            "top.sv": """
                module map_order_top;
                  same_choice selected();
                endmodule
                config map_order_config;
                  design work.map_order_top;
                  default liblist firstLib;
                endconfig
            """,
        })
        for first, second in (("first", "second"), ("second", "first")):
            with self.subTest(first_map=first):
                result = self.elaborate("top.sv", "map_order_top", maps=(f"{first}.map", f"{second}.map"))
                self.check_bindings(result, "map_order_top", {"selected": f"{first}/selected.sv"})
        configured = self.elaborate(
            "top.sv", "map_order_config:config", "-L", "secondLib",
            maps=("second.map", "first.map"),
        )
        self.check_bindings(configured, "map_order_top", {"selected": "first/selected.sv"})
