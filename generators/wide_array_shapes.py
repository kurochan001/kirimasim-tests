# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Reuse declared and live array-shape fixtures across 256/512-bit widths."""
from dataclasses import replace
import array_shape_queries as shapes

NAME = 'wide_array_shapes'
VERSION = 1
CHAPTER = 20
WIDTHS = (255, 256, 257, 511, 512, 513)


def make_case(width, form):
    original = shapes.make_case(width, form)
    name = original.name.replace('test_gen_array_shape_', 'test_gen_wide_array_shape_', 1)
    return replace(original, name=name,
                   body=original.body.replace('module '+original.name+';', 'module '+name+';', 1))


def cases():
    return [make_case(width, form) for width in WIDTHS for form in shapes.FORMS]
