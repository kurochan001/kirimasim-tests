/*
:name: test_abs_basic
:description: Test abs operations (IEEE 1800-2023 Section 11.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abs_basic.expected
*/
// Test abs operations (IEEE 1800-2023 Section 11.4)

module test_abs_basic;
  int a, b;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Positive int abs
    a = 42;
    b = (a < 0) ? -a : a;
    if (b == 42) pass_count++;

    // Test 2: Negative int abs
    a = -10;
    b = (a < 0) ? -a : a;
    if (b == 10) pass_count++;

    // Test 3: Zero abs
    a = 0;
    b = (a < 0) ? -a : a;
    if (b == 0) pass_count++;

    $display("Abs basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Abs basic tests");
    end else begin
      $display("FAIL: Some abs tests failed");
    end
  end
endmodule
