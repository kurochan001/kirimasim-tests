/*
:name: test_real_equality_is_exact
:description: Equality of reals compares the exact double values, without a tolerance, in ==, != and a case statement (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 6.12 12.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_equality_is_exact.expected
*/
// IEEE 1800-2023 §6.12: real is the C double type, so 0.1 + 0.2 is the double
// nearest to that sum, which is larger than the double nearest to 0.3. The
// equality operators (11.4.5) and the comparisons of a case statement (12.5)
// compare these values exactly: 0.1 + 0.2 is not equal to 0.3, and 1.0 is
// not equal to 1.000000000000001, although they differ by little.

module test_real_equality_is_exact;
  real sum;

  initial begin
    sum = 0.1;
    sum = sum + 0.2;
    $display("sum == 0.3: %0d, sum != 0.3: %0d, sum > 0.3: %0d", sum == 0.3, sum != 0.3,
             sum > 0.3);
    $display("1.0 == 1.000000000000001: %0d", 1.0 == 1.000000000000001);
    case (sum)
      0.3: $display("case: 0.3");
      default: $display("case: default");
    endcase
  end
endmodule
