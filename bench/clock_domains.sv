// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 20000
// bench-expect: clock_domains n=20000 checksum=00071450
// bench-expect-small: clock_domains n=1 checksum=00000014
`timescale 1ns/1ns
module clock_domains;
  logic ca=0, cb=0, cc=0;
  logic [31:0] a=0, b=0, c=0, checksum;
  int n;
  always #2 ca=~ca;
  always #3 cb=~cb;
  always #5 cc=~cc;
  always @(posedge ca) a<=a+3;
  always @(posedge cb) b<=b+5;
  always @(posedge cc) c<=c+7;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=20000;
    #(30*n+1); checksum=a^b^c;
    $display("clock_domains n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
