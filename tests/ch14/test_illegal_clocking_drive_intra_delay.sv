/*
:name: test_illegal_clocking_drive_intra_delay
:description: A synchronous drive cannot have an intra-assignment delay other than a cycle delay (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16 14.16.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a synchronous drive has a # intra-assignment delay
:expected_stderr_regex: test_illegal_clocking_drive_intra_delay\.sv:29:
*/
// IEEE 1800-2023 §14.16: a synchronous drive can delay its update by a cycle
// delay; no other form of intra-assignment delay is legal in a drive to a
// clockvar. §14.16.1: drives do not support the intra-assignment delays of
// nonblocking assignments.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_clocking_drive_intra_delay;
  logic clk = 0;
  logic y;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    @(cb);
    cb.y <= #2 1;   // illegal: # delay in a synchronous drive
  end
  always #5 clk = ~clk;
  initial #30 $finish;
endmodule
