/*
:name: test_unary_plus
:description: Test unary plus (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unary_plus.expected
*/
// Test unary plus (IEEE 1800-2023 Section 11.4.3)

module test_unary_plus;
  int a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Positive value
    a = 42;
    b = +a;
    if (b == 42) pass_count++;

    // Test 2: Negative value
    a = -10;
    b = +a;
    if (b == -10) pass_count++;

    // Test 3: Zero
    a = 0;
    b = +a;
    if (b == 0) pass_count++;

    // Test 4: Expression
    a = 5;
    b = +(a + 3);
    if (b == 8) pass_count++;

    $display("Unary plus tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Unary plus tests");
    end else begin
      $display("FAIL: Some unary plus tests failed");
    end
  end
endmodule
