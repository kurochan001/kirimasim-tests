// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 100000
// bench-expect: hierarchy_fanout n=100000 checksum=5e63f760
// bench-expect-small: hierarchy_fanout n=1 checksum=dfea0208
`timescale 1ns/1ns
module speed_comb_leaf #(parameter int ID=0)(input wire [31:0] x, output wire [31:0] y);
  assign y=(x ^ (32'(ID)*32'h10203))+(x << (ID%7+1));
endmodule
module hierarchy_fanout;
  logic [31:0] seed=1, checksum=0;
  wire [31:0] values[128];
  int n;
  for (genvar k=0; k<128; k++) begin: leaves
    speed_comb_leaf #(k) leaf(seed,values[k]);
  end
  initial begin
    if (!$value$plusargs("n=%d",n)) n=100000;
    for (int i=1; i<=n; i++) begin
      seed=seed*32'd1664525+32'd1013904223; #1;
      for (int k=0; k<128; k++) checksum=(checksum*33)^values[k];
    end
    $display("hierarchy_fanout n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
