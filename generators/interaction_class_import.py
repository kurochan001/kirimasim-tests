"""Method-local package lookup, typed results and retained object aliases."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = 'interaction_class_import'
VERSION = 1
CHAPTER = 26
MODEL = Model(
    'class_method_package_lookup',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('signed', ('u', 's')),
     ('relation', ('narrow', 'same', 'wide')), ('value', ('known', 'x', 'z')),
     ('access', ('wildcard', 'explicit', 'qualified', 'enclosing')),
     ('routine', ('function', 'task')), ('alias', ('keep', 'replace'))),
    lambda row: not (row[0] == '1' and row[3] == 'narrow'),
    groups=(('width', 'signed', 'relation'), ('state', 'value', 'access'),
            ('access', 'routine', 'alias'), ('access', 'relation', 'signed'),
            ('alias', 'routine', 'value')),
    anchors=(('1', 'bit', 'u', 'same', 'known', 'wildcard', 'function', 'keep'),
             ('129', 'logic', 's', 'narrow', 'z', 'explicit', 'task', 'replace'),
             ('65', 'logic', 'u', 'wide', 'x', 'qualified', 'function', 'replace'),
             ('33', 'bit', 's', 'wide', 'z', 'enclosing', 'task', 'keep'),
             ('32', 'logic', 's', 'narrow', 'known', 'wildcard', 'task', 'replace'),
             ('64', 'logic', 'u', 'same', 'known', 'explicit', 'function', 'keep')),
    constraints=('package幅は戻り値の幅より一つ狭い・同じ・一つ広い。幅ゼロだけを除外する。'
                 'メソッド内だけに明示またはwildcard importを置き、クラス直下には置かない。'
                 'qualifiedはpackageを直接参照し、enclosingは内側importなしでクラスの同名プロパティを読む。'
                 '外側moduleのwildcard import、別メソッド、別オブジェクトの参照先も観測する。'
                 '単一initialで別名取得、プロパティ更新、package更新、ハンドル再束縛、別名更新、'
                 '外側packageと独立オブジェクトの後続更新、既知値への回復を順に行う。'
                 'bit/logicと符号は入出力で同じ。継承、static、浅いコピーnew handle、null、'
                 '並行呼出し、時間制御、GC、混合符号と直接のclass内importは対象外。'
                 'シミュレータの未対応による除外はしない。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_classimp_' + '_'.join(row)


def package_width(row: Row) -> int:
    return int(row[0]) + {'narrow': -1, 'same': 0, 'wide': 1}[row[3]]


def assigned(bits: str, width: int, state: str, signed: bool = False) -> str:
    """Assignment conversion after evaluating a typed self-determined source."""
    fill = bits[0] if signed else '0'
    bits = (fill * max(0, width - len(bits)) + bits)[-width:]
    return bits.translate(str.maketrans('xz', '00')) if state == 'bit' else bits


def updates(row: Row) -> list[tuple[str, tuple[tuple[str, str], ...]]]:
    w, p = int(row[0]), package_width(row)
    unknown = row[4]
    pattern = ('10' * w)[:w] if unknown == 'known' else unknown * w
    package = '0' * p if unknown == 'known' else unknown * p
    rebind = (('a', 'new'),) if row[7] == 'replace' else ()
    return [
        ('init', (('a', 'new'), ('b', 'new'), ('a.data', '0' * w),
                  ('b.data', ('01' * w)[:w]), ('old', 'a'),
                  ('source_pkg::data', '1' + '0' * (p - 1)),
                  ('outer_pkg::data', '0' * (p - 1) + '1'))),
        ('property', (('a.data', pattern),)),
        ('package', (('source_pkg::data', package),)),
        ('rebind', rebind + (('a.data', '1' * w),)),
        ('alias', (('old.data', '0' * (w - 1) + '1'),)),
        ('outer', (('outer_pkg::data', '0' * p),)),
        ('guard', (('b.data', ('10' * w)[:w]),)),
        ('recover', (('source_pkg::data', '0' * (p - 1) + '1'),
                     ('a.data', '0' * w))),
    ]


def reference(row: Row) -> str:
    w, p, state = int(row[0]), package_width(row), row[1]
    objects, handles, packages, lines = [], {}, {}, []
    for tag, writes in updates(row):
        for name, value in writes:
            if value == 'new':
                handles[name] = len(objects)
                objects.append(None)
            elif name in ('a', 'b', 'old'):
                handles[name] = handles[value]
            elif '::' in name:
                packages[name] = assigned(value, p, state)
            else:
                objects[handles[name.split('.')[0]]] = assigned(value, w, state)
        members = [objects[handles[h]] for h in ('a', 'old', 'b')]
        inner, outer = packages['source_pkg::data'], packages['outer_pkg::data']
        reads = members if row[5] == 'enclosing' else [assigned(inner, w, state, row[2] == 's')] * 3
        lines.append(f'phase={tag} outer={outer} inner={inner} '
                     f'a={members[0]} old={members[1]} b={members[2]} '
                     f'read_a={reads[0]} read_old={reads[1]} read_b={reads[2]} '
                     f'same={int(handles["a"] == handles["old"])}')
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    w, p, state, sign = int(row[0]), package_width(row), row[1], ' signed' if row[2] == 's' else ''
    lines = []
    for package in ('source_pkg', 'outer_pkg'):
        lines += [f'package {package};', f'  typedef {state}{sign} [{p-1}:0] source_t;',
                  '  source_t data;', 'endpackage']
    lines += [f'module {case_name(row)};', '  import outer_pkg::*;',
              f'  typedef {state}{sign} [{w-1}:0] word_t;', '  class box_t;',
              '    word_t data;']
    kind = row[6]
    lines += ['    function automatic word_t sample();' if kind == 'function' else
              '    task automatic sample(output word_t result);']
    if row[5] in ('wildcard', 'explicit'):
        lines += ['      import source_pkg::' + ('*' if row[5] == 'wildcard' else 'data') + ';']
    expression = 'source_pkg::data' if row[5] == 'qualified' else 'data'
    lines += [('      return ' if kind == 'function' else '      result = ') + expression + ';',
              '    end' + kind, '    function automatic word_t local_read();',
              '      return data;', '    endfunction', '  endclass',
              '  box_t a, old, b;', '  word_t ra, rr, rb;', '  initial begin']
    for tag, writes in updates(row):
        for name, value in writes:
            rhs = value if value in ('new', 'a') else literal(value)
            lines += [f'    {name} = {rhs};']
        for handle, result in (('a', 'ra'), ('old', 'rr'), ('b', 'rb')):
            lines += [f'    {result} = {handle}.sample();' if kind == 'function' else
                      f'    {handle}.sample({result});']
        lines += [f'    $write("phase={tag} outer=%b inner=%b a=%b old=%b b=%b ",',
                  '           data, source_pkg::data, a.local_read(), old.local_read(), b.local_read());',
                  '    $display("read_a=%b read_old=%b read_b=%b same=%0d", ra, rr, rb, a == old);']
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row),
                'Method-local package lookup preserves lexical scope, typed results and object aliases',
                '26.3 8.6 8.7 8.12 6.11 10.8 11.8.2',
                'Two packages and a class property share the name data. A method-local explicit or '
                'wildcard import hides the property only in that method; qualification selects the '
                'package directly, while a method without an inner import uses its own property. '
                'The module retains its outer-package import. Compare typed function/task results, '
                'a retained alias, a rebound handle and an independent object at every update. '
                'Package updates must affect all imported reads, and property or handle updates '
                'must preserve the other object and packages. Check signed extension/truncation, '
                'two-state conversion, X/Z and recovery. No concurrent calls or timing assumptions.',
                source(row), reference(row), fourstate=row[4] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
