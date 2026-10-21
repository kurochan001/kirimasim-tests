/*
:name: test_illegal_cycle_delay_without_default_clocking
:description: A cycle delay needs a default clocking in its module (IEEE 1800-2023 Section 14.11)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.11 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a cycle delay is used in a module without a default clocking
:expected_stderr_regex: test_illegal_cycle_delay_without_default_clocking\.sv:25:
*/
// IEEE 1800-2023 §14.11: a cycle delay ##n waits for events of the default
// clocking; if the module has no default clocking, the compiler shall issue
// an error. The clocking block cb is not the default one.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_cycle_delay_without_default_clocking;
  logic clk = 0;
  clocking cb @(posedge clk);
  endclocking
  initial begin
    ##2;   // illegal: no default clocking
    $display("done");
  end
  always #5 clk = ~clk;
  initial #50 $finish;
endmodule
