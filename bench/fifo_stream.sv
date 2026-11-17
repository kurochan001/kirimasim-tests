// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 200000
// bench-expect: fifo_stream n=200000 checksum=6b5d551f reads=133333 pending=62
// bench-expect-small: fifo_stream n=1 checksum=00000000 reads=0 pending=1
`timescale 1ns/1ns
module speed_fifo(input logic clk, wr, rd, input logic [31:0] din,
                  output logic [31:0] dout = 0, output wire full, empty,
                  output integer used = 0);
  logic [31:0] mem[64];
  integer wp = 0, rp = 0;
  wire push = wr && !full, pop = rd && !empty;
  assign full = used == 64;
  assign empty = used == 0;
  always @(posedge clk) begin
    if (push) begin mem[wp] <= din; wp <= (wp + 1) % 64; end
    if (pop) begin dout <= mem[rp]; rp <= (rp + 1) % 64; end
    case ({push,pop})
      2'b10: used <= used + 1;
      2'b01: used <= used - 1;
      default: ;
    endcase
  end
endmodule
module fifo_stream;
  logic clk = 0, wr = 0, rd = 0;
  logic [31:0] din = 0;
  wire [31:0] dout;
  wire full, empty;
  wire signed [31:0] used;
  bit accepted;
  int n, reads = 0;
  logic [31:0] seed = 1, checksum = 0;
  speed_fifo dut(clk,wr,rd,din,dout,full,empty,used);
  initial begin
    if (!$value$plusargs("n=%d",n)) n=200000;
    for (int i=1; i<=n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      din = seed; wr = i%5 != 0; rd = i%3 != 0;
      #1; accepted = rd && !empty; clk = 1;
      #1;
      if (accepted) begin checksum = (checksum * 33) ^ dout; reads++; end
      clk = 0; #1;
    end
    $display("fifo_stream n=%0d checksum=%h reads=%0d pending=%0d",n,checksum,reads,used);
    $finish;
  end
endmodule
