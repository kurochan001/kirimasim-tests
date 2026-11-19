# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wide conditional and comparison regressions from existing clause models.

Frozen non-width configurations extend numerical/state boundaries without
changing old finite models, their selected rows or their requirement bindings.
"""
from dataclasses import replace
import interaction_cond as conditional
import interaction_compare as comparison
from wide_literals import wrap_generated_unsigned_literals

NAME = 'wide_value_boundaries'
VERSION = 1
CHAPTER = 11
WIDTHS = (255, 256, 257, 511, 512, 513)
CONDITIONAL_CONFIGURATIONS = (('signed', 'signed', '0', 'mixed_xz', 'narrow', 'bit'),
 ('signed', 'signed', 'x', 'same_xz', 'wide', 'logic'),
 ('signed', 'signed', 'z', 'equal', 'same', 'logic'),
 ('signed', 'unsigned', '1', 'equal', 'narrow', 'bit'),
 ('signed', 'unsigned', '1', 'mixed_xz', 'wide', 'logic'),
 ('signed', 'unsigned', '1', 'same_xz', 'same', 'bit'),
 ('signed', 'unsigned', 'x', 'opposite', 'narrow', 'bit'),
 ('unsigned', 'signed', '0', 'opposite', 'wide', 'logic'),
 ('unsigned', 'signed', '1', 'opposite', 'same', 'bit'),
 ('unsigned', 'signed', 'z', 'same_xz', 'narrow', 'bit'),
 ('unsigned', 'unsigned', '0', 'equal', 'same', 'bit'),
 ('unsigned', 'unsigned', '0', 'equal', 'wide', 'logic'),
 ('unsigned', 'unsigned', '0', 'mixed_xz', 'narrow', 'logic'),
 ('unsigned', 'unsigned', '0', 'opposite', 'same', 'bit'),
 ('unsigned', 'unsigned', '0', 'same_xz', 'narrow', 'logic'),
 ('unsigned', 'unsigned', '0', 'same_xz', 'wide', 'bit'),
 ('unsigned', 'unsigned', '1', 'equal', 'narrow', 'logic'),
 ('unsigned', 'unsigned', '1', 'mixed_xz', 'same', 'bit'),
 ('unsigned', 'unsigned', '1', 'opposite', 'narrow', 'logic'),
 ('unsigned', 'unsigned', '1', 'same_xz', 'same', 'logic'),
 ('unsigned', 'unsigned', 'x', 'equal', 'narrow', 'logic'),
 ('unsigned', 'unsigned', 'x', 'equal', 'same', 'bit'),
 ('unsigned', 'unsigned', 'x', 'mixed_xz', 'narrow', 'bit'),
 ('unsigned', 'unsigned', 'x', 'mixed_xz', 'same', 'logic'),
 ('unsigned', 'unsigned', 'x', 'opposite', 'narrow', 'logic'),
 ('unsigned', 'unsigned', 'x', 'same_xz', 'narrow', 'bit'),
 ('unsigned', 'unsigned', 'z', 'equal', 'wide', 'bit'),
 ('unsigned', 'unsigned', 'z', 'mixed_xz', 'narrow', 'logic'),
 ('unsigned', 'unsigned', 'z', 'mixed_xz', 'same', 'bit'),
 ('unsigned', 'unsigned', 'z', 'opposite', 'narrow', 'bit'),
 ('unsigned', 'unsigned', 'z', 'opposite', 'narrow', 'logic'),
 ('unsigned', 'unsigned', 'z', 'same_xz', 'narrow', 'logic'))
COMPARISON_CONFIGURATIONS = (('narrow', 'signed', 'signed', 'lt', 'known'),
 ('same', 'unsigned', 'signed', 'lt', 'lhs_x'),
 ('same', 'unsigned', 'unsigned', 'le', 'known'),
 ('same', 'unsigned', 'signed', 'le', 'lhs_x'),
 ('same', 'unsigned', 'signed', 'gt', 'known'),
 ('narrow', 'signed', 'signed', 'gt', 'lhs_x'),
 ('wide', 'unsigned', 'signed', 'ge', 'known'),
 ('same', 'unsigned', 'signed', 'ge', 'lhs_x'),
 ('same', 'unsigned', 'signed', 'eq', 'known'),
 ('same', 'unsigned', 'unsigned', 'eq', 'both_unknown'),
 ('same', 'unsigned', 'signed', 'ne', 'known'),
 ('same', 'unsigned', 'signed', 'ne', 'both_unknown'),
 ('narrow', 'unsigned', 'signed', 'ceq', 'known'),
 ('same', 'signed', 'signed', 'ceq', 'both_unknown'),
 ('same', 'unsigned', 'signed', 'cne', 'known'),
 ('same', 'unsigned', 'signed', 'cne', 'both_unknown'),
 ('same', 'unsigned', 'signed', 'weq', 'known'),
 ('narrow', 'signed', 'unsigned', 'weq', 'rhs_z'),
 ('narrow', 'unsigned', 'unsigned', 'wne', 'known'),
 ('same', 'unsigned', 'unsigned', 'wne', 'rhs_z'))


def make_case(width, configuration, kind):
    original = (conditional if kind == 'conditional' else comparison).make_case(
        (str(width), *configuration))
    old_prefix = 'test_gen_cross_cond_' if kind == 'conditional' else 'test_gen_cross_compare_'
    new_prefix = 'test_gen_wide_conditional_' if kind == 'conditional' else 'test_gen_wide_comparison_'
    assert original.name.startswith(old_prefix)
    name = original.name.replace(old_prefix, new_prefix, 1)
    body = original.body.replace('module '+original.name+';', 'module '+name+';', 1)
    body = wrap_generated_unsigned_literals(body)
    if kind == 'conditional':
        clauses = '11.4.11 11.6.1 11.8.1 11.8.2 6.11.2 11.4.12'
        note = ('Wide conditional cases retain both source words, their joint signing, '
                'W-1/W/W+1 destination context and final bit/logic storage conversion. '
                'Known conditions select one branch; X/Z conditions merge extended '
                'branches under Table 11-20 before final truncation. All input and '
                'result bits are observed. The 32 frozen configurations are regressions '
                'outside the existing finite model; no model rows or bindings change.')
    else:
        operator = configuration[3]
        primary = ('11.4.4' if operator in ('lt','le','gt','ge') else
                   '11.4.5' if operator in ('eq','ne','ceq','cne') else '11.4.6')
        clauses = primary+' 11.6.1 11.8.2 6.11.2 11.4.12 20.6.2'
        note = ('Each of ten comparison operators has one known and one explicit '
                'unknown-operand configuration at each width. Four input pairs expose '
                'complete operand values, signed/unsigned common-width conversion, '
                'unsigned one-bit direct results, seven-bit extensions, final bit '
                'conversion and natural expression widths. Only RHS X/Z bits act as '
                'wildcards. These 20 frozen configurations do not extend the original '
                'finite model or claim a new complete interaction covering set.')
    return replace(original,name=name,body=body,comment=note,lrm=clauses,extra={})


def cases():
    return [make_case(width,configuration,kind) for width in WIDTHS
            for kind,configurations in [('conditional',CONDITIONAL_CONFIGURATIONS),
                                         ('comparison',COMPARISON_CONFIGURATIONS)]
            for configuration in configurations]
