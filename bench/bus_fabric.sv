// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 150000
// bench-expect: bus_fabric n=150000 checksum=46f7a29b
// bench-expect-small: bus_fabric n=1 checksum=00000001
`timescale 1ns/1ns
module speed_register_bank(input logic clk, selected, write,
                           input logic [4:0] address, input logic [31:0] wdata,
                           output wire [31:0] rdata);
  logic [31:0] registers[32];
  initial for (int i=0; i<32; i++) registers[i]=0;
  always @(posedge clk) if (selected && write) registers[address] <= wdata;
  assign rdata = registers[address];
endmodule
module speed_bus(input logic clk, valid, write, input logic [6:0] address,
                 input logic [31:0] wdata, output wire [31:0] rdata);
  wire [31:0] values[4];
  for (genvar k=0; k<4; k++) begin: banks
    wire chosen=valid && address[6:5]==k;
    wire [31:0] value;
    speed_register_bank bank(clk,chosen,write,address[4:0],wdata,value);
    assign values[k]=value;
  end
  assign rdata = valid ? values[address[6:5]] : 32'b0;
endmodule
module bus_fabric;
  logic clk=0, valid=0, write=0;
  logic [6:0] address=0;
  logic [31:0] wdata=0, seed=1, checksum=0;
  wire [31:0] rdata;
  int n;
  speed_bus dut(clk,valid,write,address,wdata,rdata);
  initial begin
    if (!$value$plusargs("n=%d",n)) n=150000;
    for (int i=1; i<=n; i++) begin
      seed=seed*32'd1664525+32'd1013904223;
      valid=1; write=1; address=7'(i*17); wdata=seed;
      #1; clk=1; #1; clk=0;
      write=0; address=7'(i*29+7);
      #1; clk=1; #1; checksum=(checksum+rdata)^32'(i); clk=0; #1;
    end
    $display("bus_fabric n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
