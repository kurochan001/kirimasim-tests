/*
:name: test_statement_repeat
:description: Test for repeat statement (IEEE 1800-2023 §12.7.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_repeat.expected
*/
// Test for repeat statement (IEEE 1800-2023 §12.7.2)

module test_statement_repeat;
  int counter;
  int passed;

  initial begin
    passed = 0;
    counter = 0;

    // Test 1: Simple repeat
    $display("Test 1: Simple repeat");
    repeat (5) begin
      counter = counter + 1;
    end
    if (counter == 5) begin
      $display("  PASS: counter = %0d", counter);
      passed++;
    end else begin
      $display("  FAIL: expected 5, got %0d", counter);
    end

    // Test 2: Nested repeat
    $display("Test 2: Nested repeat");
    counter = 0;
    repeat (3) begin
      repeat (4) begin
        counter = counter + 1;
      end
    end
    if (counter == 12) begin
      $display("  PASS: nested counter = %0d", counter);
      passed++;
    end else begin
      $display("  FAIL: expected 12, got %0d", counter);
    end

    // Test 3: Repeat with variable
    $display("Test 3: Repeat with variable");
    counter = 0;
    begin
      int n;
      n = 7;
      repeat (n) begin
        counter = counter + 1;
      end
    end
    if (counter == 7) begin
      $display("  PASS: variable repeat = %0d", counter);
      passed++;
    end else begin
      $display("  FAIL: expected 7, got %0d", counter);
    end

    // Test 4: Repeat with zero
    $display("Test 4: Repeat with zero");
    counter = 100;
    repeat (0) begin
      counter = 0;
    end
    if (counter == 100) begin
      $display("  PASS: zero repeat unchanged");
      passed++;
    end else begin
      $display("  FAIL: counter changed to %0d", counter);
    end

    if (passed == 4) begin
      $display("TEST PASSED: %0d/4 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/4 tests passed", passed);
    end
    $finish;
  end
endmodule
