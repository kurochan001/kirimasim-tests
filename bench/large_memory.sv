// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 500000
// bench-expect: large_memory n=500000 checksum=267c2644
// bench-expect-small: large_memory n=1 checksum=0000d2a0
`timescale 1ns/1ns
module large_memory;
  logic [31:0] mem[262144], old, checksum=0;
  int n, index;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=500000;
    for (int i=0; i<262144; i++) mem[i]=32'(i)^32'h13579bdf;
    for (int step=1; step<=n; step++) begin
      for (int offset=0; offset<64; offset++) begin
        index=(step*4093+offset*257)&262143; old=mem[index];
        mem[index]=old+32'(step+offset); checksum+=old^mem[index];
      end
      #1; // Each burst is a timed transaction; retain the zero-time safety guard.
    end
    $display("large_memory n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
