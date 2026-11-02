#!/usr/bin/env python3
"""Check SV/DPI queries using parsed declarations, a C ABI stub and SV faults."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT/'generators'))
import interaction_dpiquery as generator

HEADER = '''
typedef void *svOpenArrayHandle;
int svDimensions(const svOpenArrayHandle);
int svLeft(const svOpenArrayHandle, int);
int svRight(const svOpenArrayHandle, int);
int svLow(const svOpenArrayHandle, int);
int svHigh(const svOpenArrayHandle, int);
int svIncrement(const svOpenArrayHandle, int);
int svSize(const svOpenArrayHandle, int);
'''
DRIVER = r'''
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"
struct shape { int rank, left[4], right[4]; };
int svDimensions(const svOpenArrayHandle h) { return ((struct shape *)h)->rank; }
int svLeft(const svOpenArrayHandle h, int d) {
    assert(d >= 0 && d <= svDimensions(h)); return ((struct shape *)h)->left[d];
}
int svRight(const svOpenArrayHandle h, int d) {
    assert(d >= 0 && d <= svDimensions(h)); return ((struct shape *)h)->right[d];
}
int svLow(const svOpenArrayHandle h, int d) {
    int l=svLeft(h,d), r=svRight(h,d); return l<r?l:r;
}
int svHigh(const svOpenArrayHandle h, int d) {
    int l=svLeft(h,d), r=svRight(h,d); return l>r?l:r;
}
int svIncrement(const svOpenArrayHandle h, int d) {
    return svLeft(h,d)<svRight(h,d)?-1:1;
}
int svSize(const svOpenArrayHandle h, int d) { return abs(svLeft(h,d)-svRight(h,d))+1; }
int cross_dpiquery(const svOpenArrayHandle, int);
int main(void) {
    struct shape a; int phase;
    while (scanf("%d %d", &a.rank, &phase)==2) {
        assert(a.rank>=1 && a.rank<=3);
        for(int d=0; d<=a.rank; ++d) assert(scanf("%d %d", &a.left[d], &a.right[d])==2);
        int result=cross_dpiquery(&a,phase);
        printf("returned=%d\n",result);
    }
    return 0;
}
'''
NAMES = ('left', 'right', 'low', 'high', 'increment', 'size')


def range_values(left, right):
    # Enumerate each index rather than sharing the generator's endpoint formulas.
    indices = list(range(left, right+(1 if left <= right else -1),
                         1 if left <= right else -1))
    return (indices[0], indices[-1], min(indices), max(indices),
            -1 if len(indices)>1 and indices[1]>indices[0] else 1, len(indices))


def interpret(source):
    shapes = {}
    for match in re.finditer(r'bit (\[-?\d+:-?\d+\]) (data_[ab])((?:\[-?\d+:-?\d+\])+);', source):
        raw = re.findall(r'\[(-?\d+):(-?\d+)\]', match[3]+match[1])
        shapes[match[2]] = [range_values(int(a),int(b)) for a,b in raw]
    assert len(shapes) == 2
    formal = re.search(r'input bit (\[\]|\[\d+:0\]) a', source)[1]
    output, requests, c_output = [], [], []
    for match in re.finditer(r'\$display\("sv phase=(\d+).*?returned = cross_dpiquery\((data_[ab]), (\d+)\);', source, re.S):
        phase, actual, call_phase = int(match[1]), match[2], int(match[3])
        assert phase == call_phase
        chunk = match[0]
        queries = re.search(r'\$dimensions\((data_[ab])\), \$unpacked_dimensions\((data_[ab])\)', chunk)
        output += [f'sv phase={phase} dims={len(shapes[queries[1]])} '
                   f'unpacked={len(shapes[queries[2]])-1}']
        for statement in re.finditer(r'\$display\("sv dim=%0d [^"]+",\s*(\d+|d),\s*(.*?)\);', chunk, re.S):
            calls = re.findall(r'\$(left|right|low|high|increment|size)\((data_[ab]), (\d+|d)\)', statement[2])
            assert [item[0] for item in calls] == list(NAMES)
            if statement[1] == 'd':
                loop = re.search(r'for \(int d = 1; d <= \$dimensions\((data_[ab])\); d\+\+\)', chunk)
                labels = range(1,len(shapes[loop[1]])+1)
            else:
                labels = (int(statement[1]),)
            for dim in labels:
                values = [shapes[who][(dim if argument == 'd' else int(argument))-1][NAMES.index(name)]
                          for name,who,argument in calls]
                output.append(f'sv dim={dim} '+ ' '.join(f'{key}={value}' for key,value in zip(NAMES,values)))
        bounds = shapes[actual]
        width = bounds[-1][-1] if formal == '[]' else int(formal[1:-3])+1
        rank = len(bounds)-1
        c_shapes = [range_values(width-1,0), *bounds[:-1]]
        c_lines = [f'c phase={phase} dims={rank}']
        checksum = 0
        for dim, values in enumerate(c_shapes):
            c_lines.append(f'c dim={dim} '+ ' '.join(f'{key}={value}' for key,value in zip(NAMES,values)))
            left,right,low,high,increment,size = values
            checksum += (dim+1)*(left*7+right*11+low*13+high*17+increment*19+size*23)
        c_lines.append(f'returned={checksum}')
        output.extend(c_lines); c_output.extend(c_lines)
        requests.append(' '.join(map(str,[rank,phase,*[number for item in c_shapes for number in item[:2]]])))
    assert len(requests) == 2
    return '\n'.join(output)+'\n', '\n'.join(requests)+'\n', '\n'.join(c_output)+'\n'


def independent(row):
    return interpret(generator.make_case(row).body)[0]


def runtime_faults(directory, verilator):
    controls = {f'rank{row[0]}_control': row for row in generator.MODEL.anchors[:3]}
    originals = {}; expected = {}; paths = {}
    c_source = (ROOT/'tests/ch35/cross_dpiquery.c').read_text()
    for name, row in controls.items():
        assert row in generator.MODEL.select()
        path = ROOT/'tests/gen/ch20'/(generator.case_name(row)+'.sv')
        source = path.read_text()
        source = source.replace(':dpi_c: '+suite_results.header(path)['dpi_c'], ':dpi_c: @probe.c')
        source = source.replace(':expected_stdout: '+suite_results.header(path)['expected_stdout'],
                                ':expected_stdout: @control.expected')
        originals[name] = source; expected[name] = generator.reference(row)
        paths[name] = path.relative_to(ROOT).as_posix()
    a,b = originals['rank1_control'], originals['rank3_control']
    wrong_packed = a.replace('$size(data_a, 2)', '$size(data_a, 1)')
    stale = b
    for query in (*NAMES,'dimensions','unpacked_dimensions'):
        stale = stale.replace('$'+query+'(data_b', '$'+query+'(data_a')
    variants = {name:(name,source,c_source) for name,source in originals.items()} | {
        'swap_c_bounds': ('rank1_control',a,c_source.replace('d, l, r, low, high, inc, size', 'd, r, l, low, high, inc, size')),
        'negate_increment': ('rank3_control',b,c_source.replace('inc = svIncrement(a, d)', 'inc = -svIncrement(a, d)')),
        'wrong_c_packed_dimension': ('rank1_control',a,c_source.replace('svSize(a, d)', 'svSize(a, d == 0 ? 1 : d)')),
        'omit_last_dimension': ('rank3_control',b,c_source.replace('d <= dims', 'd < dims')),
        'wrong_sv_packed_dimension': ('rank1_control',wrong_packed,c_source),
        'stale_sv_shape': ('rank3_control',stale,c_source),
    }
    results = {}
    for name,(control,source,foreign) in variants.items():
        assert name in controls or (source,foreign) != (originals[control],c_source)
        folder = directory/name; folder.mkdir()
        path = folder/'test.sv';path.write_text(source)
        (folder/'probe.c').write_text(foreign);(folder/'control.expected').write_text(expected[control])
        runtime = []; real_run = subprocess.run
        def capture(*args,**kwargs):
            result = real_run(*args,**kwargs)
            if isinstance(args[0],(list,tuple)) and Path(args[0][0]).name == 'Vt':runtime.append(result)
            return result
        with patch.object(run_verilator.subprocess,'run',side_effect=capture):
            ok,reason = run_verilator.run(path,verilator,1)
        assert len(runtime)==1 and runtime[0].returncode==0,(name,reason)
        actual = runtime[0]
        assert not re.search(r'unsupported|%Error|%Fatal|%Warning',actual.stdout+'\n'+actual.stderr,re.I),name
        assert ok if name in controls else not ok and reason.startswith('output differs'),(name,reason)
        raw = ''.join(line+'\n' for line in actual.stdout.splitlines() if not run_verilator.BANNER.match(line))
        normalized = real_run([sys.executable,str(run_verilator.NORMALIZE)],input=raw,capture_output=True,text=True,check=True).stdout
        results[name] = {'control':control,'status':'pass' if ok else 'detected','returncode':actual.returncode,
                         'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
                         'c_source_sha256':hashlib.sha256(foreign.encode()).hexdigest(),
                         'stdout':normalized,'stderr':actual.stderr,'reason':reason}
    return results, paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc',default='cc');parser.add_argument('--verilator',default='verilator')
    parser.add_argument('--output',type=Path,required=True);args = parser.parse_args()
    if args.output.exists():parser.error('output exists; preserve earlier evidence')
    version = subprocess.check_output([args.verilator,'--version'],text=True).strip()
    if not version.startswith('Verilator 5.052 '):parser.error('pinned Verilator 5.052 is required')
    requests = [];expected_c = []
    for row in generator.MODEL.rows():
        text,request,c_output = interpret(generator.make_case(row).body)
        assert text == generator.reference(row),row
        requests.append(request);expected_c.append(c_output)
    with tempfile.TemporaryDirectory() as temp:
        directory = Path(temp);abi = directory/'abi';abi.mkdir()
        (abi/'svdpi.h').write_text(HEADER);(abi/'driver.c').write_text(DRIVER)
        executable = abi/'probe'
        subprocess.run([args.cc,'-std=c11','-Wall','-Wextra','-Werror','-I',str(abi),
                        str(abi/'driver.c'),str(ROOT/'tests/ch35/cross_dpiquery.c'),'-o',str(executable)],check=True)
        result = subprocess.run([str(executable)],input=''.join(requests),capture_output=True,text=True,check=True)
        assert result.stdout == ''.join(expected_c),suite_results.first_difference(result.stdout,''.join(expected_c))
        faults,controls = runtime_faults(directory,args.verilator)
    sources = ('generators/interaction_dpiquery.py','tests/ch35/cross_dpiquery.c','tools/qualify_dpiquery.py')
    report = {'model':generator.MODEL.name,'version':1,
              'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope':'Independent emitted-declaration/query interpretation; actual C probe on test-owned ABI shapes (not simulator marshalling); three original normalized/sized-packed SV controls and six actual SV/C mutants. No runtime qualification of offset packed normalization or open packed formals.',
              'independent_rows':len(generator.MODEL.rows()),'c_stub_calls':2*len(generator.MODEL.rows()),
              'simulator_version':version,'compiler':suite_results.tool_version([args.cc,'--version']),
              'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in sources},
              'controls':controls,'executions':faults}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; C ABI calls:',report['c_stub_calls'],
          '; original SV controls: 3 pass; actual SV/C faults: 6 detected')


if __name__ == '__main__':main()
