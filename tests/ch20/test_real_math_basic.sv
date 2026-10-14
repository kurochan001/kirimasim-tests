/*
:name: test_real_math_basic
:description: Math functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_math_basic.expected
*/
// IEEE 1800-2023 Section 20.8 - Math functions
// Test: Basic real math functions

module test_real_math_basic;
  real r;
  real epsilon = 0.0001;  // Tolerance for floating point comparison

  function automatic bit approx_equal(real a, real b, real tol);
    real diff = (a > b) ? (a - b) : (b - a);
    return (diff < tol);
  endfunction

  initial begin
    // Test $ceil - round up
    r = $ceil(3.2);
    if (!approx_equal(r, 4.0, epsilon)) $fatal(1, "FAIL: ceil(3.2) = %f", r);

    r = $ceil(-3.2);
    if (!approx_equal(r, -3.0, epsilon)) $fatal(1, "FAIL: ceil(-3.2) = %f", r);

    // Test $floor - round down
    r = $floor(3.8);
    if (!approx_equal(r, 3.0, epsilon)) $fatal(1, "FAIL: floor(3.8) = %f", r);

    r = $floor(-3.8);
    if (!approx_equal(r, -4.0, epsilon)) $fatal(1, "FAIL: floor(-3.8) = %f", r);

    // Test $sqrt - square root
    r = $sqrt(16.0);
    if (!approx_equal(r, 4.0, epsilon)) $fatal(1, "FAIL: sqrt(16) = %f", r);

    r = $sqrt(2.0);
    if (!approx_equal(r, 1.4142, 0.001)) $fatal(1, "FAIL: sqrt(2) = %f", r);

    // Test $pow - power
    r = $pow(2.0, 3.0);
    if (!approx_equal(r, 8.0, epsilon)) $fatal(1, "FAIL: pow(2,3) = %f", r);

    r = $pow(10.0, 2.0);
    if (!approx_equal(r, 100.0, epsilon)) $fatal(1, "FAIL: pow(10,2) = %f", r);

    // Test $exp - exponential (e^x)
    r = $exp(0.0);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: exp(0) = %f", r);

    r = $exp(1.0);
    if (!approx_equal(r, 2.71828, 0.001)) $fatal(1, "FAIL: exp(1) = %f", r);

    // Test $ln - natural logarithm (IEEE 1800-2023 Section 20.8.2)
    // Note: $log math function does NOT exist in SystemVerilog; use $ln for natural log
    r = $ln(1.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: ln(1) = %f", r);

    r = $ln(2.71828);
    if (!approx_equal(r, 1.0, 0.001)) $fatal(1, "FAIL: ln(e) = %f", r);

    // Test $log10 - base 10 logarithm
    r = $log10(100.0);
    if (!approx_equal(r, 2.0, epsilon)) $fatal(1, "FAIL: log10(100) = %f", r);

    r = $log10(1000.0);
    if (!approx_equal(r, 3.0, epsilon)) $fatal(1, "FAIL: log10(1000) = %f", r);

    $display("PASS: Real math basic functions");
    $finish(0);
  end
endmodule
