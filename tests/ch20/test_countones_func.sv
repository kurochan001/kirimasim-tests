/*
:name: test_countones_func
:description: Test $countones function (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countones_func.expected
*/
// Test $countones function (IEEE 1800-2023 Section 20.9)

module test_countones_func;
  logic [7:0] val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: All zeros
    val = 8'b00000000;
    if ($countones(val) == 0) pass_count++;

    // Test 2: All ones
    val = 8'b11111111;
    if ($countones(val) == 8) pass_count++;

    // Test 3: Single bit
    val = 8'b00000001;
    if ($countones(val) == 1) pass_count++;

    // Test 4: Multiple bits
    val = 8'b10101010;
    if ($countones(val) == 4) pass_count++;

    // Test 5: Another pattern
    val = 8'b11110000;
    if ($countones(val) == 4) pass_count++;

    // Test 6: Mixed
    val = 8'b01100110;
    if ($countones(val) == 4) pass_count++;

    $display("Countones func tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Countones func tests");
    end else begin
      $display("FAIL: Some countones tests failed");
    end
  end
endmodule
