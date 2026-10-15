/*
:name: test_math_acosh
:description: $acosh function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_acosh.expected
*/
// $acosh function
module test_math_acosh;
  real result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: acosh(1) = 0
    result = $acosh(1.0);
    if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
      $display("PASS: $acosh(1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $acosh(1.0) = %f, expected 0.0", result);
      fail_count++;
    end

    // Test 2: acosh(cosh(1)) ≈ 1
    result = $acosh($cosh(1.0));
    if (result > 0.99 && result < 1.01) begin
      $display("PASS: $acosh($cosh(1.0)) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $acosh($cosh(1.0)) = %f, expected ~1.0", result);
      fail_count++;
    end

    // Test 3: acosh(2) ≈ 1.317
    result = $acosh(2.0);
    if (result > 1.31 && result < 1.32) begin
      $display("PASS: $acosh(2.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $acosh(2.0) = %f, expected ~1.317", result);
      fail_count++;
    end

    // Test 4: acosh(10) ≈ 2.993
    result = $acosh(10.0);
    if (result > 2.99 && result < 3.00) begin
      $display("PASS: $acosh(10.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $acosh(10.0) = %f, expected ~2.993", result);
      fail_count++;
    end

    // Test 5: acosh(cosh(2)) ≈ 2
    result = $acosh($cosh(2.0));
    if (result > 1.99 && result < 2.01) begin
      $display("PASS: $acosh($cosh(2.0)) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $acosh($cosh(2.0)) = %f, expected ~2.0", result);
      fail_count++;
    end

    // Summary
    $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All tests passed");
    else
      $display("FAIL: Some tests failed");
    $finish;
  end
endmodule
