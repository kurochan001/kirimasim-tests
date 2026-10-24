/*
:name: test_illegal_aggregate_parameter_element_defparam
:description: an aggregate parameter is overridden only as a whole; a defparam of one element of an unpacked array parameter is an error (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam statement overrides only the element A[1] of the unpacked array parameter A of the instance bad
:expected_stderr_regex: test_illegal_aggregate_parameter_element_defparam\.sv:35:
*/
// IEEE 1800-2023 §6.20.2: a parameter can have an aggregate type such as an
// unpacked array; it shall be assigned or overridden as a whole, and its
// individual members cannot be assigned or overridden separately, though a
// member can be used in an expression.
// The module agg_param_m has the parameter A, an unpacked array of two int with
// the default '{1, 2}, and uses the member A[1] in the expression of the
// parameter SUM. The instance ok overrides A as a whole with '{3, 4}, which is
// legal, and the legal design prints the elements and SUM of ok and the default
// element A[1] of the instance bad: 3 4 7 2. The defparam statement overrides
// only the element A[1] of bad.
// Icarus Verilog 13.0 reports unpacked array parameters as not supported (a
// message that is not an error). The 5.052 release reports the defparam as an
// unsupported defparam of an arrayed instance, which does not count.

module agg_param_m #(parameter int A [2] = '{1, 2}) ();
  localparam int SUM = A[0] + A[1];
endmodule

module test_illegal_aggregate_parameter_element_defparam;
  agg_param_m #(.A('{3, 4})) ok ();
  agg_param_m bad ();
  defparam bad.A[1] = 7;   // illegal: one element of an aggregate parameter
  initial $display("%0d %0d %0d %0d", ok.A[0], ok.A[1], ok.SUM, bad.A[1]);
endmodule
