/*
:name: test_real_operand_truth_value
:description: A real operand is true when it is not zero, also when it lies between -0.5 and 0.5 (IEEE 1800-2023 Section 11.4.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7 11.4.11 12.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_operand_truth_value.expected
*/
// IEEE 1800-2023 §11.4.7: a logical operator takes an operand as true when
// it is not equal to zero; the condition of a conditional operator (11.4.11)
// and of an if statement (12.4) is taken the same way. For a real operand
// this compares the real value with zero: 0.4 and -0.3 are true although
// they would round to the integer 0, and -0.0 equals zero, so it is false.

module test_real_operand_truth_value;
  real values[4] = '{0.4, -0.3, 0.0, -0.0};
  string names[4] = '{"0.4", "-0.3", "0.0", "-0.0"};

  initial begin
    foreach (values[i]) begin
      real r;
      r = values[i];
      $display("%s: !r=%0d r&&1=%0d r||0=%0d r?1:0=%0d", names[i], !r, r && 1, r || 0,
               r ? 1 : 0);
      if (r) $display("  if (r) takes the true branch");
      else $display("  if (r) takes the false branch");
    end
  end
endmodule
