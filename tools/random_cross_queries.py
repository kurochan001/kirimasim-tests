# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Bounded random full-width queries with scalar and wide variable controls."""
PROFILES = ('wide_bitquery_sequence',)
WIDTHS = (255, 256, 257, 511, 512, 513)


def generate(profile, rng, steps, draw):
    if profile not in PROFILES:
        raise ValueError('unknown wide bit-query profile')
    width = rng.choice(WIDTHS)
    p = {'width':width, 'sign':rng.choice(('signed','unsigned')),
         'direction':rng.choice(('ascending','descending')),
         'control_width':rng.choice((1,width))}
    fourstate = rng.randrange(2) == 0
    vectors = []
    for index in range(steps):
        if index > 0 and rng.randrange(5) == 0:
            vectors.append(dict(vectors[-1]))
            continue
        source = draw(rng,width,fourstate)
        a,b = (draw(rng,p['control_width'],fourstate) for _ in range(2))
        c = a if index % 2 == 0 else draw(rng,p['control_width'],fourstate)
        vectors.append({'source':source,'a':a,'b':b,'c':c})
    return p,vectors


def validate(case):
    p,vectors = case['parameters'],case['stimuli']
    if (case['profile'] not in PROFILES or not isinstance(p,dict)
            or set(p)!={'width','sign','direction','control_width'}
            or type(p['width']) is not int or p['width'] not in WIDTHS
            or type(p['control_width']) is not int or p['control_width'] not in (1,p['width'])
            or p['sign'] not in ('signed','unsigned')
            or p['direction'] not in ('ascending','descending')):
        raise ValueError('invalid wide bit-query parameters')
    if not isinstance(vectors,list) or not 1<=len(vectors)<=32:
        raise ValueError('invalid wide bit-query vector count')
    for vector in vectors:
        if not isinstance(vector,dict) or set(vector)!={'source','a','b','c'}:
            raise ValueError('invalid wide bit-query vector fields')
        for name,value in vector.items():
            width = p['width'] if name=='source' else p['control_width']
            if (not isinstance(value,str) or len(value)!=width
                    or not set(value)<=set('01xz')):
                raise ValueError('invalid wide bit-query value')


def requires_fourstate(case):
    validate(case)
    return any(set(value)&set('xz') for vector in case['stimuli'] for value in vector.values())


def materialize(case):
    validate(case)
    p,vectors = case['parameters'],case['stimuli'];width=p['width'];cw=p['control_width']
    bounds = f'0:{width-1}' if p['direction']=='ascending' else f'{width-1}:0'
    lines = [f'module random_cross_{case["id"]};',
             f'  logic {p["sign"]} [{bounds}] source;',
             f'  logic [{cw-1}:0] control_a, control_b, control_c;', '  initial begin']
    expected = []
    for index,vector in enumerate(vectors):
        for key,target in (('source','source'),('a','control_a'),('b','control_b'),('c','control_c')):
            value=vector[key];lines.append(f"    {target} = {len(value)}'b{value};")
        source=vector['source'];ones=source.count('1');selected={vector[key][-1] for key in ('a','b','c')}
        lines += [f'    $display("v{index}_input=%b a=%b b=%b c=%b",',
                  '             source, control_a, control_b, control_c);',
                  f'    $display("v{index}_hist zeros=%0d ones=%0d x=%0d z=%0d",',
                  "             $countbits(source, 1'b0), $countones(source),",
                  "             $countbits(source, 1'bx), $countbits(source, 1'bz));",
                  f'    $display("v{index}_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",',
                  '             $onehot(source), $onehot0(source), $isunknown(source),',
                  '             $countbits(source, control_a, control_b, control_c, control_a),',
                  '             $countbits(source, control_a));',
                  f'    $display("v{index}_after=%b a=%b b=%b c=%b",',
                  '             source, control_a, control_b, control_c);']
        expected += [f'v{index}_input={source} a={vector["a"]} b={vector["b"]} c={vector["c"]}',
                     f'v{index}_hist zeros={source.count("0")} ones={ones} x={source.count("x")} z={source.count("z")}',
                     f'v{index}_queries hot={int(ones==1)} hot0={int(ones<=1)} unknown={int(bool(set(source)&set("xz")))} selected={sum(source.count(bit) for bit in selected)} single={source.count(vector["a"][-1])}',
                     f'v{index}_after={source} a={vector["a"]} b={vector["b"]} c={vector["c"]}']
    lines += ['    $display("return_bits=%0d,%0d,%0d,%0d,%0d",',
              "             $bits($countbits(source, 1'b1)), $bits($countones(source)),",
              '             $bits($onehot(source)), $bits($onehot0(source)),',
              '             $bits($isunknown(source)));']
    expected.append('return_bits=32,32,1,1,1')
    return lines,expected,'20.9 20.6.2'
