#!/usr/bin/env python3
"""Interpret rendered specify/SDF paths and qualify observations with Icarus."""

import argparse
import datetime
import hashlib
import heapq
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

import run_icarus
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'generators'))
import interaction_sdfpath as generator


def sexpr(text):
    tokens = re.findall(r'"[^"\n]*"|[()]|[^\s()]+',text)
    position = 0
    def parse():
        nonlocal position
        token = tokens[position];position += 1
        if token != '(':
            assert token != ')'
            return json.loads(token) if token.startswith('"') else token
        values = []
        while tokens[position] != ')':
            values.append(parse())
        position += 1
        return values
    result = parse();assert position == len(tokens)
    return result


def child(node,name):
    found = [item for item in node if isinstance(item,list) and item[0] == name]
    assert len(found) == 1,(name,found)
    return found[0]


def paths(source):
    declarations = source.split('  specify\n',1)[1].split('  endspecify',1)[0]
    result = []
    for match in re.finditer(r'(?:(if \(sel\)|if \(!sel\)|ifnone)\s+)?\(a => ([yz])\) = \((\d+), (\d+)\);',declarations):
        condition = {None:'all','if (sel)':'on','if (!sel)':'off','ifnone':'default'}[match[1]]
        result.append({'condition':condition,'port':match[2],
                       'delay':[int(match[3]),int(match[4])]})
    assert len(result) in (2,3)
    return result


def interpret(source):
    # Decode the SDF actually written by the SV input, not generator.sdf_text().
    written = re.findall(r'\$fdisplay\(fd, "((?:\\.|[^"\\])*)"\);',source)
    text = '\n'.join(json.loads('"'+line+'"') for line in written)
    tree = sexpr(text)
    assert child(tree,'TIMESCALE')[1] == '1ns'
    cell = child(tree,'CELL');assert child(cell,'CELLTYPE')[1] == 'cross_sdf_cell'
    instance = child(cell,'INSTANCE')[1:]
    call = re.search(r'\$sdf_annotate\("cross_path.sdf"(?:, ([vg]))?\);',source)
    assert call
    target = instance[0] if instance else call[1]
    assert target in ('v','g')
    assert not (instance and call[1]), 'nested instance scopes are outside this interpreter'
    declaration = paths(source)
    banks = {name:[{'condition':p['condition'],'port':p['port'],'delay':list(p['delay'])}
                   for p in declaration] for name in ('v','g')}
    mode = child(cell,'DELAY')[1];assert mode[0] in ('ABSOLUTE','INCREMENT')
    entry = mode[1]
    condition = 'all'
    if entry[0] == 'COND':
        condition = {'sel':'on','!sel':'off'}[entry[1]];entry = entry[2]
    elif entry[0] == 'CONDELSE':
        condition = 'default';entry = entry[1]
    assert entry[:2] == ['IOPATH','a']
    port = entry[2];delta = [int(value[0]) for value in entry[3:]]
    assert len(delta) == 2
    matched = 0
    for path in banks[target]:
        if path['port'] == port and (condition == 'all' or condition == path['condition']):
            path['delay'] = [old+amount if mode[0] == 'INCREMENT' else amount
                             for old,amount in zip(path['delay'],delta)]
            matched += 1
    assert matched
    initial = re.search(r'reg vsel = ([01]), gsel = ([01]);',source)
    selects = {'v':int(initial[1]),'g':int(initial[2])}
    outputs = {name:[0,0,-1] for name in ('v_y','v_z','g_y','g_z')}
    pending = [];clock = 0;data = 0;lines = []
    def advance(amount):
        nonlocal clock
        clock += amount
        while pending and pending[0][0] <= clock:
            due,name,value = heapq.heappop(pending)
            old,hits,last = outputs[name]
            if old != value:
                outputs[name] = [value,hits+int(due>=20),due if due>=20 else last]
    def change(value):
        nonlocal data
        if value == data:return
        edge = 0 if value else 1
        for name in outputs:
            instance,port = name.split('_');enabled = []
            for path in banks[instance]:
                c = path['condition']
                if path['port'] == port and (c == 'all' or c == ('on' if selects[instance] else 'off')):
                    enabled.append(path)
            if not enabled:
                enabled = [p for p in banks[instance] if p['port'] == port and p['condition'] == 'default']
            assert len(enabled) == 1
            heapq.heappush(pending,(clock+enabled[0]['delay'][edge],name,value))
        data = value
    driver = source.split('  initial begin\n',1)[1]
    pattern = r'#(\d+);|\b(a|vsel|gsel) = ([01]);|\$display\("phase=(\d+) time='
    for token in re.finditer(pattern,driver):
        if token[1] is not None:
            advance(int(token[1]))
        elif token[2] == 'a':
            change(int(token[3]))
        elif token[2]:
            selects[token[2][0]] = int(token[3])
        else:
            phase = int(token[4])
            lines += [f'phase={phase} time={clock} vsel={selects["v"]} gsel={selects["g"]} a={data}']
            for name,(value,hits,last) in outputs.items():
                lines.append(f'phase={phase} lane={name} value={value} hits={hits} last={last}')
    assert not pending
    return '\n'.join(lines)+'\n'


def independent(row):
    return interpret(generator.make_case(row).body)


def source_faults():
    changed = {}
    row = generator.MODEL.anchors[3]
    case = generator.make_case(row)
    old = '(COND sel (IOPATH a y (8) (2)))'
    changed['unconditional_matches_both'] = (row,case.body.replace(old,'(IOPATH a y (8) (2))'))
    row = generator.MODEL.anchors[4];case = generator.make_case(row)
    changed['increment_replaces'] = (row,case.body.replace('(INCREMENT','(ABSOLUTE'))
    row = generator.MODEL.anchors[5];case = generator.make_case(row)
    changed['ifnone_matches_on'] = (row,case.body.replace('(CONDELSE (IOPATH','(COND sel (IOPATH'))
    results = {}
    for name,(row,source) in changed.items():
        assert source != generator.make_case(row).body
        assert interpret(source) != generator.reference(row),name
        results[name] = {'source_check':'output differs','source_sha256':hashlib.sha256(source.encode()).hexdigest()}
    return results


def runtime_faults(directory,iverilog_bin):
    rows = {f'control{index}':row for index,row in enumerate(generator.MODEL.anchors[:3])}
    originals = {};expected = {};paths_by_name = {}
    for name,row in rows.items():
        assert row in generator.MODEL.select()
        path = ROOT/'tests/gen/ch32'/(generator.case_name(row)+'.sv')
        source = path.read_text();field = suite_results.header(path)['expected_stdout']
        originals[name] = source.replace(':expected_stdout: '+field,':expected_stdout: @control.expected')
        expected[name] = generator.reference(row);paths_by_name[name] = path.relative_to(ROOT).as_posix()
    a,b,c = (originals['control'+str(index)] for index in range(3))
    variants = {name:(name,source) for name,source in originals.items()} | {
        'wrong_cell_scope':('control0',a.replace('$sdf_annotate("cross_path.sdf", v);',
                                               '$sdf_annotate("cross_path.sdf", g);')),
        'swap_rise_fall':('control1',b.replace('(IOPATH a y (8) (2))','(IOPATH a y (2) (8))')),
        'skip_annotation':('control0',a.replace('    $sdf_annotate("cross_path.sdf", v);','')),
        'wrong_output_path':('control1',b.replace('(IOPATH a y (8) (2))','(IOPATH a z (8) (2))')),
        'annotate_both_instances':('control0',a.replace('$sdf_annotate("cross_path.sdf", v);',
            '$sdf_annotate("cross_path.sdf", v);\n    $sdf_annotate("cross_path.sdf", g);')),
        'wrong_unannotated_path':('control2',c.replace('(a => z) = (4, 6);','(a => z) = (8, 2);')),
    }
    executions = {}
    for name,(control,source) in variants.items():
        assert name in rows or source != originals[control],name
        folder = directory/name;folder.mkdir();test = folder/'test.sv'
        test.write_text(source);(folder/'control.expected').write_text(expected[control])
        runtime = [];real_run = subprocess.run
        def capture(*args,**kwargs):
            result = real_run(*args,**kwargs)
            if isinstance(args[0],(list,tuple)) and Path(args[0][0]).name == 'vvp':runtime.append(result)
            return result
        with patch.object(run_icarus.subprocess,'run',side_effect=capture):
            ok,reason = run_icarus.run(test,iverilog_bin)
        assert len(runtime) == 1 and runtime[0].returncode == 0,(name,reason)
        actual = runtime[0]
        assert not re.search(r'unsupported|error|warning|fatal',actual.stdout+'\n'+actual.stderr,re.I),name
        assert ok if name in rows else not ok and reason.startswith('output differs'),(name,reason)
        raw = ''.join(line+'\n' for line in actual.stdout.splitlines()
                      if not run_icarus.SEVERITY.match(line) and not run_icarus.VCD_BANNER.match(line))
        normalized = real_run([sys.executable,str(run_icarus.NORMALIZE)],input=raw,capture_output=True,text=True,check=True).stdout
        executions[name] = {'control':control,'status':'pass' if ok else 'detected','returncode':actual.returncode,
                            'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
                            'stdout':normalized,'stderr':actual.stderr,'reason':reason}
    return executions,paths_by_name


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--iverilog-bin',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True);args = parser.parse_args()
    if args.output.exists():parser.error('output exists; preserve earlier evidence')
    version = suite_results.tool_version([str(args.iverilog_bin/'iverilog'),'-V'])
    if 'Icarus Verilog version 13.0' not in version:parser.error('pinned Icarus 13.0 is required')
    for row in generator.MODEL.rows():assert independent(row) == generator.reference(row),row
    faults = source_faults()
    with tempfile.TemporaryDirectory() as folder:executions,controls = runtime_faults(Path(folder),args.iverilog_bin)
    names = ('generators/interaction_sdfpath.py','tools/qualify_sdfpath.py')
    report = {'model':generator.MODEL.name,'version':1,
              'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope':'Independent parsing of rendered specify paths, SDF expressions and stimulus; event-heap simulation for every legal row. Three original plain/ABSOLUTE controls and six actual SV/SDF mutants execute on pinned Icarus. Additional COND/CONDELSE/INCREMENT source mutations are interpreted only, not runtime-qualified.',
              'independent_rows':len(generator.MODEL.rows()),'simulator_version':version,
              'sources_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in names},
              'source_faults':faults,'controls':controls,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('independent rows:',report['independent_rows'],'; original controls: 3 pass; runtime faults: 6 detected; source-only faults: 3')


if __name__ == '__main__':main()
