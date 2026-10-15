/*
:name: test_array_assign_2
:description: Test array assignments (IEEE 1800-2023 Section 7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 7.5 10.9.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_assign_2.expected
*/
// Test array assignments (IEEE 1800-2023 Section 7)

module test_array_assign_2;
  int arr1 [4];
  int arr2 [4];
  int dyn [];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Literal assignment
    arr1 = '{10, 20, 30, 40};
    if (arr1[0] == 10 && arr1[3] == 40) pass_count++;

    // Test 2: Array copy
    arr2 = arr1;
    if (arr2[1] == 20) pass_count++;

    // Test 3: Independence after copy
    arr1[0] = 99;
    if (arr2[0] == 10) pass_count++;

    // Test 4: Dynamic array literal
    dyn = '{1, 2, 3, 4, 5};
    if (dyn.size() == 5) pass_count++;

    // Test 5: Element update
    dyn[2] = 100;
    if (dyn[2] == 100) pass_count++;

    // Test 6: Default value
    arr1 = '{default: 0};
    if (arr1[0] == 0 && arr1[3] == 0) pass_count++;

    $display("Array assign tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: Array assign tests");
    end else begin
      $display("FAIL: Some array assign tests failed");
    end
  end
endmodule
