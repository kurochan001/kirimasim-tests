"""Bit vector functions count only the bits they name, inside immediate and deferred assertions."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_assertquery'
VERSION = 1
CHAPTER = 16

QUERIES = {'onehot': '$onehot(v)', 'onehot0': '$onehot0(v)', 'countones': '$countones(v) == 2',
           'known': '!$isunknown(v)', 'countzero': "$countbits(v, '0) == 2"}
# Each pattern as written, most significant bit first.
PATTERNS = {'one': '0100', 'zero': '0000', 'two': '0110', 'xone': '01x0', 'xall': 'xxxx', 'zone': '1z00'}
INITIAL, GLITCH = '1111', '0011'
KINDS = {'simple': 'assert', 'observed': 'assert #0', 'final': 'assert final'}


def legal(row: Row) -> bool:
    _, _, _, site, timing = row
    return not (site == 'initial' and timing == 'glitch')


MODEL = Model(
    'assertion_vector_query',
    (('query', tuple(QUERIES)), ('pattern', tuple(PATTERNS)), ('kind', tuple(KINDS)),
     ('site', ('initial', 'comb', 'clocked')), ('timing', ('settled', 'glitch'))),
    legal,
    groups=(('kind', 'site', 'timing'),),
    anchors=(('onehot', 'xone', 'observed', 'comb', 'glitch'), ('countzero', 'zone', 'final', 'comb', 'glitch'),
             ('known', 'xall', 'simple', 'comb', 'glitch'), ('onehot0', 'xall', 'final', 'clocked', 'glitch'),
             ('countones', 'two', 'observed', 'initial', 'settled'),
             ('onehot', 'zone', 'simple', 'clocked', 'settled')),
    constraints=('vの初期値は1111、途中の値は0011で、どちらも観測する値と重ならない。'
                 '$onehot・$onehot0・$countonesは1のビットだけを、$countbitsは指定した値のビットだけを数え、'
                 'xとzのビットは数えない。$isunknownはxかzのビットがあれば1になる。'
                 'always_combは時刻0に一度評価する。途中の値で再評価すると、遅延アサーションの報告は取り消され、'
                 '即時アサーションの報告は残る。クロックの立上りと同時のNBAは、その立上りで評価する値を変えない。'
                 'initialでの途中の値は評価の前に上書きされるので除外する。'
                 '並行アサーションはkirimasimの実装を待つので、このモデルに含めない。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_assertquery_' + '_'.join(row)


def holds(query: str, bits: str) -> bool:
    ones, zeros = bits.count('1'), bits.count('0')
    return {'onehot': ones == 1, 'onehot0': ones <= 1, 'countones': ones == 2,
            'known': 'x' not in bits and 'z' not in bits, 'countzero': zeros == 2}[query]


def evaluations(row: Row) -> list[tuple[int, str]]:
    """Each report as (time, the value the assertion read)."""
    _, pattern, kind, site, timing = row
    value = PATTERNS[pattern]
    if site == 'initial': return [(1, value)]
    if site == 'clocked': return [(2, GLITCH if timing == 'glitch' else value)]
    reports = [(0, INITIAL)]
    if timing == 'glitch' and kind == 'simple': reports.append((1, GLITCH))
    return reports + [(1, value)]


def reference(row: Row) -> str:
    query = row[0]
    return ''.join(f'{time} {"pass" if holds(query, bits) else "fail"}\n' for time, bits in evaluations(row))


def source(row: Row) -> str:
    query, pattern, kind, site, timing = row
    value = f"4'b{PATTERNS[pattern]}"
    check = [f'a: {KINDS[kind]} ({QUERIES[query]})', '  $display("%0d pass", $time);', 'else',
             '  $display("%0d fail", $time);']
    lines = [f'module {case_name(row)};', f"  logic [3:0] v = 4'b{INITIAL};"]
    if site == 'clocked': lines.append("  bit clk = 1'b0;")
    if site == 'initial':
        lines += ['  initial begin', '    #1;', f'    v = {value};', *['    ' + line for line in check], '  end']
    else:
        lines += [f'  {"always_comb" if site == "comb" else "always @(posedge clk)"} begin',
                  *['    ' + line for line in check], '  end']
        steps = ['#1;']
        if site == 'comb':
            steps += [f"v = 4'b{GLITCH};", '#0;', f'v = {value};'] if timing == 'glitch' else [f'v = {value};']
        elif timing == 'glitch':
            steps += [f"v = 4'b{GLITCH};", '#1;', "clk = 1'b1;", f'v <= {value};']
        else:
            steps += [f'v = {value};', '#1;', "clk = 1'b1;"]
        lines += ['  initial begin', *['    ' + line for line in steps], '  end']
    lines += ['  initial #5 $finish;', 'endmodule']
    return '\n'.join(lines)


KIND_CLAUSE = {'simple': '16.3', 'observed': '16.4 16.4.2', 'final': '16.4 16.4.2'}
SITE_CLAUSE = {'initial': '9.2.1', 'comb': '9.2.2.2', 'clocked': '9.4.2'}


def make_case(row: Row) -> Case:
    query, pattern, kind, site, timing = row
    glitch = ' 4.4.2.3' if timing == 'glitch' else ''
    return Case(case_name(row), 'Bit vector functions count only the bits they name, inside immediate and deferred assertions',
                f'{KIND_CLAUSE[kind]} 20.9 {SITE_CLAUSE[site]}{glitch}',
                '$onehot, $onehot0 and $countones count the bits that are 1, $countbits the bits equal to a '
                'given value, and $isunknown finds an x or z bit, so an x or z bit is never counted as 1 or 0. '
                'An immediate assertion reports each evaluation. A deferred assertion reports in the observed '
                'or postponed region, and an always_comb that runs again for a later value in the same slot '
                'flushes the earlier report. A nonblocking write at a rising clock does not change the value '
                'that the clocked procedure reads at that edge.',
                source(row), reference(row), fourstate=any(c in 'xz' for c in PATTERNS[pattern]),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
