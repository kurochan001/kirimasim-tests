# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Observe copy-out versus immediate alias changes inside wide runtime functions."""
from common import Case
import function_formal_contexts as functions
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_runtime_aliases'
VERSION = 1
CHAPTER = 13
WIDTHS = (255, 256, 257, 511, 512, 513)


def make_case(direction, width, signed):
    label = 'signed' if signed else 'unsigned'
    name = f'test_gen_wide_runtime_alias_{direction}_w{width}_{label}'
    body = '\n'.join(functions.definitions(name, direction, width, signed, control=True))
    assert body.count('word_t before_value, after_value, answer;') == 1
    body = body.replace('word_t before_value, after_value, answer;',
                        'word_t before_value, inside_value, after_value, answer;')
    for leaf, wrapper, formal in (('leaf', 'wrapped', direction),
                                  ('input_leaf', 'input_wrapped', 'input')):
        declaration = f'  function automatic word_t {leaf}({formal} word_t arg);'
        assert body.count(declaration) == 1
        body = body.replace(declaration,
            f'  function automatic word_t {leaf}(\n'
            f'      {formal} word_t arg, ref word_t witness, output word_t during_call);', 1)
        call = f'    result.answer = {leaf}(temporary);'
        assert body.count(call) == 1
        body = body.replace(call,
            f'    result.answer = {leaf}(temporary, temporary, result.inside_value);', 1)
    assert body.count('    return ~arg;') == 2
    body = body.replace('    return ~arg;', '    during_call = witness;\n    return ~arg;')
    lines = [body, '  word_t runtime_source;', '  result_t observed, input_observed;',
             '  integer nonce, found;', '  initial begin', '    nonce = 0;',
             '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);']
    expected = ['nonce=1 found=1']
    middle = width//2
    for phase, seed in enumerate((0, functions.mask(width), 1 << (width-1),
                                  functions.alternating(width))):
        after = functions.edited(direction, width, seed)
        inside = after if direction == 'ref' else seed
        answer = functions.mask(width) ^ after
        lines += [f'    runtime_source = {functions.literal(width, seed ^ (1 << middle))};',
                  f'    runtime_source[{middle}] = runtime_source[{middle}] ^ nonce[0];',
                  '    observed = wrapped(runtime_source);',
                  '    input_observed = input_wrapped(runtime_source);',
                  f'    $display("p{phase} runtime before=%b inside=%b after=%b answer=%b",',
                  '             observed.before_value, observed.inside_value,',
                  '             observed.after_value, observed.answer);',
                  f'    $display("p{phase} input before=%b inside=%b after=%b answer=%b",',
                  '             input_observed.before_value, input_observed.inside_value,',
                  '             input_observed.after_value, input_observed.answer);',
                  f'    $display("p{phase} decimal after=%0d answer=%0d",',
                  '             observed.after_value, observed.answer);',
                  f'    $display("p{phase} caller=%b", runtime_source);']
        expected += [f'p{phase} runtime before={seed:0{width}b} inside={inside:0{width}b} '
                     f'after={after:0{width}b} answer={answer:0{width}b}',
                     f'p{phase} input before={seed:0{width}b} inside={seed:0{width}b} '
                     f'after={seed:0{width}b} answer={answer:0{width}b}',
                     f'p{phase} decimal after={functions.decimal(after, width, signed)} '
                     f'answer={functions.decimal(answer, width, signed)}',
                     f'p{phase} caller={seed:0{width}b}']
    lines += ['    $display("widths=%0d,%0d,%0d",',
              '             $bits(word_t), $bits(result_t), $bits(observed.answer));',
              '    $finish;', '  end', 'endmodule']
    expected.append(f'widths={width},{4*width},{width}')
    note = ('The automatic wrapper passes the same exactly typed local variable '
            'to an editable formal and a separate read-only-by-use ref witness. '
            'The leaf reads the witness after assigning the editable formal but '
            'before returning. Output/inout edits copy back only on return, so '
            'the witness still observes the old seed; a ref edit is immediately '
            'visible through both aliases. The witness itself is never assigned '
            'and is deliberately not const-qualified. A separate input-formal '
            'control mutates only its copy. Four full-word seeds receive a real '
            'runtime middle-bit dependency from +nonce=1. Full before/inside/after/'
            'answer vectors, signed decimal fields, outer caller retention and '
            'four-word packed-result widths are visible. All calls are ordinary '
            'runtime functions; no constant call has noninput formals. Original '
            'formal-context helpers and tests remain unchanged.')
    return Case(name, 'Runtime function aliases distinguish immediate updates from return-time copies',
                '13.5.2 13.5.1 13.4.1 6.22.2 11.4.5 11.4.8 20.6.2 21.6 21.2.1',
                note, wrap_generated_unsigned_literals('\n'.join(lines)),
                '\n'.join(expected)+'\n', extra={'args':'+nonce=1'})


def cases():
    return [make_case(direction, width, signed) for direction in functions.DIRECTIONS
            for width in WIDTHS for signed in (False, True)]
