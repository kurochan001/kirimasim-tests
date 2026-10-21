/*
:name: test_illegal_clocking_two_default
:description: A module cannot specify a default clocking more than once (IEEE 1800-2023 Section 14.12)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module has two default clocking blocks
:expected_stderr_regex: test_illegal_clocking_two_default\.sv:23:
*/
// IEEE 1800-2023 §14.12: only one default clocking can be specified in a
// module, interface, program or checker; a second one is a compiler error.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_clocking_two_default;
  logic clk1 = 0, clk2 = 0;
  default clocking cb1 @(posedge clk1);
  endclocking
  default clocking cb2 @(posedge clk2);   // illegal: second default clocking
  endclocking
  initial begin
    ##1;
    $display("done");
  end
  always #5 clk1 = ~clk1;
  always #7 clk2 = ~clk2;
  initial #30 $finish;
endmodule
