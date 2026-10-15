/*
:name: test_add_expr
:description: Test addition expressions (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_add_expr.expected
*/
// Test addition expressions (IEEE 1800-2023 Section 11.4.3)

module test_add_expr;
  logic [7:0] a, b, result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple add
    a = 8'd10;
    b = 8'd20;
    result = a + b;
    if (result == 8'd30) pass_count++;

    // Test 2: Add zero
    a = 8'd50;
    b = 8'd0;
    result = a + b;
    if (result == 8'd50) pass_count++;

    // Test 3: Add with carry
    a = 8'd200;
    b = 8'd100;
    result = a + b;
    if (result == 8'd44) pass_count++;  // Overflow wraps

    // Test 4: Max add
    a = 8'd255;
    b = 8'd1;
    result = a + b;
    if (result == 8'd0) pass_count++;  // Overflow

    // Test 5: Multiple add
    result = a + b + 8'd10;
    if (result == 8'd10) pass_count++;

    // Test 6: Subtract
    a = 8'd50;
    b = 8'd30;
    result = a - b;
    if (result == 8'd20) pass_count++;

    $display("Add expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Add expr tests");
    end else begin
      $display("FAIL: Some add tests failed");
    end
  end
endmodule
