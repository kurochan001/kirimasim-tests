/*
:name: test_array_unique_2
:description: Test for array unique method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_unique_2.expected
*/
// Test for array unique method
module test_array_unique_2;
  int arr1[] = '{1, 2, 3, 2, 1, 4, 3};
  int arr2[] = '{5, 5, 5, 5};
  int arr3[] = '{10, 20, 30};
  int arr4[] = '{7};
  int result[];
  int pass_count = 0;
  int fail_count = 0;
  int i;

  initial begin
    // Test 1: Unique of array with duplicates
    result = arr1.unique();
    if (result.size() == 4) begin
      $display("PASS: arr1.unique() has %0d elements", result.size());
      pass_count++;
    end else begin
      $display("FAIL: arr1.unique() has %0d elements, expected 4", result.size());
      fail_count++;
    end

    // Test 2: Unique of all same elements
    result = arr2.unique();
    if (result.size() == 1 && result[0] == 5) begin
      $display("PASS: arr2.unique() = {%0d}", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr2.unique() failed, expected {5}");
      fail_count++;
    end

    // Test 3: Unique of already unique array
    result = arr3.unique();
    if (result.size() == 3) begin
      $display("PASS: arr3.unique() has %0d elements (all unique)", result.size());
      pass_count++;
    end else begin
      $display("FAIL: arr3.unique() has %0d elements, expected 3", result.size());
      fail_count++;
    end

    // Test 4: Unique of single element
    result = arr4.unique();
    if (result.size() == 1 && result[0] == 7) begin
      $display("PASS: single element unique = {%0d}", result[0]);
      pass_count++;
    end else begin
      $display("FAIL: single element unique failed");
      fail_count++;
    end

    // Test 5: Check all unique elements are present
    result = arr1.unique();
    // Check if 1, 2, 3, 4 are all present
    begin
      static int found_1 = 0, found_2 = 0, found_3 = 0, found_4 = 0;
      for (i = 0; i < result.size(); i++) begin
        if (result[i] == 1) found_1 = 1;
        if (result[i] == 2) found_2 = 1;
        if (result[i] == 3) found_3 = 1;
        if (result[i] == 4) found_4 = 1;
      end
      if (found_1 && found_2 && found_3 && found_4) begin
        $display("PASS: unique contains all distinct values");
        pass_count++;
      end else begin
        $display("FAIL: unique missing some distinct values");
        fail_count++;
      end
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
