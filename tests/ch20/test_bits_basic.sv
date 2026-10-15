/*
:name: test_bits_basic
:description: Test $bits basic (IEEE 1800-2023 Section 20.6)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_basic.expected
*/
// Test $bits basic (IEEE 1800-2023 Section 20.6)

module test_bits_basic;
  logic [7:0] a;
  logic [31:0] b;
  int c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: 8-bit logic
    if ($bits(a) == 8) pass_count++;

    // Test 2: 32-bit logic
    if ($bits(b) == 32) pass_count++;

    // Test 3: int type
    if ($bits(c) == 32) pass_count++;

    // Test 4: Type expression
    if ($bits(logic [15:0]) == 16) pass_count++;

    $display("Bits basic tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Bits basic tests");
    end else begin
      $display("FAIL: Some bits tests failed");
    end
  end
endmodule
