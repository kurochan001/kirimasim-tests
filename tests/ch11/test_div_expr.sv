/*
:name: test_div_expr
:description: Test division expressions (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_div_expr.expected
*/
// Test division expressions (IEEE 1800-2023 Section 11.4.3)

module test_div_expr;
  int a, b, result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple divide
    a = 15;
    b = 3;
    result = a / b;
    if (result == 5) pass_count++;

    // Test 2: Integer division
    a = 17;
    b = 5;
    result = a / b;
    if (result == 3) pass_count++;

    // Test 3: Divide by one
    a = 42;
    b = 1;
    result = a / b;
    if (result == 42) pass_count++;

    // Test 4: Larger values
    a = 1000;
    b = 10;
    result = a / b;
    if (result == 100) pass_count++;

    // Test 5: Modulo
    a = 17;
    b = 5;
    result = a % b;
    if (result == 2) pass_count++;

    // Test 6: Modulo zero
    a = 20;
    b = 5;
    result = a % b;
    if (result == 0) pass_count++;

    $display("Div expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Div expr tests");
    end else begin
      $display("FAIL: Some div tests failed");
    end
  end
endmodule
