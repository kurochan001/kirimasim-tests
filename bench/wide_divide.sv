// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 80000
// bench-expect: wide_divide n=80000 checksum=06154fbc
// bench-expect-small: wide_divide n=1 checksum=2e9c71e6
`timescale 1ns/1ns
module wide_divide;
  logic [256:0] value=(257'b1<<256)|257'h123456789abcdef0, quotient, remainder;
  logic [32:0] divisor;
  logic [31:0] checksum=0;
  int n;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=80000;
    for (int i=1; i<=n; i++) begin
      value=(value<<7)^(value>>3)^257'(32'(i*17));
      divisor=33'(i%65521+1); quotient=value/divisor; remainder=value%divisor;
      checksum+=quotient[31:0]^quotient[256:225]^remainder[31:0];
    end
    $display("wide_divide n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
