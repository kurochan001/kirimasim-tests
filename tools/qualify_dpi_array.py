#!/usr/bin/env python3
"""Independently check DPI array expectations, C element access and observations."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_dpi_array as generator

# A test-owned ABI stub, not a simulator implementation or simulator header.
HEADER = '''
typedef void *svOpenArrayHandle;
int svLow(const svOpenArrayHandle, int);
int svHigh(const svOpenArrayHandle, int);
int svLeft(const svOpenArrayHandle, int);
int svRight(const svOpenArrayHandle, int);
int svIncrement(const svOpenArrayHandle, int);
int svSize(const svOpenArrayHandle, int);
int svDimensions(const svOpenArrayHandle);
void *svGetArrElemPtr1(const svOpenArrayHandle, int);
'''
DRIVER = r'''
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"
struct array { int left, right, dynamic, slots[12]; };
int svLeft(const svOpenArrayHandle h, int d) { assert(d == 1); return ((struct array *)h)->left; }
int svRight(const svOpenArrayHandle h, int d) { assert(d == 1); return ((struct array *)h)->right; }
int svLow(const svOpenArrayHandle h, int d) { int l=svLeft(h,d),r=svRight(h,d); return l<r?l:r; }
int svHigh(const svOpenArrayHandle h, int d) { int l=svLeft(h,d),r=svRight(h,d); return l>r?l:r; }
/* 20.7: -1 for a dynamic array or queue dimension, whatever its size. */
int svIncrement(const svOpenArrayHandle h, int d) {
    return ((struct array *)h)->dynamic || svLeft(h,d)<svRight(h,d) ? -1 : 1;
}
int svSize(const svOpenArrayHandle h, int d) { return svHigh(h,d)-svLow(h,d)+1; }
int svDimensions(const svOpenArrayHandle h) { (void)h; return 1; }
void *svGetArrElemPtr1(const svOpenArrayHandle h, int i) {
    if (i < svLow(h,1) || i > svHigh(h,1)) return NULL;
    return &((struct array *)h)->slots[2*(i-svLow(h,1))+1];
}
int cross_dpi_array_input(const svOpenArrayHandle,int,int);
int cross_dpi_array_output(const svOpenArrayHandle,int,int);
int cross_dpi_array_inout(const svOpenArrayHandle,int,int);
int main(int argc, char **argv) {
    const int words[2][5]={{11,18,25,32,39},{24,31,38,45,52}};
    int l,r,reverse,phase,direction,mixed,dynamic, poison=argc>1?atoi(argv[1]):123456;
    while (scanf("%d %d %d %d %d %d %d",&l,&r,&reverse,&phase,&direction,&mixed,&dynamic)==7) {
        struct array a; int k,n,lo,step,i,result,values[5];
        a.left=l; a.right=r; a.dynamic=dynamic; n=svSize(&a,1); lo=svLow(&a,1); step=l<=r?1:-1;
        assert(n>=1 && n<=5 && phase>=0 && phase<=1);
        for(k=0;k<12;k++) a.slots[k]=7654321;
        for(k=0;k<n;k++) {
            values[k]=words[phase][k];
            if(mixed && ((k+phase)&1)) values[k]=-values[k];
            a.slots[2*k+1]=direction==1?poison:values[k];
        }
        printf("call phase=%d size=%d\n",phase,n);
        for(i=l;;i+=step) { printf("before[%d]=%d\n",i,values[i-lo]); if(i==r) break; }
        result=direction==0?cross_dpi_array_input(&a,reverse,phase):
               direction==1?cross_dpi_array_output(&a,reverse,phase):
                            cross_dpi_array_inout(&a,reverse,phase);
        printf("returned=%d\n",result);
        for(i=l;;i+=step) { printf("after[%d]=%d\n",i,a.slots[2*(i-lo)+1]); if(i==r) break; }
        for(k=0;k<12;k++) if(k%2==0 || k>=2*n) assert(a.slots[k]==7654321);
        puts("guard=31,-47,83");
    }
    return 0;
}
'''


def independent(row):
    actual, direction, length, pattern, walk, calls = row
    output, requests = [], []
    words = ((11, 18, 25, 32, 39), (24, 31, 38, 45, 52))
    sizes = (int(length), {'1': 3, '3': 5, '5': 2}[length]
             if calls == 'resize' else int(length))
    for phase, n in enumerate(sizes):
        indices = (list(range(-2, n-2)) if actual == 'ascending' else
                   list(range(n+2, 2, -1)) if actual == 'descending' else list(range(n)))
        numerical = sorted(indices)
        values = dict(zip(numerical, words[phase][:n]))
        if pattern == 'mixed':
            for ordinal, i in enumerate(numerical):
                if (ordinal + phase) & 1:
                    values[i] = -values[i]
        output += [f'call phase={phase} size={n}']
        output += [f'before[{i}]={values[i]}' for i in indices]
        l, r, lo, hi = indices[0], indices[-1], numerical[0], numerical[-1]
        # IEEE 1800-2023 20.7 (H.12.2 uses the same semantics): a queue or
        # dynamic array dimension has the increment -1 at every size.
        resizable = actual in ('dynamic', 'queue')
        output += [f'c phase={phase} dims=1 left={l} right={r} low={lo} high={hi} '
                   f'inc={-1 if resizable or l<r else 1} size={n}']
        request = f'{l} {r} {int(walk=="descending")} {phase} '
        requests += [request + f'{("input", "output", "inout").index(direction)} '
                     f'{int(pattern=="mixed")} {int(resizable)}']
        ordered = numerical[::(-1 if walk == 'descending' else 1)]
        checksum = 0
        for ordinal, i in enumerate(ordered, 1):
            before = 0 if direction == 'output' else values[i]
            # Calculate by adding phase-specific constants to the explicit input table.
            if direction == 'output':
                values[i] = (-100, -200)[phase] + i * 3
            elif direction == 'inout':
                values[i] += (100, 200)[phase] + i
            output += [f'c index={i} before={before} after={values[i]}']
            checksum += ordinal * values[i]
        output += [f'returned={checksum}']
        output += [f'after[{i}]={values[i]}' for i in indices]
        output += ['guard=31,-47,83']
    return '\n'.join(output) + '\n', '\n'.join(requests) + '\n'


def fixed_faults(directory, verilator):
    row = generator.MODEL.anchors[1]
    path = ROOT / 'tests/gen/ch35' / (generator.case_name(row) + '.sv')
    source = path.read_text()
    for name in ('expected_stdout', 'dpi_c'):
        field = suite_results.header(path)[name]
        source = source.replace(':' + name + ': ' + field,
                                ':' + name + ': @' + str((path.parent / field[1:]).resolve()))
    helper = (ROOT / 'tests/ch35/cross_dpi_array.c').read_text()
    faults = {
        'wrong_bounds': (source, helper.replace('svLeft(a, 1)', 'svLow(a, 1)')),
        'reversed_element_walk': (source, helper.replace(
            'reverse_walk ? high - pos : low + pos', 'reverse_walk ? low + pos : high - pos')),
        'lost_sv_copyback': (source.replace('    $display("returned=',
                              '    foreach (data[i]) data[i] = 0;\n    $display("returned='), helper),
        'lost_input_sign': (source, helper.replace(
            'direction == 1 ? 0 : *element',
            'direction == 1 ? 0 : (*element < 0 ? -*element : *element)')),
        'stale_call_phase': (source.replace('(data, 0, 1)', '(data, 0, 0)'), helper),
    }
    outcomes = {}
    for name, (sv, c) in {'control': (source, helper), **faults}.items():
        assert name == 'control' or (sv, c) != (source, helper)
        c_path = directory / (name + '.c')
        c_path.write_text(c)
        sv = sv.replace('@' + str(ROOT / 'tests/ch35/cross_dpi_array.c'), '@' + str(c_path))
        test = directory / (name + '.sv')
        test.write_text(sv)
        ok, reason = run_verilator.run(test, verilator, 1)
        if name == 'control':
            assert ok, reason
        else:
            assert not ok and reason.startswith('output differs'), (name, ok, reason)
        outcomes[name] = 'pass' if ok else 'detected'
    return outcomes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    rows = generator.MODEL.rows()
    expected, requests = [], []
    for row in rows:
        text, request = independent(row)
        assert text == generator.reference(row), row
        expected.append(text)
        requests.append(request)
    with tempfile.TemporaryDirectory() as folder:
        directory = Path(folder)
        # Keep the test ABI stub out of the simulator experiment's include path.
        abi = directory / 'abi'
        abi.mkdir()
        (abi / 'svdpi.h').write_text(HEADER)
        (abi / 'driver.c').write_text(DRIVER)
        exe = abi / 'probe'
        subprocess.run([args.cc, '-std=c11', '-Wall', '-Wextra', '-Werror',
                        '-I', str(abi), str(abi / 'driver.c'),
                        str(ROOT / 'tests/ch35/cross_dpi_array.c'), '-o', str(exe)], check=True)
        for poison in ('123456', '-987654'):
            probe = subprocess.run([str(exe), poison], input=''.join(requests),
                                   capture_output=True, text=True, check=True)
            assert probe.stdout == ''.join(expected), suite_results.first_difference(
                probe.stdout, ''.join(expected))
        outcomes = fixed_faults(directory, args.verilator)
    sources = ('generators/interaction_dpi_array.py', 'tests/ch35/cross_dpi_array.c',
               'tools/qualify_dpi_array.py')
    tests = [ROOT / 'tests/gen/ch35' / (generator.case_name(r) + '.sv') for r in generator.MODEL.select()]
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'independent_rows': len(rows), 'c_stub_rows_per_poison': len(rows),
              'output_poison_values': [123456, -987654],
              'c_stub_scope': 'Test-owned ABI with separated element slots and canaries; not simulator DPI marshalling.',
              'fault_injection': outcomes,
              'compiler': suite_results.tool_version([args.cc, '--version']),
              'simulator': suite_results.tool_version([args.verilator, '--version']),
              'sources_sha256': {n: hashlib.sha256((ROOT / n).read_bytes()).hexdigest() for n in sources},
              'inputs_sha256': {t.relative_to(ROOT).as_posix(): suite_results.input_digest(t) for t in tests}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f'{len(rows)} independent rows and C-stub rows at each of two output poisons; '
          'one fixed-tool control; five output-difference faults.')


if __name__ == '__main__':
    main()
