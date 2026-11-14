"""Program instances placed in the hierarchy in different ways (nested, instantiated in the top or in a child, or implicit at the top level), with parameters by default, override or defparam, write a shared design variable through a hierarchical name or the name of the parent, may read a peer program, and end the run when the last one ends."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_progmod'
VERSION = 1
CHAPTER = 24

FORMS = ('nested', 'nested_inst', 'top_inst', 'child_inst', 'implicit_top')
COUNTS = ('one', 'two')
ACCESSES = ('absolute', 'upward')
PARAMS = ('default', 'override', 'defparam')
PEERS = ('none', 'read')
DECOYS = ('none', 'ignored')

IMPLICIT = ('nested', 'implicit_top')
NESTED = ('nested', 'nested_inst')
SENTINEL_TIME = 50
DECOY_TIME = 1
# (D, K) of the first and the second instance.
VALUES = {'default': ((3, 1), (3, 1)), 'override': ((4, 2), (6, 5)), 'defparam': ((5, 3), (7, 6))}
BASES = (10, 20)    # the input port of an explicit instance


def legal(row: Row) -> bool:
    form, count, access, param, peer, _ = row
    if form in IMPLICIT and (count == 'two' or param == 'override'):
        return False    # one implicit instance, no ports, no instance parameter assignment (24.3)
    if form == 'implicit_top' and param == 'defparam':
        return False    # a defparam would have to name another top-level instance
    if access == 'upward' and form not in NESTED:
        return False    # 23.4: only a nested program sees the names of its parent
    if count == 'two' and param == 'default':
        return False    # equal delays would make the two writes race (4.7)
    return peer == 'none' or count == 'two'


MODEL = Model(
    'program_hierarchy_instances',
    (('form', FORMS), ('count', COUNTS), ('access', ACCESSES), ('param', PARAMS), ('peer', PEERS),
     ('decoy', DECOYS)),
    legal,
    groups=(('form', 'access', 'param'), ('form', 'count', 'peer'), ('form', 'param', 'decoy')),
    anchors=(('nested', 'one', 'upward', 'defparam', 'none', 'ignored'),
             ('implicit_top', 'one', 'absolute', 'default', 'none', 'ignored'),
             ('child_inst', 'two', 'absolute', 'defparam', 'read', 'none'),
             ('nested_inst', 'two', 'upward', 'override', 'read', 'ignored'),
             ('top_inst', 'two', 'absolute', 'override', 'read', 'none'),
             ('top_inst', 'one', 'absolute', 'default', 'none', 'ignored')),
    constraints=('programのインスタンスは、トップに入れ子で宣言した暗黙のインスタンス・入れ子で宣言して'
                 'トップで明示したインスタンス・コンパイル単位で宣言してトップか子のmoduleで明示した'
                 'インスタンス・明示しないトップレベルの暗黙のインスタンスのいずれかで、1個か2個置く。'
                 '暗黙のインスタンスは1個で、ポートとインスタンスのパラメータ代入を持たない。'
                 'トップレベルの暗黙のインスタンスへのdefparamは除く。'
                 '名前だけで親の変数を読むのは入れ子のprogramだけ（23.4）。'
                 'ref ポートはkirimasimが未実装なので、実装後に経路へ加える。'
                 '2個のときは遅延が等しいと同じ時刻の書込みが競合するので、既定のパラメータの組を除く。'
                 '相手のprogramの変数を読むのは2個のときだけ。'
                 'ポートを持つ入れ子のprogramを明示しない（無視される）組と、置かない組を交差する。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_progmod_' + '_'.join(row)


def instances(row: Row) -> list[tuple[str, int, int, int]]:
    """(path below the top, D, K, base) of each program instance that runs."""
    form, count, _, param, _, _ = row
    if form == 'nested':
        d, k = VALUES[param][0]
        return [('prog', d, k, 0)]
    if form == 'implicit_top':
        d, k = VALUES[param][0]
        return [('$worker', d, k, 0)]
    prefix = 'c.' if form == 'child_inst' else ''
    n = 1 if count == 'one' else 2
    return [(f'{prefix}p{i + 1}', *VALUES[param][i], BASES[i]) for i in range(n)]


def reference(row: Row) -> str:
    _, _, _, _, peer, _ = row
    name = case_name(row)
    runs = instances(row)
    lines = []
    first = runs[0][2] + runs[0][3]
    for path, d, k, base in sorted(runs, key=lambda r: r[1]):
        scope = 'worker' if path == '$worker' else f'{name}.{path}'
        line = f'{scope} t={d} got={k + base}'
        if peer == 'read':
            line += f' seen={first}'
        lines.append(line)
    end = max(d for _, d, _, _ in runs)
    lines.append(f'end t={end} total={sum(k + base for _, _, k, base in runs)}')
    return '\n'.join(lines) + '\n'


def program_lines(row: Row, name: str, decl: str) -> list[str]:
    form, _, access, _, peer, _ = row
    ports = []
    if form not in IMPLICIT:
        ports.append('input var int base')
    header = f'program {decl} #(parameter int D = 3, parameter int K = 1)'
    header += f'({", ".join(ports)});' if ports else ';'
    target = {'upward': 'total', 'absolute': f'{name}.total'}[access]
    add = 'K + base' if form not in IMPLICIT else 'K'
    lines = [header, '  int local_count = 0;', '  initial begin', '    #D;', f'    {target} += {add};',
             f'    local_count = {add};']
    if peer == 'read':
        first = f'{name}.' + ('c.p1' if form == 'child_inst' else 'p1')
        lines += [f'    $display("%m t=%0t got=%0d seen=%0d", $time, {add},', f'      {first}.local_count);']
    else:
        lines += [f'    $display("%m t=%0t got=%0d", $time, {add});']
    lines += ['  end', 'endprogram']
    return lines


def instance_lines(row: Row, kind: str) -> list[str]:
    form, count, access, param, _, _ = row
    n = 1 if count == 'one' else 2
    lines = []
    for i in range(n):
        d, k = VALUES[param][i]
        override = f' #(.D({d}), .K({k}))' if param == 'override' else ''
        lines.append(f'{kind}{override} p{i + 1}(.base({BASES[i]}));')
    return lines


def defparam_lines(row: Row) -> list[str]:
    form, count, _, param, _, _ = row
    if param != 'defparam':
        return []
    if form == 'nested':
        d, k = VALUES[param][0]
        return [f'defparam prog.D = {d}, prog.K = {k};']
    prefix = 'c.' if form == 'child_inst' else ''
    n = 1 if count == 'one' else 2
    return [f'defparam {prefix}p{i + 1}.D = {VALUES[param][i][0]}, {prefix}p{i + 1}.K = {VALUES[param][i][1]};'
            for i in range(n)]


def source(row: Row) -> str:
    form, count, access, param, peer, decoy = row
    name = case_name(row)
    lines = ['`timescale 1ns/1ns']
    if form in ('top_inst', 'child_inst', 'implicit_top'):
        lines += program_lines(row, name, 'worker') + ['']
    if form == 'child_inst':
        lines += ['module holder;', *['  ' + l for l in instance_lines(row, 'worker')], 'endmodule', '']
    lines += [f'module {name};', '  int total = 0;',
              f'  initial #{SENTINEL_TIME} $display("sentinel t=%0t", $time);']
    if form in NESTED:
        lines += ['  ' + l for l in program_lines(row, name, 'prog')]
    if form == 'nested_inst':
        lines += ['  ' + l for l in instance_lines(row, 'prog')]
    elif form == 'top_inst':
        lines += ['  ' + l for l in instance_lines(row, 'worker')]
    elif form == 'child_inst':
        lines += ['  holder c();']
    lines += ['  ' + l for l in defparam_lines(row)]
    if decoy == 'ignored':
        lines += ['  program unused(input var int base);', '    initial begin', f'      #{DECOY_TIME};',
                  f'      {name}.total += 100;', '      $display("ignored program ran");', '    end',
                  '  endprogram']
    lines += ['  final $display("end t=%0t total=%0d", $time, total);', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    form, count, access, param, peer, decoy = row
    parts = ['24.3', '23.3']
    if form in NESTED or decoy == 'ignored': parts.append('23.4')
    if access == 'absolute' or peer == 'read': parts.append('23.6')
    if access == 'upward': parts.append('23.9')
    if param == 'override': parts.append('23.10.2.2')
    if param == 'defparam': parts.append('23.10.1')
    parts.append('21.2.1.5')
    return Case(case_name(row),
                'Program instances in the hierarchy write a shared variable and end the run with the last one',
                ' '.join(dict.fromkeys(parts)),
                'Each program instance waits for its parameter D, adds K and its input base to the variable total '
                'of the top module, through a hierarchical name from the top or the name of the parent seen '
                'from a nested program, and prints its hierarchical name with %m. The instance is a '
                'nested program without ports (implicitly instantiated once), a nested program with ports '
                'instantiated in the top, a program declared in the compilation unit and instantiated in the top '
                'or in a child module, or a top-level program that is not instantiated and so is instantiated '
                'once at the top level (24.3). Parameters keep their defaults, or are set by the instance or by '
                'defparam. With two instances, each may read the local variable of the first through a '
                'hierarchical name from one program to another, which 24.3 allows. A nested program with ports '
                'that is never instantiated does not run (23.4). The run ends when the last program ends, by the '
                'implicit $finish of 24.3, so the sentinel at 50 never prints, and the final procedure shows the '
                'end time and the total. The delays of two instances differ, so no two writes share a time.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
