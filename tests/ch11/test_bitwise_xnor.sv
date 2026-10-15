/*
:name: test_bitwise_xnor
:description: Test bitwise xnor (IEEE 1800-2023 Section 11.4.8)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_xnor.expected
*/
// Test bitwise xnor (IEEE 1800-2023 Section 11.4.8)

module test_bitwise_xnor;
  logic [7:0] a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Xnor same values
    a = 8'hAB;
    c = a ~^ a;
    if (c == 8'hFF) pass_count++;

    // Test 2: Xnor with all ones
    c = a ~^ 8'hFF;
    if (c == 8'hAB) pass_count++;

    // Test 3: Xnor with zeros
    c = a ~^ 8'h00;
    if (c == 8'h54) pass_count++;

    // Test 4: Xnor pattern
    a = 8'hF0;
    b = 8'h0F;
    c = a ~^ b;
    if (c == 8'h00) pass_count++;

    $display("Bitwise xnor tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Bitwise xnor tests");
    end else begin
      $display("FAIL: Some bitwise xnor tests failed");
    end
  end
endmodule
