/*
:name: test_illegal_clocking_read_output_clockvar
:description: A clockvar of direction output cannot be read (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of an output clockvar is read
:expected_stderr_regex: test_illegal_clocking_read_output_clockvar\.sv:25:
*/
// IEEE 1800-2023 §14.3: it shall be illegal to read the value of a clockvar
// whose clocking direction is output; an inout clockvar reads as its input.

module test_illegal_clocking_read_output_clockvar;
  logic clk = 0;
  logic y;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    @(cb);
    $display("y=%b", cb.y);   // illegal: read of an output clockvar
  end
  always #5 clk = ~clk;
  initial #30 $finish;
endmodule
