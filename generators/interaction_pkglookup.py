"""A name in a procedural loop binds to a package, a declaration or another import by the search of 26.3."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_pkglookup'
VERSION = 1
CHAPTER = 26

# The value each candidate gives, for a variable n and for a function f().
VALUE = {'var': {'p': 3, 'q': 4, 'outer': 5, 'inner': 6, 'later': 8},
         'call': {'p': 30, 'q': 40, 'outer': 50, 'later': 70}}
SITES = ('module_wild', 'block_wild', 'explicit', 'scoped')
COMPETITORS = ('none', 'outer_decl', 'inner_decl', 'inner_import', 'later_decl', 'later_import')


def bound(row: Row):
    """The candidate the reference binds to, or None for an illegal description."""
    site, competitor, ref, _ = row
    if competitor == 'inner_decl' and ref == 'call': return None  # a block cannot declare a function
    if site == 'scoped': return 'p'
    table = {
        'module_wild': {'none': 'p', 'outer_decl': 'outer', 'inner_decl': 'inner', 'inner_import': 'q',
                        # A variable reference makes p::n locally visible in the module, so a later n is illegal;
                        # a function call searches the whole module first and finds the later f.
                        'later_decl': None if ref == 'var' else 'later', 'later_import': 'p'},
        # Two wildcard imports in the block that both supply the name make the reference illegal.
        'block_wild': {'none': 'p', 'outer_decl': 'p', 'inner_decl': 'inner', 'inner_import': None,
                       'later_decl': 'p', 'later_import': 'p'},
        # An explicit import conflicts with a declaration of the same name in the same scope.
        'explicit': {'none': 'p', 'outer_decl': None, 'inner_decl': 'inner', 'inner_import': 'q',
                     'later_decl': None, 'later_import': 'p'}}
    return table[site][competitor]


def legal(row: Row) -> bool: return bound(row) is not None


MODEL = Model(
    'package_name_lookup',
    (('site', SITES), ('competitor', COMPETITORS), ('ref', ('var', 'call')), ('loop', ('for', 'while', 'repeat', 'do'))),
    legal,
    groups=(('site', 'competitor', 'ref'),),
    anchors=(('block_wild', 'outer_decl', 'var', 'for'), ('module_wild', 'later_decl', 'call', 'repeat'),
             ('explicit', 'inner_import', 'var', 'while'), ('block_wild', 'later_decl', 'call', 'do'),
             ('module_wild', 'inner_import', 'call', 'for'), ('block_wild', 'inner_decl', 'var', 'repeat'),
             ('explicit', 'later_import', 'call', 'while')),
    constraints=('名前はまず参照のあるスコープで、宣言と明示のimportを探し、なければその点より前のwildcard importを探す。'
                 '見つからなければ外側のスコープで同じことを繰り返す。関数の呼出しは、スコープの終わりまでの宣言を探す。'
                 'ブロックのwildcard importは外側の宣言より先に見つかり、後のwildcard importは参照より前に効かない。'
                 '明示のimportと同じスコープの同名の宣言、参照で見えるようになったimportの後の同名の宣言、'
                 '同じスコープで二つのwildcard importが同じ名前を与える参照は不正なので除く。'
                 'ブロックの変数は初期化子を付けずに宣言し、文で値を入れる。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_pkglookup_' + '_'.join(row)


def reference(row: Row) -> str:
    value = VALUE[row[2]][bound(row)]
    return f'value={value} count={value}\n'


def source(row: Row) -> str:
    site, competitor, ref, loop = row
    var = ref == 'var'
    name = 'n' if var else 'f'
    use = {'scoped': 'lk_p::n' if var else 'lk_p::f()'}.get(site, 'n' if var else 'f()')

    def declared(value):
        return f'  int n = {value};' if var else f'  function automatic int f(); return {value}; endfunction'
    lines = ['package lk_p;', '  int n = 3;', '  function automatic int f(); return 30; endfunction', 'endpackage',
             'package lk_q;', '  int n = 4;', '  function automatic int f(); return 40; endfunction', 'endpackage',
             f'module {case_name(row)};']
    if site == 'module_wild': lines.append('  import lk_p::*;')
    if site == 'explicit': lines.append(f'  import lk_p::{name};')
    if competitor == 'outer_decl': lines.append(declared(VALUE[ref]['outer']))
    lines.append('  initial begin')
    if site == 'block_wild': lines.append('    import lk_p::*;')
    if competitor == 'inner_import': lines.append('    import lk_q::*;')
    if competitor == 'inner_decl': lines.append('    int n;')
    lines.append('    int count;')
    if competitor == 'inner_decl': lines.append(f"    n = {VALUE['var']['inner']};")
    lines.append('    count = 0;')
    lines.append('    ' + {'for': f'for (int i = 0; i < {use}; i++) count++;', 'while': f'while (count < {use}) count++;',
                         'repeat': f'repeat ({use}) count++;', 'do': f'do count++; while (count < {use});'}[loop])
    lines += [f'    $display("value=%0d count=%0d", {use}, count);', '  end']
    if competitor == 'later_decl': lines.append(declared(VALUE[ref]['later']))
    if competitor == 'later_import': lines.append('  import lk_q::*;')
    lines.append('endmodule')
    return '\n'.join(lines)


LOOP_CLAUSE = {'for': '12.7.1', 'while': '12.7.4', 'repeat': '12.7.2', 'do': '12.7.5'}


def make_case(row: Row) -> Case:
    _, _, ref, loop = row
    clauses = f'26.3 {LOOP_CLAUSE[loop]} {"13.4.1 23.8.1" if ref == "call" else "6.21"} 26.2'.split()
    return Case(case_name(row), 'A name in a loop binds by the package search order of 26.3',
                ' '.join(dict.fromkeys(clauses)),
                'A variable n or a function f() bounds a for, while, repeat or do-while loop. The package lk_p is '
                'imported by a wildcard in the module or in the procedure block, imported explicitly, or named with '
                'lk_p::. A declaration before or after the procedure, a block variable, or a wildcard import of '
                'lk_q in the block or after the procedure competes for the name. The search looks in the scope of '
                'the reference first, at declarations and explicit imports and then at earlier wildcard imports, '
                'and then outward; a function call also sees declarations later in the scope.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
