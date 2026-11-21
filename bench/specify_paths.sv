// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 30.4 (module path delays), 30.7 (default pulse rejection).
// bench-n: 400000
// bench-expect: specify_paths n=400000 checksum=7a667f84
// bench-expect-small: specify_paths n=1 checksum=052054e9
`timescale 1ns/1ns
// Scalar cells with simple module paths. Each output has one continuous
// assignment. The buffer's rise and fall delays differ and its input changes
// once per step; the inverter's single delay is 8 and its input gets pulses of
// 2, 4, 6, 10 or 12, so pulses shorter than 8 are rejected (30.7). The two
// inputs of the xor cell never change within one path delay of each other.
// No sample falls on a delay boundary.
module holdout_buf(input a, output y);
  assign y = a;
  specify
    (a => y) = (6, 10);
  endspecify
endmodule
module holdout_inv(input a, output y);
  assign y = ~a;
  specify
    (a => y) = 8;
  endspecify
endmodule
module holdout_xor(input a, b, output y);
  assign y = a ^ b;
  specify
    (a => y) = 4;
    (b => y) = 6;
  endspecify
endmodule
module specify_paths;
  logic a = 0, b = 0, p = 0;
  wire y1, y2, y3;
  holdout_buf u_buf (a, y1);
  holdout_inv u_inv (p, y2);
  holdout_xor u_xor (a, b, y3);
  logic [31:0] seed = 1, checksum = 0;
  int n, w;
  int widths[5] = '{2, 4, 6, 10, 12};
  task automatic sample(input logic [2:0] k);
    checksum = (checksum * 33) ^ {26'd0, k, y1, y2, y3};
  endtask
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 400000;
    #60;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      w = widths[seed[5:3] % 5];
      a = seed[0];
      #7 sample(0);
      #5 sample(1);
      b = seed[2];
      #5 sample(2);
      #4 sample(3);
      p = ~p;
      p <= #(w) ~p;
      #9 sample(4);
      #15 sample(5);
      #3;
    end
    $display("specify_paths n=%0d checksum=%h", n, checksum);
    $finish;
  end
endmodule
