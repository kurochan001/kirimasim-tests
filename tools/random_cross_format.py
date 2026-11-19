# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Opt-in known wide numeric text/scan sequences with independently visible text."""
from function_formal_contexts import decimal

PROFILES = ('wide_format_scan_sequence',)
WIDTHS = (255, 256, 257, 511, 512, 513)
RADICES = ('b', 'h', 'd')


def generate(profile, rng, steps, draw):
    if profile not in PROFILES:
        raise ValueError('unknown wide format/scan profile')
    p = {'width':rng.choice(WIDTHS), 'sign':rng.choice(('signed','unsigned')),
         'radix':rng.choice(RADICES)}
    return p,[{'source':draw(rng,p['width'],False)} for _ in range(steps)]


def validate(case):
    p,vectors = case['parameters'],case['stimuli']
    if (case['profile'] not in PROFILES or not isinstance(p,dict)
            or set(p)!={'width','sign','radix'} or type(p['width']) is not int
            or p['width'] not in WIDTHS or p['sign'] not in ('signed','unsigned')
            or p['radix'] not in RADICES):
        raise ValueError('invalid wide format/scan parameters')
    if not isinstance(vectors,list) or not 1<=len(vectors)<=32:
        raise ValueError('invalid wide format/scan vector count')
    for vector in vectors:
        if (not isinstance(vector,dict) or set(vector)!={'source'}
                or not isinstance(vector['source'],str) or len(vector['source'])!=p['width']
                or not set(vector['source'])<=set('01')):
            raise ValueError('invalid known wide format/scan source bits')


def requires_fourstate(case):
    validate(case)
    return False


def materialize(case):
    validate(case)
    p,vectors = case['parameters'],case['stimuli']
    width,radix = p['width'],p['radix']
    lines = [f'module random_cross_{case["id"]};',
             f'  typedef bit {p["sign"]} [{width-1}:0] word_t;',
             '  word_t source, parsed;', '  string text;', '  integer scanned;',
             '  initial begin']
    expected = []
    for index,vector in enumerate(vectors):
        source = vector['source'];value = int(source,2)
        text = (format(value,'b') if radix=='b' else format(value,'x') if radix=='h'
                else str(decimal(value,width,p['sign']=='signed')))
        lines += [f"    source = {width}'b{source};",
                  f'    text = $sformatf("%0{radix}", source);',
                  *(['    text = text.tolower();'] if radix=='h' else []),
                  "    parsed = '1;", f'    scanned = $sscanf(text, "%{radix}", parsed);',
                  f'    $display("v{index}_input=%b", source);',
                  f'    $display("v{index}_text=%s length=%0d", text, text.len());',
                  f'    $display("v{index}_parsed=%b count=%0d source_after=%b",',
                  '             parsed, scanned, source);']
        expected += [f'v{index}_input={source}', f'v{index}_text={text} length={len(text)}',
                     f'v{index}_parsed={source} count=1 source_after={source}']
    lines += ['    $display("widths=%0d,%0d", $bits(source), $bits(parsed));']
    expected.append(f'widths={width},{width}')
    clauses = ('21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 '
               + ('6.16.5 ' if radix=='h' else '') + '20.6.2')
    return lines,expected,clauses
