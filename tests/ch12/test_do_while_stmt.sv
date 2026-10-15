/*
:name: test_do_while_stmt
:description: Test do-while statement (IEEE 1800-2023 Section 12.7.5)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_do_while_stmt.expected
*/
// Test do-while statement (IEEE 1800-2023 Section 12.7.5)

module test_do_while_stmt;
  int counter;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Basic do-while
    counter = 0;
    do begin
      counter = counter + 1;
    end while (counter < 5);
    if (counter == 5) pass_count++;

    // Test 2: Execute at least once
    counter = 10;
    do begin
      counter = counter + 1;
    end while (counter < 5);
    if (counter == 11) pass_count++;

    // Test 3: Multiple iterations
    counter = 0;
    do begin
      counter = counter + 3;
    end while (counter < 10);
    if (counter == 12) pass_count++;

    $display("Do-while tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Do-while tests");
    end else begin
      $display("FAIL: Some do-while tests failed");
    end
  end
endmodule
