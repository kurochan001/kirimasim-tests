/*
:name: test_illegal_global_clock_past_function_without_global_clocking
:description: the global clocking past sampled value functions need a global clocking declaration (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $rose_gclk is used in a module, and a design, without a global clocking declaration
:expected_stderr_regex: test_illegal_global_clock_past_function_without_global_clocking\.sv:26:
*/
// IEEE 1800-2023 §16.9.4: the global clocking past and future sampled value
// functions may be used only if global clocking is defined (14.14).
// The design declares no global clocking. a_ok uses $rose with the clock of
// the assertion, which is legal; a_bad uses $rose_gclk, a global clocking past
// function.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count. Verilator 5.052 reports that $global_clock,
// which $rose_gclk uses, is not defined.

module test_illegal_global_clock_past_function_without_global_clocking;
  logic clk = 0, a = 0, b = 0;
  a_ok: assert property (@(posedge clk) a |-> $rose(b));
  a_bad: assert property (@(posedge clk) a |-> $rose_gclk(b));   // illegal
endmodule
