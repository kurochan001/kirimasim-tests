/*
:name: test_illegal_for_init_declares_after_existing
:description: a for-loop initialization cannot mix a declared control variable with an existing one (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7.1 12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the for-loop initialization assigns the existing variable x and declares the local variable y
:expected_stderr_regex: test_illegal_for_init_declares_after_existing\.sv:27:
*/
// IEEE 1800-2023 §12.7.1: in a for-loop initialization, either all of the
// control variables or none of them shall be declared in the loop. The first
// loop declares both i and k, and the second declares neither; both are legal.
// The third assigns the module variable x and declares y in the loop.
// Icarus Verilog 13.0 reports a syntax error here, but it reports one on the
// legal first loop as well, which declares two variables, so it does not
// count; Verilator 5.052 accepts the design.

module test_illegal_for_init_declares_after_existing;
  int x, z;
  initial begin
    for (int i = 0, k = 1; i < 1; i++) $display("%0d %0d", i, k);
    for (x = 0, z = 1; x < 1; x++) $display("%0d %0d", x, z);
    for (x = 0, int y = 0; x < 1; x++) $display("%0d %0d", x, y);   // illegal
  end
endmodule
