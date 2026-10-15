/*
:name: test_math_edge
:description: Math function edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2 20.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_edge.expected
*/
// IEEE 1800-2023 §20.8: Math function edge cases
`timescale 1ns/1ps

module test_math_edge;
  real r;
  int i;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: $pow edge cases
    r = $pow(2.0, 10.0);
    if (!(r > 1024.0 - 1e-9 && r < 1024.0 + 1e-9)) begin
      $display("FAIL: $pow(2,10) expected 1024, got %f", r);
      test_passed = 0;
    end

    // Test 2: $pow(0, 0) - mathematically undefined but typically 1
    r = $pow(0.0, 0.0);
    if (!(r > 1.0 - 1e-9 && r < 1.0 + 1e-9)) begin
      $display("FAIL: $pow(0,0) expected 1, got %f", r);
      test_passed = 0;
    end

    // Test 3: $pow with negative exponent
    r = $pow(2.0, -1.0);
    if (abs_real(r - 0.5) > 0.0001) begin
      $display("FAIL: $pow(2,-1) expected 0.5, got %f", r);
      test_passed = 0;
    end

    // Test 4: $sqrt
    r = $sqrt(2.0);
    if (abs_real(r - 1.41421356) > 0.0001) begin
      $display("FAIL: $sqrt(2) incorrect: %f", r);
      test_passed = 0;
    end

    // Test 5: $sqrt(0)
    r = $sqrt(0.0);
    if (r != 0.0) begin
      $display("FAIL: $sqrt(0) should be 0");
      test_passed = 0;
    end

    // Test 6: $ln(1) = 0
    r = $ln(1.0);
    if (abs_real(r) > 0.0001) begin
      $display("FAIL: $ln(1) should be 0, got %f", r);
      test_passed = 0;
    end

    // Test 7: $exp(0) = 1
    r = $exp(0.0);
    if (abs_real(r - 1.0) > 0.0001) begin
      $display("FAIL: $exp(0) should be 1, got %f", r);
      test_passed = 0;
    end

    // Test 8: $log10(100) = 2
    r = $log10(100.0);
    if (abs_real(r - 2.0) > 0.0001) begin
      $display("FAIL: $log10(100) should be 2, got %f", r);
      test_passed = 0;
    end

    // Test 9: Trigonometric at boundaries
    r = $sin(0.0);
    if (abs_real(r) > 0.0001) begin
      $display("FAIL: $sin(0) should be 0");
      test_passed = 0;
    end

    r = $cos(0.0);
    if (abs_real(r - 1.0) > 0.0001) begin
      $display("FAIL: $cos(0) should be 1");
      test_passed = 0;
    end

    // Test 10: $atan2 quadrants
    r = $atan2(1.0, 1.0);  // 45 degrees = pi/4
    if (abs_real(r - 0.7853981) > 0.0001) begin
      $display("FAIL: $atan2(1,1) should be pi/4, got %f", r);
      test_passed = 0;
    end

    r = $atan2(1.0, -1.0);  // 135 degrees = 3*pi/4
    if (abs_real(r - 2.3561944) > 0.0001) begin
      $display("FAIL: $atan2(1,-1) should be 3*pi/4, got %f", r);
      test_passed = 0;
    end

    // Test 11: $hypot
    r = $hypot(3.0, 4.0);
    if (abs_real(r - 5.0) > 0.0001) begin
      $display("FAIL: $hypot(3,4) should be 5, got %f", r);
      test_passed = 0;
    end

    // Test 12: $ceil/$floor
    if ($ceil(2.3) != 3.0) begin
      $display("FAIL: $ceil(2.3) should be 3");
      test_passed = 0;
    end
    if ($floor(2.9) != 2.0) begin
      $display("FAIL: $floor(2.9) should be 2");
      test_passed = 0;
    end

    // Test 13: $clog2
    i = $clog2(8);
    if (i != 3) begin
      $display("FAIL: $clog2(8) should be 3, got %0d", i);
      test_passed = 0;
    end
    i = $clog2(9);
    if (i != 4) begin
      $display("FAIL: $clog2(9) should be 4, got %0d", i);
      test_passed = 0;
    end

    // Test 14: $clog2 edge cases
    i = $clog2(1);
    if (i != 0) begin
      $display("FAIL: $clog2(1) should be 0, got %0d", i);
      test_passed = 0;
    end
    i = $clog2(0);
    if (i != 0) begin
      $display("FAIL: $clog2(0) should be 0, got %0d", i);
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Math function edge cases");
    end else begin
      $display("FAIL: Some math tests failed");
    end
    $finish;
  end

  // Helper function for absolute value
  function real abs_real(real x);
    return (x < 0.0) ? -x : x;
  endfunction
endmodule
