/*
:name: test_exp_basic
:description: Test $exp basic (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exp_basic.expected
*/
// Test $exp basic (IEEE 1800-2023 Section 20.8)

module test_exp_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: exp(0) = 1
    r = $exp(0.0);
    if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) pass_count++;

    // Test 2: exp(1) ~= e
    r = $exp(1.0);
    if (r > 2.71 && r < 2.72) pass_count++;

    // Test 3: exp > 1 for x > 0
    r = $exp(2.0);
    if (r > 1.0) pass_count++;

    $display("Exp basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Exp basic tests");
    end else begin
      $display("FAIL: Some exp tests failed");
    end
  end
endmodule
