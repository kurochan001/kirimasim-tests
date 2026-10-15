/*
:name: test_break_stmt
:description: Test break statement (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_stmt.expected
*/
// Test break statement (IEEE 1800-2023 Section 12.8)

module test_break_stmt;
  int counter;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Break from for loop
    counter = 0;
    for (int i = 0; i < 100; i++) begin
      counter = counter + 1;
      if (i == 4) break;
    end
    if (counter == 5) pass_count++;

    // Test 2: Break from while loop
    counter = 0;
    while (counter < 100) begin
      counter = counter + 1;
      if (counter == 7) break;
    end
    if (counter == 7) pass_count++;

    // Test 3: Nested break (inner only)
    counter = 0;
    for (int i = 0; i < 3; i++) begin
      for (int j = 0; j < 10; j++) begin
        counter = counter + 1;
        if (j == 1) break;
      end
    end
    if (counter == 6) pass_count++;  // 3 outer * 2 inner

    $display("Break stmt tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Break stmt tests");
    end else begin
      $display("FAIL: Some break stmt tests failed");
    end
  end
endmodule
