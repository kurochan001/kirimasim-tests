"""Generated loop boundaries, private process state and edge/rearm behavior."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_genloop as g
import qualify_genloop as q


def snapshots(output):
    result={};current=None
    for line in output.splitlines():
        fields=dict(v.split('=',1) for v in line.split()[1:])
        if line.startswith('h '):current=result[fields['p'],fields['step']]={}
        else:current[line[0],int(fields.pop('id'))]=fields
    return result


class GeneratedProcessLoopTransfer(unittest.TestCase):
    def test_legal_universe_and_complete_deterministic_selection(self):
        self.assertEqual(len(g.MODEL.rows()),6912);selected=g.MODEL.select()
        self.assertEqual(len(selected),36)
        self.assertEqual(Counter(map(len,g.MODEL.universe())),{2:293,3:160})
        self.assertEqual({t for r in selected for t in g.MODEL.targets(r)},g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors)<=set(selected));self.assertEqual(g.MODEL.select(),selected)

    def test_every_legal_actual_program_matches_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row):self.assertEqual(q.independent(row),g.reference(row))

    def test_interpretation_uses_no_primary_reference_or_layout_helpers(self):
        row=g.MODEL.anchors[1];source=g.source(row);expected=g.reference(row)
        with patch.object(g,'source',side_effect=AssertionError('source')), \
             patch.object(g,'reference',side_effect=AssertionError('reference')), \
             patch.object(g,'layout',side_effect=AssertionError('layout')), \
             patch.object(g,'stimulus',side_effect=AssertionError('stimulus')), \
             patch.object(g,'flipped',side_effect=AssertionError('xor')), \
             patch.object(g,'assigned',side_effect=AssertionError('conversion')):
            self.assertEqual(q.interpret(source),expected)

    def test_metadata_and_comment_keywords_do_not_select_behavior(self):
        case=g.make_case(g.MODEL.anchors[0]);source,_=common.render(case,g.NAME,g.VERSION,g.CHAPTER,'spec')
        self.assertEqual(q.interpret(source+'\n// always @(negedge clk) begin break; end\n'),case.expected)

    def test_scalar_hand_calculated_break_and_refresh(self):
        s=snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertEqual(s['0','after']['v',0],{'bits':'1','left':'-2','right':'-2','guard':'1','checksum':'0',
            'runs':'1','done':'1','visited':'1','kept':'0','hits':'1','weight':'1','kept_weight':'0','i':'0','ordinal':'0','at':'-2'})
        self.assertEqual(s['0','again']['v',0]['kept'],'1')
        self.assertEqual(s['0','again']['v',0]['hits'],'0')
        self.assertEqual(s['0','again']['v',0]['i'],'1')

    def test_generated_widths_and_array_queries_are_scope_specific(self):
        s=snapshots(q.independent(g.MODEL.anchors[4]))['0','before']
        self.assertEqual([s['v',i]['bits'] for i in range(4)],['32','34','33','33'])
        self.assertEqual([s['v',i]['left'] for i in range(4)],['3','5','4','4'])
        self.assertTrue(all(int(s['v',i]['left'])-int(s['v',i]['right'])==2 for i in range(4)))

    def test_if_and_case_elaborate_the_same_private_processes(self):
        row=g.MODEL.anchors[1]
        self.assertEqual(q.independent(row),q.independent((*row[:6],'if',*row[7:])))

    def test_break_stops_and_continue_skips_only_the_marked_element(self):
        row=g.MODEL.anchors[4];cont=snapshots(q.independent(row));stop=snapshots(q.independent((*row[:4],'break',*row[5:])))
        # The odd generated scope reverses tail to head.
        self.assertEqual(stop['0','after']['v',1]['visited'],'1')
        self.assertEqual(cont['0','after']['v',1]['visited'],'3')
        self.assertEqual(cont['0','after']['v',1]['kept'],'2')
        self.assertEqual(stop['0','after']['v',1]['kept'],'0')

    def test_for_increment_occurs_after_body_but_other_forms_advance_before_jump(self):
        row=('32','logic','known','for','break','middle','if','up','3')
        a=snapshots(q.independent(row))['0','after']['v',0]
        self.assertEqual((a['visited'],a['i'],a['ordinal']),('2','1','1'))
        for loop in ('while','repeat'):
            b=snapshots(q.independent((*row[:3],loop,*row[4:])))['0','after']['v',0]
            self.assertEqual((b['visited'],b['i'],b['ordinal']),('2','2','1'))

    def test_input_refresh_waits_for_next_edge_and_other_scopes_keep_results(self):
        s=snapshots(q.independent(g.MODEL.anchors[4]))
        for slot in range(4):
            self.assertEqual(s['0','refresh']['v',slot]['checksum'],s['0','after']['v',slot]['checksum'])
            self.assertEqual(s['0','refresh']['v',slot]['runs'],'1')
        self.assertNotEqual(s['0','refresh']['d',0],s['0','after']['d',0])
        for slot in (1,2,3):self.assertEqual(s['0','again']['d',slot],s['0','after']['d',slot])

    def test_guard_change_and_falling_edges_do_not_modify_process_results(self):
        s=snapshots(q.independent(g.MODEL.anchors[4]))
        self.assertNotEqual(s['0','after']['v',3]['guard'],s['0','refresh']['v',3]['guard'])
        for phase in ('0','1','2'):
            for slot in range(4):
                self.assertEqual(s[phase,'again']['v',slot],s[phase,'idle']['v',slot])
                self.assertEqual(s[phase,'again']['v',slot]['runs'],str(2*(int(phase)+1)))

    def test_bit_conversion_changes_unknown_marker_control_but_keeps_fourstate_metadata(self):
        row=g.MODEL.anchors[2];logic=snapshots(q.independent(row));bit=(*row[:1],'bit',*row[2:])
        converted=snapshots(q.independent(bit))
        self.assertEqual(logic['1','after']['v',0]['hits'],'1')
        self.assertEqual(converted['1','after']['v',0]['hits'],'0')
        self.assertTrue(g.make_case(bit).fourstate)

    def test_whole_word_xor_turns_unselected_z_bits_into_x_during_refresh(self):
        s=snapshots(q.independent(g.MODEL.anchors[1]))
        self.assertIn('z',s['1','after']['d',0]['0'])
        self.assertNotIn('z',s['1','refresh']['d',0]['0'])
        self.assertIn('x',s['1','refresh']['d',0]['0'])
        self.assertNotIn('x',s['2','before']['d',0]['0'])

    def test_negative_ranges_reverse_queries_without_reversing_logical_walk(self):
        row=g.MODEL.anchors[4];other=(*row[:7],'up',row[8])
        a=snapshots(q.independent(row));b=snapshots(q.independent(other))
        for slot in range(4):
            for field in ('checksum','visited','kept','hits','weight','kept_weight'):
                self.assertEqual(a['0','after']['v',slot][field],b['0','after']['v',slot][field])

    def test_nine_source_mutations_change_observations(self):
        controls,programs=q.variants();self.assertEqual(len(controls),5);self.assertEqual(len(programs),14)
        for name,(parent,source,kind) in programs.items():
            with self.subTest(name=name):
                if kind=='control':self.assertEqual(q.interpret(source),controls[parent].expected)
                else:self.assertNotEqual(q.interpret(source),controls[parent].expected)

    def test_unsupported_syntax_and_out_of_range_reads_are_rejected(self):
        source=g.source(g.MODEL.anchors[0])
        for bad in (source.replace('runs++;','runs++; $random;',1),
                    source.replace('data[at][0]','data[999][0]'),
                    source.replace('bit clk=0;','bit clk=0; initial begin end'),
                    source.replace('$finish;','$finish; clk=1;')):
            with self.assertRaises((AssertionError,ValueError)):q.interpret(bad)


if __name__=='__main__':unittest.main()
