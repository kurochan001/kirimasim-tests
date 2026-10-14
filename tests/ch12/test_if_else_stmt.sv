/*
:name: test_if_else_stmt
:description: Test if-else statements (IEEE 1800-2023 Section 12.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_stmt.expected
*/
// Test if-else statements (IEEE 1800-2023 Section 12.4)

module test_if_else_stmt;
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple if true
    val = 10;
    if (val > 5) pass_count++;

    // Test 2: Simple if false
    if (val > 20) val = 0;
    else val = 1;
    if (val == 1) pass_count++;

    // Test 3: Nested if
    val = 50;
    if (val > 0) begin
      if (val > 25) begin
        val = 100;
      end
    end
    if (val == 100) pass_count++;

    // Test 4: if-else-if chain
    val = 30;
    if (val < 10) val = 1;
    else if (val < 20) val = 2;
    else if (val < 40) val = 3;
    else val = 4;
    if (val == 3) pass_count++;

    // Test 5: Compound condition
    val = 15;
    if (val > 10 && val < 20) pass_count++;

    // Test 6: Or condition
    val = 5;
    if (val == 5 || val == 10) pass_count++;

    $display("If-else statement tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: If-else statement tests");
    end else begin
      $display("FAIL: Some if-else tests failed");
    end
  end
endmodule
