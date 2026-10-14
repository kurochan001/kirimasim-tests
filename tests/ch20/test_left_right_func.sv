/*
:name: test_left_right_func
:description: Test $left/$right functions (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_left_right_func.expected
*/
// Test $left/$right functions (IEEE 1800-2023 Section 20.7)

module test_left_right_func;
  logic [7:0] arr [3:0];
  logic [15:8] rev_range;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Array left bound
    if ($left(arr) == 3) pass_count++;

    // Test 2: Array right bound
    if ($right(arr) == 0) pass_count++;

    // Test 3: Reversed range left
    if ($left(rev_range) == 15) pass_count++;

    // Test 4: Reversed range right
    if ($right(rev_range) == 8) pass_count++;

    // Test 5: $low (minimum bound)
    if ($low(arr) == 0) pass_count++;

    // Test 6: $high (maximum bound)
    if ($high(arr) == 3) pass_count++;

    $display("Left/right func tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Left/right func tests");
    end else begin
      $display("FAIL: Some left/right tests failed");
    end
  end
endmodule
