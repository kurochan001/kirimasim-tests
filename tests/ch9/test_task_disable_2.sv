/*
:name: test_task_disable_2
:description: Disable in tasks test
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2 13.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_disable_2.expected
*/
// Disable in tasks test
module test_task_disable_2;

  int result;
  int events[8];
  int event_count;

  // Task with disable statement
  task find_first(input int arr[8], input int target, output int found_idx);
    found_idx = -1;
    for (int i = 0; i < 8; i++) begin
      if (arr[i] == target) begin
        found_idx = i;
        return;  // Early return acts like disable
      end
    end
  endtask

  // Named task block with disable
  task search_with_disable(input int arr[8], input int target, output int found);
    found = 0;
    begin : search_block
      for (int i = 0; i < 8; i++) begin
        if (arr[i] == target) begin
          found = 1;
          disable search_block;
        end
      end
    end
  endtask

  // Task with nested disable
  task nested_search(input int matrix[2][4], input int target,
                     output int row, output int col);
    row = -1;
    col = -1;
    begin : outer_loop
      for (int r = 0; r < 2; r++) begin
        for (int c = 0; c < 4; c++) begin
          if (matrix[r][c] == target) begin
            row = r;
            col = c;
            disable outer_loop;
          end
        end
      end
    end
  endtask

  // Task with conditional disable
  task conditional_process(input int value, output int processed);
    processed = 0;
    begin : process_block
      if (value < 0) begin
        processed = -1;
        disable process_block;
      end
      if (value > 100) begin
        processed = 100;
        disable process_block;
      end
      processed = value * 2;
    end
  endtask

  // Task with return statement (implicit disable)
  task early_return_task(input int n, output int sum);
    sum = 0;
    for (int i = 1; i <= n; i++) begin
      sum = sum + i;
      if (sum > 50) return;  // Early exit when sum exceeds 50
    end
  endtask

  initial begin
    int test_arr[8];
    int matrix[2][4];
    int idx, found, row, col, processed, sum;
    int pass_count;

    pass_count = 0;

    // Test 1: Early return in task
    test_arr = '{5, 10, 15, 20, 25, 30, 35, 40};
    find_first(test_arr, 25, idx);
    if (idx == 4) begin
      $display("Test 1 PASS: find_first() found target at index %0d", idx);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: idx = %0d, expected 4", idx);
    end

    // Test 2: Named block disable
    search_with_disable(test_arr, 15, found);
    if (found == 1) begin
      $display("Test 2 PASS: search_with_disable() found = %0d", found);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: found = %0d, expected 1", found);
    end

    // Test 3: Nested disable
    matrix[0] = '{1, 2, 3, 4};
    matrix[1] = '{5, 6, 7, 8};
    nested_search(matrix, 6, row, col);
    if (row == 1 && col == 1) begin
      $display("Test 3 PASS: nested_search() found at [%0d][%0d]", row, col);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: row=%0d, col=%0d (expected 1, 1)", row, col);
    end

    // Test 4: Conditional disable
    conditional_process(50, processed);
    if (processed == 100) begin
      $display("Test 4 PASS: conditional_process(50) = %0d", processed);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: processed = %0d, expected 100", processed);
    end

    // Test 5: Early return when condition met
    early_return_task(20, sum);
    // Sum would be 1+2+3+4+5+6+7+8+9+10 = 55, exits when >50 at 10
    if (sum == 55) begin
      $display("Test 5 PASS: early_return_task(20) sum = %0d (stopped at 55)", sum);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: sum = %0d", sum);
    end

    if (pass_count == 5)
      $display("PASS: All task disable tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
