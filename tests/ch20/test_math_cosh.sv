/*
:name: test_math_cosh
:description: $cosh at simple arguments
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_cosh.expected
*/
// $cosh at simple arguments
module test_math_cosh;
  real result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: cosh(0) = 1
    result = $cosh(0.0);
    if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
      $display("PASS: $cosh(0.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(0.0) = %f, expected 1.0", result);
      fail_count++;
    end

    // Test 2: cosh(1) ≈ 1.543
    result = $cosh(1.0);
    if (result > 1.54 && result < 1.55) begin
      $display("PASS: $cosh(1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(1.0) = %f, expected ~1.543", result);
      fail_count++;
    end

    // Test 3: cosh(-1) ≈ 1.543 (even function)
    result = $cosh(-1.0);
    if (result > 1.54 && result < 1.55) begin
      $display("PASS: $cosh(-1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(-1.0) = %f, expected ~1.543", result);
      fail_count++;
    end

    // Test 4: cosh(2) ≈ 3.762
    result = $cosh(2.0);
    if (result > 3.76 && result < 3.77) begin
      $display("PASS: $cosh(2.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(2.0) = %f, expected ~3.762", result);
      fail_count++;
    end

    // Test 5: cosh(x) >= 1 for all x
    result = $cosh(0.5);
    if (result > 1.127 && result < 1.128) begin  // cosh(0.5) = 1.1276...
      $display("PASS: $cosh(0.5) = %f >= 1.0", result);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(0.5) = %f should be >= 1.0", result);
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
