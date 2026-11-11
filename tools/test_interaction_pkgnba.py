"""Package identity, reservation-time capture and one-thread NBA ordering."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_pkgnba as g
import lint_metadata
import qualify_pkgnba as q


class PackageNbaCapture(unittest.TestCase):
    def test_every_cartesian_row_is_legal(self):
        self.assertEqual(prod(len(v) for _,v in g.MODEL.factors),1296)
        self.assertEqual(len(g.MODEL.rows()),1296)
        self.assertEqual(set(g.MODEL.anchors)-set(g.MODEL.rows()),set())

    def test_selection_preserves_all_pairs_triples_and_six_anchors(self):
        rows=g.MODEL.select()
        self.assertEqual(len(rows),36)
        self.assertEqual(len(g.MODEL.anchors),6)
        self.assertEqual(Counter(map(len,g.MODEL.universe())),{2:183,3:126})
        self.assertEqual({t for row in rows for t in g.MODEL.targets(row)},g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors)<=set(rows))
        self.assertEqual(rows,g.MODEL.select())

    def test_every_emitted_legal_program_matches_the_independent_queue(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):self.assertEqual(q.independent(row),g.reference(row))

    def test_saved_sv_interpreter_does_not_call_generator_helpers(self):
        row=g.MODEL.anchors[1];source=g.source(row);want=g.reference(row)
        with patch.object(g,'reference',side_effect=AssertionError('oracle')), \
             patch.object(g,'stimuli',side_effect=AssertionError('stimuli')), \
             patch.object(g,'indices',side_effect=AssertionError('indices')), \
             patch.object(g,'address',side_effect=AssertionError('address')):
            self.assertEqual(q.interpret(source),want)

    def test_scalar_known_order_has_hand_checked_old_and_new_values(self):
        text=g.reference(g.MODEL.anchors[0])
        self.assertIn('put phase=0 who=0 t=0 index=0 data=1',text)
        self.assertIn('put phase=0 who=1 t=0 index=0 data=0',text)
        self.assertIn('at=active t=0 value=1 guard=1 other=0 og=0 alias=1',text)
        self.assertIn('at=edge t=1 value=0 guard=1 other=0 og=0 alias=0',text)

    def test_due_time_active_observation_precedes_delayed_nba(self):
        row=('1','bit','known','qualified','scalar','delayed','a_b')
        text=g.reference(row)
        self.assertIn('at=edge t=1 value=1 guard=1',text)
        self.assertIn('at=after t=2 value=0 guard=1',text)
        self.assertEqual(q.independent(row),text)

    def test_unknowns_survive_logic_and_become_zero_only_in_bit_destination(self):
        logic=('1','logic','z','explicit','down','delayed','b_a')
        bit=(*logic[:1],'bit',*logic[2:])
        self.assertIn('data=z',g.reference(logic))
        self.assertIn('at=after t=2 value=z',g.reference(logic))
        self.assertIn('data=z',g.reference(bit))
        self.assertIn('at=after t=2 value=0',g.reference(bit))

    def test_task_input_mutations_do_not_change_captured_address_or_value(self):
        for row in g.MODEL.anchors:
            source=g.source(row)
            self.assertIn("data = '1;",source)
            self.assertIn('where = '+str(g.indices(row)[1])+';',source)
            self.assertEqual(q.interpret(source),g.reference(row))

    def test_distinct_reference_spellings_refer_to_one_package_object(self):
        rows=[('33','logic','known',access,'up','delayed','b_a')
              for access in ('qualified','wildcard','explicit')]
        self.assertEqual(len({g.reference(row) for row in rows}),1)
        self.assertEqual(len({q.independent(row) for row in rows}),1)
        self.assertIn('import payload_pkg::*;',g.source(rows[1]))
        self.assertIn('import payload_pkg::target;',g.source(rows[2]))

    def test_reversing_sequential_calls_changes_final_value(self):
        ab=g.MODEL.anchors[0];ba=(*ab[:-1],'b_a')
        self.assertIn('at=after t=2 value=0',g.reference(ab))
        self.assertIn('at=after t=2 value=1',g.reference(ba))
        self.assertNotEqual(q.independent(ab),q.independent(ba))

    def test_neighbor_and_other_package_are_retained_through_idle(self):
        for row in g.MODEL.select():
            for phase in (0,1):
                lines=[l for l in g.reference(row).splitlines() if l.startswith(f's phase={phase}')]
                self.assertEqual(len(lines),4)
                guard=[l.split(' guard=',1)[1].split(' alias=',1)[0] for l in lines]
                self.assertEqual(len(set(guard)),1)
                self.assertEqual(lines[2].split(' value=',1)[1],lines[3].split(' value=',1)[1])

    def test_interpreter_reads_real_package_types_operations_and_targets(self):
        examples=[(g.MODEL.anchors[0],'payload_pkg::target <= data;','payload_pkg::target = data;'),
                  (g.MODEL.anchors[1],'<= #1 data;','<= data;'),
                  (g.MODEL.anchors[1],'typedef logic','typedef bit'),
                  (g.MODEL.anchors[2],'import payload_pkg::*;','import control_pkg::*;'),
                  (g.MODEL.anchors[3],'target[where] <=','target[1] <=')]
        for row,old,new in examples:
            with self.subTest(old=old):
                source=g.source(row);self.assertIn(old,source)
                self.assertNotEqual(q.interpret(source.replace(old,new,1)),g.reference(row))

    def test_unknown_statements_and_extra_producers_are_rejected(self):
        source=g.source(g.MODEL.anchors[0])
        with self.assertRaises(AssertionError):q.interpret(source.replace("data = '1;",'data = opaque();',1))
        with self.assertRaises(AssertionError):q.interpret(source.replace('    #1;','    $opaque();',1))
        with self.assertRaises(AssertionError):q.interpret(source+'\nmodule extra; initial begin end endmodule\n')
        with self.assertRaises(AssertionError):q.interpret(source+'\nmodule extra; always begin end endmodule\n')

    def test_selected_cases_have_valid_metadata_line_lengths_and_state_flags(self):
        with tempfile.TemporaryDirectory() as directory:
            chapter=Path(directory)/'ch26';chapter.mkdir()
            for row in g.MODEL.select():
                case=g.make_case(row);sv,want=common.render(case,g.NAME,1,26,'spec')
                path=chapter/(case.name+'.sv');path.write_text(sv, encoding="utf-8");path.with_suffix('.expected').write_text(want, encoding='utf-8')
                self.assertEqual(lint_metadata.check(path),[])
                self.assertEqual(case.fourstate,row[2]!='known')


if __name__=='__main__':
    unittest.main()
