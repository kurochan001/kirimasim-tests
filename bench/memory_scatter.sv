// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 5000000
// bench-expect: memory_scatter n=5000000 checksum=55ef0184
// bench-expect-small: memory_scatter n=1 checksum=c4b9aa95
`timescale 1ns/1ns
module memory_scatter;
  logic [31:0] mem[32768], seed=1, old, checksum=0;
  int n, wa, ra;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=5000000;
    for (int i=0; i<32768; i++) mem[i]=(32'(i)*32'h10203)^32'h89abcdef;
    for (int i=1; i<=n; i++) begin
      seed=seed*32'd1664525+32'd1013904223;
      wa=(seed>>7)&32767; ra=((seed>>17)^seed)&32767;
      old=mem[ra]; mem[wa]=(old+seed)^32'(i); checksum=(checksum+old)^mem[wa];
    end
    $display("memory_scatter n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
