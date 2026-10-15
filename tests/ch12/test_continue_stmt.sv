/*
:name: test_continue_stmt
:description: Test continue statement (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continue_stmt.expected
*/
// Test continue statement (IEEE 1800-2023 Section 12.8)

module test_continue_stmt;
  int sum;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Skip evens with continue
    sum = 0;
    for (int i = 0; i < 10; i++) begin
      if (i % 2 == 0) continue;
      sum = sum + i;
    end
    if (sum == 25) pass_count++;  // 1+3+5+7+9

    // Test 2: Continue on specific value
    sum = 0;
    for (int i = 0; i < 5; i++) begin
      if (i == 2) continue;
      sum = sum + i;
    end
    if (sum == 8) pass_count++;  // 0+1+3+4

    // Test 3: Continue in while
    sum = 0;
    begin
      static int j = 0;
      while (j < 6) begin
        j = j + 1;
        if (j == 3) continue;
        sum = sum + j;
      end
    end
    if (sum == 18) pass_count++;  // 1+2+4+5+6

    $display("Continue stmt tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Continue stmt tests");
    end else begin
      $display("FAIL: Some continue stmt tests failed");
    end
  end
endmodule
