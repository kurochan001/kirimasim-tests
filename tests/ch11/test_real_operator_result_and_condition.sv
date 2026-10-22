/*
:name: test_real_operator_result_and_condition
:description: A real arithmetic operand promotes arithmetic and conditional results but comparisons stay one bit (IEEE 1800-2023 Section 11.3.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_operator_result_and_condition.expected
*/
// IEEE 1800-2023 11.3.1: The conditional condition itself does not promote the
// branch result; a real branch does promote it, while comparisons return a
// single bit.

module test_real_operator_result_and_condition;
  real r = 2.5;
  int n = 3;
  initial begin
    $display("sum=%0.1f conditional=%0.1f compare_bits=%0d condition_bits=%0d",
             r+n, 1 ? r : n, $bits(r < n), $bits(r ? 1 : 2));
  end
endmodule
