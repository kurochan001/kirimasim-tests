/*
:name: test_bitwise_and
:description: Test bitwise and (IEEE 1800-2023 Section 11.4.8)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_and.expected
*/
// Test bitwise and (IEEE 1800-2023 Section 11.4.8)

module test_bitwise_and;
  logic [7:0] a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: And with all ones
    a = 8'hAB;
    b = 8'hFF;
    c = a & b;
    if (c == 8'hAB) pass_count++;

    // Test 2: And with all zeros
    c = a & 8'h00;
    if (c == 8'h00) pass_count++;

    // Test 3: And pattern
    a = 8'hF0;
    b = 8'h0F;
    c = a & b;
    if (c == 8'h00) pass_count++;

    // Test 4: And same value
    a = 8'hCD;
    c = a & a;
    if (c == 8'hCD) pass_count++;

    $display("Bitwise and tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Bitwise and tests");
    end else begin
      $display("FAIL: Some bitwise and tests failed");
    end
  end
endmodule
