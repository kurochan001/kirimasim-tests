/*
:name: test_array_reduction_methods_2
:description: Array manipulation methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_methods_2.expected
*/
// IEEE 1800-2023 Section 7.12 - Array manipulation methods
// Test: min, max, unique, sum, product, and, or, xor

module test_array_reduction_methods_2;
  int nums[] = '{5, 2, 8, 2, 1, 8, 3};
  bit [3:0] bits[] = '{4'b1010, 4'b1100, 4'b0011};
  int min_queue[$], max_queue[$], unique_queue[$];  // IEEE 1800-2023: min/max/unique return queue
  int sum_val, product_val;
  bit [3:0] and_val, or_val, xor_val;

  initial begin
    // IEEE 1800-2023 §7.12.1: min() returns queue of minimum values
    min_queue = nums.min();
    if (min_queue.size() != 1) $fatal(1, "FAIL: min() queue size");
    if (min_queue[0] != 1) $fatal(1, "FAIL: min() value");

    // IEEE 1800-2023 §7.12.1: max() returns queue with single maximum element
    max_queue = nums.max();
    if (max_queue.size() != 1) $fatal(1, "FAIL: max() queue size (IEEE §7.12.1: size 1)");
    if (max_queue[0] != 8) $fatal(1, "FAIL: max() value");

    // IEEE 1800-2023 §7.12.1: unique() returns queue of unique elements
    unique_queue = nums.unique();
    if (unique_queue.size() != 5) $fatal(1, "FAIL: unique() size");
    // The order of the unique() result is unrelated to the array order (7.12.1)
    unique_queue.sort();
    if (unique_queue[0] != 1) $fatal(1, "FAIL: unique()[0]");
    if (unique_queue[1] != 2) $fatal(1, "FAIL: unique()[1]");
    if (unique_queue[2] != 3) $fatal(1, "FAIL: unique()[2]");
    if (unique_queue[3] != 5) $fatal(1, "FAIL: unique()[3]");
    if (unique_queue[4] != 8) $fatal(1, "FAIL: unique()[4]");

    // Restore nums for sum/product tests
    nums = '{5, 2, 8, 2, 1, 8, 3};

    // Test sum() - returns sum of all elements
    sum_val = nums.sum();
    if (sum_val != 29) $fatal(1, "FAIL: sum() value (5+2+8+2+1+8+3=29)");

    // Test product() - returns product of all elements
    product_val = nums.product();
    if (product_val != 3840) $fatal(1, "FAIL: product() value (5*2*8*2*1*8*3=3840)");

    // Test bitwise reduction methods
    // and() - bitwise AND of all elements
    and_val = bits.and();
    if (and_val != 4'b0000) $fatal(1, "FAIL: and() value (1010 & 1100 & 0011 = 0000)");

    // or() - bitwise OR of all elements
    or_val = bits.or();
    if (or_val != 4'b1111) $fatal(1, "FAIL: or() value (1010 | 1100 | 0011 = 1111)");

    // xor() - bitwise XOR of all elements
    xor_val = bits.xor();
    if (xor_val != 4'b0101) $fatal(1, "FAIL: xor() value (1010 ^ 1100 ^ 0011 = 0101)");

    $display("PASS: Array reduction methods");
    $finish(0);
  end
endmodule
