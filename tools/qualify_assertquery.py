#!/usr/bin/env python3
"""Interpret actual assertion programs with bit vector functions independently.

Variables hold four-state bits. The functions are computed from the bits:
$onehot, $onehot0 and $countones count the 1 bits, $countbits counts the bits
equal to its control bits, and $isunknown looks for x or z. Processes run on
a scheduler with active, inactive, NBA, observed and postponed regions.
always_comb runs once at time 0 and again when a variable it reads changes,
and always @(posedge clk) runs on a rise. An immediate assertion reports at
once; a deferred one queues its report for the observed or postponed region,
and the next run of the same process flushes what it queued before. Every
order of the processes ready together must give the same output.
"""

from itertools import permutations
import re
import sys

from qualify_support import ROOT, apply_faults, qualify

sys.path.insert(0, str(ROOT / 'generators'))
import interaction_assertquery as generator


def bits_of(text):
    found = re.fullmatch(r"(\d+)'b([01xz?_]+)", text)
    assert found, ('unsupported value', text)
    digits = found[2].replace('_', '').replace('?', 'z')
    assert len(digits) == int(found[1]), 'width'
    return digits


def control(text):
    found = re.fullmatch(r"'([01xz])|1'b([01xz])", text.strip())
    assert found, ('unsupported control bit', text)
    return found[1] or found[2]


def condition(text, store):
    """The value of an assertion expression: True, False or None for x."""
    text = text.strip()
    negated = re.fullmatch(r'!(.*)', text)
    if negated:
        inner = condition(negated[1], store)
        return None if inner is None else not inner
    compared = re.fullmatch(r'(.*) == (\d+)', text)
    if compared: return number(compared[1], store) == int(compared[2])
    call = re.fullmatch(r'\$(onehot|onehot0|isunknown)\((\w+)\)', text)
    assert call, ('unsupported condition', text)
    bits = store[call[2]]
    if call[1] == 'isunknown': return any(bit in 'xz' for bit in bits)
    ones = bits.count('1')
    return ones == 1 if call[1] == 'onehot' else ones <= 1


def number(text, store):
    countones = re.fullmatch(r'\$countones\((\w+)\)', text.strip())
    if countones: return store[countones[1]].count('1')
    countbits = re.fullmatch(r'\$countbits\((\w+), (.*)\)', text.strip())
    assert countbits, ('unsupported number', text)
    wanted = {control(item) for item in countbits[2].split(',')}
    return sum(bit in wanted for bit in store[countbits[1]])


class Simulation:
    def __init__(self, source):
        code = re.sub(r'//[^\n]*|/\*.*?\*/', '', source, flags=re.S)
        found = re.fullmatch(r'\s*module \w+;(.*)endmodule\s*', code, re.S)
        assert found, 'unsupported program'
        body = found[1]
        self.store, self.blocks = {}, []
        for item in re.finditer(r"(logic \[3:0\]|bit) (\w+) = ([^;]+);", body):
            self.store[item[2]] = bits_of(item[3]) if item[1] != 'bit' else bits_of(item[3])
        pattern = r'(initial|always_comb|always @\(posedge (\w+)\)) begin\n(.*?)\n  end\n|initial #(\d+) \$finish;'
        for block in re.finditer(pattern, body, re.S):
            if block[4]:
                self.blocks.append(('initial', None, [('delay', int(block[4])), ('finish',)]))
            else:
                kind = 'initial' if block[1] == 'initial' else 'comb' if block[1] == 'always_comb' else 'edge'
                self.blocks.append((kind, block[2], self.parse(block[3])))
        rest = re.sub(pattern, '', re.sub(r"(logic \[3:0\]|bit) (\w+) = ([^;]+);", '', body), flags=re.S)
        assert not rest.strip(), ('unsupported items', rest.strip()[:80])

    @staticmethod
    def parse(text):
        text = re.sub(r'\s+', ' ', text).strip()
        out = []
        while text:
            check = re.match(r'(\w+): assert( #0| final)? \((.*?)\) \$display\("%0d (\w+)", \$time\); else '
                             r'\$display\("%0d (\w+)", \$time\);', text)
            if check:
                kind = {None: 'simple', ' #0': 'observed', ' final': 'final'}[check[2]]
                out.append(('assert', kind, check[3], check[4], check[5]))
                text = text[check.end():].strip()
                continue
            statement, _, text = text.partition(';')
            statement, text = statement.strip(), text.strip()
            delay = re.fullmatch(r'#(\d+)', statement)
            late = re.fullmatch(r'(\w+) <= (.*)', statement)
            now = re.fullmatch(r'(\w+) = (.*)', statement)
            if delay: out.append(('delay', int(delay[1])))
            elif late: out.append(('nba', late[1], bits_of(late[2])))
            elif now: out.append(('set', now[1], bits_of(now[2])))
            else: raise AssertionError(('unsupported statement', statement))
        return out

    def reads(self, statements):
        names = set()
        for item in statements:
            if item[0] == 'assert': names |= set(re.findall(r'\b([a-z]\w*)\b(?!\()', item[2])) & set(self.store)
        return names

    def run(self, order):
        self.output, now = [], 0
        waiting = {0: []}
        procedures = []
        for index in order:
            kind, clock, statements = self.blocks[index]
            if kind == 'initial': waiting[0].append(('initial', index, iter(self.steps(index, statements))))
            else: procedures.append(index)
        queued = {}      # process index -> list of (region, line)
        finished = False
        first = True
        while waiting and not finished:
            now = min(waiting)
            active, inactive, nba = list(waiting.pop(now)), [], []
            if first:
                # always_comb runs once at time 0, after the initial procedures start.
                active += [('run', index, None) for index in procedures if self.blocks[index][0] == 'comb']
                first = False
            observed, postponed = [], []

            def changed(name, old):
                for index in procedures:
                    kind, clock, statements = self.blocks[index]
                    woken = (kind == 'comb' and name in self.reads(statements)) or \
                        (kind == 'edge' and name == clock and old == '0' and self.store[name] == '1')
                    if woken and not any(entry[0] == 'run' and entry[1] == index for entry in active):
                        active.append(('run', index, None))
            while active or inactive or nba:
                if not active and inactive:
                    active, inactive = inactive, []
                    continue
                if not active:
                    for name, value in nba:
                        old = self.store[name]
                        self.store[name] = value
                        if old != value: changed(name, old)
                    nba = []
                    continue
                entry = active.pop(0)
                if entry[0] == 'run':
                    index = entry[1]
                    queued[index] = []      # a new run flushes the pending deferred reports
                    for item in self.blocks[index][2]:
                        self.check(item, now, queued[index])
                    continue
                _, index, steps = entry
                while True:
                    step = next(steps, None)
                    if step is None: break
                    if step[0] == 'finish':
                        finished = True
                        break
                    if step[0] == 'delay':
                        if step[1] == 0: inactive.append(entry)
                        else: waiting.setdefault(now + step[1], []).append(entry)
                        break
                    if step[0] == 'nba': nba.append((step[1], step[2]))
                    elif step[0] == 'set':
                        old = self.store[step[1]]
                        self.store[step[1]] = step[2]
                        if old != step[2]: changed(step[1], old)
                    elif step[0] == 'assert': self.check(step, now, queued.setdefault(index, []))
                if finished: break
            for index in sorted(queued):
                observed += [line for region, line in queued[index] if region == 'observed']
                postponed += [line for region, line in queued[index] if region == 'final']
            queued = {}
            self.output += observed + postponed
        return ''.join(line + '\n' for line in self.output)

    def steps(self, index, statements):
        for item in statements:
            yield item

    def check(self, item, now, queue):
        _, kind, text, passed, failed = item
        result = condition(text, self.store)
        line = f'{now} {passed if result else failed}'
        if kind == 'simple': self.output.append(line)
        else: queue.append((kind, line))


def interpret(source):
    first = Simulation(source)
    results = {Simulation(source).run(order) for order in permutations(range(len(first.blocks)))}
    assert len(results) == 1, ('depends on the order of processes', results)
    return results.pop()


def independent(row): return interpret(generator.source(row))


def anchor(row):
    assert row in generator.MODEL.anchors, row
    return generator.make_case(row)


def variants():
    controls = {'observed_glitch': anchor(('onehot', 'xone', 'observed', 'comb', 'glitch')),
                'final_glitch': anchor(('countzero', 'zone', 'final', 'comb', 'glitch')),
                'simple_glitch': anchor(('known', 'xall', 'simple', 'comb', 'glitch')),
                'clocked_nba': anchor(('onehot0', 'xall', 'final', 'clocked', 'glitch')),
                'initial_count': anchor(('countones', 'two', 'observed', 'initial', 'settled')),
                'clocked_onehot': anchor(('onehot', 'zone', 'simple', 'clocked', 'settled'))}
    faults = (
        ('immediate_glitch', 'observed_glitch', [('assert #0 (', 'assert (')]),
        ('count_ones', 'final_glitch', [("$countbits(v, '0) == 2", "$countbits(v, '1) == 2")]),
        ('no_glitch', 'simple_glitch', [("    v = 4'b0011;\n    #0;\n", '')]),
        ('blocking_edge', 'clocked_nba', [("v <= 4'bxxxx;", "v = 4'bxxxx;"), ("clk = 1'b1;\n    v = 4'bxxxx;", "v = 4'bxxxx;\n    clk = 1'b1;")]),
        ('other_count', 'initial_count', [('$countones(v) == 2', '$countones(v) == 1')]),
        ('unknown_bit', 'clocked_onehot', [("v = 4'b1z00;", "v = 4'b1100;")]),
    )
    return controls, apply_faults(controls, faults, interpret)


FILES = ('generators/interaction_assertquery.py', 'generators/interaction_cover.py', 'generators/common.py',
         'tools/qualify_assertquery.py', 'tools/qualify_support.py')


def main():
    qualify(generator, interpret, variants, FILES,
            'Independent four-state bit counts and region scheduling of actual assertion programs. '
            'Auxiliary controls and faults are not fixed-suite or coverage passes.', __doc__)


if __name__ == '__main__': main()
