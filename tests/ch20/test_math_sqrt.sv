/*
:name: test_math_sqrt
:description: $sqrt function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_sqrt.expected
*/
// $sqrt function
module test_math_sqrt;
  real result;
  real expected;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: sqrt(4) = 2
    result = $sqrt(4.0);
    expected = 2.0;
    if (result == expected) begin
      $display("PASS: $sqrt(4.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sqrt(4.0) = %f, expected %f", result, expected);
      fail_count++;
    end

    // Test 2: sqrt(9) = 3
    result = $sqrt(9.0);
    expected = 3.0;
    if (result == expected) begin
      $display("PASS: $sqrt(9.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sqrt(9.0) = %f, expected %f", result, expected);
      fail_count++;
    end

    // Test 3: sqrt(2) ≈ 1.414
    result = $sqrt(2.0);
    if (result > 1.41 && result < 1.42) begin
      $display("PASS: $sqrt(2.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sqrt(2.0) = %f, expected ~1.414", result);
      fail_count++;
    end

    // Test 4: sqrt(0) = 0
    result = $sqrt(0.0);
    expected = 0.0;
    if (result == expected) begin
      $display("PASS: $sqrt(0.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sqrt(0.0) = %f, expected %f", result, expected);
      fail_count++;
    end

    // Test 5: sqrt(100) = 10
    result = $sqrt(100.0);
    expected = 10.0;
    if (result == expected) begin
      $display("PASS: $sqrt(100.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sqrt(100.0) = %f, expected %f", result, expected);
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
