/*
:name: test_array_product
:description: Test for array product method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_product.expected
*/
// Test for array product method
module test_array_product;
  int arr1[] = '{1, 2, 3, 4, 5};
  int arr2[] = '{2, 3, 4};
  int arr3[] = '{-2, 3, -4};
  int arr4[];
  int arr5[] = '{7};
  int result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: Product of 1*2*3*4*5 = 120
    result = arr1.product();
    if (result == 120) begin
      $display("PASS: arr1.product() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: arr1.product() = %0d, expected 120", result);
      fail_count++;
    end

    // Test 2: Product of 2*3*4 = 24
    result = arr2.product();
    if (result == 24) begin
      $display("PASS: arr2.product() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: arr2.product() = %0d, expected 24", result);
      fail_count++;
    end

    // Test 3: Product with negatives: -2*3*-4 = 24
    result = arr3.product();
    if (result == 24) begin
      $display("PASS: arr3.product() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: arr3.product() = %0d, expected 24", result);
      fail_count++;
    end

    // The standard does not give the product of an empty array (7.12.3), so it is not checked

    // Test 5: Product of single element = element
    result = arr5.product();
    if (result == 7) begin
      $display("PASS: single element product = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: single element product = %0d, expected 7", result);
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
