/*
:name: test_illegal_cycle_delay_intra_assignment
:description: A cycle delay cannot be an intra-assignment delay (IEEE 1800-2023 Section 14.11)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.11 10.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a blocking assignment has a cycle delay as its intra-assignment delay
:expected_stderr_regex: test_illegal_cycle_delay_intra_assignment\.sv:26:
*/
// IEEE 1800-2023 §14.11: cycle delay timing controls shall not be used as
// intra-assignment delays of blocking or nonblocking assignments; they can
// prefix a statement or a synchronous drive.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_cycle_delay_intra_assignment;
  logic clk = 0;
  int a = 1, b;
  default clocking cb @(posedge clk);
  endclocking
  initial begin
    b = ##1 a;   // illegal: cycle delay inside the assignment
    $display("b=%0d", b);
  end
  always #5 clk = ~clk;
  initial #50 $finish;
endmodule
