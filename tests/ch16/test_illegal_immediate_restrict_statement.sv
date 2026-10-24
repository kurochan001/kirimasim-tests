/*
:name: test_illegal_immediate_restrict_statement
:description: there is no immediate form of the restrict statement (IEEE 1800-2023 Section 16.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: restrict is written as an immediate assertion statement in an initial procedure
:expected_stderr_regex: test_illegal_immediate_restrict_statement\.sv:25:
*/
// IEEE 1800-2023 §16.2: assert, assume and cover have both immediate and
// concurrent forms, but there is no immediate restrict assertion statement;
// restrict exists only as restrict property. The module has a concurrent
// restrict property and an immediate assert, which are legal; the initial
// procedure then writes restrict as an immediate statement.

module test_illegal_immediate_restrict_statement;
  logic clk = 0, a = 1;
  p_r: restrict property (@(posedge clk) a);
  initial begin
    i_a: assert (a);
    restrict (a);   // illegal
  end
endmodule
