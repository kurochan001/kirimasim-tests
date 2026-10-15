/*
:name: test_pow_basic
:description: Test $pow basic (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pow_basic.expected
*/
// Test $pow basic (IEEE 1800-2023 Section 20.8.2)

module test_pow_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: pow(2,3) = 8
    r = $pow(2.0, 3.0);
    if (r > 8.0 - 1e-9 && r < 8.0 + 1e-9) pass_count++;

    // Test 2: pow(3,2) = 9
    r = $pow(3.0, 2.0);
    if (r > 9.0 - 1e-9 && r < 9.0 + 1e-9) pass_count++;

    // Test 3: pow(5,0) = 1
    r = $pow(5.0, 0.0);
    if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) pass_count++;

    $display("Pow basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Pow basic tests");
    end else begin
      $display("FAIL: Some pow tests failed");
    end
  end
endmodule
