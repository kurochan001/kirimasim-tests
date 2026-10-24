/*
:name: test_illegal_continuously_assigned_variable_procedural_write
:description: a variable driven by a continuous assignment cannot also be written by a procedural assignment (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.2 6.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v is the target of a continuous assignment and of a procedural assignment in the initial procedure
:expected_stderr_regex: test_illegal_continuously_assigned_variable_procedural_write\.sv:(24|28):
*/
// IEEE 1800-2023 §10.3.2: it shall be an error for a variable driven by a
// continuous assignment to have any procedural assignment. u is written only
// procedurally and w only by a continuous assignment, which is legal; v is
// written both ways. A tool can report either assignment.

module test_illegal_continuously_assigned_variable_procedural_write;
  logic a = 1'b1;
  logic u, w, v;

  assign w = a;
  assign v = a;   // (or reported here)

  initial begin
    u = 1'b0;
    v = 1'b0;   // illegal: procedural assignment to a continuously driven variable
    #1 $display("%b %b", u, w);
  end
endmodule
