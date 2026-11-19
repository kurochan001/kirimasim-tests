# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wrap exact-width unsigned constants in controlled generated source.

Callers supply known hexadecimal or binary/X/Z literals with exact bit widths;
their string literals must not contain sized-literal syntax. This is a source
formatting helper, not a general SystemVerilog lexer or value reference.
"""
import re


def wrap_literal(match):
    width, radix, value = int(match[1]), match[2], match[3]
    if width <= 64:
        return match[0]
    bits = f'{int(value, 16):0{width}b}' if radix == 'h' else value
    assert width == len(bits) and set(bits) <= set('01xz')
    chunks = [bits[i:i+64] for i in range(0, width, 64)]
    return '{\n' + ',\n'.join(f"      {len(chunk)}'b{chunk}" for chunk in chunks) + '\n    }'


def wrap_generated_unsigned_literals(body):
    return re.sub(r"(?<![\w'])([0-9]+)'([bh])([0-9a-fxz]+)", wrap_literal, body)
