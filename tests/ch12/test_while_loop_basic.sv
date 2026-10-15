/*
:name: test_while_loop_basic
:description: Test while loop basic (IEEE 1800-2023 Section 12.7.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_while_loop_basic.expected
*/
// Test while loop basic (IEEE 1800-2023 Section 12.7.4)

module test_while_loop_basic;
  int i, sum;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple while
    i = 0;
    sum = 0;
    while (i < 5) begin
      sum++;
      i++;
    end
    if (sum == 5) pass_count++;

    // Test 2: Sum values
    i = 1;
    sum = 0;
    while (i <= 10) begin
      sum = sum + i;
      i++;
    end
    if (sum == 55) pass_count++;

    // Test 3: Never execute
    i = 10;
    sum = 0;
    while (i < 5) sum++;
    if (sum == 0) pass_count++;

    // Test 4: Compound condition
    i = 0;
    sum = 0;
    while (i < 10 && sum < 15) begin
      sum = sum + 3;
      i++;
    end
    if (sum == 15) pass_count++;

    $display("While loop basic tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: While loop basic tests");
    end else begin
      $display("FAIL: Some while loop tests failed");
    end
  end
endmodule
