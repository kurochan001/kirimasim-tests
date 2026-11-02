#!/usr/bin/env python3
"""Interpret the emitted straight-line driver and automatic event frames."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT/'generators'))
import interaction_eventlife as generator


class StrandedRegistration(Exception):
    """An armed or not-yet-armed child remains at the end of the driver."""


def interpret(source):
    """Object store + registrations + ordered NBA queue, independent of reference().

    This deliberately small interpreter accepts only this generator's emitted
    subset. It is a source-level cross-check, not a SystemVerilog simulator or
    evidence of simulator acceptance of aggregate/event operations.
    """
    task = re.search(r'task automatic launch\(.*?;(.*?)endtask', source, re.S)[1]
    setup, children = task.split('    fork\n')
    children = re.findall(r'begin\s*#(\d+);\s*@\(([^)]+)\);(.*?)end', children, re.S)
    assert children
    members = (('original_go', 'copied_go', 'original_value', 'copied_value')
               if 'event original_go' in setup else
               ('original.leaf.go', 'copied.leaf.go', 'original.leaf.value', 'copied.leaf.value')
               if 'original.leaf.' in setup else
               ('original.go', 'copied.go', 'original.value', 'copied.value'))
    state = {'noise': 0, 'stamp': 0}
    pending, waiting, nba, output = [], [], [], []
    clock, serial = 0, 1

    def evaluate(text, local=None):
        text = text.strip()
        if '&&' in text:
            return int(all(evaluate(part, local) for part in text.split('&&')))
        for operator in ('!=', '=='):
            if operator in text:
                a, b = (evaluate(part, local) for part in text.split(operator))
                return int(a != b if operator == '!=' else a == b)
        if text == 'null':
            return None
        if text == "1'b1":
            return 1
        if re.fullmatch(r'-?\d+', text):
            return int(text)
        if local is not None:
            if text == '100 + tag':
                return 100 + local['tag']
            if text == '-700 - tag':
                return -700 - local['tag']
            if text == '700 + tag':
                return 700 + local['tag']
            if text in local:
                return local[text]
        return state[text]

    def trigger(event):
        if event is None:
            return
        for registration in waiting[:]:
            handle, frame, body = registration
            if handle != event:
                continue
            for command in body.split(';'):
                command = command.strip()
                if not command:
                    continue
                command = command.replace('[tag]', f'[{frame["tag"]}]')
                inc = re.fullmatch(r'(\w+\[\d+\]\[\d+\])(\+\+| \+= \d+)', command)
                if inc:
                    key, operation = inc.groups()
                    state[key] += 1 if operation == '++' else int(operation.split()[-1])
                    continue
                lhs, rhs = command.split(' = ')
                state[lhs] = clock if rhs == '$time' else evaluate(rhs, frame)
            waiting.remove(registration)

    def flush():
        for kind, value in nba:
            if kind == 'stamp':
                state['stamp'] = value
            else:
                trigger(value)
        nba.clear()

    def advance(amount):
        nonlocal clock
        flush()
        target = clock + amount
        for due in sorted({entry[0] for entry in pending if entry[0] <= target}):
            clock = due
            for entry in pending[:]:
                tick, frame, event_field, body = entry
                if tick == due:
                    event = evaluate(event_field, frame)
                    assert event is not None, 'undefined null wait'
                    waiting.append((event, frame, body))
                    pending.remove(entry)
        clock = target

    def launch(tag, retained, bridge):
        nonlocal serial
        frame = {members[0]: serial, members[1]: serial+1,
                 members[2]: 0, members[3]: 0, 'tag': tag}
        serial += 2
        for command in setup.split(';'):
            command = command.strip()
            if ' = ' not in command:
                continue
            lhs, rhs = command.split(' = ')
            if lhs == 'copied' and rhs == 'original':
                frame.update({'copied'+key[len('original'):]: value
                              for key, value in list(frame.items()) if key.startswith('original.')})
            else:
                frame[lhs] = evaluate(rhs, frame)
        state[retained], state[bridge] = frame['retained'], frame['bridge']
        for delay, event_field, body in children:
            pending.append((clock+int(delay), frame, event_field, body))

    driver = source.split('  initial begin\n', 1)[1].rsplit('  end\n', 1)[0]
    for command in driver.split(';'):
        command = command.strip()
        if not command:
            continue
        delay = re.fullmatch(r'#(\d+)', command)
        call = re.fullmatch(r'launch\((\d+), (\w+), (\w+)\)', command)
        display = re.fullmatch(r'\$display\("([^"]*)"(?:,\s*(.*))?\)', command, re.S)
        if delay:
            advance(int(delay[1]))
        elif call:
            launch(int(call[1]), call[2], call[3])
        elif display:
            args = [] if display[2] is None else [
                clock if arg.strip() == '$time' else evaluate(arg)
                for arg in display[2].split(',')]
            output.append(display[1].replace('%0d', '%d') % tuple(args))
        elif command.startswith('->> '):
            nba.append(('event', evaluate(command[4:])))
        elif command.startswith('-> '):
            trigger(evaluate(command[3:]))
        elif command.startswith('stamp <= '):
            nba.append(('stamp', int(command[9:])))
        elif ' = ' in command:
            lhs, rhs = command.split(' = ')
            state[lhs] = evaluate(rhs)
        else:
            assert command == '$finish', command
    flush()
    if pending or waiting:
        raise StrandedRegistration()
    return '\n'.join(output)+'\n'


def independent(row):
    return interpret(generator.make_case(row).body)


def source_faults():
    row = generator.MODEL.anchors[2]
    original = generator.make_case(row).body
    scalar = generator.make_case(generator.MODEL.anchors[5]).body
    sources = {'nested_copy': original, 'scalar_copy': scalar}
    variants = {
        'drop_whole_copy': ('nested_copy', original.replace('    copied = original;\n', '')),
        'read_overwritten_payload': ('nested_copy', original.replace(
            '= copied.leaf.value;', '= original.leaf.value;')),
        'share_event_between_calls': ('nested_copy', original.replace(
            '    copied = original;', '    original.leaf.go = noise;\n    copied = original;')),
        'late_registration': ('nested_copy', original.replace('        #2;', '        #7;')),
        'release_trigger_alias_early': ('nested_copy', original.replace(
            '    primary0 = null;\n    primary1 = null;',
            '    primary0 = null; backup0 = null;\n    primary1 = null;')),
        'wrong_trigger': ('nested_copy', original.replace('    -> backup0;', '    -> backup1;')),
        'double_count': ('nested_copy', original.replace('hits[tag][0]++;', 'hits[tag][0] += 2;')),
        'lose_scalar_payload_copy': ('scalar_copy', scalar.replace(
            '    copied_value = original_value;', '    copied_value = 0;')),
    }
    results = {}
    for name, (control, changed) in variants.items():
        assert changed != sources[control], name
        try:
            actual = interpret(changed)
            assert actual != interpret(sources[control]), name
            outcome = 'output differs'
        except StrandedRegistration:
            # A stranded registration is also a semantic failure, not an SV
            # compile/runtime result. Record it without calling it a run.
            outcome = 'stranded registration'
        results[name] = {'control': control, 'source_sha256': hashlib.sha256(changed.encode()).hexdigest(),
                         'source_check': outcome}
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        parser.error('output exists; preserve earlier evidence')
    for row in generator.MODEL.rows():
        assert independent(row) == generator.reference(row), row
    files = ('generators/interaction_eventlife.py', 'tools/qualify_eventlife.py')
    report = {'model': generator.MODEL.name, 'version': generator.MODEL.version,
              'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Independent interpretation of emitted SV stimulus: object identities, automatic frames, whole copies, registrations and ordered NBA updates. Source faults are interpreted, not compiled or executed. All pinned simulator selections reject the original input; no simulator-qualified oracle or runtime fault-detection claim.',
              'independent_rows': len(generator.MODEL.rows()),
              'sources_sha256': {name: hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in files},
              'source_faults': source_faults(), 'runtime_controls': 0, 'runtime_faults': 0}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
    print('independent rows:', report['independent_rows'], '; interpreted source faults: 8; runtime qualification: none')


if __name__ == '__main__':
    main()
