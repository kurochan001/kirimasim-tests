/*
:name: test_task_disable
:description: Tests disabling named blocks within tasks
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2 13.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_disable.expected
*/
// Tests disabling named blocks within tasks

module test_task_disable;

  int result;
  int iteration_count;

  // Test 1: Disable named block in loop
  task automatic search_value(input int arr[8], input int target, output int index);
    index = -1;
    begin : search_block
      for (int i = 0; i < 8; i++) begin
        if (arr[i] == target) begin
          index = i;
          disable search_block;
        end
      end
    end
  endtask

  // Test 2: Disable outer block from inner loop
  task automatic find_first_positive(input int arr[5], output int value);
    value = 0;
    begin : outer_block
      for (int i = 0; i < 5; i++) begin : inner_loop
        if (arr[i] > 0) begin
          value = arr[i];
          disable outer_block;
        end
      end
    end
  endtask

  // Test 3: Multiple named blocks
  task automatic process_data(input int data, output int status);
    status = 0;
    begin : validation
      if (data < 0) begin
        status = -1;
        disable validation;
      end
      if (data > 100) begin
        status = -2;
        disable validation;
      end
      status = 1;  // Valid
    end
  endtask

  // Test 4: Nested named blocks
  task automatic nested_search(input int matrix[4][4], input int target, output int row, output int col);
    row = -1;
    col = -1;
    begin : outer_search
      for (int i = 0; i < 4; i++) begin : row_loop
        for (int j = 0; j < 4; j++) begin : col_loop
          if (matrix[i][j] == target) begin
            row = i;
            col = j;
            disable outer_search;
          end
        end
      end
    end
  endtask

  // Test 5: Disable with cleanup
  task automatic process_with_cleanup(input int value, output int result);
    result = 0;
    begin : main_process
      if (value == 0) begin
        result = -1;
        disable main_process;
      end

      // Normal processing
      result = value * 2;

      if (result > 100) begin
        result = 100;  // Cap at 100
        disable main_process;
      end

      result = result + 10;  // Add bonus
    end
  endtask

  initial begin
    static int pass_count = 0;
    static int fail_count = 0;

    static int arr8[8] = '{5, 10, 15, 20, 25, 30, 35, 40};
    static int arr5[5] = '{-3, -1, 0, 5, 10};
    int matrix[4][4];
    int index, value, status, row, col, res;

    // Initialize matrix
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        matrix[i][j] = i * 4 + j;
      end
    end
    matrix[2][3] = 99;  // Special value to find

    // Test 1: Search with disable
    $display("Test 1: Search with disable named block");
    search_value(arr8, 20, index);
    if (index == 3) begin
      $display("PASS: Test 1 - Found value at index %0d", index);
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Expected index 3, got %0d", index);
      fail_count++;
    end

    // Test 1b: Value not found
    search_value(arr8, 100, index);
    if (index == -1) begin
      $display("  Value not found correctly (index=%0d)", index);
    end

    // Test 2: Find first positive
    $display("Test 2: Find first positive with disable outer");
    find_first_positive(arr5, value);
    if (value == 5) begin
      $display("PASS: Test 2 - First positive = %0d", value);
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Expected 5, got %0d", value);
      fail_count++;
    end

    // Test 3: Multiple validation exits
    $display("Test 3: Multiple validation with disable");
    process_data(50, status);
    if (status == 1) begin
      $display("PASS: Test 3a - Valid data (status=%0d)", status);
      pass_count++;
    end else begin
      $display("FAIL: Test 3a - Expected status=1, got %0d", status);
      fail_count++;
    end

    process_data(-5, status);
    if (status == -1) begin
      $display("PASS: Test 3b - Negative rejected (status=%0d)", status);
      pass_count++;
    end else begin
      $display("FAIL: Test 3b - Expected status=-1, got %0d", status);
      fail_count++;
    end

    process_data(150, status);
    if (status == -2) begin
      $display("PASS: Test 3c - Too large rejected (status=%0d)", status);
      pass_count++;
    end else begin
      $display("FAIL: Test 3c - Expected status=-2, got %0d", status);
      fail_count++;
    end

    // Test 4: Nested search in matrix
    $display("Test 4: Nested matrix search with disable");
    nested_search(matrix, 99, row, col);
    if (row == 2 && col == 3) begin
      $display("PASS: Test 4 - Found at [%0d][%0d]", row, col);
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Expected [2][3], got [%0d][%0d]", row, col);
      fail_count++;
    end

    // Test 5: Process with cleanup
    $display("Test 5: Process with early exit");
    process_with_cleanup(0, res);
    if (res == -1) begin
      $display("PASS: Test 5a - Zero input exits early (result=%0d)", res);
      pass_count++;
    end else begin
      $display("FAIL: Test 5a - Expected -1, got %0d", res);
      fail_count++;
    end

    process_with_cleanup(60, res);
    if (res == 100) begin
      $display("PASS: Test 5b - Capped at 100 (result=%0d)", res);
      pass_count++;
    end else begin
      $display("FAIL: Test 5b - Expected 100, got %0d", res);
      fail_count++;
    end

    process_with_cleanup(30, res);
    if (res == 70) begin  // 30*2 + 10 = 70
      $display("PASS: Test 5c - Normal processing (result=%0d)", res);
      pass_count++;
    end else begin
      $display("FAIL: Test 5c - Expected 70, got %0d", res);
      fail_count++;
    end

    // Summary
    $display("");
    $display("=== Task Disable Named Blocks Test Summary ===");
    $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
    if (fail_count == 0) begin
      $display("PASS: All tests passed");
    end else begin
      $display("FAIL: Some tests failed");
    end

    $finish;
  end

endmodule
