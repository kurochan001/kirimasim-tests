# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Reuse numeric round trips while checking positive field padding and expansion."""
from dataclasses import replace
import re
import wide_format_roundtrips as roundtrips

NAME = 'wide_format_fields'
VERSION = 1
CHAPTER = 21


def make_case(width,signed,radix,field):
    original=roundtrips.make_case(width,signed,radix)
    count=3 if field=='small' else width+2
    name=original.name.replace('test_gen_wide_format_roundtrip_',
                               'test_gen_wide_format_field_',1)+'_'+field
    body=original.body.replace('module '+original.name+';', 'module '+name+';',1)
    before=f'$sformatf("%0{radix}", source)';after=f'$sformatf("%{count}{radix}", source)'
    assert body.count(before)==4
    body=body.replace(before,after)
    expected=[]
    for line in original.expected.splitlines():
        matched=re.fullmatch(r'(p\d+ text=)([0-9a-f-]+) length=\d+',line)
        if matched:
            text=matched[2].rjust(count,' ' if radix=='d' else '0')
            line=f'{matched[1]}{text} length={len(text)}'
        expected.append(line)
    clauses=' '.join(dict.fromkeys(('21.2.1.2 '+original.lrm).split()))
    note=('Positive field widths are minimum sizes, not truncation limits. '
          'A three-character field must expand for large values; a W+2-character '
          'field pads every selected source. Decimal uses leading spaces, while '
          'binary and hexadecimal use leading zeros. The underlying known-word '
          'round-trip fixture, runtime dependency, explicit hex lowercase '
          'normalization, full source/parsed values and assignment count remain '
          'unchanged. Exact text and string length expose field handling '
          'independently of successful parsing. No file I/O, real formatting or '
          'four-state values are included.')
    return replace(original,name=name,
                   description='Positive format fields pad small values and retain full wide numbers',
                   lrm=clauses,comment=note,body=body,expected='\n'.join(expected)+'\n')


def cases():
    return [make_case(width,signed,radix,field) for width in roundtrips.WIDTHS
            for signed in (False,True) for radix in roundtrips.RADICES
            for field in ('small','wide')]
