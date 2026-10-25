/*
:name: test_math_functions_constant_expressions
:description: $clog2 and the real math functions can be used in constant expressions: localparam values, packed and unpacked dimensions and generate conditions (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8 20.8.1 20.8.2 11.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_functions_constant_expressions.expected
*/
// IEEE 1800-2023 §20.8: the integer and real math functions may be used in
// constant expressions (§11.2.1), where their arguments are constant.
// $clog2(1000) = 10 sets a localparam and the width of an address, $clog2 of
// a parameter sets a packed range, $rtoi of $pow(2, 3) sets the size of an
// unpacked array, localparams take $sqrt(2.0), $floor(7.9), $hypot(6, 8)
// and $atan2(0.0, -1.0) (pi), and two generate if conditions use $ln and
// $ceil.

module test_math_functions_constant_expressions;
  parameter int DEPTH = 200;
  localparam int AW = $clog2(1000);
  localparam real ROOT2 = $sqrt(2.0);
  localparam real FL = $floor(7.9);
  localparam real HY = $hypot(6, 8);
  localparam real PI = $atan2(0.0, -1.0);

  logic [AW - 1:0] addr;
  logic [$clog2(DEPTH):1] cnt;
  int table_a [$rtoi($pow(2.0, 3.0))];

  if ($ln(1.0) == 0.0) begin : g_ln
    initial #1 $display("generate: ln 1 is 0");
  end

  if ($ceil(2.1) == 3.0) begin : g_ceil
    initial #2 $display("generate: ceil 2.1 is 3");
  end

  initial begin
    $display("AW=%0d addr=%0d cnt=%0d [%0d:%0d] table=%0d", AW, $bits(addr), $bits(cnt),
             $left(cnt), $right(cnt), $size(table_a));
    $display("ROOT2=%.4f FL=%.1f HY=%.1f PI=%.5f", ROOT2, FL, HY, PI);
  end
endmodule
