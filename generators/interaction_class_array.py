"""Array value storage versus nested handle sharing in class shallow copies."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_class_array'
VERSION = 1
CHAPTER = 8
MODEL = Model(
    'class_array_shallow_copy',
    (('container', ('fixed', 'dynamic', 'queue')),
     ('width', ('1', '8', '33')), ('length', ('1', '3')),
     ('position', ('first', 'last')), ('copy', ('shallow', 'alias')),
     ('writer', ('source', 'copy')), ('operation', ('element', 'resize'))),
    lambda row: not (row[0] == 'fixed' and row[6] == 'resize'),
    groups=(('container', 'copy', 'operation'), ('width', 'length', 'operation'),
            ('copy', 'writer', 'operation'), ('container', 'length', 'position'),
            ('container', 'width', 'copy')),
    anchors=(('fixed', '33', '3', 'last', 'shallow', 'copy', 'element'),
             ('dynamic', '8', '3', 'last', 'shallow', 'copy', 'resize'),
             ('queue', '1', '1', 'first', 'alias', 'source', 'resize'),
             ('dynamic', '33', '1', 'last', 'shallow', 'source', 'element')),
    constraints=('直積288行のうち合法240行。固定配列のresizeだけを水準の意味から除く。'
                 '未対応を理由とする除外なし。各holderは同じ形状のbitベクタ配列とクラスハンドル配列を持つ。'
                 '浅いコピーでは配列の要素格納領域を独立させ、要素ハンドルの参照先は共有する。'
                 'ハンドル代入を共有の対照とし、元/コピーのどちらかから変更する。'
                 'サイズ変更は1→3または3→1で、残す接頭部と追加要素の既定値を確認する。'
                 '保存した要素ハンドルは、置換や縮小後も参照先を保持する。'
                 '初回長1のfirst/lastは等価な対照。X/Z、空配列、継承、rand状態、covergroup、ref、並行実行は対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_class_array_' + '_'.join(row)


def reference(row: Row) -> str:
    _, width, length, position, copy, writer, operation = row
    w, n = int(width), int(length)
    mask = (1 << w) - 1
    mark = 0 if position == 'first' else n - 1
    initial = [mask if i % 2 else 0 for i in range(n)]
    lines = []
    for stage, label in enumerate(('copied', 'shared', 'changed', 'retained')):
        words = {owner: initial.copy() for owner in ('source', 'copy')}
        refs = {owner: list(range(n)) for owner in words}
        leaves = {i: mask ^ v for i, v in enumerate(initial)}
        if stage >= 1:
            leaves[mark] = initial[mark]
        if stage >= 2:
            owners = ('source', 'copy') if copy == 'alias' else (writer,)
            for owner in owners:
                if operation == 'element':
                    words[owner][mark] = mask ^ initial[mark]
                    refs[owner][mark] = 'replacement'
                    leaves['replacement'] = mask
                else:
                    size = 3 if n == 1 else 1
                    words[owner] = (words[owner] + [0] * size)[:size]
                    refs[owner] = (refs[owner] + [None] * size)[:size]
        if stage == 3:
            leaves[mark] = mask ^ initial[mark]
        old_match = lambda owner: int(mark < len(refs[owner]) and refs[owner][mark] == mark)
        lines += [f'stage={label} same_holder={int(copy=="alias")} ctor=2 old={leaves[mark]:0{w}b}',
                  f'same_first={int(refs["source"][0]==refs["copy"][0])} '
                  f'old_source={old_match("source")} old_copy={old_match("copy")}']
        for owner in ('source', 'copy', 'guard'):
            values = [mask ^ v for v in initial] if owner == 'guard' else words[owner]
            lines += [f'{owner} stamp={2 if owner=="guard" else 1} size={len(values)}']
            for i, value in enumerate(values):
                target = i if owner == 'guard' else refs[owner][i]
                ref = (f'{initial[i]:0{w}b}' if owner == 'guard' else
                       'null' if target is None else f'{leaves[target]:0{w}b}')
                lines += [f'{owner}[{i}] word={value:0{w}b} ref={ref}']
    return '\n'.join(lines) + '\n'


def resize_lines(container: str, owner: str, n: int) -> list[str]:
    size = 3 if n == 1 else 1
    if container == 'dynamic':
        return [f'    {owner}.words = new[{size}]({owner}.words);',
                f'    {owner}.refs = new[{size}]({owner}.refs);']
    if n == 1:
        return [f'    repeat (2) begin', f"      {owner}.words.push_back('0);",
                f'      {owner}.refs.push_back(null);', '    end']
    return ['    repeat (2) begin', f"      void'({owner}.words.pop_back());",
            f"      void'({owner}.refs.pop_back());", '    end']


def make_case(row: Row) -> Case:
    container, width, length, position, copy, writer, operation = row
    w, n = int(width), int(length)
    mark = 0 if position == 'first' else n - 1
    mask = (1 << w) - 1
    base = mask if mark % 2 else 0
    dims = f'[0:{n-1}]' if container == 'fixed' else '[]' if container == 'dynamic' else '[$]'
    literal = lambda value: f"{w}'h{value:x}"
    lines = [f'typedef bit [{w-1}:0] copy_word_t;', 'class copy_leaf;',
             '  copy_word_t value;', 'endclass', 'class copy_holder;',
             f'  copy_word_t words{dims};', f'  copy_leaf refs{dims};',
             '  static int constructed = 0;', '  int stamp;',
             '  function new();', '    constructed++; stamp = constructed;', '  endfunction',
             'endclass', f'module {case_name(row)};',
             '  copy_holder source, copy, guard;', '  copy_leaf fresh, old_ref;',
             '  task automatic show(input string stage);',
             '    copy_holder h;', '    string who;', '    int old_source, old_copy;',
             '    old_source = 0; old_copy = 0;',
             f'    if ($size(source.refs) > {mark}) old_source = source.refs[{mark}] == old_ref;',
             f'    if ($size(copy.refs) > {mark}) old_copy = copy.refs[{mark}] == old_ref;',
             '    $display("stage=%s same_holder=%0d ctor=%0d old=%b",',
             '             stage, source == copy, copy_holder::constructed, old_ref.value);',
             '    $display("same_first=%0d old_source=%0d old_copy=%0d",',
             '             source.refs[0] == copy.refs[0], old_source, old_copy);',
             '    for (int owner = 0; owner < 3; owner++) begin',
             '      case (owner)', '        0: begin h = source; who = "source"; end',
             '        1: begin h = copy; who = "copy"; end',
             '        2: begin h = guard; who = "guard"; end', '      endcase',
             '      $display("%s stamp=%0d size=%0d", who, h.stamp, $size(h.words));',
             '      foreach (h.words[i]) begin', '        if (h.refs[i] == null)',
             '          $display("%s[%0d] word=%b ref=null", who, i, h.words[i]);',
             '        else',
             '          $display("%s[%0d] word=%b ref=%b", who, i, h.words[i], h.refs[i].value);',
             '      end', '    end', '  endtask', '  initial begin',
             '    source = new; guard = new;']
    for owner in ('source', 'guard'):
        if container == 'dynamic':
            lines += [f'    {owner}.words = new[{n}];', f'    {owner}.refs = new[{n}];']
        elif container == 'queue':
            lines += [f'    repeat ({n}) begin', f"      {owner}.words.push_back('0);",
                      f'      {owner}.refs.push_back(null);', '    end']
        for i in range(n):
            value = mask if i % 2 else 0
            if owner == 'guard':
                value ^= mask
            lines += [f'    {owner}.words[{i}] = {literal(value)};',
                      '    fresh = new;', f'    fresh.value = {literal(mask ^ value)};',
                      f'    {owner}.refs[{i}] = fresh;']
    lines += ['    copy = new source;' if copy == 'shallow' else '    copy = source;',
              f'    old_ref = source.refs[{mark}];', '    show("copied");',
              f'    {writer}.refs[{mark}].value = {literal(base)};', '    show("shared");']
    if operation == 'element':
        lines += [f'    {writer}.words[{mark}] = {literal(mask ^ base)};',
                  '    fresh = new;', f'    fresh.value = {literal(mask)};',
                  f'    {writer}.refs[{mark}] = fresh;']
    else:
        lines += resize_lines(container, writer, n)
    lines += ['    show("changed");', f'    old_ref.value = {literal(mask ^ base)};',
              '    show("retained");', '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Class shallow copies separate array storage while sharing referenced element objects',
                '8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2',
                'A holder owns a known-bit vector array and a same-shaped array of class handles. '
                'A new shallow copy must copy the array variables without duplicating objects '
                'referenced by their elements or rerunning the holder constructor. Plain handle '
                'assignment is an alias control. A nested write through either holder must be '
                'shared, while replacing vector and handle elements in one shallow copy must '
                'leave the other container unchanged. Dynamic arrays preserve a prefix through '
                'new[size](old); queues grow with zero/null elements or shrink by popping their '
                'tail. An external saved element handle is written after replacement or resize '
                'to check retained object identity. Four sequential snapshots compare '
                'all words, nulls and payloads, holder/element identity, constructor count, '
                'copied stamps and a distinct guard holder. Single-element first/last positions '
                'are equivalence controls. No X/Z, empty containers, inheritance, randomization, '
                'covergroups, ref arguments, time controls or concurrent processes are used.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
