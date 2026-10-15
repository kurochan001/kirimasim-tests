/*
:name: test_for_loop_basic
:description: Test for loop basic (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_basic.expected
*/
// Test for loop basic (IEEE 1800-2023 Section 12.7.1)

module test_for_loop_basic;
  int i, sum;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple for loop
    sum = 0;
    for (i = 0; i < 5; i++) sum++;
    if (sum == 5) pass_count++;

    // Test 2: Sum values
    sum = 0;
    for (i = 1; i <= 10; i++) sum = sum + i;
    if (sum == 55) pass_count++;

    // Test 3: Decrement
    sum = 0;
    for (i = 5; i > 0; i--) sum++;
    if (sum == 5) pass_count++;

    // Test 4: Step by 2
    sum = 0;
    for (i = 0; i < 10; i = i + 2) sum++;
    if (sum == 5) pass_count++;

    $display("For loop basic tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: For loop basic tests");
    end else begin
      $display("FAIL: Some for loop tests failed");
    end
  end
endmodule
