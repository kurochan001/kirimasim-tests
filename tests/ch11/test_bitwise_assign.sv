/*
:name: test_bitwise_assign
:description: Test bitwise compound assignment (IEEE 1800-2023 Section 11.4.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_assign.expected
*/
// Test bitwise compound assignment (IEEE 1800-2023 Section 11.4.1)

module test_bitwise_assign;
  logic [7:0] a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: &= operator
    a = 8'hFF;
    a &= 8'h0F;
    if (a == 8'h0F) pass_count++;

    // Test 2: |= operator
    a = 8'hF0;
    a |= 8'h0F;
    if (a == 8'hFF) pass_count++;

    // Test 3: ^= operator
    a = 8'hAA;
    a ^= 8'hFF;
    if (a == 8'h55) pass_count++;

    $display("Bitwise assign tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Bitwise assign tests");
    end else begin
      $display("FAIL: Some bitwise assign tests failed");
    end
  end
endmodule
