"""A process reaches another instance through a hierarchical name to disable, trigger, write or call there."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_hierproc'
VERSION = 1
CHAPTER = 23

ACTIONS = ('disable', 'trigger', 'write', 'level', 'nba', 'call')
PATHS = ('down', 'nested', 'array', 'generate', 'root', 'up', 'sibling')
# When the target starts to wait: before the action at time 2, or after it.
START = {'waiting': 1, 'late': 4}


def legal(row: Row) -> bool: return True


MODEL = Model(
    'hierarchical_process_control',
    (('action', ACTIONS), ('path', PATHS), ('timing', tuple(START)), ('actor', ('initial', 'task', 'fork'))),
    legal,
    groups=(('action', 'timing', 'actor'),),
    anchors=(('disable', 'up', 'waiting', 'task'), ('trigger', 'sibling', 'waiting', 'fork'),
             ('level', 'generate', 'late', 'initial'), ('nba', 'array', 'waiting', 'initial'),
             ('call', 'nested', 'waiting', 'fork'), ('disable', 'root', 'late', 'initial'),
             ('write', 'down', 'late', 'task')),
    constraints=('対象のプロセスは時刻1か4に待ち始め、操作する側は時刻2に一度だけ操作する。'
                 '操作する側は操作の前に値を表示し、同じタイムスロットでほかのプロセスと表示の順序を競わない。'
                 '実行中でないブロックのdisableは何もせず、待つプロセスのないイベントの起動と値の変化は失われる。'
                 'wait文は待ち始めに条件が成り立っていればすぐに進む。'
                 '下向きの名前、インスタンス配列と生成ブロックを通る名前、$root、'
                 'モジュール名による上向きの名前、兄弟のインスタンスへの上向きの名前で同じものを指す。',),
)


def case_name(row: Row) -> str: return 'test_gen_cross_hierproc_' + '_'.join(row)


def reference(row: Row) -> str:
    action, _, timing, _ = row
    late = timing == 'late'
    lines = ['2 act x=0']
    if action == 'nba': lines.append('2 sent x=0')
    if action == 'disable':
        lines += ['7 inner', '7 after x=0'] if late else ['2 after x=0']
    elif action == 'level':
        lines.append(f'{4 if late else 2} woke x=5')
    elif not late:
        lines.append({'trigger': '2 woke x=0', 'write': '2 woke x=5', 'nba': '2 woke x=5', 'call': '3 woke x=5'}[action])
    lines.append(f'8 end x={0 if action in ("disable", "trigger") else 5}')
    return '\n'.join(lines) + '\n'


def target_items(action: str, timing: str) -> list[str]:
    """The declarations and the waiting process of the target, indented for a module."""
    wait = {'disable': ['begin : blk', '  #3 $display("%0d inner", $time);', 'end',
                        '$display("%0d after x=%0d", $time, x);'],
            'trigger': ['@(e) $display("%0d woke x=%0d", $time, x);'],
            'level': ["wait (x == 8'd5) $display(\"%0d woke x=%0d\", $time, x);"]}
    body = wait.get(action, ['@(x) $display("%0d woke x=%0d", $time, x);'])
    return ['  event e;', "  logic [7:0] x = 8'd0;", '  task t(input logic [7:0] k);', '    #1 x = k;', '  endtask',
            '  initial begin : run', f'    #{START[timing]};', *['    ' + line for line in body], '  end']


def actor_items(action: str, actor: str, prefix: str) -> list[str]:
    """The process that acts at time 2 through the hierarchical prefix, indented for a module."""
    # The argument goes on its own line, since a name from $root or the top module is long.
    body = ['$display("%0d act x=%0d", $time,', f'         {prefix}x);']
    body += {'disable': [f'disable {prefix}run.blk;'], 'trigger': [f'-> {prefix}e;'],
             'write': [f"{prefix}x = 8'd5;"], 'level': [f"{prefix}x = 8'd5;"],
             'nba': [f"{prefix}x <= 8'd5;", '$display("%0d sent x=%0d", $time,', f'         {prefix}x);'],
             'call': [f"{prefix}t(8'd5);"]}[action]
    if actor == 'initial': return ['  initial begin', '    #2;', *['    ' + line for line in body], '  end']
    if actor == 'task':
        return ['  task act;', *['    ' + line for line in body], '  endtask',
                '  initial begin', '    #2;', '    act;', '  end']
    return ['  initial begin', '    #2;', '    fork', '      begin', *['        ' + line for line in body],
            '      end', '    join_none', '  end']


def source(row: Row) -> str:
    action, path, timing, actor = row
    top = case_name(row)
    target = target_items(action, timing)
    lines = []
    if path != 'up': lines += ['module hpc_target;', *target, 'endmodule']
    if path == 'nested': lines += ['module hpc_wrap;', '  hpc_target v ();', 'endmodule']
    prefix = {'down': 'u.', 'nested': 'u.v.', 'array': 'u[1].', 'generate': 'g[1].u.', 'root': f'$root.{top}.u.',
              'up': f'{top}.', 'sibling': 'a.'}[path]
    if path in ('up', 'sibling'): lines += ['module hpc_actor;', *actor_items(action, actor, prefix), 'endmodule']
    lines.append(f'module {top};')
    lines += {'down': ['  hpc_target u ();'], 'nested': ['  hpc_wrap u ();'], 'array': ['  hpc_target u [1:1] ();'],
              'generate': ['  for (genvar i = 1; i < 2; i++) begin : g', '    hpc_target u ();', '  end'],
              'root': ['  hpc_target u ();'], 'up': [*target, '  hpc_actor w ();'],
              'sibling': ['  hpc_target a ();', '  hpc_actor b ();']}[path]
    if path not in ('up', 'sibling'): lines += actor_items(action, actor, prefix)
    final = {'up': '', 'sibling': 'a.', 'root': 'u.'}.get(path, prefix)
    lines += ['  initial begin', '    #8;', f'    $display("%0d end x=%0d", $time, {final}x);', '    $finish;', '  end',
              'endmodule']
    return '\n'.join(lines)


PATH_CLAUSE = {'down': '23.3.2', 'nested': '23.3.2', 'array': '23.3.2', 'generate': '27.4', 'root': '23.3.2',
               'up': '23.8', 'sibling': '23.8'}
ACTION_CLAUSE = {'disable': '9.6.2 9.3.4', 'trigger': '15.5.1 9.4.2', 'write': '9.4.2', 'level': '9.4.3',
                 'nba': '10.4.2 9.4.2', 'call': '13.3 23.8.1 9.4.2'}
ACTOR_CLAUSE = {'initial': '9.2.1', 'task': '13.3', 'fork': '9.3.2'}


def make_case(row: Row) -> Case:
    action, path, _, actor = row
    clauses = f'23.6 {PATH_CLAUSE[path]} {ACTION_CLAUSE[action]} {ACTOR_CLAUSE[actor]}'.split()
    return Case(case_name(row), 'A process acts on a process of another instance through a hierarchical name',
                ' '.join(dict.fromkeys(clauses)),
                'A process reaches a target in another instance through a hierarchical name: downward, through '
                'an instance array or a loop generate block, from $root, upward by the module name, or upward '
                'to a sibling instance. At time 2 it disables a named block, triggers an event, writes a '
                'variable with a blocking or a nonblocking assignment, or calls a task of the target. The '
                'target waits from time 1, or only from time 4, after the action. Disabling a block that is '
                'not running does nothing, a trigger or a change with nobody waiting is lost, and a wait '
                'statement passes at once when its condition already holds.',
                source(row), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]: return [make_case(row) for row in MODEL.select()]
