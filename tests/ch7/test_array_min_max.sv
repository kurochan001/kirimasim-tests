/*
:name: test_array_min_max
:description: Test array min/max methods (IEEE 1800-2023 Section 7.12.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_min_max.expected
*/
// Test array min/max methods (IEEE 1800-2023 Section 7.12.1)

module test_array_min_max;
  int arr[];
  int result[];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: min
    arr = '{5, 2, 8, 1, 9, 3};
    result = arr.min();
    if (result.size() == 1 && result[0] == 1) pass_count++;

    // Test 2: max
    result = arr.max();
    if (result.size() == 1 && result[0] == 9) pass_count++;

    // Test 3: Single element
    arr = '{42};
    result = arr.min();
    if (result[0] == 42) pass_count++;

    $display("Array min/max tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Array min/max tests");
    end else begin
      $display("FAIL: Some array min/max tests failed");
    end
  end
endmodule
