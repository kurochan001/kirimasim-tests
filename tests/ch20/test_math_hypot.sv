/*
:name: test_math_hypot
:description: $hypot of Pythagorean triples and other values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_hypot.expected
*/
// $hypot of Pythagorean triples and other values
module test_math_hypot;
  real result;
  real expected;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: hypot(3, 4) = 5 (3-4-5 triangle)
    result = $hypot(3.0, 4.0);
    expected = 5.0;
    // $hypot need not be exact to the last bit; allow 1e-9.
    if (result - expected < 1e-9 && expected - result < 1e-9) begin
      $display("PASS: $hypot(3.0, 4.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $hypot(3.0, 4.0) = %f, expected %f", result, expected);
      fail_count++;
    end

    // Test 2: hypot(5, 12) = 13 (5-12-13 triangle)
    result = $hypot(5.0, 12.0);
    expected = 13.0;
    // $hypot need not be exact to the last bit; allow 1e-9.
    if (result - expected < 1e-9 && expected - result < 1e-9) begin
      $display("PASS: $hypot(5.0, 12.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $hypot(5.0, 12.0) = %f, expected %f", result, expected);
      fail_count++;
    end

    // Test 3: hypot(1, 1) ≈ 1.414
    result = $hypot(1.0, 1.0);
    if (result > 1.41 && result < 1.42) begin
      $display("PASS: $hypot(1.0, 1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $hypot(1.0, 1.0) = %f, expected ~1.414", result);
      fail_count++;
    end

    // Test 4: hypot(0, 5) = 5
    result = $hypot(0.0, 5.0);
    expected = 5.0;
    // $hypot need not be exact to the last bit; allow 1e-9.
    if (result - expected < 1e-9 && expected - result < 1e-9) begin
      $display("PASS: $hypot(0.0, 5.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $hypot(0.0, 5.0) = %f, expected %f", result, expected);
      fail_count++;
    end

    // Test 5: hypot(8, 15) = 17 (8-15-17 triangle)
    result = $hypot(8.0, 15.0);
    expected = 17.0;
    // $hypot need not be exact to the last bit; allow 1e-9.
    if (result - expected < 1e-9 && expected - result < 1e-9) begin
      $display("PASS: $hypot(8.0, 15.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $hypot(8.0, 15.0) = %f, expected %f", result, expected);
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
