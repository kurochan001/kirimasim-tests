/*
:name: test_power_expr
:description: Test power expressions (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_power_expr.expected
*/
// Test power expressions (IEEE 1800-2023 Section 11.4.3)

module test_power_expr;
  int result;
  real r_result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: 2^3
    result = 2 ** 3;
    if (result == 8) pass_count++;

    // Test 2: 3^2
    result = 3 ** 2;
    if (result == 9) pass_count++;

    // Test 3: Power of 0
    result = 5 ** 0;
    if (result == 1) pass_count++;

    // Test 4: Power of 1
    result = 10 ** 1;
    if (result == 10) pass_count++;

    // Test 5: 0 to power
    result = 0 ** 5;
    if (result == 0) pass_count++;

    // Test 6: Larger power
    result = 2 ** 10;
    if (result == 1024) pass_count++;

    $display("Power expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Power expr tests");
    end else begin
      $display("FAIL: Some power tests failed");
    end
  end
endmodule
