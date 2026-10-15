/*
:name: test_array_ordering
:description: Test array ordering methods (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_ordering.expected
*/
// Test array ordering methods (IEEE 1800-2023 Section 7.12.2)

module test_array_ordering;
  int arr[];
  int pass_count;

  initial begin
    pass_count = 0;
    arr = '{3, 1, 4, 1, 5, 9, 2, 6};

    // Test 1: sort
    arr.sort();
    if (arr[0] == 1 && arr[7] == 9) pass_count++;

    // Test 2: rsort
    arr.rsort();
    if (arr[0] == 9 && arr[7] == 1) pass_count++;

    // Test 3: reverse
    arr = '{1, 2, 3, 4};
    arr.reverse();
    if (arr[0] == 4 && arr[3] == 1) pass_count++;

    $display("Array ordering tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Array ordering tests");
    end else begin
      $display("FAIL: Some array ordering tests failed");
    end
  end
endmodule
