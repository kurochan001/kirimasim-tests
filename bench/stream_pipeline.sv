// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 250000
// bench-expect: stream_pipeline n=250000 checksum=741abec0 frames=171428
// bench-expect-small: stream_pipeline n=1 checksum=c1aa0550 frames=1
`timescale 1ns/1ns
module speed_pipeline(input wire clk, advance, input_valid, input wire [31:0] base,
                      output wire output_valid, output logic [31:0] total);
  logic [31:0] data[8][32];
  logic valid[8];
  initial for (int s=0; s<8; s++) begin
    valid[s]=0; for (int lane=0; lane<32; lane++) data[s][lane]=0;
  end
  for (genvar s=0; s<8; s++) begin: stages
    if (s==0) begin: first
      always @(posedge clk) if (advance) begin
        valid[s]<=input_valid;
        if (input_valid) for (int lane=0; lane<32; lane++) data[s][lane]<=((base+32'(lane))*33)^32'(lane);
      end
    end else begin: following
      always @(posedge clk) if (advance) begin
        valid[s]<=valid[s-1];
        if (valid[s-1]) for (int lane=0; lane<32; lane++) data[s][lane]<=(data[s-1][lane]*33)^32'(s*32'h10203+lane);
      end
    end
  end
  assign output_valid=valid[7];
  always_comb begin
    total=0; for (int lane=0; lane<32; lane++) total+=data[7][lane];
  end
endmodule
module stream_pipeline;
  logic clk=0, advance=0, input_valid=0;
  logic [31:0] base=0, checksum=0;
  wire output_valid;
  wire [31:0] total;
  int n, frames=0;
  speed_pipeline dut(clk,advance,input_valid,base,output_valid,total);
  initial begin
    if (!$value$plusargs("n=%d",n)) n=250000;
    for (int step=1; step<=n+8; step++) begin
      base=32'(step*17); advance=step>n || step%7!=0;
      input_valid=step<=n && step%5!=0;
      #1;
      if (advance && output_valid) begin checksum=(checksum*33)^total; frames++; end
      clk=1; #1; clk=0; #1;
    end
    $display("stream_pipeline n=%0d checksum=%h frames=%0d",n,checksum,frames); $finish;
  end
endmodule
