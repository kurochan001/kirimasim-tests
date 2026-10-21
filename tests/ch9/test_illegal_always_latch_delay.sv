/*
:name: test_illegal_always_latch_delay
:description: An always_latch procedure cannot contain a delay (IEEE 1800-2023 Section 9.2.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.3 9.2.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_latch procedure has a delay control
:expected_stderr_regex: test_illegal_always_latch_delay\.sv:24:
*/
// IEEE 1800-2023 §9.2.2.3: always_latch is the same construct as always_comb
// except for the checks tools make for latched behavior, so its statements are
// held to §9.2.2.2.2 too: no blocking timing or event controls.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_illegal_always_latch_delay;
  logic en = 1, d = 1, q;
  always_latch begin
    if (en) #1 q = d;   // illegal: delay in always_latch
  end
  initial #5 $display("q=%b", q);
endmodule
