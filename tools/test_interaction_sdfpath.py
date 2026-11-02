"""Conditional SDF matching, addition, hierarchy and exact transition records."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_sdfpath as generator
import qualify_sdfpath as qualification


class SdfConditionalPaths(unittest.TestCase):
    def test_all_rows_match_independent_sdf_parser_and_event_heap(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row),qualification.independent(row))

    def test_conditional_annotation_preserves_the_other_branch(self):
        text = generator.reference(generator.MODEL.anchors[3])
        self.assertIn('phase=0 lane=v_y value=1 hits=1 last=26',text)
        self.assertIn('phase=1 lane=v_y value=0 hits=2 last=42',text)
        self.assertIn('phase=2 lane=v_y value=1 hits=3 last=68',text)
        self.assertIn('phase=3 lane=v_y value=0 hits=4 last=82',text)

    def test_ifnone_increment_applies_only_when_no_if_path_is_enabled(self):
        text = generator.reference(generator.MODEL.anchors[6])
        self.assertIn('phase=0 lane=g_y value=1 hits=1 last=22',text)
        self.assertIn('phase=2 lane=g_y value=1 hits=3 last=68',text)
        self.assertIn('phase=3 lane=g_y value=0 hits=4 last=90',text)
        self.assertIn('phase=2 lane=v_y value=1 hits=3 last=66',text)

    def test_increment_adds_both_edge_delays_and_leaves_z_unchanged(self):
        row = ('plain','increment','rise','parent','v','low','opposite')
        text = generator.reference(row)
        self.assertIn('phase=0 lane=v_y value=1 hits=1 last=30',text)
        self.assertIn('phase=1 lane=v_y value=0 hits=2 last=46',text)
        self.assertIn('phase=0 lane=v_z value=1 hits=1 last=24',text)
        self.assertIn('phase=1 lane=v_z value=0 hits=2 last=46',text)

    def test_cell_and_parent_scope_have_the_same_resolved_target(self):
        for row in generator.MODEL.anchors:
            other = (*row[:3], 'parent' if row[3]=='cell' else 'cell', *row[4:])
            self.assertEqual(qualification.independent(row),qualification.independent(other))

    def test_unsupported_semantic_faults_are_source_interpretations_only(self):
        results = qualification.source_faults()
        self.assertEqual(set(results),{'unconditional_matches_both','increment_replaces','ifnone_matches_on'})
        self.assertEqual({r['source_check'] for r in results.values()},{'output differs'})


if __name__ == '__main__':unittest.main()
