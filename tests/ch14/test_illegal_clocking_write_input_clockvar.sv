/*
:name: test_illegal_clocking_write_input_clockvar
:description: A clockvar of direction input cannot be written (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a synchronous drive writes an input clockvar
:expected_stderr_regex: test_illegal_clocking_write_input_clockvar\.sv:27:
*/
// IEEE 1800-2023 §14.3: it shall be illegal to write to a clockvar whose
// clocking direction is input; only output and inout clockvars are driven.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_clocking_write_input_clockvar;
  logic clk = 0;
  logic a = 0;
  clocking cb @(posedge clk);
    input a;
  endclocking
  initial begin
    @(cb);
    cb.a <= 1;   // illegal: write to an input clockvar
  end
  always #5 clk = ~clk;
  initial #30 $finish;
endmodule
