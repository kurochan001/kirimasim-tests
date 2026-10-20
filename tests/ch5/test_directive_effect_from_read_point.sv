/*
:name: test_directive_effect_from_read_point
:description: A compiler directive takes effect where it is read and holds for the rest of the compilation unit, across module boundaries, until another directive changes it (IEEE 1800-2023 Section 5.6.4)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.4 22.5.1 22.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_directive_effect_from_read_point.expected
*/
// IEEE 1800-2023 §5.6.4: a compiler directive takes effect as soon as it is
// read and stays in effect for the rest of the compilation unit unless
// another directive changes it. The macro LEVEL is defined inside the first
// module and still defined in the second, which is not a scope for it; it is
// redefined (22.5.1) between two uses, so each use gets the definition read
// before it, and after `undef (22.5.2) `ifdef sees it undefined.

module test_directive_effect_from_read_point_first;
`define LEVEL 3
  localparam int A = `LEVEL;
  initial $display("first: A=%0d", A);
endmodule

module test_directive_effect_from_read_point;
  localparam int B = `LEVEL;
`define LEVEL 5
  localparam int C = `LEVEL;
`undef LEVEL
`ifdef LEVEL
  localparam bit D = 1;
`else
  localparam bit D = 0;
`endif

  test_directive_effect_from_read_point_first f();

  initial #1 $display("second: B=%0d C=%0d defined at the end: %0d", B, C, D);
endmodule
