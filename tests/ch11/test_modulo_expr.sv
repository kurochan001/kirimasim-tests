/*
:name: test_modulo_expr
:description: Test modulo expression (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modulo_expr.expected
*/
// Test modulo expression (IEEE 1800-2023 Section 11.4.3)

module test_modulo_expr;
  int a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple modulo
    a = 17;
    b = 5;
    c = a % b;
    if (c == 2) pass_count++;

    // Test 2: Modulo with zero remainder
    c = 20 % 4;
    if (c == 0) pass_count++;

    // Test 3: Negative modulo
    c = -17 % 5;
    if (c == -2) pass_count++;

    // Test 4: Large modulo
    c = 1000 % 7;
    if (c == 6) pass_count++;

    $display("Modulo expr tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Modulo expr tests");
    end else begin
      $display("FAIL: Some modulo expr tests failed");
    end
  end
endmodule
