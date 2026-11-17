// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 4000000
// bench-expect: word_boundary n=4000000 checksum=0f74bad8
// bench-expect-small: word_boundary n=1 checksum=9abcdef0
`timescale 1ns/1ns
module word_boundary;
  logic [63:0] a=64'hfedcba9876543210;
  logic [64:0] b=65'h1123456789abcdef0, shifted;
  logic [31:0] checksum=0;
  int n, amount;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=4000000;
    for (int i=1; i<=n; i++) begin
      a=a^(a<<13); a=a^(a>>7); a=a^(a<<17);
      b=((b<<1)|(b>>64))^{1'b0,a}; amount=i%65;
      shifted=(b>>amount)^{1'b0,(a>>amount)};
      checksum=(checksum+shifted[31:0])^{31'b0,b[amount]};
    end
    $display("word_boundary n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
