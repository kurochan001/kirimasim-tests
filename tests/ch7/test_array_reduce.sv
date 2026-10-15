/*
:name: test_array_reduce
:description: Test array reduction methods (IEEE 1800-2023 Section 7.12.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduce.expected
*/
// Test array reduction methods (IEEE 1800-2023 Section 7.12.3)

module test_array_reduce;
  int arr[] = '{1, 2, 3, 4, 5};
  int result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: sum
    result = arr.sum();
    if (result == 15) pass_count++;

    // Test 2: product
    result = arr.product();
    if (result == 120) pass_count++;

    // Test 3: and/or
    begin
      static logic [3:0] bits[] = '{4'hF, 4'hA, 4'h5};
      if (bits.and() == 4'h0) pass_count++;
    end

    $display("Array reduce tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Array reduce tests");
    end else begin
      $display("FAIL: Some array reduce tests failed");
    end
  end
endmodule
