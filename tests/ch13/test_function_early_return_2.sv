/*
:name: test_function_early_return_2
:description: Test for function early return statements (IEEE 1800-2023 §13)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 12.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_early_return_2.expected
*/
// Test for function early return statements (IEEE 1800-2023 §13)

module test_function_early_return_2;
  int passed;

  // Function with early return in loop
  function int find_first_even(int arr[5]);
    for (int i = 0; i < 5; i++) begin
      if (arr[i] % 2 == 0)
        return arr[i];
    end
    return -1;
  endfunction

  // Function with nested conditionals
  function int classify(int x);
    if (x < 0) begin
      return -1;  // Negative
    end else if (x == 0) begin
      return 0;   // Zero
    end else if (x < 100) begin
      return 1;   // Small positive
    end else begin
      return 2;   // Large positive
    end
  endfunction

  // Function with return in while loop
  function int count_until_zero(int arr[8]);
    int count;
    int idx;
    count = 0;
    idx = 0;
    while (idx < 8) begin
      if (arr[idx] == 0)
        return count;
      count++;
      idx++;
    end
    return count;
  endfunction

  initial begin
    passed = 0;

    // Test 1: Find first even
    $display("Test 1: Find first even");
    begin
      int arr[5];
      arr = '{1, 3, 4, 5, 6};
      if (find_first_even(arr) == 4) begin
        $display("  PASS: first even = 4");
        passed++;
      end else begin
        $display("  FAIL: got %0d", find_first_even(arr));
      end
    end

    // Test 2: No even found
    $display("Test 2: No even found");
    begin
      int arr[5];
      arr = '{1, 3, 5, 7, 9};
      if (find_first_even(arr) == -1) begin
        $display("  PASS: no even returns -1");
        passed++;
      end else begin
        $display("  FAIL: got %0d", find_first_even(arr));
      end
    end

    // Test 3: Classify negative
    $display("Test 3: Classify negative");
    if (classify(-50) == -1) begin
      $display("  PASS: classify(-50) = -1");
      passed++;
    end else begin
      $display("  FAIL: got %0d", classify(-50));
    end

    // Test 4: Classify zero
    $display("Test 4: Classify zero");
    if (classify(0) == 0) begin
      $display("  PASS: classify(0) = 0");
      passed++;
    end else begin
      $display("  FAIL: got %0d", classify(0));
    end

    // Test 5: Classify positive
    $display("Test 5: Classify positive");
    if (classify(50) == 1 && classify(200) == 2) begin
      $display("  PASS: classify(50)=1, classify(200)=2");
      passed++;
    end else begin
      $display("  FAIL");
    end

    // Test 6: Count until zero
    $display("Test 6: Count until zero");
    begin
      int arr[8];
      arr = '{1, 2, 3, 0, 5, 6, 7, 8};
      if (count_until_zero(arr) == 3) begin
        $display("  PASS: count_until_zero = 3");
        passed++;
      end else begin
        $display("  FAIL: got %0d", count_until_zero(arr));
      end
    end

    if (passed == 6) begin
      $display("TEST PASSED: %0d/6 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/6 tests passed", passed);
    end
    $finish;
  end
endmodule
