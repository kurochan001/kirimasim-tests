/*
:name: test_array_min
:description: Test for array min method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_min.expected
*/
// Test for array min method
module test_array_min;
  int arr1[] = '{5, 3, 8, 1, 9};
  int arr2[] = '{-5, -10, -2};
  int arr3[] = '{42};
  int arr4[] = '{7, 7, 7, 7};
  int result[];
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: Min of {5, 3, 8, 1, 9} = 1
    result = arr1.min();
    if (result.size() > 0 && result[0] == 1) begin
      $display("PASS: arr1.min() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr1.min() failed, expected 1");
      fail_count++;
    end

    // Test 2: Min of negative numbers
    result = arr2.min();
    if (result.size() > 0 && result[0] == -10) begin
      $display("PASS: arr2.min() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr2.min() failed, expected -10");
      fail_count++;
    end

    // Test 3: Min of single element
    result = arr3.min();
    if (result.size() > 0 && result[0] == 42) begin
      $display("PASS: arr3.min() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr3.min() failed, expected 42");
      fail_count++;
    end

    // Test 4: Min of identical elements
    result = arr4.min();
    if (result.size() > 0 && result[0] == 7) begin
      $display("PASS: arr4.min() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr4.min() failed, expected 7");
      fail_count++;
    end

    // Test 5: Verify min returns queue with one element
    result = arr1.min();
    if (result.size() == 1) begin
      $display("PASS: min() returns queue with 1 element");
      pass_count++;
    end else begin
      $display("FAIL: min() returned queue with %0d elements", result.size());
      fail_count++;
    end

    // Summary
    $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All tests passed");
    else
      $display("FAIL: Some tests failed");
    $finish;
  end
endmodule
