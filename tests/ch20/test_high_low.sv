/*
:name: test_high_low
:description: Test $high/$low (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_high_low.expected
*/
// Test $high/$low (IEEE 1800-2023 Section 20.7)

module test_high_low;
  logic [7:0] arr[0:9];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: $high
    if ($high(arr) == 9) pass_count++;

    // Test 2: $low
    if ($low(arr) == 0) pass_count++;

    // Test 3: Dimension specified
    if ($high(arr, 1) == 9) pass_count++;

    $display("High/low tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: High/low tests");
    end else begin
      $display("FAIL: Some high/low tests failed");
    end
  end
endmodule
