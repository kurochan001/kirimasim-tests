/*
:name: test_clog2_basic
:description: Test $clog2 basic (IEEE 1800-2023 Section 20.8)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2_basic.expected
*/
// Test $clog2 basic (IEEE 1800-2023 Section 20.8)

module test_clog2_basic;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Power of 2
    if ($clog2(8) == 3) pass_count++;

    // Test 2: Non-power of 2
    if ($clog2(5) == 3) pass_count++;

    // Test 3: 1
    if ($clog2(1) == 0) pass_count++;

    // Test 4: Larger value
    if ($clog2(256) == 8) pass_count++;

    $display("Clog2 basic tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Clog2 basic tests");
    end else begin
      $display("FAIL: Some clog2 tests failed");
    end
  end
endmodule
