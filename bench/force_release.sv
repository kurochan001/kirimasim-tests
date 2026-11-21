// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 10.6.1 (assign/deassign) and 10.6.2 (force/release).
// bench-n: 1500000
// bench-expect: force_release n=1500000 checksum=39c19273 w=5dcc89a0 v=0796d3fb
// bench-expect-small: force_release n=1 checksum=4598ebb4 w=3c88596c v=3c88596c
`timescale 1ns/1ns
// A four-step cycle: force a net and assign a variable to expressions of
// src, change src while both overrides hold, release and deassign them, and
// write the variable again. Values are folded in one time unit after each step.
module force_release;
  logic [31:0] driver = 0, v = 0, src = 0;
  wire [31:0] w = driver;
  logic [31:0] seed = 1, checksum = 0;
  int n;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 1500000;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      driver = seed;
      case (i % 4)
        0: begin
          force w = src ^ 32'h5a5a5a5a;
          assign v = src + 32'd1;
        end
        1: begin
          src = seed >> 3;
          v = seed;
        end
        2: begin
          release w;
          deassign v;
        end
        3: begin
          v = seed ^ 32'h0000ffff;
          src = src + 32'd7;
        end
      endcase
      #1;
      checksum = (checksum * 33) ^ w ^ (v << 1);
    end
    $display("force_release n=%0d checksum=%h w=%h v=%h", n, checksum, w, v);
    $finish;
  end
endmodule
