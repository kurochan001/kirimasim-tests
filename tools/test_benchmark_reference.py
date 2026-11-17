# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Check independent transaction, edge-count and four-state reference contracts."""
import importlib.util
import itertools
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('speed_reference',Path(__file__).resolve().parent.parent/'bench/reference_expanded.py')
reference=importlib.util.module_from_spec(spec)
spec.loader.exec_module(reference)


class BenchmarkReferenceTests(unittest.TestCase):
    def test_scalar_resolution_conflicts_unknown_and_neutral_z(self):
        for a,b,c in itertools.product('01xz',repeat=3):
            value=reference.resolve_bit([a,b,c])
            for order in itertools.permutations([a,b,c]):
                self.assertEqual(reference.resolve_bit(order),value)
            active=set([a,b,c])-{'z'}
            if 'x' in active or {'0','1'} <= active:self.assertEqual(value,'x')
            elif not active:self.assertEqual(value,'z')
            else:self.assertEqual(value,next(iter(active)))
            self.assertEqual(reference.resolve_bit([a,b,c,'z']),value)

    def test_fifo_first_write_is_not_read_on_empty(self):
        self.assertEqual(reference.oracle('fifo_stream',1),'fifo_stream n=1 checksum=00000000 reads=0 pending=1')
        self.assertEqual(reference.oracle('fifo_stream',2),'fifo_stream n=2 checksum=3c88596c reads=1 pending=1')

    def test_uart_payload_order_and_frame_count(self):
        self.assertEqual(reference.oracle('uart_loopback',1),'uart_loopback n=1 checksum=0000005c frames=1 errors=0')
        self.assertEqual(reference.oracle('uart_loopback',2),'uart_loopback n=2 checksum=00000c81 frames=2 errors=0')

    def test_independent_clocks_finish_between_edges(self):
        # Before time 31, periods 4/6/10 have 8/5/3 positive edges.
        self.assertEqual(reference.oracle('clock_domains',1),'clock_domains n=1 checksum=00000014')

    def test_fourstate_modes_observe_both_unknown_and_floating_bits(self):
        self.assertEqual(reference.oracle('fourstate_arith',4),'fourstate_arith n=4 checksum=0000000c unknowns=2')
        self.assertTrue(reference.oracle('resolved_bus',5).endswith('x_bits=9 z_bits=8'))

    def test_all_frozen_full_workloads_and_small_expectations(self):
        reference.check()


if __name__=='__main__':unittest.main()
