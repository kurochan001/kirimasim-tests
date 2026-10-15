/*
:name: test_hyperbolic_functions
:description: Test for hyperbolic functions (IEEE 1800-2023 §20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hyperbolic_functions.expected
*/
// Test for hyperbolic functions (IEEE 1800-2023 §20.8)
// Tests $sinh, $cosh, $tanh, $asinh, $acosh, $atanh

module test_hyperbolic_functions;

  int pass_count = 0;
  int test_count = 0;
  real r;
  real tolerance = 0.0001;

  // Helper function to check approximate equality
  // automatic: diff gets the new arguments on each call (13.4.2)
  function automatic bit approx_eq(real a, real b, real tol);
    real diff = a - b;
    if (diff < 0) diff = -diff;
    return diff < tol;
  endfunction

  initial begin
    // Test 1: $sinh(0) = 0
    test_count++;
    r = $sinh(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $sinh(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $sinh(0) expected 0, got %f", r);
    end

    // Test 2: $cosh(0) = 1
    test_count++;
    r = $cosh(0.0);
    if (approx_eq(r, 1.0, tolerance)) begin
      $display("PASS: $cosh(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(0) expected 1, got %f", r);
    end

    // Test 3: $tanh(0) = 0
    test_count++;
    r = $tanh(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $tanh(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(0) expected 0, got %f", r);
    end

    // Test 4: $sinh(1) approx 1.1752
    test_count++;
    r = $sinh(1.0);
    if (approx_eq(r, 1.1752, 0.001)) begin
      $display("PASS: $sinh(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $sinh(1) expected ~1.1752, got %f", r);
    end

    // Test 5: $cosh(1) approx 1.5431
    test_count++;
    r = $cosh(1.0);
    if (approx_eq(r, 1.5431, 0.001)) begin
      $display("PASS: $cosh(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $cosh(1) expected ~1.5431, got %f", r);
    end

    // Test 6: $tanh(1) approx 0.7616
    test_count++;
    r = $tanh(1.0);
    if (approx_eq(r, 0.7616, 0.001)) begin
      $display("PASS: $tanh(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $tanh(1) expected ~0.7616, got %f", r);
    end

    // Test 7: $asinh(0) = 0
    test_count++;
    r = $asinh(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $asinh(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $asinh(0) expected 0, got %f", r);
    end

    // Test 8: $acosh(1) = 0
    test_count++;
    r = $acosh(1.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $acosh(1) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $acosh(1) expected 0, got %f", r);
    end

    // Test 9: $atanh(0) = 0
    test_count++;
    r = $atanh(0.0);
    if (approx_eq(r, 0.0, tolerance)) begin
      $display("PASS: $atanh(0) = %f", r);
      pass_count++;
    end else begin
      $display("FAIL: $atanh(0) expected 0, got %f", r);
    end

    // Test 10: Identity cosh^2 - sinh^2 = 1
    test_count++;
    begin
      static real sinh_val = $sinh(1.0);
      static real cosh_val = $cosh(1.0);
      static real diff;
      // Assigned here so the result does not depend on the order of static initializers.
      diff = cosh_val * cosh_val - sinh_val * sinh_val;
      if (approx_eq(diff, 1.0, tolerance)) begin
        $display("PASS: cosh^2(1) - sinh^2(1) = %f", diff);
        pass_count++;
      end else begin
        $display("FAIL: cosh^2 - sinh^2 expected 1, got %f", diff);
      end
    end

    // Test 11: $tanh is bounded by [-1, 1]
    test_count++;
    begin
      static real tanh_large = $tanh(10.0);
      if (tanh_large > 0.99 && tanh_large < 1.01) begin
        $display("PASS: $tanh(10) approaches 1: %f", tanh_large);
        pass_count++;
      end else begin
        $display("FAIL: $tanh(10) expected ~1, got %f", tanh_large);
      end
    end

    // Test 12: Inverse function check asinh(sinh(x)) = x
    test_count++;
    begin
      static real x = 0.5;
      static real y;
      static real z;
      // Assigned here so the result does not depend on the order of static initializers.
      y = $sinh(x);
      z = $asinh(y);
      if (approx_eq(z, x, tolerance)) begin
        $display("PASS: $asinh($sinh(0.5)) = %f", z);
        pass_count++;
      end else begin
        $display("FAIL: $asinh($sinh(0.5)) expected 0.5, got %f", z);
      end
    end

    // Summary
    $display("");
    $display("=== Hyperbolic Functions Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All hyperbolic function tests passed");
    end else begin
      $display("FAIL: Some hyperbolic function tests failed");
    end

    $finish;
  end

endmodule
