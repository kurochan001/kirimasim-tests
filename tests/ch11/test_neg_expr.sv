/*
:name: test_neg_expr
:description: Test negation expressions (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_neg_expr.expected
*/
// Test negation expressions (IEEE 1800-2023 Section 11.4.3)

module test_neg_expr;
  int a, result;
  logic signed [7:0] s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Negate positive
    a = 42;
    result = -a;
    if (result == -42) pass_count++;

    // Test 2: Negate negative
    a = -10;
    result = -a;
    if (result == 10) pass_count++;

    // Test 3: Negate zero
    a = 0;
    result = -a;
    if (result == 0) pass_count++;

    // Test 4: Double negate
    a = 15;
    result = -(-a);
    if (result == 15) pass_count++;

    // Test 5: Signed negate
    s = 8'sd50;
    s = -s;
    if (s == -8'sd50) pass_count++;

    // Test 6: Negate in expression
    a = 10;
    result = 5 + (-a);
    if (result == -5) pass_count++;

    $display("Neg expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Neg expr tests");
    end else begin
      $display("FAIL: Some neg tests failed");
    end
  end
endmodule
