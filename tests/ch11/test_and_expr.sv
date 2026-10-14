/*
:name: test_and_expr
:description: Test AND expressions (IEEE 1800-2023 Section 11.4.8)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_and_expr.expected
*/
// Test AND expressions (IEEE 1800-2023 Section 11.4.8)

module test_and_expr;
  logic [7:0] a, b, result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: AND all ones
    a = 8'hFF;
    b = 8'hFF;
    result = a & b;
    if (result == 8'hFF) pass_count++;

    // Test 2: AND with zeros
    a = 8'hFF;
    b = 8'h00;
    result = a & b;
    if (result == 8'h00) pass_count++;

    // Test 3: AND mask
    a = 8'hAB;
    b = 8'hF0;
    result = a & b;
    if (result == 8'hA0) pass_count++;

    // Test 4: AND lower nibble
    a = 8'hCD;
    b = 8'h0F;
    result = a & b;
    if (result == 8'h0D) pass_count++;

    // Test 5: NAND
    result = ~(a & b);
    if (result == 8'hF2) pass_count++;

    // Test 6: Chained AND
    result = a & b & 8'h0F;
    if (result == 8'h0D) pass_count++;

    $display("AND expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: AND expr tests");
    end else begin
      $display("FAIL: Some AND tests failed");
    end
  end
endmodule
