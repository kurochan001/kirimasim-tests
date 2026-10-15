/*
:name: test_array_sum
:description: Test for array sum method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_sum.expected
*/
// Test for array sum method
module test_array_sum;
  int arr1[] = '{1, 2, 3, 4, 5};
  int arr2[] = '{10, 20, 30};
  int arr3[] = '{-5, 10, -3, 8};
  int arr4[];
  int arr5[] = '{100};
  int result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: Sum of 1+2+3+4+5 = 15
    result = arr1.sum();
    if (result == 15) begin
      $display("PASS: arr1.sum() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: arr1.sum() = %0d, expected 15", result);
      fail_count++;
    end

    // Test 2: Sum of 10+20+30 = 60
    result = arr2.sum();
    if (result == 60) begin
      $display("PASS: arr2.sum() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: arr2.sum() = %0d, expected 60", result);
      fail_count++;
    end

    // Test 3: Sum with negative numbers: -5+10-3+8 = 10
    result = arr3.sum();
    if (result == 10) begin
      $display("PASS: arr3.sum() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: arr3.sum() = %0d, expected 10", result);
      fail_count++;
    end

    // The standard does not give the sum of an empty array (7.12.3), so it is not checked

    // Test 5: Sum of single element = element
    result = arr5.sum();
    if (result == 100) begin
      $display("PASS: single element sum = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: single element sum = %0d, expected 100", result);
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
