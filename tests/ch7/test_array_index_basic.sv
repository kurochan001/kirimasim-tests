/*
:name: test_array_index_basic
:description: Test array indexing (IEEE 1800-2023 Section 7.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_index_basic.expected
*/
// Test array indexing (IEEE 1800-2023 Section 7.4)

module test_array_index_basic;
  int arr[4];
  int pass_count;

  initial begin
    pass_count = 0;
    arr[0] = 10;
    arr[1] = 20;
    arr[2] = 30;
    arr[3] = 40;

    // Test 1: Index read
    if (arr[0] == 10) pass_count++;

    // Test 2: Index write
    arr[2] = 300;
    if (arr[2] == 300) pass_count++;

    // Test 3: Variable index
    begin
      int i;
      i = 1;
      if (arr[i] == 20) pass_count++;
    end

    $display("Array index tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Array index tests");
    end else begin
      $display("FAIL: Some array index tests failed");
    end
  end
endmodule
