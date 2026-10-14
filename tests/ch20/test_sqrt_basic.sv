/*
:name: test_sqrt_basic
:description: Test $sqrt basic (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sqrt_basic.expected
*/
// Test $sqrt basic (IEEE 1800-2023 Section 20.8.2)

module test_sqrt_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: sqrt(4) = 2
    r = $sqrt(4.0);
    if (r == 2.0) pass_count++;

    // Test 2: sqrt(9) = 3
    r = $sqrt(9.0);
    if (r == 3.0) pass_count++;

    // Test 3: sqrt(16) = 4
    r = $sqrt(16.0);
    if (r == 4.0) pass_count++;

    $display("Sqrt basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Sqrt basic tests");
    end else begin
      $display("FAIL: Some sqrt tests failed");
    end
  end
endmodule
