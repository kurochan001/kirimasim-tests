"""Independent Boolean completions, terminal objects and strongest-driver arbitration."""

import itertools
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import interaction_udp as cases


def frames(row):
    width, function, strength, rival, direction, ports, mode = row
    w, mask = int(width), 2**int(width)-1
    for phase in range(10):
        raw = sum(2**i for i in range(w) if (i+1)//2**phase%2) if phase < 8 else mask*(phase-8)
        a = f'{raw:0{w}b}'
        b = f'{mask^raw:0{w}b}' if mode == 'vector' else ('0' if function == 'andnot' else '1')
        for value in ('0', '1', 'z'):
            yield f'k{phase}_{value}', a, b, value
    symbols = dict(enumerate(('0','1','x','z')))
    for phase in range(16):
        a = ''.join(symbols[(phase+i)%4] for i in reversed(range(w)))
        b = (''.join(symbols[(phase//4+i//4)%4] for i in reversed(range(w))) if mode == 'vector'
             else symbols[phase//4])
        yield f't{phase}', a, b, 'z'


def evaluate(function, a, b):
    possibilities = {'0': (0,), '1': (1,), 'x': (0,1), 'z': (0,1)}
    answers = {int(x and not y) if function == 'andnot' else int(x or not y)
               for x,y in itertools.product(possibilities[a],possibilities[b])}
    return str(next(iter(answers))) if len(answers) == 1 else 'x'


def arbitrate(value, rival, drive, contender):
    ranks = {'weak': 1, 'pull': 2, 'strong': 3}
    strengths = {'default': ('strong','strong'), 'pull': ('pull','pull'),
                 'strong_weak': ('strong','weak'), 'weak_strong': ('weak','strong')}
    if rival == 'z':
        return value
    assert value in ('0','1')
    drivers = [(value, ranks[strengths[drive][int(value)]]), (rival, ranks[contender])]
    maximum = max(rank for _,rank in drivers)
    winners = {v for v,rank in drivers if rank == maximum}
    return next(iter(winners)) if len(winners) == 1 else 'x'


def interpret(row):
    lines = []
    for label, a, b, rival in frames(row):
        terminals = [dict(a=bit, b=b[i] if row[6] == 'vector' else b) for i,bit in enumerate(a)]
        solo = ''.join(evaluate(row[1], t['a'], t['b']) for t in terminals)
        net = ''.join(arbitrate(v, rival, row[2], row[3]) for v in solo)
        sample = evaluate(row[1], a[-1], b[-1])
        lines += [f'{label} a={a} b={b} rival={rival}', f'{label} solo={solo} net={net} sample={sample}']
    return '\n'.join(lines)+'\n'


class UdpArrayStrength(unittest.TestCase):
    def test_all_1152_rows_match_independent_boolean_completions_and_arbitration(self):
        self.assertEqual(len(cases.MODEL.rows()), 1152)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_retains_every_pair_triple_and_six_mandatory_cases(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 25)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 182)
        self.assertEqual(sum(len(t) == 3 for t in targets), 80)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_every_terminal_receives_all_16_fourstate_input_pairs(self):
        for mode in ('scalar', 'vector'):
            row = ('129','andnot','default','strong','up','up',mode)
            observed = [set() for _ in range(129)]
            for label,a,b,rival in frames(row):
                if label.startswith('t'):
                    self.assertEqual(rival,'z')
                    for i,bit in enumerate(a):
                        observed[i].add((bit,b[i] if mode == 'vector' else b))
            self.assertTrue(all(pairs == set(itertools.product('01xz', repeat=2)) for pairs in observed))

    def test_known_frames_identify_all_129_bits_and_their_complements(self):
        row = cases.MODEL.anchors[1]
        data = [a for label,a,b,r in frames(row) if label.startswith('k') and r == 'z']
        signatures = list(zip(*data))
        inverted = [tuple('1' if b=='0' else '0' for b in signature) for signature in signatures]
        self.assertEqual(len(set(signatures+inverted)),258)
        self.assertEqual(data[-2], '0'*129)
        self.assertEqual(data[-1], '1'*129)

    def test_known_frames_exercise_each_udp_output_value_with_both_rivals_and_release(self):
        for row in cases.MODEL.select():
            bins = [set() for _ in range(int(row[0]))]
            for label,a,b,rival in frames(row):
                if not label.startswith('k'):
                    continue
                for i,bit in enumerate(a):
                    v = evaluate(row[1],bit,b[i] if row[6]=='vector' else b)
                    self.assertEqual(v,bit)
                    bins[i].add((v,rival))
            self.assertTrue(all(values == set(itertools.product('01','01z')) for values in bins))

    def test_asymmetric_strengths_choose_different_winners_for_zero_and_one(self):
        self.assertEqual(arbitrate('0','1','strong_weak','pull'),'0')
        self.assertEqual(arbitrate('1','0','strong_weak','pull'),'0')
        self.assertEqual(arbitrate('0','1','weak_strong','pull'),'1')
        self.assertEqual(arbitrate('1','0','weak_strong','pull'),'1')
        self.assertEqual(arbitrate('0','1','default','strong'),'x')
        self.assertEqual(arbitrate('1','0','pull','pull'),'x')

    def test_unknown_tables_distinguish_operand_order_and_z_as_x(self):
        for function in ('andnot','ornot'):
            for a,b in itertools.product('01xz', repeat=2):
                self.assertEqual(evaluate(function,a,b),evaluate(function,a.replace('z','x'),b.replace('z','x')))
                self.assertEqual(evaluate(function,a,b),cases.logic(function,a,b))
            self.assertNotEqual(evaluate(function,'0','1'),evaluate(function,'1','0'))

    def test_array_and_packed_directions_preserve_external_terminal_behavior(self):
        for row in cases.MODEL.anchors:
            for direction,ports in itertools.product(('down','up'), repeat=2):
                self.assertEqual(cases.reference(row),interpret((*row[:4],direction,ports,row[6])))

    def test_rendered_cases_require_fourstate_and_keep_unnamed_and_isolated_controls(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case,cases.NAME,cases.VERSION,cases.CHAPTER,'spec')
            self.assertTrue(case.fourstate)
            self.assertIn(' (sample, a[0],',case.body)
            self.assertIn('isolated[',case.body)
            self.assertNotIn('%v',case.body)
            self.assertNotIn('assign (',case.body.split('isolated',1)[0])


if __name__ == '__main__':
    unittest.main()
