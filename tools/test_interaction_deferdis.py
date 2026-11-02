"""Queue cancellation, input evaluation and ordinary disable control flow."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_deferdis as generator
import qualify_deferdis as qualification


class DeferredDisableReports(unittest.TestCase):
    def test_all_rows_match_independent_source_ast_and_report_queues(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_label_cancel_preserves_sibling_and_input_evaluation_side_effect(self):
        text=generator.reference(generator.MODEL.anchors[6])
        self.assertIn('item=0 pass=0 fail=0 captured=0 live=0 eval=1 last=-1',text)
        self.assertIn('item=1 pass=1 fail=0 captured=11 live=111 eval=1 last=10',text)
        self.assertIn('item=0 pass=1 fail=0 captured=21 live=121 eval=3 last=20',text)

    def test_outer_disable_skips_later_sibling_and_preserves_already_matured_history(self):
        text=generator.reference(generator.MODEL.anchors[7])
        self.assertIn('phase=2 time=23 target_tail=1 worker_tail=1',text)
        self.assertIn('item=0 pass=1 fail=0 captured=11 live=11 eval=0 last=10',text.split('phase=2')[1])
        self.assertIn('item=0 pass=2 fail=0 captured=42 live=42 eval=0 last=30',text)

    def test_inner_and_task_disable_keep_reports_but_skip_local_tail(self):
        row=generator.MODEL.anchors[1];other=('task',*row[1:])
        expected=generator.reference(row)
        self.assertEqual(generator.reference(other),expected)
        self.assertEqual(qualification.independent(other),expected)
        self.assertIn('phase=2 time=23 target_tail=1 worker_tail=2',expected)
        self.assertIn('item=0 pass=1 fail=1 captured=32 live=32 eval=0 last=20',expected)

    def test_input_capture_and_live_reads_differ_for_both_sibling_orders(self):
        before=generator.MODEL.anchors[8];after=(*before[:4],'after',*before[5:])
        self.assertIn('item=0 pass=1 fail=0 captured=11 live=111 eval=1 last=10',generator.reference(before))
        self.assertIn('item=1 pass=0 fail=1 captured=11 live=111 eval=1 last=10',generator.reference(before))
        self.assertIn('item=1 pass=0 fail=1 captured=111 live=111 eval=1 last=10',generator.reference(after))

    def test_failed_cover_has_no_report_or_capture_function_side_effect(self):
        row=('none','cover','even','inverse','after','function','stable')
        text=generator.reference(row).split('phase=2')[0]
        self.assertIn('item=0 pass=0 fail=0 captured=0 live=0 eval=0 last=-1',text)
        self.assertIn('item=1 pass=1 fail=0 captured=11 live=11 eval=1 last=10',text)

    def test_source_interpreter_exposes_wrong_cancel_scope_and_captured_value(self):
        for row,old,new in (
            (generator.MODEL.anchors[6],'disable target_chk;','disable inner;'),
            (generator.MODEL.anchors[7],'disable worker;','disable inner;'),
            (generator.MODEL.anchors[8],'captured_sum[item] += value;','captured_sum[item] += wdata;')):
            source=generator.make_case(row).body
            self.assertNotEqual(qualification.interpret(source.replace(old,new)),generator.reference(row))


if __name__=='__main__':unittest.main()
