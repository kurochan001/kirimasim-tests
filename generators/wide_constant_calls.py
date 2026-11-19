# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wide constant controls and runtime variable actuals with visible input copies."""
from dataclasses import replace
import function_formal_contexts as functions
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_constant_calls'
VERSION = 1
CHAPTER = 13
WIDTHS = (255, 256, 257, 511, 512, 513)
SCOPES = ('module', 'package', 'class')


def make_case(scope, width, signed):
    original = functions.constant(scope, width, signed)
    name = original.name.replace('test_gen_formal_constant_',
                                 'test_gen_wide_constant_call_', 1)
    body = original.body
    if body.startswith('// Icarus Verilog 13.0 does not elaborate these class-static calls.\n'):
        body = body.split('\n', 1)[1]
    body = body.replace('module '+original.name+';', 'module '+name+';', 1)
    assert body.count('  word_t runtime_value;') == 1
    body = body.replace('  word_t runtime_value;',
        '  word_t runtime_value, runtime_source, runtime_leaf;\n  integer nonce, found;', 1)
    body = body.replace('  initial begin',
        '  initial begin\n    nonce = 0;\n'
        '    found = $value$plusargs("nonce=%d", nonce);\n'
        '    $display("nonce=%0d found=%0d", nonce, found != 0);', 1)
    owner = 'constant_helpers::' if scope == 'package' else 'helper::' if scope == 'class' else ''
    seeds = (0, functions.mask(width), 1 << (width-1), functions.alternating(width))
    prior = original.expected.splitlines()
    assert len(prior) == 6
    expected = ['nonce=1 found=1']
    middle = width//2
    for phase, seed in enumerate(seeds):
        old = f'    runtime_value = {owner}calculate(\n        {functions.literal(width, seed)});'
        assert body.count(old) == 1
        supplied = seed ^ (1 << middle)
        new = [f'    runtime_source = {functions.literal(width, supplied)};',
               f'    runtime_source[{middle}] = runtime_source[{middle}] ^ nonce[0];',
               f'    $display("p{phase}_input=%b", runtime_source);',
               f'    runtime_value = {owner}calculate(runtime_source);',
               f'    runtime_leaf = {owner}leaf(runtime_source);',
               f'    $display("p{phase}_input_after=%b", runtime_source);',
               f'    $display("p{phase}_leaf=%b decimal=%0d", runtime_leaf, runtime_leaf);']
        body = body.replace(old, '\n'.join(new), 1)
        value = functions.shift(seed ^ functions.alternating(width), width, signed)
        expected += [f'p{phase}_input={seed:0{width}b}',
                     f'p{phase}_input_after={seed:0{width}b}',
                     f'p{phase}_leaf={value:0{width}b} '
                     f'decimal={functions.decimal(value, width, signed)}', prior[phase]]
    expected += prior[4:]
    end = '\n  end\nendmodule'
    assert body.count(end) == 1
    body = body.replace(end,
        '\n    $display("widths=%0d,%0d,%0d",\n'
        f'             $bits({owner}leaf(runtime_source)),\n'
        f'             $bits({owner}calculate(runtime_source)), $bits(runtime_value));\n'
        '    $finish;'+end, 1)
    expected.append(f'widths={width},{width},{width}')
    clauses = '13.4.3 13.4.1 13.5.1 11.4.10 11.8.1 11.8.2 20.6.2 21.6 21.2.1'
    if scope == 'class':
        clauses += ' 8.10'
    note = ('Literal and parameter actuals remain the only inputs to elaboration-time '
            'constant calls; every nested leaf in calculate receives FIXED_ARG. '
            'Runtime calls instead use complete word vectors whose known middle bit '
            'is restored from +nonce=1. The leaf modifies only its input copy and '
            'returns a signed/unsigned right-shifted value. Original source values '
            'are checked again after the runtime leaf call. Folded wrapper, runtime '
            'wrapper and direct runtime leaf results are checked independently, '
            'with full bits, decimal signing and declared function-result widths. '
            'Four frozen known seeds cover zero/ones/top/alternating bits across '
            'module/package/static-class scopes. No arbitrary recursion, noninput '
            'constant formals or four-state behavior is claimed.')
    return replace(original, name=name,
                   description='Folded and runtime wide function calls preserve values and declared types',
                   body=wrap_generated_unsigned_literals(body),
                   expected='\n'.join(expected)+'\n', lrm=clauses, comment=note,
                   extra={'args':'+nonce=1'})


def cases():
    return [make_case(scope, width, signed)
            for scope in SCOPES for width in WIDTHS for signed in (False, True)]
