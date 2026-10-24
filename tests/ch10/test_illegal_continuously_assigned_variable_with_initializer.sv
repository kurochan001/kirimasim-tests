/*
:name: test_illegal_continuously_assigned_variable_with_initializer
:description: a variable driven by a continuous assignment cannot have an initializer in its declaration (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.2 6.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v is declared with the initializer 1'b0 and is the target of a continuous assignment
:expected_stderr_regex: test_illegal_continuously_assigned_variable_with_initializer\.sv:(24|27):
*/
// IEEE 1800-2023 §10.3.2: it shall be an error for a variable driven by a
// continuous assignment to have an initializer in its declaration. u has an
// initializer and no continuous assignment, and w a continuous assignment and
// no initializer, which is legal; v has both. A tool can report the
// declaration or the assignment.

module test_illegal_continuously_assigned_variable_with_initializer;
  logic a = 1'b1;
  logic u = 1'b0;
  logic w;
  logic v = 1'b0;   // (or reported here)

  assign w = a;
  assign v = a;   // illegal: v has an initializer

  initial #1 $display("%b %b", u, w);
endmodule
