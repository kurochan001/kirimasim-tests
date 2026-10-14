/*
:name: test_real_math_hyperbolic
:description: Math functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_math_hyperbolic.expected
*/
// IEEE 1800-2023 Section 20.8 - Math functions
// Test: Hyperbolic functions

module test_real_math_hyperbolic;
  real r;
  real epsilon = 0.001;

  function automatic bit approx_equal(real a, real b, real tol);
    real diff = (a > b) ? (a - b) : (b - a);
    return (diff < tol);
  endfunction

  initial begin
    // Test $sinh - hyperbolic sine
    r = $sinh(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: sinh(0) = %f", r);

    r = $sinh(1.0);
    if (!approx_equal(r, 1.17520, epsilon)) $fatal(1, "FAIL: sinh(1) = %f", r);

    // Test $cosh - hyperbolic cosine
    r = $cosh(0.0);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: cosh(0) = %f", r);

    r = $cosh(1.0);
    if (!approx_equal(r, 1.54308, epsilon)) $fatal(1, "FAIL: cosh(1) = %f", r);

    // Test $tanh - hyperbolic tangent
    r = $tanh(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: tanh(0) = %f", r);

    r = $tanh(1.0);
    if (!approx_equal(r, 0.76159, epsilon)) $fatal(1, "FAIL: tanh(1) = %f", r);

    // Test $asinh - inverse hyperbolic sine
    r = $asinh(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: asinh(0) = %f", r);

    r = $asinh(1.17520);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: asinh(sinh(1)) = %f", r);

    // Test $acosh - inverse hyperbolic cosine
    r = $acosh(1.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: acosh(1) = %f", r);

    r = $acosh(1.54308);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: acosh(cosh(1)) = %f", r);

    // Test $atanh - inverse hyperbolic tangent
    r = $atanh(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: atanh(0) = %f", r);

    r = $atanh(0.76159);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: atanh(tanh(1)) = %f", r);

    $display("PASS: Hyperbolic functions");
    $finish(0);
  end
endmodule
