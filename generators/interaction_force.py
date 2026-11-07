"""A force overrides every other assignment until release, and a release restores by kind."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_force'
VERSION = 1
CHAPTER = 10


def legal(row: Row) -> bool:
    return True


MODEL = Model(
    'force_release_visibility',
    (('target', ('var', 'cont', 'pca', 'net', 'part', 'wor', 'vcat', 'ncat')),
     ('rhs', ('const', 'unknown', 'expr')),
     ('during', ('hold', 'driver', 'source')),
     ('write', ('blocking', 'nba')),
     ('observer', ('display', 'strobe', 'monitor', 'event', 'query')),
     ('site', ('direct', 'task', 'hier'))),
    legal,
    groups=(('target', 'rhs', 'during'),),
    anchors=(('var', 'const', 'driver', 'blocking', 'display', 'direct'),
             ('net', 'expr', 'source', 'nba', 'display', 'direct'),
             ('cont', 'expr', 'driver', 'blocking', 'monitor', 'task'),
             ('pca', 'const', 'driver', 'nba', 'strobe', 'direct'),
             ('part', 'unknown', 'driver', 'blocking', 'event', 'hier'),
             ('wor', 'const', 'driver', 'blocking', 'query', 'direct'),
             ('vcat', 'expr', 'source', 'blocking', 'display', 'hier'),
             ('ncat', 'unknown', 'hold', 'nba', 'monitor', 'task')),
    constraints=('左辺は変数、連続代入で駆動される変数、assignが有効な変数、網、網の部分選択、複数ドライバのwor、変数の連結、網の連結に限る。'
                 '変数のビット選択・部分選択は規格で禁じられているので使わない。'
                 'forceの間にドライバと右辺の信号を変え、releaseの後にもドライバを変える。'
                 '$monitorが最初の表示を行うかは規格が明示しないので、開始と同じ時刻に値を変えて必ず表示が出る形にする。'
                 '@の観測は時刻0の競合を避けて時刻1以降だけ表示する。'
                 'release直後の読出しは、規格が即時と定める網と、変わらないと定める変数に限る。'
                 '読出しは書込みと別の時刻に行う。シミュレータの未対応による除外はしない。',),
)

PHASE = 2
FORCED = {'const': '1010', 'unknown': '1x0z'}
START, SECOND, THIRD, OTHER = '0001', '0011', '1100', '0010'
SOURCE_START, SOURCE_NEXT = '1001', '0110'
PART_START, PART_SECOND, PART_THIRD = '00010001', '00110011', '11001100'
HOLDS = ('var', 'vcat')          # a release leaves the value until the next assignment
IMMEDIATE = ('var', 'vcat', 'net', 'part', 'wor', 'ncat')


def case_name(row: Row) -> str: return 'test_gen_cross_force_' + '_'.join(row)


def forced_value(row: Row, source_value: str) -> str:
    return source_value if row[1] == 'expr' else FORCED[row[1]]


def driven(target: str, phase_value: str) -> str:
    """What the drivers of the target give for the driver value of a phase."""
    if target == 'wor':
        return ''.join('1' if a == '1' or b == '1' else '0' for a, b in zip(phase_value, OTHER))
    return phase_value


def with_part(driver: str, forced: str) -> str:
    return driver[:2] + forced + driver[6:]


def history(row: Row) -> list[tuple[int, str, str]]:
    """(time, label, value) of each phase: the value at the end of that time step."""
    target, _, during, _, _, _ = row
    part = target == 'part'
    first = PART_START if part else START
    second = PART_SECOND if part else SECOND
    third = PART_THIRD if part else THIRD
    source_value = SOURCE_START

    def forced_shape(driver, value): return with_part(driver, value) if part else value
    rows = [(0, 'start', driven(target, first))]
    driver = first
    value = forced_value(row, source_value)
    rows.append((PHASE, 'force', forced_shape(driver, value)))
    if during == 'driver': driver = second
    if during == 'source': source_value = SOURCE_NEXT
    value = forced_value(row, source_value)
    rows.append((2 * PHASE, 'during', forced_shape(driver, value)))
    released = value if target in HOLDS else driven(target, driver)
    rows.append((3 * PHASE, 'release', released))
    rows.append((4 * PHASE, 'after', driven(target, third) if target not in HOLDS else THIRD))
    if target == 'pca':
        rows.append((5 * PHASE, 'deassign', THIRD))
        rows.append((6 * PHASE, 'write', '0101'))
    return rows


def reference(row: Row) -> str:
    target, _, _, _, observer, _ = row
    phases = history(row)
    lines = []
    last = None
    for time, label, value in phases:
        if observer == 'display':
            if label == 'release' and target in IMMEDIATE: lines.append(f'{time} r {value}')
            lines.append(f'{time + 1} {value}')
        elif observer == 'strobe': lines.append(f'{time} {value}')
        elif observer == 'query':
            lines.append(f'{time + 1} {value.count("1")} {int(any(c in value for c in "xz"))} {len(value)}')
        elif value != last and (observer == 'monitor' or time > 0): lines.append(f'{time} {value}')
        last = value
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    target, rhs, during, write, observer, site = row
    name = case_name(row)
    prefix = 'u.' if site == 'hier' else ''
    p = prefix
    obs = {'vcat': f'{{{p}t1, {p}t0}}', 'ncat': f'{{{p}t1, {p}t0}}'}.get(target, f'{p}t')
    left = {'part': f'{p}t[5:2]'}.get(target, obs)
    drive = 't' if target == 'var' else '{t1, t0}' if target == 'vcat' else 'd'
    drive = p + drive if not drive.startswith('{') else obs
    assign = '<=' if write == 'nba' else '='
    width = 8 if target == 'part' else 4
    decl = {'var': ['logic [3:0] t;'],
            'cont': ['logic [3:0] d;', 'logic [3:0] t;', 'assign t = d;'],
            'pca': ['logic [3:0] d;', 'logic [3:0] t;'],
            'net': ['logic [3:0] d;', 'wire [3:0] t;', 'assign t = d;'],
            'part': ['logic [7:0] d;', 'wire [7:0] t;', 'assign t = d;'],
            'wor': ['logic [3:0] d, e;', 'wor [3:0] t;', 'assign t = d;', 'assign t = e;'],
            'vcat': ['logic [1:0] t1, t0;'],
            'ncat': ['logic [3:0] d;', 'wire [1:0] t1, t0;', 'assign {t1, t0} = d;']}[target]
    decl = ['logic [3:0] src;', *decl]
    value = {'const': "4'b1010", 'unknown': "4'b1x0z", 'expr': f'{p}src'}[rhs]
    force = f'force {left} = {value};'
    release = f'release {left};'
    first = PART_START if target == 'part' else START
    second = PART_SECOND if target == 'part' else SECOND
    third = PART_THIRD if target == 'part' else THIRD
    show = {'query': f'$display("%0d %0d %0d %0d", $time, $countones({obs}), $isunknown({obs}), $bits({obs}));'}.get(
        observer, f'$display("%0d %b", $time, {obs});')
    body = [f"{p}src = 4'b{SOURCE_START};"]
    if target == 'wor': body.append(f"{p}e = 4'b{OTHER};")
    if target == 'pca': body.append(f'assign {p}t = {p}d;')
    if observer == 'monitor': body.insert(0, f'$monitor("%0d %b", $time, {obs});')

    def phase(statements, immediate=False):
        out = list(statements)
        if observer == 'strobe': out.append(f'$strobe("%0d %b", $time, {obs});')
        if immediate and observer == 'display': out.append(f'$display("%0d r %b", $time, {obs});')
        return out + ['#1;', *([show] if observer in ('display', 'query') else []), '#1;']

    drive_first = f"{drive} = {width}'b{first};"
    body += phase([drive_first])
    use_tasks = site == 'task'
    body += phase(['put_force;' if use_tasks else force])
    during_action = {'hold': [], 'driver': [f"{drive} {assign} {width}'b{second};"],
                     'source': [f"{p}src = 4'b{SOURCE_NEXT};"]}[during]
    body += phase(during_action)
    body += phase(['put_release;' if use_tasks else release], target in IMMEDIATE)
    body += phase([f"{drive} {assign} {width}'b{third};"])
    if target == 'pca':
        body += phase([f'deassign {p}t;'])
        body += phase([f"{p}t = 4'b0101;"])
    out: list[str] = []
    if site == 'hier':
        out += ['module force_inner;', *['  ' + line for line in decl], 'endmodule', f'module {name};',
                '  force_inner u ();']
    else:
        out += [f'module {name};', *['  ' + line for line in decl]]
    if observer == 'event':
        out.append(f'  always @({obs}) if ($time > 0) $display("%0d %b", $time, {obs});')
    if use_tasks:
        out += ['  task automatic put_force();', f'    {force}', '  endtask',
                '  task automatic put_release();', f'    {release}', '  endtask']
    out += ['  initial begin', *['    ' + line for line in body], '    $finish;', '  end', 'endmodule']
    return '\n'.join(out)


TARGET_CLAUSE = {'var': '6.8', 'cont': '10.3.2', 'pca': '10.6.1', 'net': '6.7', 'part': '11.5.1', 'wor': '6.6.3',
                 'vcat': '11.4.12', 'ncat': '11.4.12'}
OBSERVER_CLAUSE = {'display': '21.2.1', 'strobe': '21.2.2', 'monitor': '21.2.3', 'event': '9.4.2', 'query': '20.9'}


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'A force overrides every other assignment until release, and a release restores by kind',
                f'10.6.2 10.6.1 {TARGET_CLAUSE[row[0]]} {OBSERVER_CLAUSE[row[4]]} 4.4',
                'A force overrides procedural, continuous and assign procedural continuous assignments, '
                'and all drivers of a net, and a forced expression keeps following its operands. On '
                'release a net takes the value of its drivers at once, a variable with a continuous or '
                'assign procedural continuous assignment takes it back through a new evaluation, and any '
                'other variable keeps its value until the next assignment. Every phase is read in its own '
                'time step, and a part-select of a net leaves the other bits to the driver.',
                source(row), reference(row), fourstate=row[1] == 'unknown',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
