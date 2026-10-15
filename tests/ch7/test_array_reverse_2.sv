/*
:name: test_array_reverse_2
:description: Test for array reverse method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reverse_2.expected
*/
// Test for array reverse method
module test_array_reverse_2;
  int arr1[] = '{1, 2, 3, 4, 5};
  int arr2[] = '{10, 20};
  int arr3[] = '{7};
  int arr4[] = '{1, 2, 3};
  int arr5[] = '{100, 200, 300, 400};
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: Reverse {1, 2, 3, 4, 5} -> {5, 4, 3, 2, 1}
    arr1.reverse();
    if (arr1[0] == 5 && arr1[1] == 4 && arr1[2] == 3 && arr1[3] == 2 && arr1[4] == 1) begin
      $display("PASS: arr1.reverse() = {%0d, %0d, %0d, %0d, %0d}", arr1[0], arr1[1], arr1[2], arr1[3], arr1[4]);
      pass_count++;
    end else begin
      $display("FAIL: arr1.reverse() incorrect");
      fail_count++;
    end

    // Test 2: Reverse {10, 20} -> {20, 10}
    arr2.reverse();
    if (arr2[0] == 20 && arr2[1] == 10) begin
      $display("PASS: arr2.reverse() = {%0d, %0d}", arr2[0], arr2[1]);
      pass_count++;
    end else begin
      $display("FAIL: arr2.reverse() incorrect");
      fail_count++;
    end

    // Test 3: Reverse single element {7} -> {7}
    arr3.reverse();
    if (arr3[0] == 7) begin
      $display("PASS: arr3.reverse() = {%0d}", arr3[0]);
      pass_count++;
    end else begin
      $display("FAIL: arr3.reverse() incorrect");
      fail_count++;
    end

    // Test 4: Double reverse restores original
    arr4.reverse();  // {3, 2, 1}
    arr4.reverse();  // {1, 2, 3}
    if (arr4[0] == 1 && arr4[1] == 2 && arr4[2] == 3) begin
      $display("PASS: double reverse restores original");
      pass_count++;
    end else begin
      $display("FAIL: double reverse failed");
      fail_count++;
    end

    // Test 5: Reverse 4 elements
    arr5.reverse();
    if (arr5[0] == 400 && arr5[1] == 300 && arr5[2] == 200 && arr5[3] == 100) begin
      $display("PASS: arr5.reverse() = {%0d, %0d, %0d, %0d}", arr5[0], arr5[1], arr5[2], arr5[3]);
      pass_count++;
    end else begin
      $display("FAIL: arr5.reverse() incorrect");
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
