/*
:name: test_function_ref
:description: Tests ref, const ref, and output arguments in functions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 13.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_ref.expected
*/
// Tests ref, const ref, and output arguments in functions

module test_function_ref;

  // Test 1: Basic ref argument
  function automatic void increment_ref(ref int value);
    value = value + 1;
  endfunction

  // Test 2: Multiple ref arguments
  function automatic void swap_ref(ref int a, ref int b);
    int temp;
    temp = a;
    a = b;
    b = temp;
  endfunction

  // Test 3: const ref argument (read-only reference)
  function automatic int sum_array_const_ref(const ref int arr[4]);
    int total = 0;
    for (int i = 0; i < 4; i++) begin
      total += arr[i];
    end
    return total;
  endfunction

  // Test 4: Output argument
  function automatic void get_min_max(input int arr[4], output int min_val, output int max_val);
    min_val = arr[0];
    max_val = arr[0];
    for (int i = 1; i < 4; i++) begin
      if (arr[i] < min_val) min_val = arr[i];
      if (arr[i] > max_val) max_val = arr[i];
    end
  endfunction

  // Test 5: Inout argument
  function automatic void scale_inout(inout int value, input int factor);
    value = value * factor;
  endfunction

  // Test 6: Mixed argument types
  function automatic int process_mixed(
    input int in_val,
    ref int ref_val,
    output int out_val,
    inout int inout_val
  );
    ref_val = ref_val + in_val;
    out_val = in_val * 2;
    inout_val = inout_val + 10;
    return in_val + ref_val + inout_val;
  endfunction

  initial begin
    static int pass_count = 0;
    static int fail_count = 0;

    int x, y, result;
    static int arr[4] = '{10, 20, 5, 15};
    int min_val, max_val;
    int ref_v, out_v, inout_v;

    // Test 1: Basic ref argument
    $display("Test 1: Basic ref argument");
    x = 10;
    increment_ref(x);
    if (x == 11) begin
      $display("PASS: Test 1 - ref argument incremented value to %0d", x);
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Expected 11, got %0d", x);
      fail_count++;
    end

    // Test 2: Multiple ref arguments (swap)
    $display("Test 2: Multiple ref arguments (swap)");
    x = 100;
    y = 200;
    swap_ref(x, y);
    if (x == 200 && y == 100) begin
      $display("PASS: Test 2 - Values swapped (x=%0d, y=%0d)", x, y);
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Swap failed (x=%0d, y=%0d)", x, y);
      fail_count++;
    end

    // Test 3: const ref argument
    $display("Test 3: const ref argument");
    result = sum_array_const_ref(arr);
    if (result == 50) begin
      $display("PASS: Test 3 - Array sum = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Expected 50, got %0d", result);
      fail_count++;
    end

    // Test 4: Output arguments
    $display("Test 4: Output arguments");
    get_min_max(arr, min_val, max_val);
    if (min_val == 5 && max_val == 20) begin
      $display("PASS: Test 4 - min=%0d, max=%0d", min_val, max_val);
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Expected min=5, max=20; got min=%0d, max=%0d", min_val, max_val);
      fail_count++;
    end

    // Test 5: Inout argument
    $display("Test 5: Inout argument");
    x = 5;
    scale_inout(x, 3);
    if (x == 15) begin
      $display("PASS: Test 5 - Inout value scaled to %0d", x);
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Expected 15, got %0d", x);
      fail_count++;
    end

    // Test 6: Mixed argument types
    $display("Test 6: Mixed argument types");
    ref_v = 10;
    inout_v = 5;
    result = process_mixed(3, ref_v, out_v, inout_v);
    // ref_v = 10 + 3 = 13
    // out_v = 3 * 2 = 6
    // inout_v = 5 + 10 = 15
    // return = 3 + 13 + 15 = 31
    if (ref_v == 13 && out_v == 6 && inout_v == 15 && result == 31) begin
      $display("PASS: Test 6 - ref=%0d, out=%0d, inout=%0d, result=%0d",
               ref_v, out_v, inout_v, result);
      pass_count++;
    end else begin
      $display("FAIL: Test 6 - Unexpected values (ref=%0d, out=%0d, inout=%0d, result=%0d)",
               ref_v, out_v, inout_v, result);
      fail_count++;
    end

    // Summary
    $display("");
    $display("=== Function Reference Arguments Test Summary ===");
    $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
    if (fail_count == 0) begin
      $display("PASS: All tests passed");
    end else begin
      $display("FAIL: Some tests failed");
    end

    $finish;
  end

endmodule
