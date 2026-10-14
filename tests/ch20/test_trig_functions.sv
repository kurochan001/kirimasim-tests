/*
:name: test_trig_functions
:description: Test for trigonometric functions (IEEE 1800-2023 §20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_trig_functions.expected
*/
// Test for trigonometric functions (IEEE 1800-2023 §20.8)
// Tests $sin, $cos, $tan, $asin, $acos, $atan, $atan2

module test_trig_functions;

  int pass_count = 0;
  int test_count = 0;
  real r;
  real pi;
  real tolerance = 0.0001;

  // Helper function to check approximate equality
  // automatic: diff gets the new arguments on each call (13.4.2)
  function automatic bit approx_eq(real a, real b, real tol);
    real diff = a - b;
    if (diff < 0) diff = -diff;
    return diff < tol;
  endfunction

  initial begin
    pi = 3.14159265358979;

    // Test 1: $sin(0) = 0
    test_count++;
    r = $sin(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $sin(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $sin(0) expected 0, got %f", r);
    end

    // Test 2: $sin(pi/2) = 1
    test_count++;
    r = $sin(pi / 2.0);
    if (approx_eq(r, 1.0, tolerance)) begin
      $display("PASS: $sin(pi/2) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $sin(pi/2) expected 1, got %f", r);
    end

    // Test 3: $cos(0) = 1
    test_count++;
    r = $cos(0.0);
    if (approx_eq(r, 1.0, tolerance)) begin
      $display("PASS: $cos(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $cos(0) expected 1, got %f", r);
    end

    // Test 4: $cos(pi) = -1
    test_count++;
    r = $cos(pi);
    if (approx_eq(r, -1.0, tolerance)) begin
      $display("PASS: $cos(pi) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $cos(pi) expected -1, got %f", r);
    end

    // Test 5: $tan(0) = 0
    test_count++;
    r = $tan(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $tan(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $tan(0) expected 0, got %f", r);
    end

    // Test 6: $tan(pi/4) = 1
    test_count++;
    r = $tan(pi / 4.0);
    if (approx_eq(r, 1.0, tolerance)) begin
      $display("PASS: $tan(pi/4) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $tan(pi/4) expected 1, got %f", r);
    end

    // Test 7: $asin(0) = 0
    test_count++;
    r = $asin(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $asin(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $asin(0) expected 0, got %f", r);
    end

    // Test 8: $asin(1) = pi/2
    test_count++;
    r = $asin(1.0);
    if (approx_eq(r, pi / 2.0, tolerance)) begin
      $display("PASS: $asin(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $asin(1) expected %f, got %f", pi / 2.0, r);
    end

    // Test 9: $acos(1) = 0
    test_count++;
    r = $acos(1.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $acos(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $acos(1) expected 0, got %f", r);
    end

    // Test 10: $acos(0) = pi/2
    test_count++;
    r = $acos(0.0);
    if (approx_eq(r, pi / 2.0, tolerance)) begin
      $display("PASS: $acos(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $acos(0) expected %f, got %f", pi / 2.0, r);
    end

    // Test 11: $atan(0) = 0
    test_count++;
    r = $atan(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $atan(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $atan(0) expected 0, got %f", r);
    end

    // Test 12: $atan(1) = pi/4
    test_count++;
    r = $atan(1.0);
    if (approx_eq(r, pi / 4.0, tolerance)) begin
      $display("PASS: $atan(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $atan(1) expected %f, got %f", pi / 4.0, r);
    end

    // Test 13: $atan2(1, 1) = pi/4
    test_count++;
    r = $atan2(1.0, 1.0);
    if (approx_eq(r, pi / 4.0, tolerance)) begin
      $display("PASS: $atan2(1, 1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $atan2(1, 1) expected %f, got %f", pi / 4.0, r);
    end

    // Test 14: $atan2(0, 1) = 0
    test_count++;
    r = $atan2(0.0, 1.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $atan2(0, 1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $atan2(0, 1) expected 0, got %f", r);
    end

    // Test 15: sin^2 + cos^2 = 1 identity
    test_count++;
    begin
      static real sin_val = $sin(1.0);
      static real cos_val = $cos(1.0);
      static real sum;
      // Assigned here so the result does not depend on the order of static initializers.
      sum = sin_val * sin_val + cos_val * cos_val;
      if (approx_eq(sum, 1.0, tolerance)) begin
        $display("PASS: sin^2(1) + cos^2(1) = %f", sum);
        pass_count++;
      end else begin
        $display("FAIL: sin^2 + cos^2 expected 1, got %f", sum);
      end
    end

    // Summary
    $display("");
    $display("=== Trigonometric Functions Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All trigonometric function tests passed");
    end else begin
      $display("FAIL: Some trigonometric function tests failed");
    end

    $finish;
  end

endmodule
