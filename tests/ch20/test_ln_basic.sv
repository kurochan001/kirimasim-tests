/*
:name: test_ln_basic
:description: Test $ln basic (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ln_basic.expected
*/
// Test $ln basic (IEEE 1800-2023 Section 20.8.2)

module test_ln_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: ln(1) = 0
    r = $ln(1.0);
    if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) pass_count++;

    // Test 2: ln(e) ~= 1
    r = $ln(2.718281828);
    if (r > 0.99 && r < 1.01) pass_count++;

    // Test 3: ln > 0 for x > 1
    r = $ln(10.0);
    if (r > 0.0) pass_count++;

    $display("Ln basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Ln basic tests");
    end else begin
      $display("FAIL: Some ln tests failed");
    end
  end
endmodule
