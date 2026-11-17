// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 1500000
// bench-expect: packed_slice n=1500000 checksum=88ffc174
// bench-expect-small: packed_slice n=1 checksum=3456789a
`timescale 1ns/1ns
module packed_slice;
  logic [510:0] value=(511'b1<<510)|511'h123456789abcdef0;
  logic [31:0] part, checksum=0;
  int n, read_index, write_index;
  initial begin
    if (!$value$plusargs("n=%d",n)) n=1500000;
    for (int i=1; i<=n; i++) begin
      value=((value<<13)|(value>>498))^511'(i);
      read_index=(i*37)%480; write_index=(i*53)%480;
      part=value[read_index+:32]; value[write_index+:32]=part^(32'(i)*32'h9e37);
      checksum+=part;
    end
    $display("packed_slice n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
