/*
:name: test_real_type
:description: Test real/shortreal types (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_type.expected
*/
// Test real/shortreal types (IEEE 1800-2023 Section 6.12)

module test_real_type;
  real r1, r2;
  shortreal sr;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Real assignment
    r1 = 3.14159;
    if (r1 > 3.14 && r1 < 3.15) pass_count++;

    // Test 2: Real arithmetic
    r1 = 10.5;
    r2 = 2.5;
    if (r1 + r2 == 13.0) pass_count++;

    // Test 3: Real subtraction
    if (r1 - r2 == 8.0) pass_count++;

    // Test 4: Real multiplication
    r1 = 2.5;
    r2 = 4.0;
    if (r1 * r2 == 10.0) pass_count++;

    // Test 5: Real division
    r1 = 10.0;
    r2 = 4.0;
    if (r1 / r2 == 2.5) pass_count++;

    // Test 6: Real comparison
    r1 = 5.5;
    r2 = 5.5;
    if (r1 == r2) pass_count++;

    // Test 7: Shortreal
    sr = 1.5;
    if (sr > 1.0) pass_count++;

    $display("Real type tests: %0d/7 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Real type tests");
    end else begin
      $display("FAIL: Some real tests failed");
    end
  end
endmodule
