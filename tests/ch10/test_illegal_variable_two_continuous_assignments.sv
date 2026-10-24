/*
:name: test_illegal_variable_two_continuous_assignments
:description: a variable can be driven by only one continuous assignment, while a net can have several (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.2 6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v is the target of two continuous assignments
:expected_stderr_regex: test_illegal_variable_two_continuous_assignments\.sv:(29|30):
*/
// IEEE 1800-2023 §10.3.2: nets can be driven by several continuous
// assignments, but a variable only by one continuous assignment (or one
// primitive or module output). The net n has two continuous assignments and
// the variable u one, which is legal; the variable v has two. A tool can
// report either assignment to v.
// The design is accepted by Verilator 5.052.

module test_illegal_variable_two_continuous_assignments;
  logic a = 1'b1, b = 1'b1;
  wire n;
  logic u, v;

  assign n = a;
  assign n = b;
  assign u = a;
  assign v = a;   // (or reported here)
  assign v = b;   // illegal: a second continuous assignment to the variable v

  initial #1 $display("%b %b", n, u);
endmodule
