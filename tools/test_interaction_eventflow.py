"""Event delivery, persistent same-slot readiness and bounded loop transfers."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_eventflow as g
import qualify_eventflow as q


def snapshots(output):
    result={};current=None
    for line in output.splitlines():
        fields=dict(part.split('=',1) for part in line.split()[1:])
        if line.startswith('h '):current=result[fields.pop('step')]={'h':fields};continue
        key=line[0]+fields.pop('id','')
        if 'slot' in fields:key+='_'+fields.pop('slot')
        current[key]=fields
    return result


def observed(row):return snapshots(q.independent(row))


class NamedEventLoopTransfer(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case=g.make_case(row);self.assertEqual(int(case.lrm.split()[0].split('.')[0]),g.CHAPTER)
            common.render(case,g.NAME,g.VERSION,g.CHAPTER,'spec')

    def test_canonical_legal_pair_triple_and_anchor_selection(self):
        selected=g.MODEL.select();self.assertEqual(len(g.MODEL.rows()),2016);self.assertEqual(len(selected),36)
        self.assertFalse(any(row[6]=='all' and row[7]!='middle' for row in g.MODEL.rows()))
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)},g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors)<=set(selected));self.assertEqual(selected,g.MODEL.select())
        # 225 Cartesian pairs minus two unused all/pivot pairs; triple groups total 140.
        self.assertEqual(Counter(map(len,g.MODEL.universe())),{2:223,3:140})

    def test_every_legal_actual_sv_matches_independent_scheduler(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):self.assertEqual(q.independent(row),g.reference(row))

    def test_independent_scheduler_uses_no_primary_semantic_helpers(self):
        row=g.MODEL.anchors[1];source,expected=g.source(row),g.reference(row)
        with patch.object(g,'source',side_effect=AssertionError('source')), \
             patch.object(g,'reference',side_effect=AssertionError('reference')), \
             patch.object(g,'payload',side_effect=AssertionError('payload')), \
             patch.object(g,'waiter',side_effect=AssertionError('waiter')), \
             patch.object(g,'assigned',side_effect=AssertionError('conversion')):
            self.assertEqual(q.interpret(source),expected)

    def test_comments_and_metadata_do_not_choose_semantics(self):
        case=g.make_case(g.MODEL.anchors[0]);source,_=common.render(case,g.NAME,g.VERSION,g.CHAPTER,'spec')
        self.assertEqual(q.interpret(source+'\n// break; wait (go.triggered); ->> other;\n'),case.expected)

    def test_hand_calculated_one_bit_payloads_and_indices(self):
        v=observed(g.MODEL.anchors[0])
        self.assertEqual([v['b3']['d0_'+str(i)]['seen'] for i in range(4)],['1','0','1','0'])
        self.assertEqual([v['b3']['d0_'+str(i)]['at'] for i in range(4)],['2','8','14','20'])
        self.assertEqual(v['b3']['c0']['weight'],'10');self.assertEqual(v['b3']['c0']['kept'],'4')
        self.assertEqual(v['b3']['v0']['checksum'],'0');self.assertEqual(v['b3']['v1']['checksum'],'1')

    def test_late_edge_wait_loses_only_first_blocking_pulse(self):
        v=observed(g.MODEL.anchors[5])
        self.assertEqual(v['a0']['c0']['hits'],'0');self.assertEqual(v['b3']['c0']['hits'],'3')
        self.assertEqual(v['b3']['c0']['armed'],'4');self.assertEqual(v['b3']['c0']['done'],'0')
        self.assertEqual(v['b3']['d0_0']['at'],'8');self.assertEqual(v['b3']['d0_3']['at'],'-1')

    def test_late_persistent_wait_detects_blocking_trigger_in_same_slot(self):
        v=observed(g.MODEL.anchors[3])
        self.assertEqual(v['a0']['d0_0']['at'],'2');self.assertEqual(v['a0']['c0']['stopped'],'1')
        self.assertEqual(v['a0']['c0']['done'],'1');self.assertEqual(v['a0']['c0']['kept'],'0')

    def test_late_edge_arms_before_nba_trigger_dispatch(self):
        v=observed(g.MODEL.anchors[4])
        self.assertEqual(v['a0']['d0_0']['at'],'2');self.assertEqual(v['b3']['c0']['hits'],'4')
        self.assertEqual(v['a0']['c0']['scheduled'],'0')
        self.assertEqual(observed(g.MODEL.anchors[0])['a0']['c0']['scheduled'],'1')

    def test_continue_keeps_capture_but_skips_tail_and_accumulation(self):
        v=observed(g.MODEL.anchors[4])
        self.assertEqual(v['b3']['c0']['hits'],'4');self.assertEqual(v['b3']['c0']['skipped'],'1')
        self.assertEqual(v['b3']['c0']['kept'],'3');self.assertEqual(v['b3']['c0']['tails'],'3')
        self.assertEqual([v['b3']['d0_'+str(i)]['kept'] for i in range(4)],['1','0','1','1'])
        self.assertEqual(v['b3']['d0_1']['at'],'8')

    def test_break_leaves_later_history_unwritten(self):
        v=observed(g.MODEL.anchors[2])
        self.assertEqual(v['b3']['c0']['hits'],'2');self.assertEqual(v['b3']['c0']['stopped'],'1')
        self.assertEqual(v['b3']['c0']['done'],'1');self.assertEqual(v['b3']['d0_1']['at'],'14')
        self.assertEqual(v['b3']['d0_2']['at'],'-1')

    def test_guard_event_remains_independent_of_target_transfer(self):
        for row in g.MODEL.anchors:
            v=observed(row)
            self.assertEqual(v['b3']['c1']['hits'],'4');self.assertEqual(v['b3']['c1']['kept'],'4')
            self.assertEqual(v['b3']['c1']['skipped'],'0');self.assertEqual(v['b3']['c1']['stopped'],'0')
            self.assertEqual([v['b3']['d1_'+str(i)]['at'] for i in range(4)],['5','11','17','23'])

    def test_triggered_flags_reset_on_time_advance(self):
        for row in g.MODEL.anchors:
            for state in observed(row).values():
                self.assertEqual(state['g']['a_trig'],'0');self.assertEqual(state['g']['b_trig'],'0')

    def test_cancelled_pending_loop_does_not_consume_recovery_pulse(self):
        v=observed(g.MODEL.anchors[5])
        for key in ('c0','c1','d0_3','d1_3'):self.assertEqual(v['cancelled'][key],v['idle'][key])
        self.assertEqual(v['cancelled']['h']['cancelled'],'1')
        self.assertEqual(v['rearmed']['v0']['fresh_armed'],'1');self.assertEqual(v['rearmed']['v0']['recovered'],'0')
        self.assertEqual(v['idle']['v0']['recovered'],'1');self.assertEqual(v['idle']['v0']['fresh_at'],'30')
        self.assertEqual(v['idle']['v1']['fresh_at'],'33')

    def test_xz_before_bit_conversion_and_known_recovery_are_distinct(self):
        row=g.MODEL.anchors[1];logic=observed(row);bit=observed((row[0],'bit',*row[2:]))
        self.assertIn('z',logic['a1']['g']['raw']);self.assertIn('z',bit['a1']['g']['raw'])
        self.assertIn('x',logic['idle']['v0']['checksum'])
        self.assertTrue(set(bit['a1']['d0_1']['seen'])<={'0','1'})
        self.assertTrue(set(logic['idle']['v0']['fresh'])<={'0','1'})
        self.assertTrue(g.make_case((row[0],'bit',*row[2:])).fourstate)

    def test_idle_preserves_every_observation_except_time(self):
        v=observed(g.MODEL.anchors[1]);before=v['fresh_b'];after=v['idle']
        self.assertEqual({k:x for k,x in before.items() if k!='h'},{k:x for k,x in after.items() if k!='h'})

    def test_six_controls_and_nine_real_sv_faults(self):
        controls,programs=q.variants();self.assertEqual(len(controls),6);self.assertEqual(len(programs),15)
        for name,(parent,source,kind) in programs.items():
            with self.subTest(name=name):
                if kind=='control':self.assertEqual(q.interpret(source),controls[parent].expected)
                else:self.assertNotEqual(q.interpret(source),controls[parent].expected)

    def test_unsupported_syntax_and_unknown_events_are_rejected(self):
        source=g.source(g.MODEL.anchors[0])
        for bad in (source.replace('@(go);','@(missing);'),source.replace('-> go;','-> unknown;'),
                    source.replace('payload_a=raw_a;','payload_a=$random;'),
                    source.replace('join_none','join_any')):
            with self.assertRaises((AssertionError,KeyError,ValueError,SyntaxError)):q.interpret(bad)


if __name__=='__main__':unittest.main()
