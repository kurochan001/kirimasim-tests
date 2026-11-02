"""Clock attempts, vacuity, pending consequences and program isolation."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_progassert as generator
import qualify_progassert as qualification


class ProgramAssertionAttempts(unittest.TestCase):
    def test_all_legal_rows_match_independent_emitted_source_interpretation(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_same_slot_nba_uses_preponed_sample(self):
        row = generator.MODEL.anchors[0]
        text = generator.reference(row)
        self.assertIn('site0 program pass=1 fail=0 reqsum=0 acksum=1',text)
        source = generator.make_case(row).body
        self.assertNotEqual(qualification.interpret(source.replace("64'($sampled(req))","64'(req)",2)),text)

    def test_next_has_no_result_before_first_nonvacuous_consequence(self):
        row = generator.MODEL.anchors[2]
        text = generator.reference(row)
        self.assertIn('site1 program pass=0 fail=0 reqsum=0 acksum=0',text.split('phase=1')[0])
        self.assertIn('site0 program pass=4 fail=0 reqsum=128 acksum=893',text.split('phase=4')[1])

    def test_vacuous_and_pending_results_share_tick_without_order_dependency(self):
        text = generator.reference(generator.MODEL.anchors[2])
        self.assertIn('site1 program pass=2 fail=0 reqsum=0 acksum=510',text.split('phase=1')[1])
        self.assertIn('site0 program pass=4 fail=0 reqsum=128 acksum=893',text.split('phase=3')[1])

    def test_wide_sample_accumulates_above_32_bits_and_at_completion_tick(self):
        text = generator.reference(generator.MODEL.anchors[3])
        self.assertIn('site0 program pass=2 fail=0 reqsum=4294967296 acksum=12884901887',text)
        self.assertIn('site1 program pass=2 fail=0 reqsum=0 acksum=17179869182',text)

    def test_program_has_no_initial_and_is_observed_only_through_output_ports(self):
        for row in generator.MODEL.anchors:
            source = generator.make_case(row).body
            program = source.split('program assertion_program',1)[1].split('endprogram',1)[0]
            self.assertNotIn('initial',program)
            self.assertNotIn('checked.',source)
            self.assertNotIn('always',program)

    def test_pending_attempts_are_per_instance_and_use_correct_operator(self):
        row = generator.MODEL.anchors[3]
        source = generator.make_case(row).body;expected = generator.reference(row)
        for changed in (source.replace('|=>','|->',1),
                        source.replace('r1(p1.clk, p1.req, p1.ack,','r1(p0.clk, p0.req, p0.ack,')):
            self.assertNotEqual(qualification.interpret(changed),expected)


if __name__=='__main__':unittest.main()
