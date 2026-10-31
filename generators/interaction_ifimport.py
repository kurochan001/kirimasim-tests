"""Interface header imports, package function conversion and per-instance parameters."""

from common import Case
from interaction_cover import Model, Row

NAME = 'interaction_ifimport'
VERSION = 1
CHAPTER = 25
ITEMS = ('BASE','MARK','raw_t','word_t','encode')
MODEL = Model(
    'interface_header_import',
    (('width',('1','32','33','64','65','129')), ('storage',('bit','logic')),
     ('value',('known','x','z')), ('package',('a','b')),
     ('imports',('wildcard','explicit','export')), ('header',('ansi','nonansi')),
     ('override',('defaults','narrow','wide'))),
    lambda row: True,
    groups=(('width','storage','value'), ('package','imports','header'),
            ('package','override','header'), ('imports','storage','value')),
    anchors=(('1','bit','known','a','wildcard','ansi','defaults'),
             ('129','logic','z','b','export','nonansi','wide'),
             ('65','bit','x','a','explicit','nonansi','narrow'),
             ('33','logic','x','b','wildcard','ansi','narrow'),
             ('32','logic','known','a','export','ansi','wide'),
             ('64','bit','z','b','explicit','nonansi','defaults')),
    constraints=('全1296行が合法。ヘッダのimportはパラメータ既定値・入力型・本体の型と関数を供給する。'
                 'export経路は中継packageで5項目を明示importしてからexportし、未使用のwildcard候補を再公開しない。'
                 'targetだけの幅/タグの上書きと、既定値のguardを比較する。入力はlogic型、package関数の仮引数はbit/logic型。'
                 '競合するimport、型パラメータの変更、modport、virtual interface、時間を使うpackageサブルーチンは対象外。未対応による除外なし',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_ifimport_'+'_'.join(row)


def dimensions(row: Row):
    base=int(row[0]); packet=base+int(row[3]=='b'); raw=base+2
    target=packet if row[6]=='defaults' else max(1,base//2) if row[6]=='narrow' else base+3
    mark=11 if row[3]=='a' else 23
    return raw,packet,target,(99 if row[6]=='wide' else mark),mark


def stimuli(row: Row):
    raw_width,packet,*_=dimensions(row)
    for phase in range(11):
        words=[''.join(str(((role*raw_width+bit+1)>>phase)&1) if phase<9 else str(phase-9)
                       for bit in range(raw_width-1,-1,-1)) for role in range(2)]
        yield f'k{phase}',words
    if row[2]!='known':
        for phase,bit in enumerate((0,packet-1,packet//2,raw_width-1)):
            words=[]
            for role in range(2):
                word=list(''.join(str(((role*raw_width+i+1)>>phase)&1)
                                  for i in range(raw_width-1,-1,-1)))
                word[raw_width-1-bit]=row[2];words.append(''.join(word))
            yield f'u{phase}',words


def xor(bits: str, value: int) -> str:
    return ''.join(str(int(c)^((value>>(len(bits)-1-i))&1)) if c in '01' else 'x'
                   for i,c in enumerate(bits))


def reference(row: Row) -> str:
    raw_width,packet,target,tag,mark=dimensions(row);lines=[]
    for label,words in stimuli(row):
        for role,raw in zip(('target','guard'),words):
            incoming=raw[-packet:]
            typed=incoming.translate(str.maketrans('xz','00')) if row[1]=='bit' else incoming
            stored=(''.join('1' if c=='0' else '0' if c=='1' else 'x' for c in typed)
                    if row[3]=='a' else xor(typed,3))
            width,actual_tag=(target,tag) if role=='target' else (packet,mark)
            resized=stored[-width:] if width<packet else '0'*(width-packet)+stored
            echo=xor(resized,actual_tag)
            lines += [f'{label} {role} raw={raw} incoming={incoming} typed={typed} stored={stored} echo={echo}',
                      f'{label} {role} W={width} TAG={actual_tag} bits={packet},{packet},{packet},{width}']
        lines.append(f'{label} caller BASE={int(row[0])+3} MARK=99 bits=1')
    return '\n'.join(lines)+'\n'


def assign_bits(name: str,bits: str) -> list[str]:
    if len(bits)<=64:
        return [f"    {name} = {len(bits)}'b{bits};"]
    parts=[bits[i:i+64] for i in range(0,len(bits),64)]
    return [f'    {name} = {{']+[f"      {len(p)}'b{p}"+(',' if i+1<len(parts) else '')
                               for i,p in enumerate(parts)]+['    };']


def packages(row: Row) -> list[str]:
    lines=[]
    for suffix in ('a','b'):
        width=int(row[0])+int(suffix=='b'); mark=11 if suffix=='a' else 23
        expr='~data' if suffix=='a' else "data ^ word_t'(3)"
        lines += [f'package pkg_{suffix};',f'  parameter int BASE={width}, MARK={mark};',
                  '  typedef logic [BASE-1:0] raw_t;',f'  typedef {row[1]} [BASE-1:0] word_t;',
                  '  function automatic word_t encode(input word_t data);',
                  f'    return {expr};','  endfunction','endpackage']
    if row[4]=='export':
        lines += ['package bridge_pkg;',*[f'  import pkg_{row[3]}::{name};' for name in ITEMS],
                  f'  export pkg_{row[3]}::*;','endpackage']
    return lines


def imports(row: Row) -> list[str]:
    package='bridge_pkg' if row[4]=='export' else 'pkg_'+row[3]
    if row[4]=='explicit':
        return [f'  import {package}::{name};' for name in ITEMS]
    return [f'  import {package}::*;']


def make_case(row: Row) -> Case:
    width,storage,value,package,mode,header,override=row
    w=int(width);name=case_name(row);raw_width=dimensions(row)[0]
    lines=['`timescale 1ns/1ns',*packages(row),'interface imported_bus',*imports(row),
           '  #(parameter int W=BASE, TAG=MARK)']
    lines += ['  (input raw_t incoming);'] if header=='ansi' else ['  (incoming);','  input raw_t incoming;']
    lines += ['  word_t typed, stored;','  wire [W-1:0] echo;','  assign typed = incoming;',
              '  assign stored = encode(incoming);',"  assign echo = W'(stored) ^ W'(TAG);",'endinterface',
              f'module {name};',f'  localparam int BASE={w+3}, MARK=99, LOW={max(1,w//2)};',
              '  typedef bit [0:0] word_t;','  function automatic word_t encode(input word_t data);',
              "    return '0;",'  endfunction',f'  logic [{raw_width-1}:0] raw_target, raw_guard;']
    parameters='' if override=='defaults' else '#(.W(LOW)) ' if override=='narrow' else '#(.W(BASE), .TAG(MARK)) '
    lines += [f'  imported_bus {parameters}target(.incoming(raw_target));',
              '  imported_bus guard(.incoming(raw_guard));','  task automatic observe(input string label);']
    for role in ('target','guard'):
        lines += [f'    $display("%s {role} raw=%b incoming=%b typed=%b stored=%b echo=%b",',
                  f'             label, raw_{role}, {role}.incoming, {role}.typed, {role}.stored, {role}.echo);',
                  f'    $display("%s {role} W=%0d TAG=%0d bits=%0d,%0d,%0d,%0d",',
                  f'             label, {role}.W, {role}.TAG, $bits({role}.incoming),',
                  f'             $bits({role}.typed), $bits({role}.stored), $bits({role}.echo));']
    lines += ['    $display("%s caller BASE=%0d MARK=%0d bits=%0d", label, BASE, MARK, $bits(word_t));',
              '  endtask','  initial begin']
    for label,words in stimuli(row):
        lines += [*assign_bits('raw_target',words[0]),*assign_bits('raw_guard',words[1]),'    #1;',
                  f'    observe("{label}");']
    lines += ['    $finish;','  end','endmodule']
    return Case(name,'Interface header imports bind package types and functions before per-instance width overrides',
                '25.3 26.4 26.3 26.6 13.5.1 6.11.2',
                'Two packages declare the same names with different widths, tags '
                'and encoding functions. Wildcard, explicit or explicitly '
                're-exported header imports supply interface parameter defaults, '
                'the four-state input type and the internal bit/logic word type. '
                'The package function converts its formal before inversion or '
                'XOR; typed storage in the interface provides a separate '
                'conversion observation. A caller shadows parameter, type and '
                'function names. Defaults use the imported package, while '
                'explicit instance arguments use caller values. Only target '
                'parameters are overridden; guard retains defaults and receives '
                'different data. Intermediate incoming/typed/encoded values and '
                'actual widths prevent a later tag XOR from masking an error. '
                'Eleven known identity frames distinguish both raw input banks '
                'and their complements through 131 bits. X/Z cases exercise the '
                'least, most and middle retained bits plus one discarded bit. '
                'No conflicting imports, type-parameter changes, modports, '
                'virtual interfaces or time-consuming package routines are used.',
                '\n'.join(lines),reference(row),fourstate=value!='known',
                extra={'interaction_model':f'{MODEL.name}@{MODEL.version}',
                       'interaction_values':' '.join(f'{k}={v}' for k,v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
