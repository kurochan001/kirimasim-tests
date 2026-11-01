"""Class-held virtual interface rebinding, copied slots and saved references."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_vif_class'
VERSION = 1
CHAPTER = 25
STAGES = ('copied', 'initial_write', 'rebound', 'other_write',
          'null_write', 'saved_write', 'restored')
MODEL = Model(
    'class_virtual_interface',
    (('width', ('1', '8', '33')), ('state', ('bit', 'logic')),
     ('port', ('full', 'modport')), ('initial', ('a', 'b')),
     ('copy', ('shallow', 'alias')), ('actor', ('source', 'copy')),
     ('access', ('method', 'property'))),
    lambda row: True,
    groups=(('port', 'copy', 'actor'), ('copy', 'actor', 'access'),
            ('width', 'state', 'access'), ('initial', 'actor', 'copy'),
            ('width', 'port', 'copy')),
    anchors=(('1', 'bit', 'full', 'a', 'shallow', 'copy', 'method'),
             ('33', 'logic', 'modport', 'b', 'shallow', 'source', 'property'),
             ('8', 'bit', 'modport', 'a', 'alias', 'source', 'method'),
             ('33', 'bit', 'full', 'b', 'alias', 'copy', 'property')),
    constraints=('全192行が合法。3個のinterfaceは同じ型で、tagは11/22/33とする。'
                 'full型またはdataをrefとして公開する同じmodport型を一貫して使う。'
                 'クラスの浅いコピーはvirtual interface変数を別々に持ち、ハンドル代入はクラス実体を共有する。'
                 '元/コピーの片方を別interface→null→元interfaceへ再結合し、保存した参照を別に観測する。'
                 'null時は比較とガードだけを行い、メンバを参照せず書込み回数も変えない。'
                 '既知値だけを使い、bit/logicは等価性の対照とする。'
                 'X/Z、型不一致、null参照の異常終了、継承、clocking、時間制御、並行駆動は対象外。未対応による除外なし。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_vif_class_' + '_'.join(row)


def reference(row: Row) -> str:
    width, _, _, initial, mode, actor, _ = row
    w = int(width)
    mask = (1 << w) - 1
    guard = int(('01' * w)[:w], 2)
    other = 'b' if initial=='a' else 'a'
    tags = {'a': 11, 'b': 22, 'g': 33, None: -1}
    lines = []
    for step, stage in enumerate(STAGES):
        data = {'a': 0, 'b': mask, 'g': guard}
        bindings = {'source': initial, 'copy': initial}
        affected = ('source', 'copy') if mode=='alias' else (actor,)
        counts = {'source': 0, 'copy': 0}
        if step >= 1:
            data[initial] = mask if initial=='a' else 0
            for owner in affected:
                counts[owner] = 1
        if step >= 2:
            for owner in affected:
                bindings[owner] = other
        if step >= 3:
            data[other] = 0 if initial=='a' else mask
            for owner in affected:
                counts[owner] = 2
        if step >= 4:
            for owner in affected:
                bindings[owner] = None
        if step >= 5:
            data[initial] = 0 if initial=='a' else mask
        if step == 6:
            for owner in affected:
                bindings[owner] = initial
        ok = 1 if step in (1, 3) else 0 if step==4 else -1
        lines += [f'stage={stage} ok={ok} object={int(mode=="alias")} '
                  f'vif={int(bindings["source"]==bindings["copy"])} '
                  f'saved_source={int(bindings["source"]==initial)} '
                  f'saved_copy={int(bindings["copy"]==initial)}',
                  f'a={data["a"]:0{w}b} b={data["b"]:0{w}b} guard={guard:0{w}b} '
                  f'saved={tags[initial]}:{data[initial]:0{w}b}']
        value = lambda owner: 0 if bindings[owner] is None else data[bindings[owner]]
        lines += [f'source={tags[bindings["source"]]}:{value("source"):0{w}b} '
                  f'writes={counts["source"]} copy={tags[bindings["copy"]]}:'
                  f'{value("copy"):0{w}b} writes={counts["copy"]}',
                  f'guard=33:{guard:0{w}b} writes=0']
    return '\n'.join(lines) + '\n'


def write_lines(row: Row, value: int) -> list[str]:
    actor, access = row[5:7]
    w = int(row[0])
    literal = f"{w}'h{value:x}"
    if access=='method':
        return [f'    ok = {actor}.write_word({literal});']
    return [f'    if ({actor}.vif == null) ok = 0;', '    else begin',
            f'      {actor}.vif.data = {literal};', f'      {actor}.writes++; ok = 1;', '    end']


def make_case(row: Row) -> Case:
    width, state, port, initial, mode, actor, access = row
    w = int(width);mask = (1 << w) - 1
    other = 'b' if initial=='a' else 'a'
    guard = int(('01' * w)[:w], 2)
    virtual = 'virtual class_vif_bus' + ('.rw' if port=='modport' else '')
    literal = lambda value: f"{w}'h{value:x}"
    lines = [f'typedef {state} [{w-1}:0] vif_word_t;', 'interface class_vif_bus;',
             '  vif_word_t data;', '  int tag;', '  modport rw(ref data, input tag);',
             'endinterface', 'class vif_holder;', f'  {virtual} vif;', '  int writes = 0;',
             '  function int selected();', '    if (vif == null) return -1;',
             '    return vif.tag;', '  endfunction',
             '  function vif_word_t read_word();', "    if (vif == null) return '0;",
             '    return vif.data;', '  endfunction',
             '  function bit write_word(input vif_word_t value);',
             '    if (vif == null) return 0;', '    vif.data = value;',
             '    writes++; return 1;', '  endfunction', 'endclass',
             f'module {case_name(row)};', '  class_vif_bus a(), b(), g();',
             '  vif_holder source, copy, guard;', f'  {virtual} saved;', '  int ok;',
             '  task automatic show(input string label);',
             '    $display("stage=%s ok=%0d object=%0d vif=%0d saved_source=%0d saved_copy=%0d",',
             '             label, ok, source == copy, source.vif == copy.vif,',
             '             source.vif == saved, copy.vif == saved);',
             '    $display("a=%b b=%b guard=%b saved=%0d:%b",',
             '             a.data, b.data, g.data, saved.tag, saved.data);',
             '    $display("source=%0d:%b writes=%0d copy=%0d:%b writes=%0d",',
             '             source.selected(), source.read_word(), source.writes,',
             '             copy.selected(), copy.read_word(), copy.writes);',
             '    $display("guard=%0d:%b writes=%0d",',
             '             guard.selected(), guard.read_word(), guard.writes);',
             '  endtask', '  initial begin',
             f'    a.tag = 11; b.tag = 22; g.tag = 33;',
             f'    a.data = {literal(0)}; b.data = {literal(mask)}; g.data = {literal(guard)};',
             f'    source = new; source.vif = {initial};', '    guard = new; guard.vif = g;',
             '    copy = new source;' if mode=='shallow' else '    copy = source;',
             '    saved = source.vif;', '    ok = -1; show("copied");']
    lines += write_lines(row, mask if initial=='a' else 0)
    lines += ['    show("initial_write");', f'    {actor}.vif = {other};',
              '    ok = -1; show("rebound");']
    lines += write_lines(row, 0 if initial=='a' else mask)
    lines += ['    show("other_write");', f'    {actor}.vif = null;']
    lines += write_lines(row, mask)
    lines += ['    show("null_write");', f'    saved.data = {literal(0 if initial=="a" else mask)};',
              '    ok = -1; show("saved_write");', f'    {actor}.vif = {initial};',
              '    ok = -1; show("restored");', '    $finish;', '  end', 'endmodule']
    return Case(case_name(row),
                'Class-held virtual interfaces preserve copied bindings through rebinding and guarded null writes',
                '25.9 25.9.2 25.10 25.5 8.4 8.12 6.11.2',
                'Three instances of one interface type have distinct integer tags and known '
                'typed words. A class holds a full or ref-data modport virtual interface. '
                'A shallow copy has an independent binding slot; plain class-handle '
                'assignment shares that slot. Either source or copy writes its initial '
                'interface, binds the other instance, writes there, becomes null, attempts '
                'a guarded write and restores the original binding. Method and direct '
                'property paths use the same protocol. Read methods guard null and return '
                'a neutral zero with tag minus one. A separately saved virtual interface '
                'still refers to the original instance and writes it while the actor is '
                'null. Seven sequential snapshots check tags, all data bits, holder and '
                'virtual-interface identities, per-holder successful-write counts and an '
                'independent guard instance. All interface types and modports match; null '
                'is never dereferenced. No unknown data, incompatible types, inheritance, '
                'clocking blocks, time controls or concurrent drivers are used.',
                '\n'.join(lines), reference(row),
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
