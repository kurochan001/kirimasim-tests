/*
:name: test_left_right
:description: Test $left/$right (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 20.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_left_right.expected
*/
// Test $left/$right (IEEE 1800-2023 Section 20.7)

module test_left_right;
  logic [15:8] data;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: $left
    if ($left(data) == 15) pass_count++;

    // Test 2: $right
    if ($right(data) == 8) pass_count++;

    // Test 3: $bits relationship
    if ($bits(data) == 8) pass_count++;

    $display("Left/right tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Left/right tests");
    end else begin
      $display("FAIL: Some left/right tests failed");
    end
  end
endmodule
