/*
:name: test_parameter_unbounded_value
:description: The dollar sign is a constant parameter expression and a parameter expression: a parameter declared with $ has the unbounded value, a data type is the other expression, $ may be assigned to another parameter, and $isunbounded reports which parameters have the value $ (IEEE 1800-2023 Sections 6.20.2, 6.20.3 and 20.6.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 6.20.3 20.6.3 A.8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_unbounded_value.expected
*/
// IEEE 1800-2023 A.8.3: constant_param_expression is a constant mintypmax
// expression, a data type or $, and param_expression is an ordinary mintypmax
// expression, a data type or $. §6.20.2: $ may be assigned to a value
// parameter of a simple bit vector type and may be assigned to another
// parameter, and §20.6.3: $isunbounded returns 1 for a parameter whose value
// is $. §6.20.3: a data type parameter takes a data type, here logic [5:0].
//
// P is declared with $ and U with a data type, and the instance cu overrides
// the value parameter N of its child with P and the type parameter T with U.
// The value of N is therefore $ as well, so $isunbounded(P) and
// $isunbounded(N) are 1, while the width of U and T is 6.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports a $ parameter, so
// this expected output follows the standard.

module ubchild #(parameter type T = logic [3:0],
                 parameter logic [7:0] N = 8'd1) ();
  task report;
    $display("child %0d %0d", $bits(T), $isunbounded(N));
  endtask
endmodule

module test_parameter_unbounded_value;
  parameter logic [7:0] P = $;
  parameter type U = logic [5:0];
  ubchild #(.T(U), .N(P)) cu ();

  initial #1 begin
    cu.report();
    $display("param %0d %0d", $isunbounded(P), $bits(U));
  end
endmodule
