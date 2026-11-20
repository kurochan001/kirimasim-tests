import tempfile
import threading
import types
import unittest
from pathlib import Path

import metamorphic as mm


def write(directory, name, body, header=""):
    path = Path(directory) / f"{name}.sv"
    path.write_text(f"/*\n:name: {name}\n:type: simulation\n{header}:expected_stdout: v=3\n*/\n{body}",
                    encoding="utf-8")
    return path


class Segments(unittest.TestCase):
    def test_strings_comments_and_directives_are_kept_apart(self):
        text = '`define A 1\nint x; // c;\nstring s = "a;b";\n/* d; */ x = 1;\n'
        kinds = [k for k, _ in mm.segments(text)]
        self.assertEqual(kinds[0], "directive")
        self.assertIn("comment", kinds)
        self.assertIn("string", kinds)
        self.assertEqual("".join(p for _, p in mm.segments(text)), text)

    def test_a_macro_definition_with_continuation_is_one_directive(self):
        text = "`define M(a) \\\n  a + 1\nint y;\n"
        self.assertEqual(mm.segments(text)[0], ("directive", "`define M(a) \\\n  a + 1"))


class Transforms(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)

    def test_m1_renames_declared_names_only_in_code(self):
        test = write(self.tmp.name, "test_r", 'module test_r;\n  int count = 3;\n'
                     '  initial $display("v=%0d", count);\nendmodule\n')
        why, text = mm.plan(test, "M1")
        self.assertIsNone(why)
        self.assertIn("int mm_count = 3;", text)
        self.assertIn('$display("v=%0d", mm_count);', text)
        self.assertIn(":name: test_r", text)
        test = write(self.tmp.name, "test_s", 'module test_s;\n  int count = 3;\n'
                     '  initial $display("count v=%0d", count);\nendmodule\n')
        self.assertEqual(mm.plan(test, "M1")[0], "a renamed name appears in a string")
        test = write(self.tmp.name, "test_v", 'module test_v;\n  int count = 3;\n'
                     '  initial $dumpvars;\nendmodule\n')
        self.assertEqual(mm.plan(test, "M1")[0], "the design names its signals in a file")

    def test_m1_leaves_names_used_after_a_dot_and_names_in_the_output(self):
        test = write(self.tmp.name, "test_d", "module test_d;\n  int v;\n  initial $display(v);\nendmodule\n")
        self.assertEqual(mm.plan(test, "M1")[0], "a renamed name appears in the expected output")
        test = write(self.tmp.name, "test_p", "module test_p;\n  int size;\n  int q[$];\n"
                     "  initial size = q.size();\nendmodule\n")
        why, text = mm.plan(test, "M1")
        self.assertIn("int size;", text)
        self.assertIn("int mm_q[$];", text)

    def test_m2_adds_comments_after_semicolons_outside_strings_and_directives(self):
        test = write(self.tmp.name, "test_w", '`timescale 1ns/1ns\nmodule test_w;\n'
                     '  initial $display("a;b");\nendmodule\n')
        why, text = mm.plan(test, "M2")
        self.assertIsNone(why)
        self.assertIn('$display("a;b"); /* m2 */\n', text)
        self.assertIn("`timescale 1ns/1ns\n", text)
        test = write(self.tmp.name, "test_e", "module test_e;\n  initial $error(\"x\");\nendmodule\n")
        self.assertEqual(mm.plan(test, "M2")[0], "can print a line or file position")

    def test_m3_scales_unit_and_precision_and_excludes_time_printing(self):
        test = write(self.tmp.name, "test_t", "`timescale 100ns/1ps\nmodule test_t;\n"
                     "  initial #5 $display(\"v=%0d\", $time);\nendmodule\n")
        why, text = mm.plan(test, "M3")
        self.assertIsNone(why)
        self.assertIn("`timescale 1us/10ps", text)
        for body, reason in (("module m; initial #5ns $display(1); endmodule\n", "a time literal with a unit"),
                             ('module m; initial $display("%t", $time); endmodule\n', "prints or reads time units"),
                             ("module m; endmodule\n", "no `timescale directive")):
            if "`timescale" not in body and reason != "no `timescale directive":
                body = "`timescale 1ns/1ns\n" + body
            with self.subTest(reason=reason):
                self.assertEqual(mm.plan(write(self.tmp.name, "test_x", body), "M3")[0], reason)
        self.assertEqual(mm.plan(write(self.tmp.name, "test_big", "`timescale 100s/1s\nmodule m; endmodule\n"),
                                 "M3")[0], "the unit cannot grow")

    def test_scaling_moves_to_the_next_unit(self):
        self.assertEqual(mm.scaled("1", "ns"), ("10", "ns"))
        self.assertEqual(mm.scaled("100", "ns"), ("1", "us"))
        self.assertIsNone(mm.scaled("100", "s"))

    def test_c_code_and_several_files_are_excluded_from_every_transform(self):
        for header, reason in ((":vpi_c: @x.c\n", "C code"), (":files: y.sv\n", "several files")):
            test = write(self.tmp.name, "test_c", "`timescale 1ns/1ns\nmodule m; int a; endmodule\n", header)
            for transform in mm.TRANSFORMS:
                with self.subTest(header=header, transform=transform):
                    self.assertEqual(mm.plan(test, transform)[0], reason)


class Capture(unittest.TestCase):
    def test_the_normalized_output_is_taken_from_the_runner(self):
        calls = []

        def first_difference(got, want):
            calls.append((got, want))
            return "x"

        def judge(test, bindir, tmp, prefix):
            got = runner.expected_output(test)
            return False, runner.suite_results.first_difference("v=3\n", got)

        runner = types.SimpleNamespace(suite_results=types.SimpleNamespace(first_difference=first_difference),
                                       expected_output=lambda test: "v=3\n", judge=judge,
                                       neutral=lambda text, tmp, prefix: text)
        options = types.SimpleNamespace(bindir=None, kirimasim=None)
        with mm.capturing(runner):
            result = mm.outcome(runner, "icarus", Path("t.sv"), options)
        self.assertEqual(result, "output:v=3\n")
        self.assertEqual(calls[0][1], mm.SENTINEL)
        self.assertTrue(mm.comparable(result, "fail:compile failed"))
        self.assertFalse(mm.comparable("fail:a", "fail:b"))


if __name__ == "__main__":
    unittest.main()
