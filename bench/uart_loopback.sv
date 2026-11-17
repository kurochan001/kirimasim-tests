// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 20000
// bench-expect: uart_loopback n=20000 checksum=75f45cf0 frames=20000 errors=0
// bench-expect-small: uart_loopback n=1 checksum=0000005c frames=1 errors=0
`timescale 1ns/1ns
// One simulation clock per serial bit; start, eight data bits, stop bit.
module speed_uart_tx(input logic clk, start, input logic [7:0] data,
                     output logic line = 1);
  logic [9:0] frame = 10'h3ff;
  int left = 0;
  bit busy = 0;
  always @(posedge clk) begin
    if (!busy) begin
      if (start) begin frame <= {1'b1,data,1'b0}; line <= 0; left <= 9; busy <= 1; end
    end else if (left != 0) begin
      line <= frame[1]; frame <= {1'b1,frame[9:1]}; left <= left-1;
    end else begin busy <= 0; line <= 1; end
  end
endmodule
module speed_uart_rx(input logic clk, line, output logic valid = 0,
                     output logic [7:0] data = 0, output integer errors = 0);
  int state = 0, index = 0;
  logic [7:0] shift = 0;
  always @(posedge clk) begin
    valid <= 0;
    case (state)
      0: if (!line) begin state <= 1; index <= 0; end
      1: begin
        shift[index] <= line;
        if (index == 7) state <= 2; else index <= index+1;
      end
      2: begin
        if (line) begin data <= shift; valid <= 1; end
        else errors <= errors+1;
        state <= 0;
      end
    endcase
  end
endmodule
module uart_loopback;
  logic clk = 0, start = 0;
  logic [7:0] data = 0;
  wire line, valid;
  wire [7:0] received;
  wire signed [31:0] errors;
  int n, frames = 0;
  logic [31:0] checksum = 0;
  speed_uart_tx tx(clk,start,data,line);
  speed_uart_rx rx(clk,line,valid,received,errors);
  task automatic tick;
    #1; clk = 1; #1;
    if (valid) begin checksum = checksum * 33 + received; frames++; end
    clk = 0; #1;
  endtask
  initial begin
    if (!$value$plusargs("n=%d",n)) n=20000;
    for (int i=1; i<=n; i++) begin
      data = 8'(i*73+19); start = 1; tick(); start = 0;
      repeat (11) tick();
    end
    $display("uart_loopback n=%0d checksum=%h frames=%0d errors=%0d",n,checksum,frames,errors);
    $finish;
  end
endmodule
