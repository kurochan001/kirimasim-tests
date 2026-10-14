/*
:name: test_math_funcs
:description: Test math functions (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_funcs.expected
*/
// Test math functions (IEEE 1800-2023 Section 20.8.2)

module test_math_funcs;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: $ln
    r = $ln(2.718281828);
    if (r > 0.99 && r < 1.01) pass_count++;

    // Test 2: $log10
    r = $log10(100.0);
    if (r > 1.99 && r < 2.01) pass_count++;

    // Test 3: $exp
    r = $exp(1.0);
    if (r > 2.71 && r < 2.72) pass_count++;

    // Test 4: $sqrt
    r = $sqrt(16.0);
    if (r > 3.99 && r < 4.01) pass_count++;

    // Test 5: $pow
    r = $pow(2.0, 3.0);
    if (r > 7.99 && r < 8.01) pass_count++;

    // Test 6: $floor
    r = $floor(3.7);
    if (r == 3.0) pass_count++;

    // Test 7: $ceil
    r = $ceil(3.2);
    if (r == 4.0) pass_count++;

    $display("Math funcs tests: %0d/7 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Math funcs tests");
    end else begin
      $display("FAIL: Some math tests failed");
    end
  end
endmodule
