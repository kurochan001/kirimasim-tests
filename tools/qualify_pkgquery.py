#!/usr/bin/env python3
"""Interpret actual package/import/query programs independently."""

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

from qualify_class_import import Type, Value, initial_value, literal
from qualify_genloop import integer
from qualify_gensub import xor
from qualify_ifquery import split_arguments
from qualify_scansel import formatted
import run_kirimasim
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_pkgquery as generator


class Array:
    def __init__(self, word, left, right):
        assert 0 < word.width <= 256 and abs(left-right) < 8
        self.word, self.left, self.right = word, left, right
        self.data = {i: initial_value(word) for i in range(min(left, right), max(left, right)+1)}

    def query(self, name, dimension):
        if name == 'bits':
            assert dimension is None; return self.word.width * len(self.data)
        if name in ('dimensions', 'unpacked_dimensions'):
            assert dimension is None; return 2 if name == 'dimensions' else 1
        assert dimension in (None, 1, 2)
        left, right = (self.left, self.right) if dimension in (None, 1) else (self.word.width-1, 0)
        return {'left': left, 'right': right, 'low': min(left, right), 'high': max(left, right),
                'increment': 1 if left >= right else -1, 'size': abs(left-right)+1}[name]


def interpret(source):
    """Resolve lexical imports and read SV declarations/statements, not row data.

    The accepted grammar is intentionally bounded. Arrays are real dictionaries
    of typed values; query operands resolve independently for every occurrence.
    """
    code = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    packages = {}
    for name, body in re.findall(r'package (\w+);(.*?)endpackage', code, re.S):
        m = re.fullmatch(r'\s*typedef (bit|logic) \[(\d+):0\] word_t;\s*word_t data\[(-?\d+):(-?\d+)\];\s*', body)
        assert m and name not in packages
        state, high, left, right = m.groups()
        packages[name] = Array(Type(int(high)+1, state, False), int(left), int(right))
    assert set(packages) == {'first_pkg', 'second_pkg'}
    code = re.sub(r'package \w+;.*?endpackage', '', code, flags=re.S)
    readers = {}
    declarations = r'\s*logic \[(\d+):0\] data\[(-?\d+):(-?\d+)\];\s*logic \[(\d+):0\] checksum=\x270;(.*?)function automatic (\w+)::word_t scan\(\);(.*?)endfunction\s*'
    for name, body in re.findall(r'module (reader_\d);(.*?)endmodule', code, re.S):
        parsed = re.fullmatch(declarations, body, re.S); assert parsed and name not in readers
        high, left, right, result_high, counters, result_package, function = parsed.groups()
        values = {'checksum': Value(int(result_high)+1)}
        for statement in (s.strip() for s in counters.split(';') if s.strip()):
            found = re.fullmatch(r'int (\w+)=0', statement); assert found and found[1] not in values
            values[found[1]] = 0
        imported = re.match(r'\s*import (\w+)::(\*|data);', function)
        selected = imported[1] if imported else None
        if imported: function = function[imported.end():]
        parsed = re.fullmatch(r'\s*(\w+)::word_t acc;\s*int at;(.*?)repeat \((.*?)\) begin(.*?)end(.*?)\s*', function, re.S)
        assert parsed and result_package in packages
        local_package, head, limit, loop, tail = parsed.groups(); assert local_package in packages
        readers[name] = {'data': Array(Type(int(high)+1, 'logic', False), int(left), int(right)),
                         'result': packages[result_package].word, 'word': packages[local_package].word,
                         'values': values, 'import': selected, 'head': head, 'limit': limit, 'loop': loop, 'tail': tail}
    assert set(readers) == {'reader_0', 'reader_1'}
    top = re.sub(r'module reader_\d;.*?endmodule', '', code, flags=re.S)
    parsed = re.fullmatch(r'\s*module \w+;\s*reader_0 a\(\); reader_1 b\(\);\s*logic \[(\d+):0\] ra=\x270, rb=\x270;\s*initial begin(.*?)\$finish;\s*end\s*endmodule\s*', top, re.S)
    assert parsed
    high, program = parsed.groups(); result_type = Type(int(high)+1, 'logic', False)
    results = {'ra': Value(result_type.width), 'rb': Value(result_type.width)}
    instances = dict(a=readers['reader_0'], b=readers['reader_1']); output = []

    def array(text, reader=None):
        text = text.strip()
        if text == 'data':
            assert reader is not None
            return packages[reader['import']] if reader['import'] else reader['data']
        m = re.fullmatch(r'(\w+)::data', text)
        if m: return packages[m[1]]
        m = re.fullmatch(r'([ab])\.data', text)
        assert m, ('unsupported array target', text)
        return instances[m[1]]['data']

    def expression(text, reader=None, frame=None):
        text = text.strip(); frame = {} if frame is None else frame
        if text in frame: return frame[text]
        if text in results: return results[text]
        if reader and text in reader['values']: return reader['values'][text]
        if text.startswith('~'):
            value = expression(text[1:], reader, frame); mask = (1 << value.width)-1
            return Value(value.width, (~(value.bits | value.x | value.z)) & mask, value.x | value.z)
        if ' ^ ' in text:
            a, b = text.split(' ^ '); return xor(expression(a, reader, frame), expression(b, reader, frame))
        shifted = re.fullmatch(r'\((\w+) << (\d+)\)', text)
        if shifted:
            value, shift = frame[shifted[1]], int(shifted[2]); mask = (1 << value.width)-1
            return Value(value.width, value.bits << shift & mask, value.x << shift & mask, value.z << shift & mask)
        element = re.fullmatch(r'([\w:.]+)\[([^]]+)\]', text)
        if element:
            owner = array(element[1], reader); at = expression(element[2], reader, frame)
            assert at in owner.data, 'out-of-range read'
            return owner.data[at]
        member = re.fullmatch(r'([ab])\.(\w+)', text)
        if member: return instances[member[1]]['values'][member[2]]
        query = re.fullmatch(r'\$(\w+)\((.*)\)', text)
        if query:
            args = split_arguments(query[2]); assert len(args) in (1, 2)
            return array(args[0], reader).query(query[1], int(args[1]) if len(args)==2 else None)
        if text == "'0":
            assert reader; return Value(reader['word'].width)
        if "'" in text: return literal(text)
        environment = {**({k:v for k,v in reader['values'].items() if isinstance(v,int)} if reader else {}),
                       **{k:v for k,v in frame.items() if isinstance(v,int)}}
        text = re.sub(r'\$(\w+)\(([\w:.]+)(?:,\s*(\d+))?\)',
                      lambda m: str(array(m[2], reader).query(m[1], int(m[3]) if m[3] else None)), text)
        return integer(text, environment)

    def execute(text, reader, frame):
        statements = [s.strip() for s in text.split(';') if s.strip()]
        for index, statement in enumerate(statements):
            if statement.startswith('return '):
                assert index == len(statements)-1
                return expression(statement[7:], reader, frame).convert(reader['result'])
            increment = re.fullmatch(r'(\w+)\+\+', statement)
            if increment: reader['values'][increment[1]] += 1; continue
            write = re.fullmatch(r'(\w+)\s*(=|\+=|-=)\s*(.*)', statement, re.S)
            assert write, ('unsupported method statement', statement)
            name, op, rhs = write.groups(); value = expression(rhs, reader, frame)
            if name == 'acc':
                assert op=='=' and isinstance(value, Value); frame[name] = value.convert(reader['word'])
            elif name == 'checksum':
                assert op=='=' and isinstance(value, Value)
                reader['values'][name] = value.convert(Type(reader['values'][name].width, 'logic', False))
            else:
                assert isinstance(value,int)
                env = frame if name == 'at' else reader['values']; assert name in env
                env[name] = value if op=='=' else env[name] + (value if op=='+=' else -value)

    def call(reader):
        frame = {'acc': initial_value(reader['word']), 'at': 0}
        assert execute(reader['head'], reader, frame) is None
        limit = expression(reader['limit'], reader, frame); assert 0 <= limit <= 8
        for _ in range(limit): assert execute(reader['loop'], reader, frame) is None
        result = execute(reader['tail'], reader, frame); assert isinstance(result,Value)
        return result.convert(result_type)

    for statement in (s.strip() for s in program.split(';') if s.strip()):
        display = re.fullmatch(r'\$(write|display)\("([^"\n]*)"(?:,\s*(.*))?\)', statement, re.S)
        if display:
            operation, fmt, arguments = display.groups()
            output.append(formatted(fmt, [expression(a) for a in split_arguments(arguments)] if arguments else []) +
                          ('\n' if operation == 'display' else '')); continue
        invoke = re.fullmatch(r'(ra|rb)=([ab])\.scan\(\)', statement)
        if invoke: results[invoke[1]] = call(instances[invoke[2]]); continue
        write = re.fullmatch(r'([\w:.]+)\[(-?\d+)\]\s*=\s*(.*)', statement, re.S)
        assert write, ('unsupported top statement', statement)
        owner, at, rhs = write.groups(); target = array(owner); at = int(at); assert at in target.data
        value = Value(target.word.width) if rhs=="'0" else expression(rhs)
        target.data[at] = value.convert(target.word)
    return ''.join(output)


def independent(row): return interpret(generator.source(row))


def variants():
    controls = {name: generator.make_case(generator.MODEL.anchors[i]) for name, i in
                (('one',0), ('wild_z',1), ('qualified_x',2), ('bit_z',3), ('known',4), ('qualified',5))}
    faults = (
        ('lost_import', 'one', [('    import first_pkg::data;', '')]),
        ('wrong_import', 'known', [('import second_pkg::data;', 'import first_pkg::data;')]),
        ('reverse_scan', 'known', [('at=$left(data, 1)', 'at=$right(data, 1)'), ('at-=$increment', 'at+=$increment')]),
        ('short_scan', 'known', [('repeat ($size(data, 1))', 'repeat ($size(data, 1)-1)')]),
        ('lost_shift', 'known', [('acc << 1', 'acc << 0')]),
        ('wrong_dimension', 'known', [('psize=$size(data, 2)', 'psize=$size(data, 1)')]),
        ('wrong_caller', 'one', [('ra=a.scan()', 'ra=b.scan()')]),
        ('clobbered_local', 'known', [('a.data[7]=~a.data[7]', "a.data[7]='0")]),
        ('wrong_query_operand', 'known', [('bits=$bits(data)', 'bits=$bits(first_pkg::data)')]),
    )
    programs = {name:(name,case.body,'control') for name,case in controls.items()}
    for name, parent, edits in faults:
        source = controls[parent].body
        for old,new in edits:
            assert old in source,(name,old); source = source.replace(old,new)
        assert interpret(source) != controls[parent].expected,name
        programs[name] = parent,source,'fault'
    return controls,programs


def runtime(executable, directory):
    import common
    controls, programs = variants(); records = {}
    for name, (parent, body, kind) in programs.items():
        case = controls[parent]; source,_ = common.render(case,generator.NAME,generator.VERSION,generator.CHAPTER,'spec')
        source = source.replace(case.body.strip('\n'),body.strip('\n'))
        original = ROOT/'tests/gen/ch26'/(case.name+'.sv')
        folder = directory/name; folder.mkdir(); path = folder/original.name
        path.write_text(source); path.with_suffix('.expected').write_text(case.expected)
        calls,run = [],subprocess.run
        def capture(*args,**kwargs):
            result = run(*args,**kwargs)
            if args[0][0] == executable: calls.append(result)
            return result
        with patch.object(run_kirimasim.subprocess,'run',side_effect=capture): status,reason = run_kirimasim.run(path,executable)
        assert len(calls)==1 and calls[0].returncode==0,(name,status,reason)
        assert status==('pass' if kind=='control' else 'fail'),(name,status,reason)
        if kind=='fault': assert reason.startswith('output differs'),(name,reason)
        normalized = run([sys.executable,str(run_kirimasim.NORMALIZE)],input=calls[0].stdout,text=True,capture_output=True,check=True).stdout
        records[name] = {'kind':kind,'control':parent,'status':'pass' if kind=='control' else 'detected',
                         'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'original_test':original.relative_to(ROOT).as_posix(),
                         'original_input_sha256':suite_results.input_digest(original),'expected_stdout':case.expected,
                         'stdout':normalized,'stderr':calls[0].stderr.replace(str(folder),'<case>'),'returncode':0}
    return records


def main():
    parser=argparse.ArgumentParser(description=__doc__); parser.add_argument('--kirimasim',required=True)
    parser.add_argument('--output',required=True,type=Path); args=parser.parse_args()
    if args.output.exists(): parser.error('preserve prior qualification evidence')
    files=('generators/interaction_pkgquery.py','generators/interaction_class_import.py','generators/interaction_cond.py',
           'generators/interaction_cover.py','generators/common.py','tools/qualify_pkgquery.py','tools/qualify_class_import.py',
           'tools/qualify_genloop.py','tools/qualify_gensub.py','tools/qualify_ifquery.py','tools/qualify_scansel.py')
    def hashes(): return {p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in files}
    sources=hashes(); runner=suite_results.runner_digest('kirimasim'); binary=Path(args.kirimasim).resolve()
    before=hashlib.sha256(binary.read_bytes()).hexdigest()
    paths=[ROOT/'tests/gen/ch26'/(generator.case_name(row)+'.sv') for row in generator.MODEL.select()]
    inputs={p:suite_results.input_digest(p) for p in paths}; evidence=hashlib.sha256()
    for row in generator.MODEL.rows():
        source,expected=generator.source(row),generator.reference(row)
        assert interpret(source)==expected,row
        evidence.update(source.encode()+b'\0'+expected.encode()+b'\0')
    with tempfile.TemporaryDirectory() as tmp: executions=runtime(str(binary),Path(tmp))
    assert hashes()==sources and runner==suite_results.runner_digest('kirimasim')
    assert all(suite_results.input_digest(p)==v for p,v in inputs.items())
    assert hashlib.sha256(binary.read_bytes()).hexdigest()==before
    result={'model':generator.MODEL.name,'generated_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'scope':'Independent lexical binding, typed-array queries and ordered scans of actual SV. Auxiliary controls/faults are not fixed-suite or coverage passes.',
            'rows_interpreted':len(generator.MODEL.rows()),'selected':len(paths),'source_and_expectation_sha256':evidence.hexdigest(),
            'source_sha256':sources,'runner_sha256':runner,'binary_sha256':before,
            'version':subprocess.check_output([str(binary),'--version'],text=True).strip(),
            'sources_unchanged':True,'inputs_unchanged':True,'binary_unchanged':True,'executions':executions}
    args.output.parent.mkdir(parents=True,exist_ok=True); args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print('Independent rows:',result['rows_interpreted'],'; native controls: 6; detected SV faults: 9')


if __name__=='__main__': main()
