/*
:name: test_array_unique_methods
:description: Array unique methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_unique_methods.expected
*/
// IEEE 1800-2023 Section 7.12.1 - Array unique methods
// Test: unique, unique_index

module test_array_unique_methods;
  int data[] = '{10, 20, 10, 30, 20, 10, 40};
  int unique_vals[$];
  int unique_idx[$];

  initial begin
    // Test unique() - returns queue of unique elements
    unique_vals = data.unique();

    // Should have 4 unique values: 10, 20, 30, 40
    if (unique_vals.size() != 4) begin
      $display("FAIL: unique() size = %0d, expected 4", unique_vals.size());
      $fatal(1, "FAIL: unique() size");
    end

    // The order of the result is unrelated to the array order (7.12.1)
    unique_vals.sort();
    if (unique_vals.size() != 4 || unique_vals[0] != 10 || unique_vals[1] != 20 ||
        unique_vals[2] != 30 || unique_vals[3] != 40) begin
      $fatal(1, "FAIL: unique() values");
    end

    // Test unique_index(): one index for each value. For a duplicated value
    // the index may be that of any of the duplicates (7.12.1).
    unique_idx = data.unique_index();

    if (unique_idx.size() != 4) begin
      $display("FAIL: unique_index() size = %0d, expected 4", unique_idx.size());
      $fatal(1, "FAIL: unique_index() size");
    end

    begin
      int vals[$];
      foreach (unique_idx[i]) vals.push_back(data[unique_idx[i]]);
      vals.sort();
      if (vals.size() != 4 || vals[0] != 10 || vals[1] != 20 || vals[2] != 30 || vals[3] != 40) begin
        $fatal(1, "FAIL: unique_index() does not select one element of each value");
      end
    end

    // Test with empty array
    begin
      int empty[];  // a dynamic array starts empty
      int empty_unique[$];

      empty_unique = empty.unique();
      if (empty_unique.size() != 0) begin
        $fatal(1, "FAIL: unique() on empty array should return empty queue");
      end
    end

    // Test with all same values
    begin
      static int same[] = '{5, 5, 5, 5, 5};
      int same_unique[$];

      same_unique = same.unique();
      if (same_unique.size() != 1) begin
        $fatal(1, "FAIL: unique() on all-same array should return single element");
      end
      if (same_unique[0] != 5) begin
        $fatal(1, "FAIL: unique() value mismatch");
      end
    end

    $display("PASS: Array unique methods");
    $finish(0);
  end
endmodule
