#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent mathematical/transaction oracles for the added speed designs.

No simulator output is read. Integer arithmetic, FIFO transactions, UART bytes,
per-clock edge counts, and scalar net resolution provide the expected results.
Run --check to verify frozen headers, both expectations and source hashes.
"""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path

MASK = (1 << 32) - 1
ROOT = Path(__file__).resolve().parent.parent


def resolve_bit(drivers):
    active = set(drivers) - {'z'}
    if not active:
        return 'z'
    return next(iter(active)) if len(active) == 1 else 'x'


def oracle(name, n):
    checksum = 0
    extra = ''
    if name == 'fifo_stream':
        queue = deque(); seed = 1; reads = 0
        for i in range(1, n + 1):
            seed = (seed * 1664525 + 1013904223) & MASK
            push, pop = i % 5 != 0 and len(queue) < 64, i % 3 != 0 and bool(queue)
            if pop:
                checksum = ((checksum * 33) ^ queue.popleft()) & MASK
                reads += 1
            if push:
                queue.append(seed)
        extra = f' reads={reads} pending={len(queue)}'
    elif name == 'uart_loopback':
        for i in range(1, n + 1):
            checksum = (checksum * 33 + ((i * 73 + 19) & 255)) & MASK
        extra = f' frames={n} errors=0'
    elif name == 'bus_fabric':
        memory = [0] * 128; seed = 1
        for i in range(1, n + 1):
            seed = (seed * 1664525 + 1013904223) & MASK
            memory[(i * 17) % 128] = seed
            checksum = ((checksum + memory[(i * 29 + 7) % 128]) ^ i) & MASK
    elif name == 'hierarchy_fanout':
        seed = 1
        for i in range(1, n + 1):
            seed = (seed * 1664525 + 1013904223) & MASK
            for leaf in range(128):
                value = ((seed ^ ((leaf * 0x10203) & MASK)) + (seed << (leaf % 7 + 1))) & MASK
                checksum = ((checksum * 33) ^ value) & MASK
    elif name == 'event_fanout':
        checksum = sum((i + 1) * ((n + i) // 17 - i // 17) for i in range(256)) & MASK
    elif name == 'word_boundary':
        a = 0xFEDCBA9876543210; b = (1 << 64) | 0x123456789ABCDEF0
        for i in range(1, n + 1):
            a ^= (a << 13) & ((1 << 64) - 1)
            a ^= a >> 7
            a ^= (a << 17) & ((1 << 64) - 1)
            b = (((b << 1) | (b >> 64)) ^ a) & ((1 << 65) - 1)
            shift = i % 65
            checksum = ((checksum + (((a >> shift) ^ (b >> shift)) & MASK)) ^ ((b >> shift) & 1)) & MASK
    elif name == 'wide_divide':
        value = (1 << 256) | 0x123456789ABCDEF0
        for i in range(1, n + 1):
            value = ((value << 7) ^ (value >> 3) ^ ((i * 17) & MASK)) & ((1 << 257) - 1)
            quotient, remainder = divmod(value, i % 65521 + 1)
            checksum = (checksum + ((quotient & MASK) ^ (quotient >> 225) ^ remainder)) & MASK
    elif name == 'packed_slice':
        value = (1 << 510) | 0x123456789ABCDEF0
        for i in range(1, n + 1):
            value = (((value << 13) | (value >> 498)) ^ i) & ((1 << 511) - 1)
            part = (value >> ((i * 37) % 480)) & MASK
            position = (i * 53) % 480
            value = (value & ~(MASK << position)) | (((part ^ (i * 0x9E37)) & MASK) << position)
            checksum = (checksum + part) & MASK
    elif name == 'memory_scatter':
        memory = [((i * 0x10203) ^ 0x89ABCDEF) & MASK for i in range(32768)]; seed = 1
        for i in range(1, n + 1):
            seed = (seed * 1664525 + 1013904223) & MASK
            write = (seed >> 7) & 32767; read = ((seed >> 17) ^ seed) & 32767
            old = memory[read]
            memory[write] = ((old + seed) ^ i) & MASK
            checksum = ((checksum + old) ^ memory[write]) & MASK
    elif name == 'clock_domains':
        finish = 30 * n + 1
        checksum = ((finish + 2) // 4 * 3) ^ ((finish + 3) // 6 * 5) ^ ((finish + 5) // 10 * 7)
        checksum &= MASK
    elif name == 'fourstate_arith':
        unknowns = 0
        for i in range(1, n + 1):
            if i % 4 in (1, 2):
                unknowns += 1
            elif i % 4 == 0:
                checksum = (checksum + (((i << 33) + i * 3) & MASK)) & MASK
            else:
                signed = -(1 << 64) + i
                checksum = (checksum ^ ((signed >> (i % 65)) & MASK)) & MASK
        extra = f' unknowns={unknowns}'
    elif name == 'resolved_bus':
        xs = zs = 0
        for i in range(1, n + 1):
            value = (i * 37) & 255; mode = i % 5; known = 0
            for bit in range(8):
                a = str((value >> bit) & 1)
                b = str(((value ^ (255 if mode == 3 else 1 << (i % 8))) >> bit) & 1)
                drivers = [] if mode == 0 else [a] if mode == 1 else [a, a, 'z'] if mode == 2 else [a, b]
                resolved = resolve_bit(drivers)
                xs += resolved == 'x'; zs += resolved == 'z'
                known |= (resolved == '1') << bit
            checksum = (checksum * 33 + known) & MASK
        extra = f' x_bits={xs} z_bits={zs}'
    elif name == 'large_hierarchy':
        values = list(range(1024))
        for step in range(1, n + 1):
            for leaf, value in enumerate(values):
                if (step + leaf) % 7:
                    values[leaf] = ((value * 33) ^ (step + leaf)) & MASK
        checksum = sum(values) & MASK
    elif name == 'large_memory':
        memory = [i ^ 0x13579BDF for i in range(262144)]
        for step in range(1, n + 1):
            for offset in range(64):
                index = (step * 4093 + offset * 257) & 262143
                old = memory[index]
                memory[index] = (old + step + offset) & MASK
                checksum = (checksum + (old ^ memory[index])) & MASK
    elif name == 'stream_pipeline':
        frames = 0
        for step in range(1, n + 1):
            if step % 5 == 0 or step % 7 == 0:
                continue
            total = 0
            for lane in range(32):
                value = (step * 17 + lane) & MASK
                for stage in range(8):
                    value = ((value * 33) ^ (stage * 0x10203 + lane)) & MASK
                total = (total + value) & MASK
            checksum = ((checksum * 33) ^ total) & MASK
            frames += 1
        extra = f' frames={frames}'
    else:
        raise ValueError('unknown reference case: ' + name)
    return f'{name} n={n} checksum={checksum:08x}' + extra


COUNTS = {'fifo_stream':200000, 'uart_loopback':20000, 'bus_fabric':150000,
          'hierarchy_fanout':100000, 'event_fanout':50000, 'word_boundary':4000000,
          'wide_divide':80000, 'packed_slice':1500000, 'memory_scatter':5000000,
          'clock_domains':20000, 'fourstate_arith':100000, 'resolved_bus':50000,
          'large_hierarchy':20000, 'large_memory':500000, 'stream_pipeline':250000}


def check():
    manifest = json.loads((ROOT/'bench/daily.json').read_text())
    cases = {c['name']: c for c in manifest['cases']}
    for name, n in COUNTS.items():
        c = cases[name]; source = ROOT/c['path']; text = source.read_text()
        assert c['count'] == n, name + ': count'
        assert c['sha256'] == hashlib.sha256(source.read_bytes()).hexdigest(), name + ': source hash'
        for field, count in [('expected',n), ('expected_small',1)]:
            expected = oracle(name, count)
            assert c[field] == expected, name + ': expectation'
            header = '// bench-expect: ' if field == 'expected' else '// bench-expect-small: '
            assert header + expected in text, name + ': header'
    print(f'{len(COUNTS)} independent references, full workloads, n=1, and frozen sources match')


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--check', action='store_true'); p.add_argument('--case', choices=COUNTS)
    p.add_argument('--n', type=int, default=1); args = p.parse_args()
    if args.check:
        check()
    elif args.case and args.n > 0:
        print(oracle(args.case, args.n))
    else:
        p.error('choose --check or --case NAME --n positive-count')
