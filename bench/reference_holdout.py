#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent oracles for the holdout speed designs.

No simulator output is read. Each design is modelled from the rules of
IEEE 1800-2023 that it exercises: object dispatch and queue order, a
cycle model of the interface handshake, IEEE 754 double additions with
exact power-of-two products, the override rules of force/assign, the
continuous-assignment delay steps of 10.3.3 and the gate delays of 28.16,
module path delays with default pulse rejection (30.7), and the exact
text that the formatting tasks write. The waveform conditions reuse the
bus_fabric oracle of bench/reference_expanded.py.
Run --check to verify frozen headers, both expectations and source hashes.
"""
import argparse
import hashlib
import importlib.util
import json
import struct
from pathlib import Path

MASK = (1 << 32) - 1
ROOT = Path(__file__).resolve().parent.parent


def lcg(seed):
    return (seed * 1664525 + 1013904223) & MASK


def expanded():
    spec = importlib.util.spec_from_file_location('reference_expanded', ROOT / 'bench/reference_expanded.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def class_pool(n):
    """8.5, 8.13, 8.20: a handle keeps its object's class, and a virtual call
    runs the override of that class; 7.10.2: push_back/pop_front keep order."""
    def weight(kind, ident, payload):
        if kind == 'read':
            return ((payload >> 3) + ident * 3) & MASK
        base = payload ^ ident
        return ((payload * 5) ^ ((payload << 1) & MASK) ^ base) & MASK
    pool, seed, checksum, consumed, reads = [], 1, 0, 0, 0
    for i in range(1, n + 1):
        seed = lcg(seed)
        if seed >> 7 & 1:
            pool.append(('read', i, seed)); reads += 1
        else:
            pool.append(('write', i, seed))
        if i % 3 == 0 or len(pool) > 8:
            checksum = ((checksum * 33) ^ weight(*pool.pop(0))) & MASK
            consumed += 1
    while pool:
        checksum = ((checksum * 33) ^ weight(*pool.pop(0))) & MASK
        consumed += 1
    return f'checksum={checksum:08x} consumed={consumed} reads={reads}'


def intf_modport(n):
    """A cycle model of the three clocked processes: each reads the values
    before the edge, and the nonblocking updates (10.4.2) apply after all of
    them ran. The source's seed is a blocking variable of its own process."""
    valid = ready = done = 0
    data = offered = checksum = accepted = cycle = parity = transfers = 0
    seed = 1
    while not done:
        next_valid, next_data, next_offered, next_done = valid, data, offered, done
        if not valid or ready:
            if offered < n:
                seed = lcg(seed)
                next_data, next_valid, next_offered = seed, 1, offered + 1
            else:
                next_valid, next_done = 0, 1
        if valid and ready:
            checksum = ((checksum * 33) ^ data) & MASK
            accepted += 1
            parity ^= data
            transfers += 1
        next_ready = 1 if cycle % 3 != 0 else 0
        cycle += 1
        valid, data, offered, done, ready = next_valid, next_data, next_offered, next_done, next_ready
    return f'checksum={checksum:08x} accepted={accepted} transfers={transfers} parity={parity:08x}'


def real_bits(value):
    return struct.unpack('<Q', struct.pack('<d', value))[0]


def real_filter(n):
    """6.12 and 11.3.1: real is IEEE 754 double precision. The coefficients
    are powers of two, so each product is exact and the sum is rounded left to
    right exactly as Python's float does it."""
    y = y1 = y2 = 0.0
    seed = 1
    checksum = 0
    for _ in range(n):
        seed = lcg(seed)
        x = float((seed >> 16) - (1 << 16) if seed >> 31 else seed >> 16)
        y = x * 0.125 + y1 * 0.5 + y2 * 0.25
        y2, y1 = y1, y
        bits = real_bits(y)
        checksum = ((checksum * 33) ^ (bits >> 32) ^ (bits & MASK)) & MASK
    return f'checksum={checksum:08x} last={real_bits(y):016x}'


def force_release(n):
    """10.6.2: a forced net holds the value of its force expression, which
    follows src, and takes its driven value again at release. 10.6.1: while a
    procedural continuous assignment holds, procedural writes to the variable
    have no effect; after deassign it keeps its value until the next write."""
    driver = src = v = checksum = 0
    seed = 1
    forced = assigned = False
    w = 0
    for i in range(1, n + 1):
        seed = lcg(seed)
        driver = seed
        step = i % 4
        if step == 0:
            forced = assigned = True
        elif step == 1:
            src = seed >> 3
            if not assigned:
                v = seed
        elif step == 2:
            forced = assigned = False
        else:
            if not assigned:
                v = seed ^ 0xffff
            src = (src + 7) & MASK
        if assigned:
            v = (src + 1) & MASK
        w = src ^ 0x5a5a5a5a if forced else driver
        checksum = ((checksum * 33) ^ w ^ ((v << 1) & MASK)) & MASK
    return f'checksum={checksum:08x} w={w:08x} v={v:08x}'


def delayed_nets(n):
    """28.16, Table 28-9: a change to 1 takes the rise delay and a change to 0
    the fall delay. 10.3.3: a continuous assignment schedules its new value
    after that delay; when the right-hand side returns to the present value
    before then, the scheduled change is removed (steps b and c). Every
    change of a, b and c is followed by a settle longer than every delay, the
    pulses on c never last exactly 8, and no sample falls on a delay."""
    a = b = c = 0
    y = z = g = 0
    h = 1
    seed = 1
    checksum = 0
    widths = (2, 4, 6, 10, 12)

    def fold(k, y, z, g, h):
        return (k << 4) | (y << 3) | (z << 2) | (g << 1) | h
    for _ in range(n):
        seed = lcg(seed)
        a, b, c = seed & 1, seed >> 1 & 1, seed >> 2 & 1
        w = widths[(seed >> 3 & 7) % 5]
        y_next, g_next, h_next, z_next = a & b, a & b, 1 - (a | b), a ^ c
        # Midway, at 9: y rises after 6 and falls after 10, g rises after 4
        # and falls after 12, h and z change after 6 and 8.
        y_mid = y_next if y_next > y else y
        g_mid = g_next if g_next > g else g
        checksum = ((checksum * 33) ^ fold(0, y_mid, z_next, g_mid, h_next)) & MASK
        y, z, g, h = y_next, z_next, g_next, h_next
        checksum = ((checksum * 33) ^ fold(1, y, z, g, h)) & MASK
        # The pulse on c: removed when shorter than 8, else z follows it 8 later.
        pulsed = z ^ 1 if w > 8 else z
        checksum = ((checksum * 33) ^ fold(2, y, pulsed, g, h)) & MASK
        checksum = ((checksum * 33) ^ fold(3, y, z, g, h)) & MASK
    return f'checksum={checksum:08x}'


def specify_paths(n):
    """30.4: a module path delays the output change by the delay of its
    transition (rise 6 / fall 10 for the buffer). 30.7: by default a pulse
    shorter than the path delay (8 for the inverter) is rejected. Each change
    of the xor cell's inputs is separated by more than both path delays."""
    a = b = p = 0
    y1, y2, y3 = 0, 1, 0
    seed = 1
    checksum = 0
    widths = (2, 4, 6, 10, 12)

    def fold(k, y1, y2, y3):
        return (k << 3) | (y1 << 2) | (y2 << 1) | y3
    for _ in range(n):
        seed = lcg(seed)
        w = widths[(seed >> 3 & 7) % 5]
        a = seed & 1
        y1_mid = a if a > y1 else y1          # at 7: a rise (6) shows, a fall (10) not
        checksum = ((checksum * 33) ^ fold(0, y1_mid, y2, a ^ b)) & MASK
        y1, y3 = a, a ^ b
        checksum = ((checksum * 33) ^ fold(1, y1, y2, y3)) & MASK
        old = y3
        b = seed >> 2 & 1
        checksum = ((checksum * 33) ^ fold(2, y1, y2, old)) & MASK      # 5 after b: before 6
        y3 = a ^ b
        checksum = ((checksum * 33) ^ fold(3, y1, y2, y3)) & MASK
        pulsed = y2 ^ 1 if w > 8 else y2      # 9 after the pulse starts
        checksum = ((checksum * 33) ^ fold(4, y1, pulsed, y3)) & MASK
        checksum = ((checksum * 33) ^ fold(5, y1, y2, y3)) & MASK
    return f'checksum={checksum:08x}'


def file_output(n):
    """21.2.1: %0d prints the decimal value with no padding and %h of a 32-bit
    value prints eight lowercase digits. 21.3.4.2: $fgets reads a line with
    its newline, so each length counts the newline; $ftell after the writes
    is the byte count of the file."""
    words = ('alpha', 'beta', 'gamma', 'delta')
    seed = 1
    checksum = size = 0
    for i in range(1, n + 1):
        seed = lcg(seed)
        line = f'{i}:{seed:08x}:{words[seed >> 8 & 3]}:{seed & 0xffff}\n'
        size += len(line)
        checksum = ((checksum * 33) ^ len(line)) & MASK
    return f'lines={n} bytes={size} checksum={checksum:08x}'


def oracle(name, n):
    if name == 'class_pool':
        extra = class_pool(n)
    elif name == 'intf_modport':
        extra = intf_modport(n)
    elif name == 'real_filter':
        extra = real_filter(n)
    elif name == 'force_release':
        extra = force_release(n)
    elif name == 'delayed_nets':
        extra = delayed_nets(n)
    elif name == 'specify_paths':
        extra = specify_paths(n)
    elif name == 'file_output':
        extra = file_output(n)
    else:
        raise ValueError('unknown reference case: ' + name)
    return f'{name} n={n} ' + extra


DESIGNS = ('class_pool', 'intf_modport', 'real_filter', 'force_release', 'delayed_nets',
           'specify_paths', 'file_output')


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def check():
    manifest = json.loads((ROOT / 'bench/holdout.json').read_text())
    bus_fabric = expanded().oracle
    assert manifest['reference_sources']['bench/reference_holdout.py'] == digest('bench/reference_holdout.py'), 'reference hash'
    assert manifest['reference_sources']['bench/reference_expanded.py'] == digest('bench/reference_expanded.py'), 'reference hash'
    assert manifest['driver_sha256'] == digest('tools/holdout_benchmark.py'), 'driver hash'
    seen = set()
    for c in manifest['cases']:
        name, design = c['name'], c.get('result_name', c['name'])
        assert c['sha256'] == digest(c['path']), name + ': source hash'
        for path, value in c.get('files', {}).items():
            assert value == digest(path), name + ': extra file hash'
        for field, n in (('expected', c['count']), ('expected_small', 1)):
            expected = bus_fabric(design, n) if design == 'bus_fabric' else oracle(design, n)
            assert c[field] == expected, name + ': ' + field
        if name in DESIGNS:
            text = (ROOT / c['path']).read_text()
            assert f'// bench-n: {c["count"]}\n' in text, name + ': count header'
            assert f'// bench-expect: {c["expected"]}\n' in text, name + ': header'
            assert f'// bench-expect-small: {c["expected_small"]}\n' in text, name + ': small header'
            assert f'$value$plusargs("n=%d", n)) n = {c["count"]};' in text, name + ': default count'
        seen.add(design)
    assert seen == {*DESIGNS, 'bus_fabric'}, 'conditions'
    print(f'{len(manifest["cases"])} holdout conditions: independent references, full workloads, '
          'n=1 and frozen sources match')


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--check', action='store_true')
    p.add_argument('--case', choices=DESIGNS); p.add_argument('--n', type=int, default=1)
    args = p.parse_args()
    if args.check:
        check()
    elif args.case and args.n > 0:
        print(oracle(args.case, args.n))
    else:
        p.error('choose --check or --case NAME --n positive-count')
