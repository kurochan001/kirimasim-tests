/*
:name: test_task_basic_2
:description: Basic task declaration test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_basic_2.expected
*/
// Basic task declaration test
module test_task_basic;

  int result;
  int array_data[4];

  // Simple task with no arguments
  task reset_result();
    result = 0;
  endtask

  // Task with input argument
  task set_result(input int value);
    result = value;
  endtask

  // Task with multiple arguments
  task add_to_result(int a, int b);
    result = a + b;
  endtask

  // Task with local variables
  task compute_sum(int max);
    int sum;
    sum = 0;
    for (int i = 1; i <= max; i++) begin
      sum = sum + i;
    end
    result = sum;
  endtask

  // Task that modifies array
  task init_array();
    for (int i = 0; i < 4; i++) begin
      array_data[i] = i * 10;
    end
  endtask

  initial begin
    int pass_count;
    pass_count = 0;

    // Test 1: Simple task call
    result = 999;
    reset_result();
    if (result == 0) begin
      $display("Test 1 PASS: reset_result() sets result to %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: result = %0d, expected 0", result);
    end

    // Test 2: Task with input argument
    set_result(42);
    if (result == 42) begin
      $display("Test 2 PASS: set_result(42) sets result to %0d", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: result = %0d, expected 42", result);
    end

    // Test 3: Task with multiple arguments
    add_to_result(15, 25);
    if (result == 40) begin
      $display("Test 3 PASS: add_to_result(15, 25) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: result = %0d, expected 40", result);
    end

    // Test 4: Task with local variables and loop
    compute_sum(10);
    if (result == 55) begin
      $display("Test 4 PASS: compute_sum(10) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: result = %0d, expected 55", result);
    end

    // Test 5: Task modifying array
    init_array();
    if (array_data[0] == 0 && array_data[1] == 10 &&
        array_data[2] == 20 && array_data[3] == 30) begin
      $display("Test 5 PASS: init_array() sets array to [%0d,%0d,%0d,%0d]",
               array_data[0], array_data[1], array_data[2], array_data[3]);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: array initialization incorrect");
    end

    if (pass_count == 5)
      $display("PASS: All basic task tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
