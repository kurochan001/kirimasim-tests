# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Extend unchanged bit-vector query fixtures across 256/512-bit boundaries."""
from dataclasses import replace
import bitvector_queries as queries

NAME = 'wide_bitvector_queries'
VERSION = 1
CHAPTER = 20
WIDTHS = (255, 256, 257, 511, 512, 513)


def make_case(width, form):
    original = queries.make_case(width, form)
    name = original.name.replace('test_gen_bitquery_', 'test_gen_wide_bitquery_', 1)
    return replace(original, name=name,
                   description=f'Wide query boundaries preserve {form} argument and result semantics',
                   body=original.body.replace('module '+original.name+';', 'module '+name+';', 1),
                   comment=original.comment.replace(
                       'An ascending two-state packed range contains set bits in every storage word.',
                       'An ascending two-state packed range retains its low set-bit cluster, '
                       'top bit and intervening zero regions.'))


def cases():
    return [make_case(width, form) for width in WIDTHS for form in queries.FORMS]
