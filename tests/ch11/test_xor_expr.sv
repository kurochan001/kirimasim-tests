/*
:name: test_xor_expr
:description: Bitwise XOR and XNOR of 8-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_xor_expr.expected
*/
// Bitwise XOR and XNOR of 8-bit values

module test_xor_expr;
  logic [7:0] a, b, result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: XOR all zeros
    a = 8'h00;
    b = 8'h00;
    result = a ^ b;
    if (result == 8'h00) pass_count++;

    // Test 2: XOR with ones
    a = 8'hFF;
    b = 8'h00;
    result = a ^ b;
    if (result == 8'hFF) pass_count++;

    // Test 3: XOR same values
    a = 8'hAA;
    b = 8'hAA;
    result = a ^ b;
    if (result == 8'h00) pass_count++;

    // Test 4: XOR different values
    a = 8'hAA;
    b = 8'h55;
    result = a ^ b;
    if (result == 8'hFF) pass_count++;

    // Test 5: XNOR
    result = ~(a ^ b);
    if (result == 8'h00) pass_count++;

    // Test 6: XOR expression
    result = (a ^ b) ^ a;
    if (result == 8'h55) pass_count++;

    $display("XOR expr tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: XOR expr tests");
    end else begin
      $display("FAIL: Some XOR tests failed");
    end
  end
endmodule
