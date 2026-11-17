// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 50000
// bench-expect: event_fanout n=50000 checksum=05c4563b
// bench-expect-small: event_fanout n=1 checksum=000007f8
`timescale 1ns/1ns
module event_fanout;
  logic clk=0;
  int step=0, n;
  logic [31:0] counts[256];
  logic [31:0] checksum=0;
  for (genvar k=0; k<256; k++) begin: workers
    initial counts[k]=0;
    always @(posedge clk) if ((step+k)%17==0) counts[k]<=counts[k]+32'(k+1);
  end
  initial begin
    if (!$value$plusargs("n=%d",n)) n=50000;
    for (int i=1; i<=n; i++) begin
      step=i; #1; clk=1; #1; clk=0; #1;
    end
    for (int k=0; k<256; k++) checksum+=counts[k];
    $display("event_fanout n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
