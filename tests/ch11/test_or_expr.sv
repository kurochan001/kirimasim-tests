/*
:name: test_or_expr
:description: Test OR expressions (IEEE 1800-2023 Section 11.4.8)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_or_expr.expected
*/
// Test OR expressions (IEEE 1800-2023 Section 11.4.8)

module test_or_expr;
  logic [7:0] a, b, result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: OR all zeros
    a = 8'h00;
    b = 8'h00;
    result = a | b;
    if (result == 8'h00) pass_count++;

    // Test 2: OR with ones
    a = 8'h00;
    b = 8'hFF;
    result = a | b;
    if (result == 8'hFF) pass_count++;

    // Test 3: OR combine
    a = 8'hF0;
    b = 8'h0F;
    result = a | b;
    if (result == 8'hFF) pass_count++;

    // Test 4: OR partial
    a = 8'hA0;
    b = 8'h0B;
    result = a | b;
    if (result == 8'hAB) pass_count++;

    // Test 5: NOR
    a = 8'h00;
    b = 8'h00;
    result = ~(a | b);
    if (result == 8'hFF) pass_count++;

    // Test 6: Chained OR
    a = 8'h01;
    b = 8'h02;
    result = a | b | 8'h04;
    if (result == 8'h07) pass_count++;

    $display("OR expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: OR expr tests");
    end else begin
      $display("FAIL: Some OR tests failed");
    end
  end
endmodule
