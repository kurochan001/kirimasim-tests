"""Container mutation boundaries and explicit functional-coverage sampling."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_cgsample'
VERSION = 1
CHAPTER = 19
MODEL = Model(
    'container_coverage_sampling',
    (('container', ('fixed', 'dynamic', 'queue')),
     ('operation', ('overwrite', 'reverse', 'replace', 'clear')),
     ('sampling', ('before', 'after', 'both')), ('binding', ('live', 'arguments')),
     ('position', ('first', 'last')), ('threshold', ('1', '2')),
     ('guard', ('all', 'nonempty')), ('length', ('1', '3'))),
    lambda row: not (row[0]=='fixed' and row[1]=='clear'),
    groups=(('container', 'operation', 'sampling'), ('sampling', 'binding', 'position'),
            ('operation', 'guard', 'threshold'), ('container', 'sampling', 'binding')),
    anchors=(('fixed', 'overwrite', 'before', 'arguments', 'first', '1', 'all', '3'),
             ('dynamic', 'replace', 'after', 'arguments', 'last', '1', 'all', '1'),
             ('queue', 'clear', 'both', 'arguments', 'first', '1', 'nonempty', '3'),
             ('fixed', 'reverse', 'both', 'live', 'last', '2', 'all', '3'),
             ('dynamic', 'clear', 'before', 'live', 'last', '2', 'all', '1'),
             ('queue', 'replace', 'after', 'live', 'first', '2', 'nonempty', '3')),
    constraints=('全1152行のうち固定配列のclearに当たる96行を除く1056行が合法。'
                 'コンテナは0始まりの既知int要素で、初期長は1/3。'
                 '同じ型の対照へ全体コピー後、対象だけを3段階で更新する。'
                 '変更前/変更後/両方で各2回sampleし、各回のサイズ・先頭/末尾値と個別coverpointの割合を観測する。'
                 '空コンテナの値は要素を読まず-1にする。nonemptyガードは空のsampleだけを抑止する。'
                 '直接参照とsample引数、at_least 1/2を比較する。固定配列の長さと長さ1のreverseは不変の対照。'
                 'X/Z、並行更新、イベント駆動sample、cross bin、型集計、get_inst_coverageのref引数、'
                 'start/stop、自動bin、default/ignore/illegal binは対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_cgsample_' + '_'.join(row)


def changed(row: Row, phase: int, previous: list[int]) -> list[int]:
    kind,operation,_,_,position,_,_,length = row
    n = int(length)
    if operation=='overwrite':
        result = list(previous);result[0 if position=='first' else -1] = (3,1,0)[phase]
        return result
    if operation=='reverse':return list(reversed(previous))
    if operation=='clear':return [2,3,1][:(3 if n==1 else 1)] if phase==1 else []
    size = n if kind=='fixed' or phase%2 else (3 if n==1 else 1)
    return ((3,2,1),(1,3,0),(0,2,3))[phase][:size]


def reference(row: Row) -> str:
    _,_,sampling,_,position,threshold,guard,length = row
    a = list(range(int(length)));b = list(a)
    counts = [[{},{}],[{},{}]];lines = []
    def point(values):return (len(values),values[0 if position=='first' else -1] if values else -1)
    def show(phase,stage,index,sample):
        states = (point(a),point(b))
        if sample:
            for lane,(size,value) in enumerate(states):
                if guard=='nonempty' and not size:continue
                for cp,key in enumerate((size,value)):
                    bins = counts[lane][cp];bins[key] = bins.get(key,0)+1
        lines.append(f'phase={phase} stage={stage} repeat={index} '
                     f'a_size={states[0][0]} a_value={states[0][1]} '
                     f'b_size={states[1][0]} b_value={states[1][1]}')
        percentages = [100*sum(count>=int(threshold) for count in bins.values())/total
                       for lane in counts for bins,total in zip(lane,(4,5))]
        lines.append('g size=%.2f value=%.2f h size=%.2f value=%.2f'%tuple(percentages))
    for phase in range(3):
        for stage in ('before','after'):
            if stage=='after':a = list(changed(row,phase,a))
            selected = sampling=='both' or sampling==stage
            for index in (range(2) if selected else (-1,)):show(phase,stage,index,selected)
    return '\n'.join(lines)+'\n'


def assignment(kind: str, name: str, values) -> list[str]:
    if kind=='dynamic':
        return [f'    {name} = new[{len(values)}];']+[
            f'    {name}[{index}] = {value};' for index,value in enumerate(values)]
    return [f"    {name} = '{{"+', '.join(map(str,values))+'};']


def make_case(row: Row) -> Case:
    kind,operation,sampling,binding,position,threshold,guard,length = row;n = int(length)
    shape = f'[0:{n-1}]' if kind=='fixed' else '[]' if kind=='dynamic' else '[$]'
    size = lambda name: str(n) if kind=='fixed' else name+'.size()'
    index = lambda name: '0' if position=='first' else size(name)+'-1'
    lines = [f'module {case_name(row)};',f'  int a{shape}, b{shape};',
             '  function automatic int current_size(input int lane);',
             f'    if (lane == 0) return {size("a")};',f'    return {size("b")};','  endfunction',
             '  function automatic int current_value(input int lane);',
             '    if (current_size(lane) == 0) return -1;',
             f'    if (lane == 0) return a[{index("a")}];',f'    return b[{index("b")}];','  endfunction']
    for group,expression,bounds in (('size_cg','current_size','0:3'),
                                    ('value_cg','current_value','0:3')):
        if binding=='live':
            lines += [f'  covergroup {group}(input int which);']
            covered = expression+'(which)'
            enabled = "1'b1" if guard=='all' else 'current_size(which) != 0'
        else:
            lines += [f'  covergroup {group} with function sample(input int value, input bit enabled);']
            covered,enabled = 'value','enabled'
        lines += ['    option.per_instance = 1;',
                  f'    cp: coverpoint {covered} iff ({enabled}) {{',
                  f'      option.at_least = {threshold};',
                  f'      bins b[] = {{[{bounds}]}};']
        if group=='value_cg':lines += ['      bins empty = {-1};']
        lines += ['    }','  endgroup']
    for lane,prefix in ((0,'g'),(1,'h')):
        for suffix,group in (('s','size_cg'),('v','value_cg')):
            lines += [f'  {group} {prefix}{suffix} = new'+(f'({lane});' if binding=='live' else '();')]
    lines += ['  task automatic show(input int phase, input string stage, input int repeat_id);',
              '    $display("phase=%0d stage=%s repeat=%0d a_size=%0d a_value=%0d b_size=%0d b_value=%0d",',
              '             phase, stage, repeat_id, current_size(0), current_value(0),',
              '             current_size(1), current_value(1));',
              '    $display("g size=%.2f value=%.2f h size=%.2f value=%.2f",',
              '             gs.get_inst_coverage(), gv.get_inst_coverage(),',
              '             hs.get_inst_coverage(), hv.get_inst_coverage());', '  endtask',
              '  task automatic sample_now(input int phase, input string stage);',
              '    for (int repeat_id = 0; repeat_id < 2; repeat_id++) begin']
    for lane,prefix in ((0,'g'),(1,'h')):
        for suffix,expression in (('s','current_size'),('v','current_value')):
            argument = '' if binding=='live' else (expression+f'({lane}), '+
                ("1'b1" if guard=='all' else f'current_size({lane}) != 0'))
            lines += [f'      {prefix}{suffix}.sample({argument});']
    lines += ['      show(phase, stage, repeat_id);', '    end', '  endtask', '  initial begin']
    a = list(range(n));lines += assignment(kind,'a',a)+['    b = a;']
    for phase in range(3):
        lines += [f'    sample_now({phase}, "before");' if sampling in ('before','both')
                  else f'    show({phase}, "before", -1);']
        if operation=='overwrite':lines += [f'    a[{0 if position=="first" else n-1}] = {(3,1,0)[phase]};']
        elif operation=='reverse':lines += ['    a.reverse();']
        elif operation=='clear' and phase!=1:lines += ['    a.delete();']
        else:lines += assignment(kind,'a',changed(row,phase,a))
        a = list(changed(row,phase,a))
        lines += [f'    sample_now({phase}, "after");' if sampling in ('after','both')
                  else f'    show({phase}, "after", -1);']
    lines += ['    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Container updates and guarded coverage samples preserve size value and instance history',
                '19.5 19.5.1 19.7 19.8 19.8.1 19.11.1 7.4.1 7.5 7.5.1 7.5.2 7.10 7.12.2',
                'Copy a known integer container into a same-type control, then '
                'mutate only the target through three overwrite, reverse, '
                'replacement or clear/recreate stages. Fixed containers never '
                'resize; one-element reversal is an unchanged control. '
                'Read size and the first or last value; an empty value is -1 '
                'without reading any element. Sample before, after or both '
                'sides of each mutation, twice per selected boundary. Observe '
                'raw target/control states and each coverpoint percentage after '
                'every sample or unsampled boundary. Size bins cover 0 through '
                '3; value bins cover -1 through 3. An optional nonempty iff '
                'guard suppresses empty samples; at_least is one or two. '
                'Compare live expressions through constructor-selected lanes '
                'with input arguments evaluated at each sample call. Separate '
                'instances retain their own history. Each group contains one '
                'coverpoint, queried through its group instance. No X/Z, concurrency, '
                'event-driven sampling, cross bins, type-level aggregation, '
                'coverage ref outputs, start/stop, automatic bins or '
                'default/ignore/illegal bins are used.',
                '\n'.join(lines),reference(row),
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{key}={value}' for key,value in MODEL.values(row).items())})


def cases() -> list[Case]:return [make_case(row) for row in MODEL.select()]
