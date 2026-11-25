"""Check the fixture reader's treatment of section boundaries and filename syntax."""

from pathlib import Path
import tempfile
import unittest

import run_waveform_sections as waveforms


PLAIN = """$timescale 10 ps $end
$scope module testbench $end
$var wire 1 ! signal $end
$upscope $end
$enddefinitions $end
# 0 $dumpvars 0! $end
#2 $dumpall 1! $end
"""
PORTS = """$date Wed Nov 25 09:15:00 2026 $end
$version Tool 1.2 {call} $end
$timescale 10ps $end
$scope module testbench $end
$scope module {scope} $end
$var port 1 < 0 signal $end
$upscope $end
$upscope $end
$enddefinitions $end
#0 $dumpports pD 6 0 < 0 $end
#2 pU 0 6 <0
$vcdclose #3 $end
"""


class WaveformSectionTests(unittest.TestCase):
    def test_inserted_comments_do_not_change_declarations_or_events(self):
        with tempfile.TemporaryDirectory() as directory:
            fixture = Path(directory) / "native.vcd"
            fixture.write_text(PLAIN, encoding="ascii")
            records = waveforms.read_sections(PLAIN)
            self.assertTrue(waveforms.inserted_comments(fixture, PLAIN, records))
            self.assertEqual(waveforms.named(records, "$dumpall")[0].time, 2)
            self.assertEqual(waveforms.timescale(records), 10_000)

    def test_keywords_in_the_wrong_phase_are_rejected(self):
        for source in (
            PLAIN.replace("$timescale 10 ps $end\n", "") + "$timescale 10 ps $end\n",
            "$dumpall $end\n" + PLAIN,
        ):
            with self.subTest(source=source), self.assertRaisesRegex(ValueError, "wrong phase"):
                waveforms.read_sections(source)

    def test_evaluated_path_is_not_evidence_of_the_original_filename_expression(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            for kind, filename in (("literal", '"literal.evcd"'), ("variable", "file_name"),
                                   ("expression", '{prefix,".evcd"}')):
                scope = kind + "_target"
                text = PORTS.format(call=f"$dumpports(testbench.{scope}, {filename})", scope=scope)
                (folder / (kind + ".evcd")).write_text(text, encoding="ascii")
            self.assertTrue(waveforms.header_checks(folder, "testbench")["pass"])
            expression = folder / "expression.evcd"
            expression.write_text(expression.read_text(encoding="ascii").replace('{prefix,".evcd"}',
                                                                                    '"expression.evcd"'),
                                  encoding="ascii")
            observed = waveforms.header_checks(folder, "testbench")
            self.assertFalse(observed["pass"])
            self.assertFalse(observed["forms"]["expression"]["scope_and_unevaluated_filename"])
