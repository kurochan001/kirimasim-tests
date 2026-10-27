/*
:name: test_23_extra_param_expressions
:description: An instance parameter value may be a data type or an omitted named expression, so a type parameter takes a data type and a named value parameter without parentheses keeps its default (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.10.2.2 6.20.3 A.8.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_param_expressions.expected
*/
// IEEE 1800-2023 §23.3.2 and A.8.3: param_expression is a
// mintypmax_expression, a data_type or the dollar token, and a named
// parameter assignment may omit its expression. The module px has a type
// parameter T, a value parameter W and a print delay D. The ordered
// assignment #(bit [7:0], 9, 1) gives the data type bit [7:0] to T, whose
// width is 8, 9 to W, and 1 to D. The named assignment #(.T(shortint),
// .W(), .D(2)) gives the data type shortint to T, whose width is 16, leaves
// W at its default 4 because .W() has no expression, and prints at time 2.
// The print times fix the order of the two lines.
// The mintypmax form and the dollar form of param_expression are not
// exercised here: neither release accepts either one in a parameter value
// assignment (see the note below).

module px #(parameter type T = logic, parameter int W = 4,
            parameter int D = 1) ();
  initial #D $display("bits=%0d W=%0d", $bits(T), W);
endmodule

module test_23_extra_param_expressions;
  px #(bit [7:0], 9, 1) a();
  px #(.T(shortint), .W(), .D(2)) b();

  initial #3 $finish;
endmodule
