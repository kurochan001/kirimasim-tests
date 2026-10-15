/*
:name: test_array_shuffle_2
:description: Test for array shuffle method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_shuffle_2.expected
*/
// Test for array shuffle method
module test_array_shuffle_2;
  int arr1[] = '{1, 2, 3, 4, 5};
  int arr2[] = '{10};
  int arr3[] = '{100, 200, 300, 400, 500, 600, 700, 800};
  int original_sum, shuffled_sum;
  int original_product, shuffled_product;
  int pass_count = 0;
  int fail_count = 0;
  int i;

  initial begin
    // Test 1: Shuffle preserves elements (sum should be same)
    original_sum = arr1.sum();
    arr1.shuffle();
    shuffled_sum = arr1.sum();
    if (original_sum == shuffled_sum) begin
      $display("PASS: shuffle preserves sum (%0d == %0d)", original_sum, shuffled_sum);
      pass_count++;
    end else begin
      $display("FAIL: shuffle changed sum (%0d != %0d)", original_sum, shuffled_sum);
      fail_count++;
    end

    // Test 2: Shuffle preserves size
    if (arr1.size() == 5) begin
      $display("PASS: shuffle preserves size (5)");
      pass_count++;
    end else begin
      $display("FAIL: shuffle changed size to %0d", arr1.size());
      fail_count++;
    end

    // Test 3: Single element shuffle
    arr2.shuffle();
    if (arr2.size() == 1 && arr2[0] == 10) begin
      $display("PASS: single element shuffle = {%0d}", arr2[0]);
      pass_count++;
    end else begin
      $display("FAIL: single element shuffle failed");
      fail_count++;
    end

    // Test 4: Shuffle preserves product (for larger array)
    original_product = arr3.product();
    arr3.shuffle();
    shuffled_product = arr3.product();
    if (original_product == shuffled_product) begin
      $display("PASS: shuffle preserves product");
      pass_count++;
    end else begin
      $display("FAIL: shuffle changed product");
      fail_count++;
    end

    // Test 5: Verify all original elements exist after shuffle
    begin
      int found[8];
      int all_found;
      arr3 = '{100, 200, 300, 400, 500, 600, 700, 800};
      arr3.shuffle();
      for (i = 0; i < 8; i++) found[i] = 0;
      for (i = 0; i < arr3.size(); i++) begin
        case (arr3[i])
          100: found[0] = 1;
          200: found[1] = 1;
          300: found[2] = 1;
          400: found[3] = 1;
          500: found[4] = 1;
          600: found[5] = 1;
          700: found[6] = 1;
          800: found[7] = 1;
        endcase
      end
      all_found = 1;
      for (i = 0; i < 8; i++) begin
        if (!found[i]) all_found = 0;
      end
      if (all_found) begin
        $display("PASS: shuffle preserves all elements");
        pass_count++;
      end else begin
        $display("FAIL: shuffle lost some elements");
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
