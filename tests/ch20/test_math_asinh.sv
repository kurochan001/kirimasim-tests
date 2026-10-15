/*
:name: test_math_asinh
:description: $asinh function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_asinh.expected
*/
// $asinh function
module test_math_asinh;
  real result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: asinh(0) = 0
    result = $asinh(0.0);
    if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
      $display("PASS: $asinh(0.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $asinh(0.0) = %f, expected 0.0", result);
      fail_count++;
    end

    // Test 2: asinh(sinh(1)) ≈ 1
    result = $asinh($sinh(1.0));
    if (result > 0.99 && result < 1.01) begin
      $display("PASS: $asinh($sinh(1.0)) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $asinh($sinh(1.0)) = %f, expected ~1.0", result);
      fail_count++;
    end

    // Test 3: asinh(1) ≈ 0.881
    result = $asinh(1.0);
    if (result > 0.88 && result < 0.89) begin
      $display("PASS: $asinh(1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $asinh(1.0) = %f, expected ~0.881", result);
      fail_count++;
    end

    // Test 4: asinh(-1) ≈ -0.881 (odd function)
    result = $asinh(-1.0);
    if (result > -0.89 && result < -0.88) begin
      $display("PASS: $asinh(-1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $asinh(-1.0) = %f, expected ~-0.881", result);
      fail_count++;
    end

    // Test 5: asinh(2) ≈ 1.444
    result = $asinh(2.0);
    if (result > 1.44 && result < 1.45) begin
      $display("PASS: $asinh(2.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $asinh(2.0) = %f, expected ~1.444", result);
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
