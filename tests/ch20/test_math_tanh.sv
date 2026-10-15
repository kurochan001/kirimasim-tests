/*
:name: test_math_tanh
:description: $tanh at simple arguments
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_tanh.expected
*/
// $tanh at simple arguments
module test_math_tanh;
  real result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: tanh(0) = 0
    result = $tanh(0.0);
    if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
      $display("PASS: $tanh(0.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(0.0) = %f, expected 0.0", result);
      fail_count++;
    end

    // Test 2: tanh(1) ≈ 0.762
    result = $tanh(1.0);
    if (result > 0.76 && result < 0.77) begin
      $display("PASS: $tanh(1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(1.0) = %f, expected ~0.762", result);
      fail_count++;
    end

    // Test 3: tanh(-1) ≈ -0.762 (odd function)
    result = $tanh(-1.0);
    if (result > -0.77 && result < -0.76) begin
      $display("PASS: $tanh(-1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(-1.0) = %f, expected ~-0.762", result);
      fail_count++;
    end

    // Test 4: tanh approaches 1 for large x
    result = $tanh(10.0);
    if (result > 0.999) begin
      $display("PASS: $tanh(10.0) = %f (close to 1)", result);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(10.0) = %f, expected close to 1", result);
      fail_count++;
    end

    // Test 5: -1 < tanh(x) < 1 for all x
    result = $tanh(0.5);
    if (result > 0.462 && result < 0.463) begin  // tanh(0.5) = 0.4621...
      $display("PASS: $tanh(0.5) = %f is in (-1, 1)", result);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(0.5) = %f should be in (-1, 1)", result);
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
