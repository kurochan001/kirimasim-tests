// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 6.12 (real), 11.3.1 (real operators), 20.5 ($realtobits).
// bench-n: 2000000
// bench-expect: real_filter n=2000000 checksum=8e364df1 last=40b24dbdfb7b8b0f
// bench-expect-small: real_filter n=1 checksum=409e4400 last=409e440000000000
`timescale 1ns/1ns
// A second-order IIR filter in double precision. Every coefficient is a
// power of two, so every product is exact and each step rounds only in its
// additions; the result is the same with or without fused multiply-add.
module real_filter;
  real x, y = 0.0, y1 = 0.0, y2 = 0.0;
  logic [63:0] bits;
  logic [31:0] seed = 1, checksum = 0;
  int n;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 2000000;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      x = $itor($signed(seed[31:16]));
      y = x * 0.125 + y1 * 0.5 + y2 * 0.25;
      y2 = y1;
      y1 = y;
      bits = $realtobits(y);
      checksum = (checksum * 33) ^ bits[63:32] ^ bits[31:0];
    end
    $display("real_filter n=%0d checksum=%h last=%h", n, checksum, $realtobits(y));
    $finish;
  end
endmodule
