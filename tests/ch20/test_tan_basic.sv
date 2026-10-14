/*
:name: test_tan_basic
:description: Test $tan basic (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tan_basic.expected
*/
// Test $tan basic (IEEE 1800-2023 Section 20.8)

module test_tan_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: tan(0) = 0
    r = $tan(0.0);
    if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) pass_count++;

    // Test 2: tan(pi/4) ~= 1
    r = $tan(0.7853981);
    if (r > 0.99 && r < 1.01) pass_count++;

    // Test 3: tan(0.5)
    r = $tan(0.5);
    if (r > 0.5463 && r < 0.5464) pass_count++;  // tan(0.5) = 0.546302...

    $display("Tan basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Tan basic tests");
    end else begin
      $display("FAIL: Some tan tests failed");
    end
  end
endmodule
