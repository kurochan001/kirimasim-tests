"""Class dispatch, four-state selection, early returns and retained aliases."""

from common import Case
from interaction_class_import import assigned
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_class_select'
VERSION = 1
CHAPTER = 8
MODEL = Model(
    'class_conditional_return',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('sign', ('u', 's')),
     ('dispatch', ('direct', 'virtual', 'nonvirtual')),
     ('control', ('if', 'case', 'conditional')),
     ('value', ('known', 'x', 'z')), ('alias', ('keep', 'rebind'))),
    lambda row: True,
    groups=(('width', 'state', 'value'), ('width', 'sign', 'control'),
            ('dispatch', 'control', 'value'), ('dispatch', 'alias', 'control'),
            ('state', 'control', 'value')),
    anchors=(('1', 'bit', 'u', 'direct', 'if', 'known', 'keep'),
             ('129', 'logic', 's', 'virtual', 'conditional', 'z', 'rebind'),
             ('65', 'logic', 's', 'nonvirtual', 'case', 'x', 'keep'),
             ('33', 'bit', 's', 'virtual', 'conditional', 'x', 'rebind'),
             ('32', 'logic', 's', 'virtual', 'if', 'known', 'rebind'),
             ('64', 'logic', 'u', 'nonvirtual', 'conditional', 'known', 'keep')),
    constraints=('全行が合法で、未対応による除外なし。二つの派生オブジェクトを使い、'
                 '直呼び・基底ハンドルのvirtual/非virtualを区別する。'
                 'ifと通常caseはX/Z条件を偽側へ送り、条件演算子は各ビットをマージする。'
                 '既知値の相と既知値またはX/Z入力の相を実行し、bit型でも条件はlogicに保つ。'
                 '返す値を取得してから同じreceiverのdataだけを更新し、早期return後の文は実行しない。'
                 '各呼出し後に両オブジェクトと保持した別名、幅を広げた結果、呼出し数を観測する。'
                 '外部更新、別ハンドルへの再束縛、guardだけの更新、反復呼出しと最終保持を確認する。'
                 '単一initial、時間を消費しないfunctionのみ。再帰・ref・null・並行性・GC・'
                 'プロパティの隠蔽・super・混合符号の演算は対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_classsel_' + '_'.join(row)


def actions(row: Row, phase: int):
    w = int(row[0]); stress = row[5] if phase and row[5] != 'known' else '0'
    return (
        ('init', (('a', 'new'), ('b', 'new'), ('old', 'a'),
                  ('a.data', ('10' * w)[:w] if not phase or row[5] == 'known' else row[5] * w),
                  ('b.data', ('01' * w)[:w]),
                  ('a.backup', ('01' * w)[:w]), ('b.backup', ('10' * w)[:w]),
                  ('a.guard', '1' * w), ('b.guard', '0' * w))),
        ('first', ('call', 'a', '0', 'ra')),
        ('other', ('call', 'b', '1', 'rb')),
        ('refresh', (('old.data', '1' * w),)),
        ('rebind', (('a', 'b'),) if row[6] == 'rebind' else ()),
        ('again', ('call', 'a', stress, 'ra')),
        ('alias', ('call', 'old', '1', 'ro')),
        ('guard', (('b.guard', '1' * w),)),
        ('probe', ('call', 'b', stress if phase and row[5] != 'known' else '1', 'rb')),
        ('last', ('call', 'old', '0', 'ro')),
        ('idle', ()),
    )


def select(condition: str, yes: str, no: str, control: str) -> str:
    if condition == '1': return yes
    if condition == '0' or control != 'conditional': return no
    return ''.join(a if a == b else 'x' for a, b in zip(yes, no))


def reference(row: Row) -> str:
    w, state, signed = int(row[0]), row[1], row[2] == 's'
    leaf = row[3] != 'nonvirtual'; tag = 2 if leaf else 1
    lines = []
    for phase in (0, 1):
        objects, handles, results = [], {}, {r: '0' * (w + 3) for r in ('ra', 'ro', 'rb')}
        selector = '0'
        for label, action in actions(row, phase):
            if action and action[0] == 'call':
                _, target, selector, result = action
                obj = objects[handles[target]]
                yes, no = (obj['backup'], obj['data']) if leaf else (obj['data'], obj['backup'])
                saved = assigned(select(selector, yes, no, row[4]), w, state)
                obj['leaf' if leaf else 'base'] += 1
                mask = format(tag & ((1 << w) - 1), f'0{w}b')
                obj['data'] = assigned(''.join(str(int(a) ^ int(b)) if a in '01' else 'x'
                                              for a, b in zip(obj['data'], mask)), w, state)
                results[result] = assigned(saved, w + 3, 'logic', signed)
            else:
                for target, value in action:
                    if value == 'new':
                        handles[target] = len(objects)
                        objects.append({'data': None, 'backup': None, 'guard': None,
                                        'base': 0, 'leaf': 0, 'dead': 0})
                    elif target in ('a', 'old', 'b'): handles[target] = handles[value]
                    else:
                        handle, field = target.split('.')
                        objects[handles[handle]][field] = assigned(value, w, state)
            lines.append(f'h p={phase} step={label} sel={selector} same={int(handles["a"] == handles["old"])} '
                         f'ab={int(handles["a"] == handles["b"])} ra={results["ra"]} ro={results["ro"]} rb={results["rb"]}')
            for handle in ('a', 'old', 'b'):
                obj = objects[handles[handle]]
                lines.append(f'v who={handle} data={obj["data"]} backup={obj["backup"]} guard={obj["guard"]} '
                             f'base={obj["base"]} leaf={obj["leaf"]} dead={obj["dead"]}')
    return '\n'.join(lines) + '\n'


def method(row: Row, leaf: bool) -> list[str]:
    virtual = 'virtual ' if not leaf and row[3] == 'virtual' else ''
    yes, no = ('backup', 'data') if leaf else ('data', 'backup')
    lines = [f'    {virtual}function automatic word_t choose(input logic sel);',
             '      word_t saved;', f'      this.{"leaf" if leaf else "base"}++;']
    def branch(value):
        return [f'        saved = this.{value};',
                f"        this.data = this.data ^ word_t'({2 if leaf else 1});", '        return saved;']
    if row[4] == 'if':
        lines += ['      if (sel) begin', *branch(yes), '      end else begin', *branch(no), '      end']
    elif row[4] == 'case':
        lines += ['      case (sel)', "        1'b1: begin", *branch(yes), '        end',
                  '        default: begin', *branch(no), '        end', '      endcase']
    else:
        lines += [f'      saved = sel ? this.{yes} : this.{no};',
                  f"      this.data = this.data ^ word_t'({2 if leaf else 1});", '      return saved;']
    lines += ['      this.dead++;', "      return '0;", '    endfunction']
    return lines


def source(row: Row) -> str:
    w = int(row[0]); signed = ' signed' if row[2] == 's' else ''
    lines = [f'typedef {row[1]}{signed} [{w-1}:0] word_t;', 'class base_t;',
             '    word_t data, backup, guard;', '    int base, leaf, dead;', *method(row, False),
             'endclass', 'class leaf_t extends base_t;', *method(row, True), 'endclass',
             f'module {case_name(row)};', '  leaf_t a, old, b;', '  base_t view;',
             '  logic sel;', f'  logic [{w+2}:0] ra, ro, rb;', '  initial begin']
    for phase in (0, 1):
        lines += ["    sel = 1'b0;", "    ra = '0; ro = '0; rb = '0;"]
        for label, action in actions(row, phase):
            if action and action[0] == 'call':
                _, handle, condition, result = action
                lines.append(f"    sel = 1'b{condition};")
                target = handle
                if row[3] != 'direct':
                    lines.append(f'    view = {handle};'); target = 'view'
                lines.append(f'    {result} = {target}.choose(sel);')
            else:
                for target, value in action:
                    lines.append(f'    {target} = {value if value in ("new", "a", "b") else literal(value)};')
                    if value == 'new':
                        lines += [f'    {target}.{field} = 0;' for field in ('base', 'leaf', 'dead')]
            lines += [f'    $display("h p={phase} step={label} sel=%b same=%0d ab=%0d ra=%b ro=%b rb=%b",',
                      '             sel, a == old, a == b, ra, ro, rb);']
            for handle in ('a', 'old', 'b'):
                lines += [f'    $display("v who={handle} data=%b backup=%b guard=%b base=%0d leaf=%0d dead=%0d",',
                          f'             {handle}.data, {handle}.backup, {handle}.guard,',
                          f'             {handle}.base, {handle}.leaf, {handle}.dead);']
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row),
                'Class dispatch and early typed returns preserve four-state selection and retained receiver identity',
                '8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1',
                'Two derived objects and a retained alias are observed after every call. Direct '
                'and virtual-base calls select the derived body; nonvirtual-base calls select '
                'the base body with reversed operands and a different update constant. Compare '
                'if, ordinary case and the conditional operator for known and X/Z selectors. '
                'Capture the typed value before updating only the receiver data, then return '
                'before unreachable effects. Observe both objects, call counters, untouched '
                'neighbors, unsigned wider result variables, external writes and handle '
                'rebinding. Every test includes a known-input phase. Calls occur in one '
                'initial with no timing, recursion, null handles or unspecified evaluation order.',
                source(row), reference(row), fourstate=row[5] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
