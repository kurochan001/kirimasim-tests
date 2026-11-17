// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 20000
// bench-expect: large_hierarchy n=20000 checksum=83e909b6
// bench-expect-small: large_hierarchy n=1 checksum=00e30c67
`timescale 1ns/1ns
module speed_tree #(parameter int LEVEL=5, BASE=0)
                   (input wire clk, input integer step, output wire [31:0] total);
  if (LEVEL==0) begin: leaf
    logic [31:0] value=32'(BASE);
    always @(posedge clk) if ((step+BASE)%7!=0) value<=(value*33)^32'(step+BASE);
    assign total=value;
  end else begin: branch
    wire [31:0] child[4];
    for (genvar k=0; k<4; k++) begin: children
      speed_tree #(LEVEL-1,BASE+k*(4**(LEVEL-1))) node(clk,step,child[k]);
    end
    assign total=child[0]+child[1]+child[2]+child[3];
  end
endmodule
module large_hierarchy;
  logic clk=0;
  int step=0, n;
  wire [31:0] checksum;
  speed_tree root(clk,step,checksum);
  initial begin
    if (!$value$plusargs("n=%d",n)) n=20000;
    for (int i=1; i<=n; i++) begin step=i; #1; clk=1; #1; clk=0; #1; end
    $display("large_hierarchy n=%0d checksum=%h",n,checksum); $finish;
  end
endmodule
