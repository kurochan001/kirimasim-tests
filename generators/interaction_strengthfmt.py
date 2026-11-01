"""Resolved scalar drive strengths through display and string-format APIs."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_strengthfmt'
VERSION = 1
CHAPTER = 21
LEVELS = {'equal_weak': (3, 3), 'equal_pull': (5, 5), 'equal_strong': (6, 6),
          'a_stronger': (6, 3), 'b_stronger': (3, 6)}
WORDS = {3: 'weak', 5: 'pull', 6: 'strong'}
MNEMONICS = {3: 'We', 5: 'Pu', 6: 'St'}
FORMAT = 'strength=%v guard0=%v guard1=%v'
MODEL = Model(
    'resolved_strength_format',
    (('net', ('wire', 'tri0', 'tri1')), ('strengths', tuple(LEVELS)),
     ('order', ('ab', 'ba')), ('api', ('display', 'sformatf', 'swrite')),
     ('polarity', ('normal', 'inverse'))),
    lambda row: True,
    groups=(('net', 'strengths', 'polarity'), ('net', 'api', 'order'),
            ('strengths', 'api', 'order')),
    anchors=(('wire', 'equal_weak', 'ab', 'sformatf', 'normal'),
             ('tri0', 'a_stronger', 'ba', 'display', 'inverse'),
             ('tri1', 'b_stronger', 'ab', 'swrite', 'normal'),
             ('wire', 'equal_strong', 'ba', 'display', 'normal')),
    constraints=('全180行が合法。2個の連続代入は0/1それぞれで同じ単一強度を持つ。'
                 'ドライバには既知の0/1とZだけを与え、Xは同強度の0/1競合で作る。'
                 'wireの解放時とtri0/tri1の既定pullを比較し、各書込みと観測を1tick離す。'
                 '全11観測でscalar netを直接format APIへ渡し、stringは毎回上書きする。'
                 '別のsupply0/supply1を強度表示の対照にする。'
                 '曖昧な駆動強度、L/H、強度範囲の数字表示、trireg、wired logic、ベクタ、'
                 '遅延付きゲート、変数経由の強度伝達、ファイル出力は対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_strength_format_' + '_'.join(row)


def observations(row: Row) -> list[tuple[str, str, str]]:
    state = {'a': 'z', 'b': 'z'}
    result = [('idle', 'z', 'z')]
    for phase, values in enumerate(('01', '10', '00', '11')):
        if row[4] == 'inverse':
            values = values.translate(str.maketrans('01', '10'))
        incoming = dict(zip('ab', values))
        for index, owner in enumerate(row[2]):
            state[owner] = incoming[owner]
            result.append((f'p{phase}_{"half" if index==0 else "full"}', state['a'], state['b']))
    for index, owner in enumerate(row[2]):
        state[owner] = 'z'
        result.append(('release_half' if index==0 else 'release_full', state['a'], state['b']))
    return result


def resolved(net: str, strengths: str, a: str, b: str) -> tuple[str, str]:
    drivers = [(value, level) for value, level in zip((a, b), LEVELS[strengths]) if value != 'z']
    if net != 'wire':
        drivers.append(('0' if net=='tri0' else '1', 5))
    if not drivers:
        return 'z', 'HiZ'
    strongest = max(level for _, level in drivers)
    values = {value for value, level in drivers if level==strongest}
    value = values.pop() if len(values)==1 else 'x'
    return value, MNEMONICS[strongest] + value.upper()


def reference(row: Row) -> str:
    lines = []
    for label, a, b in observations(row):
        value, strength = resolved(row[0], row[1], a, b)
        lines += [f'slot={label} a={a} b={b} value={value}',
                  f'strength={strength} guard0=Su0 guard1=Su1']
    return '\n'.join(lines) + '\n'


def make_case(row: Row) -> Case:
    net, strengths, order, api, polarity = row
    a_level, b_level = LEVELS[strengths]
    lines = ['`timescale 1ns/1ns', f'module {case_name(row)};', '  logic a, b;',
             f'  {net} bus;', '  supply0 guard0;', '  supply1 guard1;', '  string rendered;',
             f'  assign ({WORDS[a_level]}0, {WORDS[a_level]}1) bus = a;',
             f'  assign ({WORDS[b_level]}0, {WORDS[b_level]}1) bus = b;',
             '  initial begin', "    a = 1'bz; b = 1'bz;", '    rendered = "poison";', '    #1;']
    for index, (label, a, b) in enumerate(observations(row)):
        if index:
            owner = order[(index-1) % 2] if index <= 8 else order[index-9]
            value = a if owner=='a' else b
            lines += [f"    {owner} = 1'b{value};", '    #1;']
        lines += [f'    $display("slot={label} a=%b b=%b value=%b", a, b, bus);']
        if api == 'display':
            lines += [f'    $display("{FORMAT}", bus, guard0, guard1);']
        elif api == 'sformatf':
            lines += [f'    rendered = $sformatf("{FORMAT}", bus, guard0, guard1);',
                      '    $display("%s", rendered);']
        else:
            lines += [f'    $swrite(rendered, "{FORMAT}", bus, guard0, guard1);',
                      '    $display("%s", rendered);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Scalar strength formatting preserves resolved drives through display and string APIs',
                '21.2.1.4 21.3.3 28.12.1 28.15.1 6.6.5 10.3.4',
                'Two continuous assignments drive a scalar wire, tri0 or tri1. Their symmetric '
                'zero/one strengths are equal weak/pull/strong or stronger on one selected '
                'driver. The two variables take known 0/1 pairs in four phases, optionally '
                'complemented, and are written sequentially in either order. Idle, every half '
                'and full update, and both release steps are observed one tick after a write. '
                'Equal-strength contention produces X; all-Z drives yield HiZ or the net type '
                'pull default. Each resolved scalar net is passed directly to display, '
                'sformatf or swrite with percent-v formatting. Supply-zero and supply-one '
                'nets are isolated controls. String results overwrite a poison value and '
                'are printed as strings. Eleven observations check logic, drive values and '
                'all three strength mnemonics. Ambiguous strengths, L/H, numeric strength '
                'ranges, charge storage, wired logic, vectors and file output are excluded '
                'by scope, not by tool support. Expectations do not use the existing broad '
                'strength generator or a simulator implementation.',
                '\n'.join(lines), reference(row), fourstate=True,
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
