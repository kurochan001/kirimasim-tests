/*
:name: test_log10_basic
:description: Test $log10 basic (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_log10_basic.expected
*/
// Test $log10 basic (IEEE 1800-2023 Section 20.8.2)

module test_log10_basic;
  real r;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: log10(1) = 0
    r = $log10(1.0);
    if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) pass_count++;

    // Test 2: log10(10) = 1
    r = $log10(10.0);
    if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) pass_count++;

    // Test 3: log10(100) = 2
    r = $log10(100.0);
    if (r > 2.0 - 1e-9 && r < 2.0 + 1e-9) pass_count++;

    $display("Log10 basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Log10 basic tests");
    end else begin
      $display("FAIL: Some log10 tests failed");
    end
  end
endmodule
