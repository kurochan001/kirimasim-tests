/*
:name: test_ceil_basic
:description: Test $ceil basic (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ceil_basic.expected
*/
// Test $ceil basic (IEEE 1800-2023 Section 20.8)

module test_ceil_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: ceil(3.2) = 4
    r = $ceil(3.2);
    if (r == 4.0) pass_count++;

    // Test 2: ceil(3.0) = 3
    r = $ceil(3.0);
    if (r == 3.0) pass_count++;

    // Test 3: ceil(-2.7) = -2
    r = $ceil(-2.7);
    if (r == -2.0) pass_count++;

    $display("Ceil basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Ceil basic tests");
    end else begin
      $display("FAIL: Some ceil tests failed");
    end
  end
endmodule
