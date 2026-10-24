/*
:name: test_illegal_generate_if_condition_variable
:description: The condition of an if-generate construct has to be a constant expression; a variable is not one, while a parameter is (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the condition of the second if-generate construct reads the variable sel
:expected_stderr_regex: test_illegal_generate_if_condition_variable\.sv:25:
*/
// IEEE 1800-2023 §27.3: generate schemes are evaluated during elaboration,
// not at simulation time, so every expression in a generate scheme shall be a
// constant expression. The first if-generate construct tests the parameter
// USE, which is legal. The second tests the variable sel, whose value exists
// only during simulation, even though it has an initializer.

module test_illegal_generate_if_condition_variable #(parameter bit USE = 1'b1);
  bit sel = 1'b1;
  if (USE) begin : g_param
    int a = 1;
  end
  if (sel) begin : g_var   // illegal: sel is not a constant expression
    int b = 2;
  end
  initial $display("%0d", g_param.a);
endmodule
