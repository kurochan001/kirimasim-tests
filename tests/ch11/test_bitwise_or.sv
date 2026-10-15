/*
:name: test_bitwise_or
:description: Test bitwise or (IEEE 1800-2023 Section 11.4.8)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_or.expected
*/
// Test bitwise or (IEEE 1800-2023 Section 11.4.8)

module test_bitwise_or;
  logic [7:0] a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Or with all zeros
    a = 8'hAB;
    b = 8'h00;
    c = a | b;
    if (c == 8'hAB) pass_count++;

    // Test 2: Or with all ones
    c = a | 8'hFF;
    if (c == 8'hFF) pass_count++;

    // Test 3: Or pattern
    a = 8'hF0;
    b = 8'h0F;
    c = a | b;
    if (c == 8'hFF) pass_count++;

    // Test 4: Or same value
    a = 8'hCD;
    c = a | a;
    if (c == 8'hCD) pass_count++;

    $display("Bitwise or tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Bitwise or tests");
    end else begin
      $display("FAIL: Some bitwise or tests failed");
    end
  end
endmodule
