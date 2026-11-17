// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_expanded.py.
// spec_check: ai; IEEE 1800-2023 expression, scheduling, array and net rules.
// bench-n: 50000
// bench-expect: resolved_bus n=50000 checksum=28292930 x_bits=90000 z_bits=80000
// bench-expect-small: resolved_bus n=1 checksum=00000025 x_bits=0 z_bits=0
`timescale 1ns/1ns
module resolved_bus;
  tri [7:0] bus;
  logic [3:0] enable=0;
  logic [7:0] values[4];
  logic [7:0] known;
  logic [31:0] checksum=0;
  int n, x_bits=0, z_bits=0, mode;
  for (genvar k=0; k<4; k++) begin: drivers
    assign bus=enable[k] ? values[k] : 8'bz;
  end
  initial begin
    if (!$value$plusargs("n=%d",n)) n=50000;
    for (int i=1; i<=n; i++) begin
      mode=i%5; values[0]=8'(i*37); values[1]=values[0]; values[2]=8'bz; values[3]=0;
      case (mode)
        0: enable=0;
        1: enable=1;
        2: enable=7;
        3: begin enable=3; values[1]=~values[0]; end
        4: begin enable=3; values[1]=values[0]^(8'b1<<(i%8)); end
      endcase
      #1; known=0;
      for (int bit_index=0; bit_index<8; bit_index++) begin
        if (bus[bit_index]===1'bx) x_bits++;
        else if (bus[bit_index]===1'bz) z_bits++;
        else if (bus[bit_index]===1'b1) known[bit_index]=1;
      end
      checksum=checksum*33+known;
    end
    $display("resolved_bus n=%0d checksum=%h x_bits=%0d z_bits=%0d",n,checksum,x_bits,z_bits); $finish;
  end
endmodule
