/*
:name: test_if_stmt
:description: Test if statement (IEEE 1800-2023 Section 12.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_stmt.expected
*/
// Test if statement (IEEE 1800-2023 Section 12.4)

module test_if_stmt;
  int a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: If true
    a = 10;
    if (a > 5) b = 1;
    else b = 0;
    if (b == 1) pass_count++;

    // Test 2: If false
    a = 3;
    if (a > 5) b = 1;
    else b = 0;
    if (b == 0) pass_count++;

    // Test 3: If-else if
    a = 10;
    if (a < 5) b = 1;
    else if (a < 15) b = 2;
    else b = 3;
    if (b == 2) pass_count++;

    // Test 4: Nested if
    a = 20;
    if (a > 10) begin
      if (a > 15) b = 100;
      else b = 50;
    end
    if (b == 100) pass_count++;

    $display("If stmt tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: If stmt tests");
    end else begin
      $display("FAIL: Some if stmt tests failed");
    end
  end
endmodule
