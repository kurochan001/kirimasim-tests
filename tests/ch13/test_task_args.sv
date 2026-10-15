/*
:name: test_task_args
:description: Task arguments test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_args.expected
*/
// Task arguments test
module test_task_args;

  // Task with input arguments (default direction)
  task display_sum(int a, int b);
    $display("  Sum of %0d and %0d is %0d", a, b, a + b);
  endtask

  // Task with output argument
  task compute_square(input int value, output int squared);
    squared = value * value;
  endtask

  // Task with inout argument
  task double_value(inout int value);
    value = value * 2;
  endtask

  // Task with multiple output arguments
  task div_mod(input int dividend, input int divisor,
               output int quotient, output int remainder);
    quotient = dividend / divisor;
    remainder = dividend % divisor;
  endtask

  // Task with mixed argument directions
  task process_data(input int data_in, inout int accumulator, output int processed);
    accumulator = accumulator + data_in;
    processed = data_in * 2;
  endtask

  // Task with array argument
  task sum_array(input int arr[4], output int total);
    total = 0;
    for (int i = 0; i < 4; i++) begin
      total = total + arr[i];
    end
  endtask

  initial begin
    int result, result2;
    int acc, proc;
    int test_arr[4];
    int arr_sum;
    int pass_count;

    pass_count = 0;

    // Test 1: Output argument
    compute_square(7, result);
    if (result == 49) begin
      $display("Test 1 PASS: compute_square(7) -> squared = %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: squared = %0d, expected 49", result);
    end

    // Test 2: Inout argument
    result = 5;
    double_value(result);
    if (result == 10) begin
      $display("Test 2 PASS: double_value(5) -> value = %0d", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: value = %0d, expected 10", result);
    end

    // Test 3: Multiple output arguments
    div_mod(17, 5, result, result2);
    if (result == 3 && result2 == 2) begin
      $display("Test 3 PASS: div_mod(17, 5) -> quotient=%0d, remainder=%0d", result, result2);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: quotient=%0d (exp 3), remainder=%0d (exp 2)", result, result2);
    end

    // Test 4: Mixed argument directions
    acc = 100;
    process_data(25, acc, proc);
    if (acc == 125 && proc == 50) begin
      $display("Test 4 PASS: process_data(25, 100) -> acc=%0d, proc=%0d", acc, proc);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: acc=%0d (exp 125), proc=%0d (exp 50)", acc, proc);
    end

    // Test 5: Array argument
    test_arr = '{10, 20, 30, 40};
    sum_array(test_arr, arr_sum);
    if (arr_sum == 100) begin
      $display("Test 5 PASS: sum_array([10,20,30,40]) = %0d", arr_sum);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: sum = %0d, expected 100", arr_sum);
    end

    if (pass_count == 5)
      $display("PASS: All task arguments tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
