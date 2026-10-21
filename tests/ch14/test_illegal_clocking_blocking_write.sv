/*
:name: test_illegal_clocking_blocking_write
:description: A clockvar can only be written by a synchronous drive, not by a blocking assignment (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a blocking assignment writes an output clockvar
:expected_stderr_regex: test_illegal_clocking_blocking_write\.sv:28:
*/
// IEEE 1800-2023 §14.16: it shall be an error to write to a clockvar other
// than with the synchronous drive, which uses the nonblocking assignment
// operator; a blocking assignment to cb.y is not a drive.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_clocking_blocking_write;
  logic clk = 0;
  logic y;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    @(cb);
    cb.y = 1;   // illegal: blocking assignment to a clockvar
  end
  always #5 clk = ~clk;
  initial #30 $finish;
endmodule
