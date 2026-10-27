/*
:name: test_ch6_extra_body_parameter_local
:description: A parameter declaration in the body of a design element that has a parameter port list behaves as a localparam and cannot be overridden (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1 6.20.4 23.10.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam statement overrides B, a body parameter of a module with a parameter port list
:expected_stderr_regex: test_ch6_extra_body_parameter_local\.sv:28:
*/
// IEEE 1800-2023 §6.20.1: when the declaration of a design element uses a
// parameter port list, even an empty one, the parameter keyword in a
// parameter declaration directly contained in the body is a synonym for
// localparam. A in the port list stays overridable, but B in the body is a
// local parameter (§6.20.4) and cannot be changed by defparam (§23.10.1).
// The override of B on the marked line is therefore illegal.

module test_ch6_extra_body_parameter_local_cell #(parameter int A = 1) ();
  parameter int B = 2;
  initial $display("A=%0d B=%0d", A, B);
endmodule

module test_ch6_extra_body_parameter_local;
  test_ch6_extra_body_parameter_local_cell u();
  defparam u.B = 3;   // illegal: B behaves as a localparam
endmodule
