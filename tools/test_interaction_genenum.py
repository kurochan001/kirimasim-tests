"""Generated enum identity, ordinal navigation and width-sensitive observations."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_genenum as g
import lint_metadata
import qualify_genenum as q


class GeneratedEnumNavigation(unittest.TestCase):
    def test_only_unrepresentable_three_member_scalar_rows_are_excluded(self):
        self.assertEqual(prod(len(values) for _, values in g.MODEL.factors), 1152)
        self.assertEqual(len(g.MODEL.rows()), 1056)
        for row in g.MODEL.rows():
            for instance in (0, 1):
                for lane in (0, 1):
                    width, _, values = g.table(row, instance, lane)
                    self.assertEqual(len(set(values)), int(row[4]))
                    self.assertTrue(all(0 <= v < 1 << width for v in values))

    def test_selection_covers_pairs_triples_and_all_mandatory_boundaries(self):
        rows = g.MODEL.select()
        self.assertEqual(len(rows), 36)
        self.assertEqual(len(g.MODEL.anchors), 6)
        self.assertEqual(Counter(map(len, g.MODEL.universe())), {2: 181, 3: 110})
        self.assertEqual({t for row in rows for t in g.MODEL.targets(row)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(rows))
        self.assertEqual(rows, g.MODEL.select())

    def test_all_legal_emitted_programs_match_the_independent_interpreter(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row), g.reference(row))

    def test_interpreter_uses_saved_sv_not_generator_value_or_count_helpers(self):
        row = g.MODEL.anchors[1]; source = g.source(row); want = g.reference(row)
        with patch.object(g, 'reference', side_effect=AssertionError('expected helper')), \
             patch.object(g, 'table', side_effect=AssertionError('table helper')), \
             patch.object(g, 'step_value', side_effect=AssertionError('count helper')):
            self.assertEqual(q.interpret(source), want)

    def test_signed_scalar_has_hand_checked_bits_decimal_names_and_held_copy(self):
        text = g.reference(g.MODEL.anchors[0])
        self.assertIn('k=0 value=1 dec=-1 name=E0 next=0 prev=0', text)
        self.assertIn('p phase=2 id=0 lane=0 value=1 name=E0 held=0 held_name=E1', text)

    def test_wide_high_bit_retains_all_bits_and_signed_decimal(self):
        text = g.reference(g.MODEL.anchors[1])
        self.assertIn('k=1 value='+'1'+'0'*128+' dec='+str(-(1 << 128))+' name=E1', text)
        self.assertIn('lane=1 kind=1 bits=131 num=3', text)

    def test_descending_codes_navigate_in_declaration_order_not_numeric_order(self):
        row = ('32', 'unsigned', 'if', 'descending', '3', 'next', 'one')
        text = g.reference(row)
        self.assertIn('k=0 value='+'1'*32+' dec=4294967295 name=E0', text)
        self.assertIn('k=1 value='+'1'*31+'0 dec=4294967294 name=E1', text)

    def test_zero_and_cycle_are_distinct_sv_even_with_equal_observations(self):
        zero = ('33', 'signed', 'case', 'high', '3', 'next', 'zero')
        cycle = (*zero[:-1], 'cycle')
        self.assertEqual(g.reference(zero), g.reference(cycle))
        self.assertIn('STEP = 0;', g.source(zero))
        self.assertIn('STEP = 3;', g.source(cycle))
        self.assertNotEqual(g.source(zero), g.source(cycle))

    def test_all_scopes_are_reobserved_after_other_walks_and_at_idle(self):
        for row in g.MODEL.select():
            text = g.reference(row)
            for instance in (0, 1):
                for lane in (0, 1):
                    lines = [l for l in text.splitlines() if l.startswith('p phase=')
                             and f'id={instance} lane={lane} ' in l]
                    self.assertEqual(len(lines), 3)
                    self.assertEqual(lines[1].split(' value=', 1)[1], lines[2].split(' value=', 1)[1])

    def test_genvar_and_opposite_branches_change_width_and_table_in_both_forms(self):
        a = ('32', 'signed', 'if', 'high', '3', 'next', 'one')
        b = (*a[:2], 'case', *a[3:])
        self.assertEqual(g.reference(a), g.reference(b))
        self.assertIn('if ((SELECT + g) % 2 == 0)', g.source(a))
        self.assertIn('case ((SELECT + g) % 2)', g.source(b))
        self.assertEqual([g.table(a, i, lane)[0] for i in (0, 1) for lane in (0, 1)], [32, 34, 33, 33])
        self.assertNotEqual(g.table(a, 1, 0)[2], g.table(a, 1, 1)[2])

    def test_interpreter_responds_to_actual_declarations_counts_and_displays(self):
        row = g.MODEL.anchors[5]; source = g.source(row); want = g.reference(row)
        for old, new in [('WIDTH = BASE + g + KIND;', 'WIDTH = BASE + 0 + KIND;'),
                         ('STEP = 5;', 'STEP = 0;'), ('typedef logic signed', 'typedef logic unsigned'),
                         ('phase, ID, g, k, value, value,', 'phase, ID, g, k, value[31:0], value,'),
                         ('E0 =', 'E9 =')]:
            with self.subTest(old=old):
                self.assertIn(old, source)
                self.assertNotEqual(q.interpret(source.replace(old, new, 1)), want)

    def test_unknown_expressions_and_task_statements_are_rejected(self):
        source = g.source(g.MODEL.anchors[0])
        with self.assertRaises(AssertionError): q.interpret(source.replace('BASE + g + KIND', 'opaque()', 1))
        with self.assertRaises(AssertionError): q.interpret(source.replace('held = value;', 'held = opaque();', 1))

    def test_selected_cases_have_valid_metadata_and_source_line_lengths(self):
        with tempfile.TemporaryDirectory() as directory:
            chapter = Path(directory)/'ch6'; chapter.mkdir()
            for row in g.MODEL.select():
                case = g.make_case(row); sv, want = common.render(case, g.NAME, 1, 6, 'spec')
                path = chapter/(case.name+'.sv'); path.write_text(sv, encoding="utf-8")
                path.with_suffix('.expected').write_text(want, encoding='utf-8')
                self.assertEqual(lint_metadata.check(path), [])


if __name__ == '__main__':
    unittest.main()
