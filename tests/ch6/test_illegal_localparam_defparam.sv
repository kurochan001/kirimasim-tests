/*
:name: test_illegal_localparam_defparam
:description: A defparam statement cannot change a local parameter (IEEE 1800-2023 Section 6.20.4)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.4 23.10.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a defparam statement names the local parameter W of the instance u
:expected_stderr_regex: test_illegal_localparam_defparam\.sv:24:
*/
// IEEE 1800-2023 §6.20.4: a local parameter cannot be changed directly by a
// defparam statement (23.10.1) or by a parameter value assignment of an
// instance.

module sub;
  localparam int W = 4;
endmodule

module test_illegal_localparam_defparam;
  sub u();
  defparam u.W = 8;    // illegal: W is a local parameter
endmodule
