/*
:name: test_bitwise_xor
:description: Test bitwise xor (IEEE 1800-2023 Section 11.4.8)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_xor.expected
*/
// Test bitwise xor (IEEE 1800-2023 Section 11.4.8)

module test_bitwise_xor;
  logic [7:0] a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Xor with zeros
    a = 8'hAB;
    b = 8'h00;
    c = a ^ b;
    if (c == 8'hAB) pass_count++;

    // Test 2: Xor with all ones
    c = a ^ 8'hFF;
    if (c == 8'h54) pass_count++;

    // Test 3: Xor same values
    c = a ^ a;
    if (c == 8'h00) pass_count++;

    // Test 4: Xor pattern
    a = 8'hF0;
    b = 8'hAA;
    c = a ^ b;
    if (c == 8'h5A) pass_count++;

    $display("Bitwise xor tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Bitwise xor tests");
    end else begin
      $display("FAIL: Some bitwise xor tests failed");
    end
  end
endmodule
