/*
:name: test_statement_while
:description: Test for while statement (IEEE 1800-2023 §12.7.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_while.expected
*/
// Test for while statement (IEEE 1800-2023 §12.7.4)

module test_statement_while;
  int counter;
  int passed;

  initial begin
    passed = 0;

    // Test 1: Simple while
    $display("Test 1: Simple while");
    counter = 0;
    while (counter < 5) begin
      counter = counter + 1;
    end
    if (counter == 5) begin
      $display("  PASS: counter = %0d", counter);
      passed++;
    end else begin
      $display("  FAIL: expected 5, got %0d", counter);
    end

    // Test 2: While with break
    $display("Test 2: While with break");
    counter = 0;
    while (1) begin
      counter = counter + 1;
      if (counter >= 3) break;
    end
    if (counter == 3) begin
      $display("  PASS: break at %0d", counter);
      passed++;
    end else begin
      $display("  FAIL: expected 3, got %0d", counter);
    end

    // Test 3: While with continue
    $display("Test 3: While with continue");
    counter = 0;
    begin
      int sum;
      sum = 0;
      while (counter < 10) begin
        counter = counter + 1;
        if (counter % 2 == 0) continue;
        sum = sum + counter;
      end
      $display("  Sum of odd numbers 1-9 = %0d", sum);
      if (sum == 25) begin
        $display("  PASS");
        passed++;
      end else begin
        $display("  FAIL: sum = %0d", sum);
      end
    end

    // Test 4: While false condition
    $display("Test 4: While false condition");
    counter = 100;
    while (0) begin
      counter = 0;
    end
    if (counter == 100) begin
      $display("  PASS: while(0) not executed");
      passed++;
    end else begin
      $display("  FAIL: counter changed");
    end

    // Test 5: Nested while
    $display("Test 5: Nested while");
    begin
      int i, j, sum;
      i = 0;
      sum = 0;
      while (i < 3) begin
        j = 0;
        while (j < 3) begin
          sum = sum + 1;
          j = j + 1;
        end
        i = i + 1;
      end
      if (sum == 9) begin
        $display("  PASS: nested while sum = %0d", sum);
        passed++;
      end else begin
        $display("  FAIL: expected 9, got %0d", sum);
      end
    end

    if (passed == 5) begin
      $display("TEST PASSED: %0d/5 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/5 tests passed", passed);
    end
    $finish;
  end
endmodule
