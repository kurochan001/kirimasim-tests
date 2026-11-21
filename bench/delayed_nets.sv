// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 10.3.3 (continuous assignment delays), 28.16 (gate delays).
// bench-n: 400000
// bench-expect: delayed_nets n=400000 checksum=4cb74800
// bench-expect-small: delayed_nets n=1 checksum=0002e900
`timescale 1ns/1ns
// Each step changes a, b and c, samples midway (9) and when settled (16),
// then gives c a pulse of 2, 4, 6, 10 or 12 time units. The pulse reaches only
// z, whose single delay is 8: shorter pulses are removed (10.3.3 b and c).
// Rise and fall delays differ only where every change outlasts them, and no
// sample falls on a delay boundary.
module delayed_nets;
  logic a = 0, b = 0, c = 0;
  wire #(6,10) y = a & b;
  wire z;
  assign #8 z = a ^ c;
  wire g, h;
  and #(4,12) u_and (g, a, b);
  nor #6 u_nor (h, a, b);
  logic [31:0] seed = 1, checksum = 0;
  int n, w;
  int widths[5] = '{2, 4, 6, 10, 12};
  task automatic sample(input logic [1:0] k);
    checksum = (checksum * 33) ^ {26'd0, k, y, z, g, h};
  endtask
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 400000;
    #40;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      a = seed[0];
      b = seed[1];
      c = seed[2];
      w = widths[seed[5:3] % 5];
      #9 sample(0);
      #7 sample(1);
      c = ~c;
      c <= #(w) ~c;
      #9 sample(2);
      #15 sample(3);
      #8;
    end
    $display("delayed_nets n=%0d checksum=%h", n, checksum);
    $finish;
  end
endmodule
