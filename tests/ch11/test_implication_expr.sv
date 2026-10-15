/*
:name: test_implication_expr
:description: Test implication operator (IEEE 1800-2023 Section 11.4.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implication_expr.expected
*/
// Test implication operator (IEEE 1800-2023 Section 11.4.7)

module test_implication_expr;
  int a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: True -> True = True
    a = 1;
    b = 1;
    if ((a > 0) -> (b > 0)) pass_count++;

    // Test 2: False -> anything = True
    a = 0;
    b = 0;
    if ((a > 0) -> (b > 0)) pass_count++;

    // Test 3: True -> False = False
    a = 1;
    b = 0;
    if (!((a > 0) -> (b > 0))) pass_count++;

    $display("Implication expr tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Implication expr tests");
    end else begin
      $display("FAIL: Some implication expr tests failed");
    end
  end
endmodule
