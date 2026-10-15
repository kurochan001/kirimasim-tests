/*
:name: test_real_math_trig
:description: Math functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_math_trig.expected
*/
// IEEE 1800-2023 Section 20.8 - Math functions
// Test: Trigonometric functions

module test_real_math_trig;
  real r;
  real pi = 3.14159265;
  real epsilon = 0.001;

  function automatic bit approx_equal(real a, real b, real tol);
    real diff = (a > b) ? (a - b) : (b - a);
    return (diff < tol);
  endfunction

  initial begin
    // Test $sin
    r = $sin(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: sin(0) = %f", r);

    r = $sin(pi / 2.0);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: sin(pi/2) = %f", r);

    // Test $cos
    r = $cos(0.0);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: cos(0) = %f", r);

    r = $cos(pi);
    if (!approx_equal(r, -1.0, epsilon)) $fatal(1, "FAIL: cos(pi) = %f", r);

    // Test $tan
    r = $tan(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: tan(0) = %f", r);

    r = $tan(pi / 4.0);
    if (!approx_equal(r, 1.0, epsilon)) $fatal(1, "FAIL: tan(pi/4) = %f", r);

    // Test $asin
    r = $asin(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: asin(0) = %f", r);

    r = $asin(1.0);
    if (!approx_equal(r, pi / 2.0, epsilon)) $fatal(1, "FAIL: asin(1) = %f", r);

    // Test $acos
    r = $acos(1.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: acos(1) = %f", r);

    r = $acos(0.0);
    if (!approx_equal(r, pi / 2.0, epsilon)) $fatal(1, "FAIL: acos(0) = %f", r);

    // Test $atan
    r = $atan(0.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: atan(0) = %f", r);

    r = $atan(1.0);
    if (!approx_equal(r, pi / 4.0, epsilon)) $fatal(1, "FAIL: atan(1) = %f", r);

    // Test $atan2
    r = $atan2(1.0, 1.0);
    if (!approx_equal(r, pi / 4.0, epsilon)) $fatal(1, "FAIL: atan2(1,1) = %f", r);

    r = $atan2(0.0, 1.0);
    if (!approx_equal(r, 0.0, epsilon)) $fatal(1, "FAIL: atan2(0,1) = %f", r);

    $display("PASS: Trigonometric functions");
    $finish(0);
  end
endmodule
