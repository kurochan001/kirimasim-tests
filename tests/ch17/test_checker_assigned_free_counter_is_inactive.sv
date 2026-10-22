/*
:name: test_checker_assigned_free_counter_is_inactive
:description: An assigned free checker counter is inactive for randomization and follows its explicit arithmetic updates (IEEE 1800-2023 Section 17.7.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assigned_free_counter_is_inactive.expected
*/
// IEEE 1800-2023 17.7.2 17.7.1: An initialized rand checker variable that is
// assigned by a checker procedure must not be independently randomized between
// deterministic increments.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

checker free_counter(input bit clk, output bit [3:0] result);
  rand bit [3:0] value = 2;
  always_ff @(posedge clk) value <= value + 2;
  assign result = value;
endchecker
module test_checker_assigned_free_counter_is_inactive;
  bit clk;
  wire [3:0] result;
  free_counter c(clk, result);
  always #5 clk = ~clk;
  initial begin
    #6 $display("first=%0d", result);
    #10 $display("second=%0d", result);
    $finish;
  end
endmodule
