// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 100000
// bench-expect: fourstate_arith n=100000 checksum=0185a828 unknowns=50000
// bench-expect-small: fourstate_arith n=1 checksum=00000000 unknowns=1
`timescale 1ns/1ns
module fourstate_arith;
  logic signed [64:0] a, b, result;
  logic [31:0] checksum=0;
  int n, unknowns=0;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=100000;
    for (int i=1; i<=n; i++) begin
      case (i%4)
        0: begin a=(65'(i)<<33)|65'(i); b=65'(i*2); result=a+b; end
        1: begin a={65{1'bx}}; a[0]=1; b=3; result=a+b; end
        2: begin a=65'(i); b={65{1'bz}}; result=a+b; end
        3: begin a={1'b1,64'(i)}; result=a>>>(i%65); end
      endcase
      if ($isunknown(result)) begin
        if (result === {65{1'bx}}) unknowns++;
        else $fatal(1,"unexpected partially unknown arithmetic result");
      end else if (i%4==0) checksum+=result[31:0];
      else checksum^=result[31:0];
    end
    $display("fourstate_arith n=%0d checksum=%h unknowns=%0d",n,checksum,unknowns); $finish;
  end
endmodule
