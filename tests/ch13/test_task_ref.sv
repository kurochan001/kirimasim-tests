/*
:name: test_task_ref
:description: Ref arguments in tasks test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_ref.expected
*/
// Ref arguments in tasks test
module test_task_ref;

  // Task with ref argument for modification
  task automatic modify_ref(ref int value);
    value = value * 2;
  endtask

  // Task with ref and const ref
  task automatic copy_with_ref(ref int dest, const ref int src);
    dest = src;
  endtask

  // Task with ref array argument
  task automatic sort_three(ref int arr[3]);
    int temp;
    // Simple bubble sort
    for (int i = 0; i < 2; i++) begin
      for (int j = 0; j < 2 - i; j++) begin
        if (arr[j] > arr[j+1]) begin
          temp = arr[j];
          arr[j] = arr[j+1];
          arr[j+1] = temp;
        end
      end
    end
  endtask

  // Task with ref that swaps values
  task automatic swap_values(ref int a, ref int b);
    int temp;
    temp = a;
    a = b;
    b = temp;
  endtask

  // Task with ref for accumulation
  task automatic add_to_accumulator(ref int accumulator, input int value);
    accumulator = accumulator + value;
  endtask

  // Task with multiple ref modifications
  task automatic increment_all(ref int a, ref int b, ref int c);
    a++;
    b++;
    c++;
  endtask

  initial begin
    int val1, val2, val3;
    int arr[3];
    int acc;
    int pass_count;

    pass_count = 0;

    // Test 1: Simple ref modification
    val1 = 25;
    modify_ref(val1);
    if (val1 == 50) begin
      $display("Test 1 PASS: modify_ref(25) -> val1 = %0d", val1);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: val1 = %0d, expected 50", val1);
    end

    // Test 2: Copy with ref and const ref
    val1 = 0;
    val2 = 42;
    copy_with_ref(val1, val2);
    if (val1 == 42 && val2 == 42) begin
      $display("Test 2 PASS: copy_with_ref() dest=%0d, src=%0d", val1, val2);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: dest=%0d, src=%0d (expected both 42)", val1, val2);
    end

    // Test 3: Ref array sorting
    arr = '{30, 10, 20};
    sort_three(arr);
    if (arr[0] == 10 && arr[1] == 20 && arr[2] == 30) begin
      $display("Test 3 PASS: sort_three() -> [%0d, %0d, %0d]", arr[0], arr[1], arr[2]);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: arr = [%0d, %0d, %0d]", arr[0], arr[1], arr[2]);
    end

    // Test 4: Swap with ref
    val1 = 100;
    val2 = 200;
    swap_values(val1, val2);
    if (val1 == 200 && val2 == 100) begin
      $display("Test 4 PASS: swap_values() -> val1=%0d, val2=%0d", val1, val2);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: val1=%0d, val2=%0d (expected 200, 100)", val1, val2);
    end

    // Test 5: Multiple ref modifications
    val1 = 10;
    val2 = 20;
    val3 = 30;
    increment_all(val1, val2, val3);
    if (val1 == 11 && val2 == 21 && val3 == 31) begin
      $display("Test 5 PASS: increment_all() -> %0d, %0d, %0d", val1, val2, val3);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: values = %0d, %0d, %0d (expected 11, 21, 31)", val1, val2, val3);
    end

    if (pass_count == 5)
      $display("PASS: All task ref argument tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
