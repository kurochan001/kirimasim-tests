"""Package/import array queries, shadowing and retained ordered-scan results."""

from collections import Counter
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import common
import interaction_pkgquery as g
import qualify_pkgquery as q


def snapshots(output):
    values, current = {}, None
    for line in output.splitlines():
        fields = dict(part.split('=',1) for part in line.split()[1:])
        if line.startswith('h '): current = values[fields['p'],fields['step']] = {}; continue
        current[line[0]+fields.pop('id')] = fields
    return values


def observed(row): return snapshots(q.independent(row))


class PackageArrayQueryScope(unittest.TestCase):
    def test_primary_clause_and_rendered_line_lengths(self):
        for row in g.MODEL.select():
            case = g.make_case(row)
            self.assertEqual(int(case.lrm.split()[0].split('.')[0]),g.CHAPTER)
            common.render(case,g.NAME,g.VERSION,g.CHAPTER,'spec')

    def test_legal_pair_triple_anchor_selection_is_deterministic(self):
        selected = g.MODEL.select()
        self.assertEqual(len(g.MODEL.rows()),3456)
        self.assertEqual(len(selected),36)
        self.assertEqual(Counter(map(len,g.MODEL.universe())),{2:249,3:118})
        self.assertEqual({t for row in selected for t in g.MODEL.targets(row)},g.MODEL.universe())
        self.assertTrue(set(g.MODEL.anchors)<=set(selected))
        self.assertEqual(g.MODEL.select(),selected)

    def test_all_actual_sv_programs_match_independent_interpretation(self):
        for row in g.MODEL.rows():
            with self.subTest(row=row): self.assertEqual(q.independent(row),g.reference(row))

    def test_interpretation_uses_no_primary_reference_stimulus_or_query_helpers(self):
        row=g.MODEL.anchors[1];source,expected=g.source(row),g.reference(row)
        with patch.object(g,'source',side_effect=AssertionError('source')), \
             patch.object(g,'reference',side_effect=AssertionError('reference')), \
             patch.object(g,'layout',side_effect=AssertionError('layout')), \
             patch.object(g,'stimulus',side_effect=AssertionError('stimulus')), \
             patch.object(g,'query_values',side_effect=AssertionError('query')), \
             patch.object(g,'assigned',side_effect=AssertionError('conversion')):
            self.assertEqual(q.interpret(source),expected)

    def test_comments_and_metadata_do_not_select_semantics(self):
        case=g.make_case(g.MODEL.anchors[0]);source,_=common.render(case,g.NAME,g.VERSION,g.CHAPTER,'spec')
        self.assertEqual(q.interpret(source+'\n// import second_pkg::*;\n'),case.expected)

    def test_hand_calculated_second_package_scan(self):
        row=list(g.MODEL.anchors[0]);row[7]='second';v=observed(tuple(row))
        self.assertEqual(v['0','before']['p1'],{'0':'001','1':'110'})
        self.assertEqual(v['0','first0']['v0']['result'],'000100')
        self.assertEqual(v['0','first0']['v0']['weight'],'13')
        self.assertEqual(v['0','first0']['v0']['terminal'],'3')
        self.assertEqual(v['0','again0']['v0']['result'],'000011')

    def test_all_binding_spellings_have_the_same_observations(self):
        row=g.MODEL.anchors[1];expected=q.independent(row)
        for binding in ('explicit','wildcard','qualified'):
            self.assertEqual(q.independent((*row[:6],binding,*row[7:])),expected)

    def test_default_and_explicit_first_dimensions_agree(self):
        row=g.MODEL.anchors[1]
        self.assertEqual(q.independent(row),q.independent((*row[:8],'default')))

    def test_selected_package_changes_bits_size_and_actual_results(self):
        row=g.MODEL.anchors[0];first=observed(row);second=observed((*row[:7],'second',row[8]))
        self.assertEqual(first['0','first0']['q0']['bits'],'1')
        self.assertEqual(second['0','first0']['q0']['bits'],'6')
        self.assertEqual(first['0','first0']['q0']['size'],'1')
        self.assertEqual(second['0','first0']['q0']['size'],'2')
        self.assertNotEqual(first['0','first0']['v0']['checksum'],second['0','first0']['v0']['checksum'])

    def test_lexical_import_hides_the_local_namesake_for_queries(self):
        row=g.MODEL.anchors[0];source=g.source(row)
        correct=observed(row);wrong=snapshots(q.interpret(source.replace('import first_pkg::data;','')))
        self.assertEqual(correct['0','first0']['q0']['bits'],'1')
        self.assertEqual(wrong['0','first0']['q0']['bits'],'30')
        self.assertEqual(wrong['0','first0']['q0']['size'],'5')

    def test_nonselected_package_update_is_observed_but_does_not_change_scan(self):
        v=observed(g.MODEL.anchors[4])
        for phase in ('0','1','2'):
            self.assertNotEqual(v[phase,'first1']['p0'],v[phase,'unselected']['p0'])
            self.assertEqual(v[phase,'first1']['p1'],v[phase,'unselected']['p1'])
            self.assertEqual(v[phase,'first1']['v0']['result'],v[phase,'recheck']['v0']['result'])
            self.assertEqual(v[phase,'first1']['q0'],v[phase,'recheck']['q0'])

    def test_selected_refresh_keeps_results_until_recalled(self):
        v=observed(g.MODEL.anchors[4])
        self.assertEqual(v['0','recheck']['v0'],v['0','refresh']['v0'])
        self.assertNotEqual(v['0','refresh']['p1'],v['0','recheck']['p1'])
        self.assertNotEqual(v['0','refresh']['v1']['result'],v['0','again1']['v1']['result'])

    def test_caller_counters_and_widened_results_remain_separate(self):
        v=observed(g.MODEL.anchors[4])
        self.assertEqual(v['2','idle']['v0']['calls'],'9')
        self.assertEqual(v['2','idle']['v1']['calls'],'6')
        self.assertEqual(v['0','first0']['v1']['calls'],'0')
        for slot in ('0','1'):
            self.assertEqual(v['2','idle']['v'+slot]['result'][:3],'000')
            self.assertEqual(v['2','idle']['v'+slot]['result'],v['2','idle']['v'+slot]['checksum'])

    def test_negative_singleton_increment_and_terminal(self):
        v=observed(g.MODEL.anchors[0])['0','first0']
        self.assertEqual(v['q0']['left'],'-4');self.assertEqual(v['q0']['right'],'-4')
        self.assertEqual(v['q0']['increment'],'1');self.assertEqual(v['v0']['terminal'],'-5')
        self.assertEqual(v['q0']['psize'],'1')
        self.assertEqual(v['q0']['dimensions'],'2');self.assertEqual(v['q0']['unpacked_dimensions'],'1')

    def test_xz_conversion_and_known_recovery_retain_history(self):
        row=g.MODEL.anchors[1];logic=observed(row);bit=observed((row[0],'bit',*row[2:]))
        self.assertIn('x',logic['1','first0']['v0']['result'])
        self.assertTrue(set(bit['1','first0']['v0']['result'])<={'0','1'})
        self.assertTrue(set(logic['2','first0']['v0']['result'])<={'0','1'})
        self.assertEqual(logic['2','first0']['v0']['calls'],'7')
        self.assertTrue(g.make_case((row[0],'bit',*row[2:])).fourstate)

    def test_unselected_array_elements_and_idle_state_are_preserved(self):
        v=observed(g.MODEL.anchors[4])
        for phase in ('0','1','2'):
            before,after=v[phase,'recheck'],v[phase,'refresh']
            for ordinal in ('0','1','2'):
                self.assertEqual(before['p1'][ordinal],after['p1'][ordinal])
            for i in ('1','2','3','4'): self.assertEqual(before['l0'][i],after['l0'][i])
            for i in ('0','1','2','3'): self.assertEqual(before['l1'][i],after['l1'][i])
            self.assertEqual(v[phase,'again0'],v[phase,'idle'])

    def test_six_controls_and_nine_executable_source_faults(self):
        controls,programs=q.variants();self.assertEqual(len(controls),6);self.assertEqual(len(programs),15)
        for name,(parent,source,kind) in programs.items():
            with self.subTest(name=name):
                if kind=='control':self.assertEqual(q.interpret(source),controls[parent].expected)
                else:self.assertNotEqual(q.interpret(source),controls[parent].expected)

    def test_unknown_syntax_scopes_and_query_dimensions_are_rejected(self):
        source=g.source(g.MODEL.anchors[0])
        for bad in (source.replace('import first_pkg::data','import unknown_pkg::data'),
                    source.replace('psize=$size(data, 2)','psize=$size(data, 3)'),
                    source.replace('acc=(acc << 1)','acc=$random'),
                    source.replace('function automatic','function static')):
            with self.assertRaises((AssertionError,KeyError,ValueError,SyntaxError)):q.interpret(bad)


if __name__=='__main__': unittest.main()
