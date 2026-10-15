/*
:name: test_array_max
:description: Test for array max method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_max.expected
*/
// Test for array max method
module test_array_max;
  int arr1[] = '{5, 3, 8, 1, 9};
  int arr2[] = '{-5, -10, -2};
  int arr3[] = '{42};
  int arr4[] = '{7, 7, 7, 7};
  int result[];
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: Max of {5, 3, 8, 1, 9} = 9
    result = arr1.max();
    if (result.size() > 0 && result[0] == 9) begin
      $display("PASS: arr1.max() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr1.max() failed, expected 9");
      fail_count++;
    end

    // Test 2: Max of negative numbers
    result = arr2.max();
    if (result.size() > 0 && result[0] == -2) begin
      $display("PASS: arr2.max() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr2.max() failed, expected -2");
      fail_count++;
    end

    // Test 3: Max of single element
    result = arr3.max();
    if (result.size() > 0 && result[0] == 42) begin
      $display("PASS: arr3.max() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr3.max() failed, expected 42");
      fail_count++;
    end

    // Test 4: Max of identical elements
    result = arr4.max();
    if (result.size() > 0 && result[0] == 7) begin
      $display("PASS: arr4.max() = %0d", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr4.max() failed, expected 7");
      fail_count++;
    end

    // Test 5: Verify max returns queue with one element
    result = arr1.max();
    if (result.size() == 1) begin
      $display("PASS: max() returns queue with 1 element");
      pass_count++;
    end else begin
      $display("FAIL: max() returned queue with %0d elements", result.size());
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
