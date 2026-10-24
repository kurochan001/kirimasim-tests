/*
:name: test_illegal_drive_strength_without_assignment
:description: A net declaration with a drive strength but no continuous assignment is rejected (IEEE 1800-2023 Section 6.3.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.3.2 10.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the net declaration gives a drive strength but does not place a continuous assignment on the net
:expected_stderr_regex: test_illegal_drive_strength_without_assignment\.sv:23:
*/
// IEEE 1800-2023 §6.3.2: a drive strength shall only be used in a net
// declaration that also places a continuous assignment on the net in the
// same statement. The first declaration does that and is legal; the one on
// the marked line has a drive strength and no assignment, an error, even
// though a separate continuous assignment drives the net later. Verilator
// 5.052 accepts the design, which the clause does not allow.

module test_illegal_drive_strength_without_assignment;
  wire (weak0, weak1) with_assign = 1'b1;
  wire (weak0, weak1) no_assign;   // illegal: drive strength without an assignment

  assign no_assign = 1'b0;

  initial #1 $display("%b %b", with_assign, no_assign);
endmodule
