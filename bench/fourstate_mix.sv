// Four-state continuous bitwise logic, case equality and unknown detection.
// Original benchmark; expected values derive from IEEE 1800-2023
// 11.4.5, 11.4.8 and 20.9, and 32-bit unsigned arithmetic modulo 2**32.
// spec_check: ai. See reference_fourstate_mix.py for the scalar reference.
// Each iteration includes one time step; no result is sampled during a delta.
// bench-n: 1000000
// bench-expect: fourstate_mix n=1000000 checksum=a0ea5e58 unknowns=250000 x_hits=250000 z_hits=500000
// bench-expect-small: fourstate_mix n=1 checksum=00008abc unknowns=0 x_hits=0 z_hits=0
`timescale 1ns/1ns
module fourstate_mix;
  logic [31:0] a, b;
  wire [31:0] r = (a & b) ^ 32'h0000_ffff;
  int n;
  int unsigned seed, checksum, unknowns, x_hits, z_hits;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 1000000;
    seed = 32'h1234_5678;
    checksum = 0;
    unknowns = 0;
    x_hits = 0;
    z_hits = 0;
    for (int i = 0; i < n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      case (i % 4)
        0: begin a = seed; b = ~seed; end
        1: begin a = {16'hxxxx, seed[15:0]}; b = 32'h0000_ffff; end
        2: begin a = {16'hzzzz, seed[15:0]}; b = 32'hffff_0000; end
        3: begin a = {16'hzzzz, seed[15:0]}; b = 32'h0000_ffff; end
      endcase
      #1;
      checksum = checksum + {16'b0, (r[15:0] ^ seed[31:16])};
      unknowns = unknowns + $isunknown(r);
      x_hits = x_hits + (a[31:16] === 16'hxxxx);
      z_hits = z_hits + (a[31:16] === 16'hzzzz);
    end
    $display("fourstate_mix n=%0d checksum=%h unknowns=%0d x_hits=%0d z_hits=%0d",
             n, checksum, unknowns, x_hits, z_hits);
    $finish(0);
  end
endmodule
