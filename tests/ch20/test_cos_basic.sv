/*
:name: test_cos_basic
:description: Test $cos basic (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cos_basic.expected
*/
// Test $cos basic (IEEE 1800-2023 Section 20.8)

module test_cos_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: cos(0) = 1
    r = $cos(0.0);
    if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) pass_count++;

    // Test 2: cos(pi) ~= -1
    r = $cos(3.14159265);
    if (r > -1.01 && r < -0.99) pass_count++;

    // Test 3: cos between -1 and 1
    r = $cos(0.5);
    if (r >= -1.0 && r <= 1.0) pass_count++;

    $display("Cos basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Cos basic tests");
    end else begin
      $display("FAIL: Some cos tests failed");
    end
  end
endmodule
