"""Container copies, sample boundaries, empty guards and bin hit thresholds."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_cgsample as generator
import qualify_cgsample as qualification


class ContainerCoverageSampling(unittest.TestCase):
    def test_all_legal_rows_match_independent_emitted_operation_and_bin_interpretation(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_legality_excludes_only_fixed_array_clear(self):
        rows=generator.MODEL.rows()
        self.assertEqual(len(rows),1056)
        self.assertFalse(any(r[0]=='fixed' and r[1]=='clear' for r in rows))
        self.assertEqual(sum(r[1]=='clear' for r in rows),192)

    def test_unsampled_mutation_changes_raw_state_without_adding_a_bin(self):
        text=generator.reference(generator.MODEL.anchors[0])
        self.assertIn('phase=0 stage=after repeat=-1 a_size=3 a_value=3 b_size=3 b_value=0\n'
                      'g size=25.00 value=20.00 h size=25.00 value=20.00',text)
        self.assertIn('phase=1 stage=before repeat=0 a_size=3 a_value=3 b_size=3 b_value=0\n'
                      'g size=25.00 value=40.00 h size=25.00 value=20.00',text)

    def test_second_hit_threshold_observes_each_repeated_sample(self):
        row=generator.MODEL.anchors[3];text=generator.reference(row)
        self.assertIn('phase=0 stage=before repeat=0 a_size=3 a_value=2 b_size=3 b_value=2\n'
                      'g size=0.00 value=0.00 h size=0.00 value=0.00',text)
        self.assertIn('phase=0 stage=before repeat=1 a_size=3 a_value=2 b_size=3 b_value=2\n'
                      'g size=25.00 value=20.00 h size=25.00 value=20.00',text)

    def test_empty_guard_and_explicit_empty_bin_have_distinct_histories(self):
        base=generator.MODEL.anchors[2]
        guarded=generator.reference(base)
        unguarded=generator.reference((*base[:6],'all',base[7]))
        self.assertIn('a_size=0 a_value=-1 b_size=3 b_value=0\n'
                      'g size=25.00 value=20.00 h size=25.00 value=20.00',guarded)
        self.assertIn('a_size=0 a_value=-1 b_size=3 b_value=0\n'
                      'g size=50.00 value=40.00 h size=25.00 value=20.00',unguarded)

    def test_dynamic_replacement_resizes_target_without_changing_copied_control(self):
        text=generator.reference(generator.MODEL.anchors[1])
        self.assertIn('phase=0 stage=after repeat=0 a_size=3 a_value=1 b_size=1 b_value=0',text)
        self.assertIn('phase=1 stage=after repeat=0 a_size=1 a_value=1 b_size=1 b_value=0',text)

    def test_interpreter_exposes_wrong_binding_boundary_and_threshold(self):
        for row,old,new in (
            (generator.MODEL.anchors[1],'gv.sample(current_value(0),','gv.sample(current_value(1),'),
            (generator.MODEL.anchors[3],'option.at_least = 2;','option.at_least = 1;'),
            (generator.MODEL.anchors[0],'sample_now(0, "before");\n    a[0] = 3;',
             'a[0] = 3;\n    sample_now(0, "before");')):
            source=generator.make_case(row).body
            self.assertNotEqual(qualification.interpret(source.replace(old,new)),generator.reference(row))


if __name__=='__main__':unittest.main()
