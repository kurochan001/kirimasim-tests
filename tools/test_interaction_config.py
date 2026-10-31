"""Independent parameter candidates, instance objects and integer data planes."""

import itertools
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_config as cases


def resolve(row, guard=False):
    base, prior, action, mode, form, rhs, hierarchy = row
    width = int(base)
    if guard:
        return dict(ID=1, W=width+6, N=3, MODE=2, TAG=40)
    defaults = dict(ID=0, W=width, N=2, MODE=0, TAG=10)
    candidates = {key: [(0, value)] for key, value in defaults.items()}
    overrides = ((1, prior in ('instance', 'both'), dict(W=width+1, N=3, MODE=1, TAG=20)),
                 (2, prior in ('defparam', 'both'), dict(W=width+2, N=1, MODE=2, TAG=30)))
    for priority, enabled, values in overrides:
        if enabled:
            for key, value in values.items():
                candidates[key].append((priority, value))
    if action == 'set':
        scope = dict(literal=dict(W=width+3, MODE=int(mode)),
                     local=dict(W=width+4, MODE=(int(mode)+1)%3),
                     parent=dict(W=width+5, MODE=(int(mode)+2)%3))
        configured = scope[rhs]
    else:
        configured = defaults if action == 'reset_all' else dict(W=defaults['W'])
    for key, value in configured.items():
        candidates[key].append((3, value))
    return {key: max(values)[1] for key, values in candidates.items()}


def sample(obj, lane, phase):
    width = obj['W']
    raw = sum((((obj['ID']+1)*2048+(lane+1)*256+bit+1) // 2**phase % 2) * 2**bit
              for bit in range(width))
    value = raw ^ ((obj['TAG']+lane) % 2**width)
    if obj['MODE'] == 1:
        value = (2**width-1)-value
    elif obj['MODE'] == 2:
        value ^= 3 % 2**width
    return raw, value


def interpret(row):
    objects = [resolve(row, guard) for guard in (False, True)]
    for obj in objects:
        obj['children'] = [dict(width=obj['W'], branch=obj['MODE']) for _ in range(obj['N'])]
    lines = []
    for phase in range(13):
        for obj in objects:
            identity, width = obj['ID'], obj['W']
            lines.append(f"id={identity} p={phase} W={width} N={obj['N']} MODE={obj['MODE']} TAG={obj['TAG']}")
            for lane, child in enumerate(obj['children']):
                raw, value = sample(obj, lane, phase)
                lines.append(f"id={identity} p={phase} lane={lane} raw={raw:0{width}b} "
                             f"value={value:0{width}b} branch={child['branch']} bits={width},{child['width']}")
    return '\n'.join(lines)+'\n'


class ConfigurationGeneratedShape(unittest.TestCase):
    def test_all_1056_rows_match_independent_candidates_and_object_graph(self):
        self.assertEqual(len(cases.MODEL.rows()), 1056)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_retains_all_targets_and_six_mandatory_cases(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 41)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 213)
        self.assertEqual(sum(len(t) == 3 for t in targets), 80)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_omitted_1536_unused_levels_have_a_behaviorally_equal_representative(self):
        full = list(itertools.product(*(levels for _, levels in cases.MODEL.factors)))
        legal = set(cases.MODEL.rows())
        self.assertEqual(len(full), 2592)
        for row in set(full)-legal:
            representative = (*row[:3], '0', row[4], 'literal', row[6])
            self.assertIn(representative, legal)
            self.assertEqual(resolve(row), resolve(representative))

    def test_config_precedence_selective_reset_and_full_reset_are_distinct(self):
        row = ('33', 'both', 'set', '0', 'if', 'literal', 'direct')
        self.assertEqual(resolve(row), dict(ID=0, W=36, N=1, MODE=0, TAG=30))
        self.assertEqual(resolve((*row[:2], 'reset_w', *row[3:])),
                         dict(ID=0, W=33, N=1, MODE=2, TAG=30))
        self.assertEqual(resolve((*row[:2], 'reset_all', *row[3:])),
                         dict(ID=0, W=33, N=2, MODE=0, TAG=10))
        self.assertEqual(resolve(('33', 'instance', 'set', *row[3:])),
                         dict(ID=0, W=36, N=3, MODE=0, TAG=20))

    def test_literal_local_parent_shadow_values_are_all_distinct(self):
        row = cases.MODEL.anchors[0]
        resolved = [resolve((*row[:5], rhs, row[6])) for rhs in ('literal', 'local', 'parent')]
        self.assertEqual([p['W'] for p in resolved], [4, 5, 6])
        self.assertEqual([p['MODE'] for p in resolved], [0, 1, 2])

    def test_guard_and_every_bit_history_are_distinct_even_after_transform(self):
        row = ('129', 'instance', 'set', '0', 'case', 'parent', 'wrapped')
        signatures = [[], []]
        for guard in (False, True):
            obj = resolve(row, guard)
            for lane in range(obj['N']):
                frames = [sample(obj, lane, phase) for phase in range(13)]
                for bit in range(obj['W']):
                    for index in (0, 1):
                        signatures[index].append(tuple((frame[index] >> bit) & 1 for frame in frames))
        for histories in signatures:
            self.assertEqual(len(histories), 807)
            self.assertEqual(len(set(histories)), 807)
        raw = signatures[0]
        complements = [tuple(1-bit for bit in history) for history in raw]
        self.assertEqual(len(set(raw+complements)), 1614)
        guards = [resolve(r, True) for r in cases.MODEL.rows() if r[0] == '129']
        self.assertTrue(all(g == guards[0] for g in guards))

    def test_forms_and_wrapper_do_not_change_defined_behavior(self):
        for row in cases.MODEL.select():
            for form in ('if', 'case'):
                for hierarchy in ('direct', 'wrapped'):
                    equivalent = (*row[:4], form, row[5], hierarchy)
                    self.assertEqual(cases.reference(row), interpret(equivalent))

    def test_rendered_known_cases_observe_actual_arrays_and_avoid_generated_rhs(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, 'spec')
            self.assertFalse(case.fourstate)
            self.assertIn('lane < N', case.body)
            self.assertIn('$bits(value[lane]), width_code[lane]', case.body)
            self.assertNotIn('.g[', '\n'.join(cases.config_lines(row)))


if __name__ == '__main__':
    unittest.main()
