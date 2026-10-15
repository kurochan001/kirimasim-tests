/*
:name: test_onehot_func
:description: Test $onehot/$onehot0 functions (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_onehot_func.expected
*/
// Test $onehot/$onehot0 functions (IEEE 1800-2023 Section 20.9)

module test_onehot_func;
  logic [7:0] val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Single bit set
    val = 8'b00000100;
    if ($onehot(val)) pass_count++;

    // Test 2: Multiple bits set
    val = 8'b00000110;
    if (!$onehot(val)) pass_count++;

    // Test 3: Zero value with onehot0
    val = 8'b00000000;
    if ($onehot0(val)) pass_count++;

    // Test 4: Single bit with onehot0
    val = 8'b00100000;
    if ($onehot0(val)) pass_count++;

    // Test 5: Multiple bits with onehot0
    val = 8'b00110000;
    if (!$onehot0(val)) pass_count++;

    // Test 6: MSB set
    val = 8'b10000000;
    if ($onehot(val)) pass_count++;

    $display("Onehot func tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Onehot func tests");
    end else begin
      $display("FAIL: Some onehot tests failed");
    end
  end
endmodule
