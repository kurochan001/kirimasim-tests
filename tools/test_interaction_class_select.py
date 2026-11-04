"""Observe receiver identity, four-state branch rules and typed early returns."""

from collections import Counter
from math import prod
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_class_select as g
import qualify_class_select as q
from qualify_class_import import Value


def snapshots(text):
    result = {}; current = None
    for line in text.splitlines():
        fields = dict(item.split('=', 1) for item in line.split()[1:])
        if line.startswith('h '):
            current = result[fields['p'], fields['step']] = {'h': fields}
        else: current[fields.pop('who')] = fields
    return result


class ClassConditionalReturn(unittest.TestCase):
    def test_complete_legal_space_and_deterministic_cover(self):
        self.assertEqual(prod(len(v) for _,v in g.MODEL.factors), 1296)
        self.assertEqual(len(g.MODEL.rows()), 1296)
        selected = g.MODEL.select()
        self.assertEqual(len(selected), 36)
        self.assertEqual(Counter(map(len,g.MODEL.universe())), {2:183,3:135})
        self.assertEqual({t for r in selected for t in g.MODEL.targets(r)}, g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors) <= set(selected))
        self.assertEqual(g.MODEL.select(), selected)

    def test_all_actual_legal_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row),g.reference(row))

    def test_interpretation_uses_no_primary_generation_or_reference_helpers(self):
        row=g.MODEL.anchors[1];source=g.source(row);expected=g.reference(row)
        with patch.object(g,'source',side_effect=AssertionError('source')), \
             patch.object(g,'reference',side_effect=AssertionError('reference')), \
             patch.object(g,'actions',side_effect=AssertionError('actions')), \
             patch.object(g,'select',side_effect=AssertionError('selection')), \
             patch.object(g,'assigned',side_effect=AssertionError('conversion')):
            self.assertEqual(q.interpret(source),expected)

    def test_metadata_and_comments_are_not_interpreted_as_code(self):
        case=g.make_case(g.MODEL.anchors[0])
        source,_=common.render(case,g.NAME,g.VERSION,g.CHAPTER,'spec')
        self.assertEqual(q.interpret(source+'\n// class false; virtual function\n'),case.expected)

    def test_one_bit_hand_calculated_leaf_capture_and_result_width(self):
        s=snapshots(q.independent(g.MODEL.anchors[0]))
        self.assertEqual(s['0','first']['h']['ra'],'0001')
        self.assertEqual(s['0','first']['a'],{'data':'1','backup':'0','guard':'1','base':'0','leaf':'1','dead':'0'})
        self.assertEqual(s['0','first']['b'],s['0','init']['b'])
        self.assertEqual(s['0','alias']['h']['ro'],'0000')

    def test_direct_and_virtual_dispatch_agree_but_nonvirtual_uses_base(self):
        row=g.MODEL.anchors[4]
        direct=(*row[:3],'direct',*row[4:]);nonvirtual=(*row[:3],'nonvirtual',*row[4:])
        self.assertEqual(q.independent(direct),q.independent(row))
        self.assertNotEqual(q.independent(nonvirtual),q.independent(row))
        base=snapshots(q.independent(nonvirtual))['0','first']['a']
        self.assertEqual((base['base'],base['leaf']),('1','0'))

    def test_known_if_case_and_conditional_select_the_same_values(self):
        row=g.MODEL.anchors[4]
        outputs={q.independent((*row[:4],control,*row[5:])) for control in ('if','case','conditional')}
        self.assertEqual(len(outputs),1)

    def test_unknown_if_and_case_take_default_while_conditional_merges(self):
        row=g.MODEL.anchors[1]
        ordinary=[q.independent((*row[:4],control,*row[5:])) for control in ('if','case')]
        self.assertEqual(ordinary[0],ordinary[1])
        self.assertNotEqual(ordinary[0],q.independent(row))
        for output in ordinary:
            h=snapshots(output)['1','again']['h']
            self.assertEqual(h['sel'],'z')
            self.assertNotIn('x',h['ra'])

    def test_independent_merge_retains_equal_known_x_and_z_bits(self):
        # 10XZ versus 00XZ -> X0XZ, while known selectors keep one whole word.
        a=Value(4,8,x=2,z=1);b=Value(4,0,x=2,z=1)
        self.assertEqual(q.merged(Value(1,x=1),a,b).binary(),'x0xz')
        self.assertEqual(q.merged(Value(1,z=1),a,b).binary(),'x0xz')
        self.assertEqual(q.merged(Value(1,1),a,b),a)
        self.assertEqual(q.merged(Value(1,0),a,b),b)

    def test_bit_destination_keeps_logic_selector_and_converts_merged_result(self):
        row=g.MODEL.anchors[3]
        self.assertTrue(g.make_case(row).fourstate)
        output=snapshots(q.independent(row))
        self.assertEqual(output['1','again']['h']['sel'],'x')
        self.assertNotIn('x',output['1','again']['h']['ra'])
        self.assertNotEqual(q.independent(row),q.independent((*row[:4],'if',*row[5:])))

    def test_return_type_sign_extends_before_wider_unsigned_destination(self):
        row=g.MODEL.anchors[4]
        signed=snapshots(q.independent(row))['0','first']['h']['ra']
        unsigned=snapshots(q.independent((*row[:2],'u',*row[3:])))['0','first']['h']['ra']
        self.assertEqual(signed[:4],'1111');self.assertEqual(unsigned[:4],'0001')
        self.assertEqual(signed[4:],unsigned[4:])

    def test_rebinding_retains_original_object_and_shares_the_new_receiver(self):
        s=snapshots(q.independent(g.MODEL.anchors[4]))
        self.assertEqual(s['0','rebind']['h']['same'],'0')
        self.assertEqual(s['0','rebind']['h']['ab'],'1')
        self.assertEqual(s['0','again']['a'],s['0','again']['b'])
        self.assertEqual(s['0','again']['old'],s['0','rebind']['old'])
        self.assertEqual(s['0','alias']['b'],s['0','again']['b'])

    def test_guard_only_update_and_idle_preserve_other_observations(self):
        s=snapshots(q.independent(g.MODEL.anchors[4]))
        self.assertNotEqual(s['0','guard']['b']['guard'],s['0','alias']['b']['guard'])
        self.assertEqual(s['0','guard']['b']['data'],s['0','alias']['b']['data'])
        self.assertEqual(s['0','guard']['old'],s['0','alias']['old'])
        for who in ('a','old','b'):self.assertEqual(s['0','last'][who],s['0','idle'][who])

    def test_early_returns_leave_dead_effects_unexecuted_for_every_form(self):
        for row in g.MODEL.anchors:
            for sample in snapshots(q.independent(row)).values():
                for who in ('a','old','b'):self.assertEqual(sample[who]['dead'],'0')

    def test_nine_real_source_faults_change_interpreted_observations(self):
        controls,programs=q.variants()
        self.assertEqual(len(controls),5);self.assertEqual(len(programs),14)
        for name,(parent,source,kind) in programs.items():
            with self.subTest(name=name):
                if kind=='control':self.assertEqual(q.interpret(source),controls[parent].expected)
                else:self.assertNotEqual(q.interpret(source),controls[parent].expected)

    def test_unsupported_syntax_extra_process_and_handle_types_are_rejected(self):
        source=g.source(g.MODEL.anchors[0])
        for mutant in (source.replace('  initial begin','  initial begin\n    #1;',1),
                       source.replace('return saved;','return $random;'),
                       source.replace('$finish;','$finish; sel = 1\'b1;',1),
                       source.replace('leaf_t a, old, b;','base_t a, old, b;')):
            with self.assertRaises((AssertionError,ValueError)):q.interpret(mutant)


if __name__=='__main__':unittest.main()
