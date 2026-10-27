/*
:name: test_illegal_checker_rewritten_automatic
:description: A checker input actual that is an automatic value may not reach a formal used in continuous or procedural code after the actual is substituted (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the procedural instance passes the automatic variable av to the formal a, which the checker uses in an always_comb procedure
:expected_stderr_regex: test_illegal_checker_rewritten_automatic\.sv:(28|45):
*/
// IEEE 1800-2023 17.3: checker input actuals are substituted for the formals
// under F.4.2 after name resolution, and the instance is in error when the
// flattened checker is not legal. If an actual contains a const cast or an
// automatic value from procedural code, the formal shall not be used in a
// continuous assignment or in the procedural code of the checker. The static
// instance passes the module variable v to use_auto and is legal. The
// procedural instance passes the automatic av to the same formal, which the
// always_comb procedure uses, so that instance is not legal. use_prop uses
// its formal only in a concurrent assertion, which the restriction allows.
// Icarus Verilog 13.0 has no checkers and Verilator 5.052 accepts the design.

`timescale 1ns/1ns

checker use_auto(input logic [3:0] a, output logic [3:0] y);
  always_comb y = a + 4'd1;   // illegal when a is an automatic actual
endchecker

checker use_prop(input logic a, input logic clk, output logic y);
  p: assert property (@(posedge clk) a);
  assign y = 1'b0;
endchecker

module test_illegal_checker_rewritten_automatic;
  logic clk = 1'b0;
  logic [3:0] v = 4'd3;
  logic [3:0] y_static, y_auto, y_prop;

  use_auto u_static(v, y_static);

  initial begin
    automatic logic [3:0] av = 4'd5;
    use_auto u_auto(av, y_auto);       // illegal: automatic actual in procedural use
    use_prop u_prop(av, clk, y_prop);  // legal: formal used only in a property
  end

  always #5 clk = ~clk;
  initial #20 $finish;
endmodule
