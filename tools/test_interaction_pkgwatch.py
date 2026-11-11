"""Package observer fanout, projected sensitivity and retained wake history."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_pkgwatch as g
import lint_metadata
import qualify_pkgwatch as q


def observations(text):
    result={};tag=None
    for line in text.splitlines():
        if line.startswith('snap '):tag=line.split('tag=',1)[1].split()[0]
        elif line.startswith('o '):result[tag,line.split('name=',1)[1][0]]=line
    return result


class PackageChangeObservers(unittest.TestCase):
    def test_all_cartesian_rows_are_legal(self):
        self.assertEqual(prod(len(v) for _,v in g.MODEL.factors),2592)
        self.assertEqual(len(g.MODEL.rows()),2592)

    def test_selection_preserves_all_pairs_triples_and_six_anchors(self):
        selected=g.MODEL.select()
        self.assertEqual(len(selected),36)
        self.assertEqual(len(g.MODEL.anchors),6)
        self.assertEqual(Counter(map(len,g.MODEL.universe())),{2:225,3:122})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)},g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors)<=set(selected))
        self.assertEqual(selected,g.MODEL.select())

    def test_every_emitted_legal_program_matches_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):self.assertEqual(q.independent(row),g.reference(row))

    def test_saved_program_never_calls_generator_expectation_or_stimulus_helpers(self):
        row=g.MODEL.anchors[1];source=g.source(row);want=g.reference(row)
        with patch.object(g,'reference',side_effect=AssertionError('oracle')), \
             patch.object(g,'actions',side_effect=AssertionError('stimuli')), \
             patch.object(g,'address',side_effect=AssertionError('address')), \
             patch.object(g,'indices',side_effect=AssertionError('indices')):
            self.assertEqual(q.interpret(source),want)

    def test_saved_metadata_and_comments_do_not_become_package_declarations(self):
        row=g.MODEL.anchors[0]
        path=Path(__file__).resolve().parent.parent/'tests/gen/ch26'/(g.case_name(row)+'.sv')
        source=path.read_text(encoding='utf-8')
        self.assertEqual(q.interpret(source),g.reference(row))
        mutant=source.replace('return payload_pkg::target;', 'return control_pkg::target;', 1)
        self.assertNotEqual(q.interpret(mutant),g.reference(row))

    def test_scalar_hand_checked_arming_and_first_wake(self):
        o=observations(g.reference(g.MODEL.anchors[0]))
        self.assertEqual(o['armed','a'],'o name=a data=1 copy=1 hits=0 last=0 at=-1 pred=0 wakes=0 wt=-1 held=0')
        self.assertEqual(o['5','a'],'o name=a data=0 copy=0 hits=1 last=0 at=25 pred=1 wakes=1 wt=25 held=0')

    def test_projected_event_retains_last_word_across_upper_only_change(self):
        o=observations(g.reference(g.MODEL.anchors[1]));zero='0'*129;high='1'+'0'*128
        self.assertIn('hits=0 last='+zero+' at=-1',o['1','a'])
        self.assertIn('hits=2 last='+high+' at=20',o['5','a'])
        self.assertIn('data='+zero+' copy='+zero,o['5','a'])
        self.assertIn('wakes=1 wt=25 held='+zero,o['5','a'])

    def test_unknown_condition_is_not_true_and_bit_conversion_changes_wake_time(self):
        logic=('33','logic','x','qualified','up','blocking','full','logical')
        bit=(*logic[:1],'bit',*logic[2:])
        a,b=observations(g.reference(logic)),observations(g.reference(bit))
        self.assertIn('pred=x wakes=0 wt=-1',a['3','a'])
        self.assertIn('pred=1 wakes=1 wt=15',b['3','a'])
        self.assertIn('wakes=1 wt=25',a['5','a'])

    def test_logical_and_case_equality_have_distinct_unknown_predicates(self):
        logical=('65','logic','z','wildcard','down','nba','lsb','logical')
        case=(*logical[:-1],'case')
        a,b=observations(g.reference(logical)),observations(g.reference(case))
        self.assertIn('pred=x wakes=0',a['3','a'])
        self.assertIn('pred=0 wakes=0',b['3','a'])
        self.assertIn('wakes=1 wt=25',a['5','a']);self.assertIn('wakes=1 wt=25',b['5','a'])

    def test_first_wake_is_retained_after_current_predicate_becomes_false(self):
        o=observations(g.reference(g.MODEL.anchors[3]))
        self.assertIn('pred=0 wakes=1 wt=15',o['4','a'])
        self.assertIn('pred=1 wakes=1 wt=15',o['idle','a'])

    def test_repeated_writes_and_neighbor_changes_do_not_create_target_events(self):
        for row in g.MODEL.select():
            o=observations(g.reference(row))
            self.assertEqual(o['1','a'],o['2','a'])
            for tag in ('6','7','8','idle'):self.assertEqual(o['5','a'],o[tag,'a'])

    def test_payload_fanout_and_later_independent_guard_progress(self):
        for row in g.MODEL.select():
            o=observations(g.reference(row))
            for tag in ('armed','1','3','5','8','idle'):
                self.assertEqual(o[tag,'a'].replace('name=a','name=b'),o[tag,'b'])
            self.assertIn('hits=0',o['7','g'])
            self.assertIn('hits=1',o['8','g']);self.assertIn('wakes=1 wt=40',o['8','g'])

    def test_callback_order_does_not_change_settled_outputs(self):
        for row in g.MODEL.anchors:
            source=g.source(row)
            self.assertEqual(q.interpret(source),q.interpret(source,reverse_observers=True))

    def test_blocking_and_nba_differ_at_immediate_target_observation(self):
        row=('33','logic','known','qualified','up','blocking','full','logical')
        nba=(*row[:5],'nba',*row[6:])
        high='0'*32+'1';one='1'*33
        self.assertIn('drive step=1 t=5 raw='+high+' active='+high,g.reference(row))
        self.assertIn('drive step=1 t=5 raw='+high+' active='+one,g.reference(nba))

    def test_actual_binding_projection_and_callback_mutations_change_interpretation(self):
        for row,old,new in [(g.MODEL.anchors[0],'payload_watch b();','control_watch b();'),
                            (g.MODEL.anchors[4],'@(target[-2]);','@(target[-2][0]);'),
                            (g.MODEL.anchors[4],'hits++;','hits += 0;'),
                            (g.MODEL.anchors[0],"wait (payload_pkg::target == 1'h0);","wait (payload_pkg::target != 1'h0);")]:
            with self.subTest(old=old):
                source=g.source(row);self.assertIn(old,source)
                self.assertNotEqual(q.interpret(source.replace(old,new,1)),g.reference(row))

    def test_equality_known_mismatch_dominates_unknown_and_unknown_is_not_true(self):
        self.assertEqual(q.equality(q.Word('1x'),q.Word('00'),'==').bits,'0')
        self.assertEqual(q.equality(q.Word('0x'),q.Word('00'),'==').bits,'x')
        self.assertEqual(q.equality(q.Word('0x'),q.Word('00'),'===').bits,'0')
        self.assertEqual(q.equality(q.Word('0x'),q.Word('00'),'!==').bits,'1')

    def test_unknown_statements_and_extra_producers_are_rejected(self):
        source=g.source(g.MODEL.anchors[0])
        with self.assertRaises(AssertionError):q.interpret(source.replace('hits++;','hits -= 1;',1))
        with self.assertRaises(AssertionError):q.interpret(source.replace('copy = sample_word();','copy = opaque();',1))
        with self.assertRaises(AssertionError):q.interpret(source+'\nmodule extra; initial begin end endmodule\n')

    def test_generated_metadata_and_line_lengths(self):
        with tempfile.TemporaryDirectory() as folder:
            chapter=Path(folder)/'ch26';chapter.mkdir()
            for row in g.MODEL.select():
                c=g.make_case(row);sv,want=common.render(c,g.NAME,1,26,'spec')
                p=chapter/(c.name+'.sv');p.write_text(sv, encoding="utf-8");p.with_suffix('.expected').write_text(want, encoding='utf-8')
                self.assertEqual(lint_metadata.check(p),[])
                self.assertEqual(c.fourstate,row[2]!='known')


if __name__=='__main__':unittest.main()
