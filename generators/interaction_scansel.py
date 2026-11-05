"""Formatted scanning, query-derived field widths and guarded partial writes."""

from common import Case
from interaction_class_import import assigned
from interaction_cover import Model, Row
from interaction_cond import literal
from interaction_genloop import flipped

NAME = 'interaction_scansel'
VERSION = 1
CHAPTER = 21
MODEL = Model(
    'formatted_scan_partial_write',
    (('width', ('1', '32', '33', '64', '65', '129')),
     ('state', ('bit', 'logic')), ('value', ('known', 'x', 'z')),
     ('radix', ('bin', 'hex')), ('outcome', ('all', 'long_first', 'bad_second', 'empty')),
     ('target', ('whole', 'plus', 'minus')), ('field', ('target', 'word')),
     ('placement', ('low', 'high')), ('format', ('literal', 'runtime'))),
    lambda row: row[5] != 'whole' or row[7] == 'low',
    groups=(('width', 'state', 'value'), ('target', 'outcome', 'format'),
            ('radix', 'format', 'outcome'), ('field', 'format', 'target'),
            ('state', 'value', 'target'), ('width', 'target', 'field')),
    anchors=(('1', 'bit', 'known', 'bin', 'all', 'whole', 'target', 'low', 'literal'),
             ('129', 'logic', 'z', 'hex', 'long_first', 'minus', 'word', 'high', 'runtime'),
             ('65', 'logic', 'x', 'bin', 'bad_second', 'plus', 'target', 'high', 'literal'),
             ('33', 'bit', 'z', 'hex', 'empty', 'minus', 'word', 'low', 'runtime'),
             ('32', 'logic', 'known', 'hex', 'long_first', 'plus', 'word', 'low', 'literal'),
             ('64', 'bit', 'known', 'bin', 'bad_second', 'whole', 'target', 'low', 'runtime')),
    constraints=('wholeでは使わないplacementをlowに代表させる。他の全行は合法で未対応による除外なし。'
                 '二つの出力幅はWとW+1、格納語の幅はW+7。部分選択は低位または高位へ置き、+:と-:を区別する。'
                 '書式の先頭フィールド幅は対象または格納語の$bitsから作り、最大文字数として使う。'
                 'hexでは文字数とビット数は異なる。literalでは同じ幅を生成時に埋め、runtimeでは実際の書式変数を渡す。'
                 '先頭成功後の文字不一致、第二変換の不一致、空入力、全成功を区別する。'
                 '成功した変換だけが書き込み、後続出力と選択範囲外を保持する。'
                 '既知・既知またはX/Z・既知への回復の各相で試行と全成功の再呼出しを行い、履歴を保持する。'
                 'X/Zは既知ASCIIの数字として入力し、bit格納への変換でもfourstateを指定する。'
                 '可変の選択添字・変換抑制・空白の特殊規則・実数・ファイルI/O・並行実行は対象外。',),
)


def case_name(row: Row) -> str:
    return 'test_gen_cross_scansel_' + '_'.join(row)


def target(row: Row, second=False) -> str:
    name = 'b' if second else 'a'
    if row[5] == 'whole': return name
    width = int(row[0]) + int(second)
    base = (6 if second else 7) if row[7] == 'high' else 0
    return f'w{name}[{base} +: {width}]' if row[5] == 'plus' else f'w{name}[{base + width - 1} -: {width}]'


def limit(row: Row) -> int:
    return int(row[0]) + (7 if row[6] == 'word' else 0)


def format_text(row: Row) -> str:
    return f'%{limit(row)}' + ('b' if row[3] == 'bin' else 'h') + '|%b|%d'


def numeric_token(length, radix, phase, followup, unknown='known'):
    if unknown != 'known': return unknown * length
    alphabet = '10' if radix == 'bin' else 'a5c3'
    shift = (phase + int(followup)) % len(alphabet)
    return ''.join(alphabet[(i + shift) % len(alphabet)] for i in range(length))


def input_text(row: Row, phase: int, followup: bool) -> str:
    unknown = row[2] if phase == 1 else 'known'
    first = numeric_token(limit(row), row[3], phase, followup, unknown)
    other = {'known': 'known', 'x': 'z', 'z': 'x'}[unknown]
    second = numeric_token(int(row[0]) + 1, 'bin', phase + 1, followup, other)
    tag = phase * 10 + (8 if followup else 7)
    if not followup:
        if row[4] == 'empty': return ''
        if row[4] == 'long_first': first += '1' if row[3] == 'bin' else 'a'
        if row[4] == 'bad_second': second = '!'
    return first + '|' + second + '|' + str(tag)


def initial(width, code):
    return ''.join(str(((i + code) % 2) if i >= 3 else ((code >> i) & 1)) for i in reversed(range(width)))


def reference(row: Row) -> str:
    width = int(row[0]); sizes = {'a': width, 'b': width + 1, 'wa': width + 7, 'wb': width + 7}
    values = {name: initial(size, code) for code, (name, size) in enumerate(sizes.items(), 1)}
    rc, tag, lines = -77, -91, []
    def selected(second):
        name = 'b' if second else 'a'; size = width + int(second)
        if row[5] == 'whole': return values[name]
        base = (6 if second else 7) if row[7] == 'high' else 0
        bits = values['w' + name]; return bits[len(bits) - base - size:len(bits) - base]
    def write(second, token, radix):
        size = width + int(second)
        bits = token[0] * size if set(token) <= {'x'} or set(token) <= {'z'} else format(int(token, radix) & ((1 << size) - 1), f'0{size}b')
        bits = assigned(bits, size, row[1]); name = 'b' if second else 'a'
        if row[5] == 'whole': values[name] = bits
        else:
            key = 'w' + name; base = (6 if second else 7) if row[7] == 'high' else 0
            old = values[key]; start = len(old) - base - size
            values[key] = old[:start] + bits + old[start + size:]
    def snapshot(phase, step, text):
        lines.append(f'h p={phase} step={step} fmt=[{format_text(row)}] text=[{text}] rc={rc} tag={tag}')
        lines.append('v ' + ' '.join(f'{name}={values[name]}' for name in ('a', 'b', 'wa', 'wb')) +
                     f' seen_a={selected(False)} seen_b={selected(True)} bits_a={width} bits_b={width + 1} field={limit(row)}')
    def scan(phase, followup):
        nonlocal rc, tag
        text = input_text(row, phase, followup)
        if not text: rc = -1; return
        first = text.split('|')[0][:limit(row)]
        write(False, first, 2 if row[3] == 'bin' else 16)
        rc = 1
        if not followup and row[4] in ('long_first', 'bad_second'): return
        write(True, text.split('|')[1], 2); tag = phase * 10 + (8 if followup else 7); rc = 3
    for phase in range(3):
        text = input_text(row, phase, False); snapshot(phase, 'before', text)
        scan(phase, False); snapshot(phase, 'trial', text)
        text = input_text(row, phase, True); scan(phase, True); snapshot(phase, 'again', text)
        guard = 'wa' if row[5] == 'whole' else 'a'; values[guard] = flipped(values[guard]); snapshot(phase, 'guard', text)
        snapshot(phase, 'idle', text)
    return '\n'.join(lines) + '\n'


def source(row: Row) -> str:
    width = int(row[0]); names = {'a': width, 'b': width + 1, 'wa': width + 7, 'wb': width + 7}
    lines = [f'module {case_name(row)};']
    for name, size in names.items(): lines.append(f'  {row[1]} [{size - 1}:0] {name};')
    lines += ['  string fmt, text;', '  int rc, tag;', '  initial begin']
    for code, (name, size) in enumerate(names.items(), 1): lines.append(f'    {name}={literal(initial(size, code))};')
    query = 'wa' if row[6] == 'word' else target(row)
    conv = 'b' if row[3] == 'bin' else 'h'
    lines += ['    rc=-77; tag=-91;', f'    fmt=$sformatf("%%%0d{conv}|%%b|%%d", $bits({query}));']
    def snapshot(phase, step):
        nonlocal lines
        lines += [f'    $display("h p={phase} step={step} fmt=[%s] text=[%s] rc=%0d tag=%0d",',
                  '      fmt, text, rc, tag);',
                  '    $display("v a=%b b=%b wa=%b wb=%b seen_a=%b seen_b=%b bits_a=%0d bits_b=%0d field=%0d",',
                  f'      a, b, wa, wb, {target(row)}, {target(row, True)},',
                  f'      $bits({target(row)}), $bits({target(row, True)}),', f'      $bits({query}));']
    fmt = 'fmt' if row[8] == 'runtime' else '"' + format_text(row) + '"'
    call = [f'    rc=$sscanf(text, {fmt},', f'      {target(row)}, {target(row, True)}, tag);']
    def text_assignment(text):
        if len(text) < 70: return [f'    text="{text}";']
        chunks = [text[i:i + 48] for i in range(0, len(text), 48)]
        return ['    text={'] + ['      "' + chunk + '"' + (',' if i < len(chunks) - 1 else '')
                                for i, chunk in enumerate(chunks)] + ['    };']
    for phase in range(3):
        lines += text_assignment(input_text(row, phase, False)); snapshot(phase, 'before')
        lines += call; snapshot(phase, 'trial')
        lines += text_assignment(input_text(row, phase, True)) + call; snapshot(phase, 'again')
        guard = 'wa' if row[5] == 'whole' else 'a'
        lines.append(f"    {guard}={guard} ^ 1'b1;"); snapshot(phase, 'guard'); snapshot(phase, 'idle')
    lines += ['    $finish;', '  end', 'endmodule']
    return '\n'.join(lines)


def make_case(row: Row) -> Case:
    return Case(case_name(row), 'Formatted scanning updates only successful destinations and preserves selected-word guards',
                '21.3.4.3 21.3.3 11.5.1 20.6.2 6.11.2',
                'Scan a bounded binary/hex field, a binary field and a decimal marker into whole '
                'variables or indexed part-selects. Field width counts characters and is derived '
                'from $bits of the target or guarded word. Literal and runtime formats have the '
                'same contents. Distinguish full success, an overlong first field, a second-field '
                'mismatch and empty input. Observe return count, every full storage word and both '
                'selected views before/after each trial and valid followup. Preserve earlier '
                'assignments, later outputs and all unselected bits. Known, ASCII X/Z digit and '
                'known-recovery phases retain history. Change only an unscanned guard afterward. '
                'No variable indices, suppressed conversions, real or file input, whitespace '
                'edge cases, concurrent calls or unspecified argument ordering are used.',
                source(row), reference(row), fourstate=row[2] != 'known',
                extra={'interaction_model': f'{MODEL.name}@{MODEL.version}',
                       'interaction_values': ' '.join(f'{k}={v}' for k, v in MODEL.values(row).items())})


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
