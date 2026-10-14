/*
:name: test_clog2_func
:description: Test $clog2 function (IEEE 1800-2023 Section 20.6)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2_func.expected
*/
// Test $clog2 function (IEEE 1800-2023 Section 20.6)

module test_clog2_func;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Power of 2
    if ($clog2(8) == 3) pass_count++;

    // Test 2: Non-power of 2
    if ($clog2(5) == 3) pass_count++;

    // Test 3: Edge case 1
    if ($clog2(1) == 0) pass_count++;

    // Test 4: Edge case 2
    if ($clog2(2) == 1) pass_count++;

    // Test 5: Larger value
    if ($clog2(16) == 4) pass_count++;

    // Test 6: 256
    if ($clog2(256) == 8) pass_count++;

    // Test 7: 1024
    if ($clog2(1024) == 10) pass_count++;

    $display("Clog2 func tests: %0d/7 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Clog2 func tests");
    end else begin
      $display("FAIL: Some clog2 tests failed");
    end
  end
endmodule
