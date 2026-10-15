/*
:name: test_math_atanh
:description: $atanh function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_atanh.expected
*/
// $atanh function
module test_math_atanh;
  real result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: atanh(0) = 0
    result = $atanh(0.0);
    if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
      $display("PASS: $atanh(0.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $atanh(0.0) = %f, expected 0.0", result);
      fail_count++;
    end

    // Test 2: atanh(tanh(0.5)) ≈ 0.5
    result = $atanh($tanh(0.5));
    if (result > 0.49 && result < 0.51) begin
      $display("PASS: $atanh($tanh(0.5)) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $atanh($tanh(0.5)) = %f, expected ~0.5", result);
      fail_count++;
    end

    // Test 3: atanh(0.5) ≈ 0.549
    result = $atanh(0.5);
    if (result > 0.54 && result < 0.56) begin
      $display("PASS: $atanh(0.5) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $atanh(0.5) = %f, expected ~0.549", result);
      fail_count++;
    end

    // Test 4: atanh(-0.5) ≈ -0.549 (odd function)
    result = $atanh(-0.5);
    if (result > -0.56 && result < -0.54) begin
      $display("PASS: $atanh(-0.5) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $atanh(-0.5) = %f, expected ~-0.549", result);
      fail_count++;
    end

    // Test 5: atanh(0.9) ≈ 1.472
    result = $atanh(0.9);
    if (result > 1.47 && result < 1.48) begin
      $display("PASS: $atanh(0.9) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $atanh(0.9) = %f, expected ~1.472", result);
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
