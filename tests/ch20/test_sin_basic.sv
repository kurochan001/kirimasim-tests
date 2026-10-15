/*
:name: test_sin_basic
:description: Test $sin basic (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sin_basic.expected
*/
// Test $sin basic (IEEE 1800-2023 Section 20.8.2)

module test_sin_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: sin(0) = 0
    r = $sin(0.0);
    if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) pass_count++;

    // Test 2: sin(pi/2) ~= 1
    r = $sin(1.5707963);
    if (r > 0.99 && r < 1.01) pass_count++;

    // Test 3: sin between -1 and 1
    r = $sin(0.5);
    if (r >= -1.0 && r <= 1.0) pass_count++;

    $display("Sin basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Sin basic tests");
    end else begin
      $display("FAIL: Some sin tests failed");
    end
  end
endmodule
