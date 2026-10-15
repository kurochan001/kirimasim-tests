/*
:name: test_unary_minus
:description: Test unary minus (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unary_minus.expected
*/
// Test unary minus (IEEE 1800-2023 Section 11.4.3)

module test_unary_minus;
  int a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Negate positive
    a = 42;
    b = -a;
    if (b == -42) pass_count++;

    // Test 2: Negate negative
    a = -10;
    b = -a;
    if (b == 10) pass_count++;

    // Test 3: Negate zero
    a = 0;
    b = -a;
    if (b == 0) pass_count++;

    // Test 4: Double negation
    a = 5;
    b = -(-a);
    if (b == 5) pass_count++;

    $display("Unary minus tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Unary minus tests");
    end else begin
      $display("FAIL: Some unary minus tests failed");
    end
  end
endmodule
