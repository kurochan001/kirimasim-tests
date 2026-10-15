/*
:name: test_array_method_sum
:description: Test for array method sum/product (IEEE 1800-2023 §7.12.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method_sum.expected
*/
// Test for array method sum/product (IEEE 1800-2023 §7.12.3)

module test_array_method_sum;
  int arr1[5];
  int arr2[4];
  logic [7:0] larr[3];
  int sum_val, prod_val;
  int passed;

  initial begin
    passed = 0;

    // Initialize arrays
    arr1 = '{1, 2, 3, 4, 5};
    arr2 = '{2, 3, 4, 5};
    larr = '{8'h01, 8'h02, 8'h03};

    // Test 1: Simple sum
    $display("Test 1: Simple sum");
    sum_val = arr1.sum();
    if (sum_val == 15) begin
      $display("  PASS: sum of {1,2,3,4,5} = %0d", sum_val);
      passed++;
    end else begin
      $display("  FAIL: expected 15, got %0d", sum_val);
    end

    // Test 2: Simple product
    $display("Test 2: Simple product");
    prod_val = arr2.product();
    if (prod_val == 120) begin
      $display("  PASS: product of {2,3,4,5} = %0d", prod_val);
      passed++;
    end else begin
      $display("  FAIL: expected 120, got %0d", prod_val);
    end

    // Test 3: Sum with condition (with clause)
    $display("Test 3: Sum with condition");
    sum_val = arr1.sum() with (item > 2 ? item : 0);
    if (sum_val == 12) begin
      $display("  sum of items > 2 = %0d", sum_val);
      passed++;
    end else begin
      $display("  FAIL: expected 12, got %0d", sum_val);
    end

    // Test 4: Product with small array
    $display("Test 4: Product with logic array");
    sum_val = larr.sum();
    if (sum_val == 6) begin
      $display("  sum of logic array = %0d", sum_val);
      passed++;
    end else begin
      $display("  FAIL: expected 6, got %0d", sum_val);
    end

    // Test 5: Empty like sum
    $display("Test 5: Sum with filtering");
    sum_val = arr1.sum() with (item % 2 == 0 ? item : 0);
    $display("  sum of even items = %0d", sum_val);  // 2 + 4 = 6
    if (sum_val == 6) begin
      $display("  PASS");
      passed++;
    end else begin
      $display("  FAIL: expected 6, got %0d", sum_val);
    end

    // Test 6: xor reduction
    $display("Test 6: XOR reduction");
    sum_val = arr1.xor();
    if (sum_val == 1) begin
      $display("  xor of array = %0d", sum_val);
      passed++;
    end else begin
      $display("  FAIL: expected 1, got %0d", sum_val);
    end

    // Test 7: and/or reduction
    $display("Test 7: AND/OR reduction");
    sum_val = arr1.and();
    $display("  and of array = %0d", sum_val);
    prod_val = arr1.or();
    $display("  or of array = %0d", prod_val);
    if (sum_val == 0 && prod_val == 7) begin
      $display("  PASS: and/or");
      passed++;
    end else begin
      $display("  FAIL: and=%0d or=%0d", sum_val, prod_val);
    end

    if (passed == 7) begin
      $display("TEST PASSED: %0d/7 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/7 tests passed", passed);
    end
    $finish;
  end
endmodule
