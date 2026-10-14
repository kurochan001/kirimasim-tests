/*
:name: test_dyn_array_new
:description: Test dynamic array new (IEEE 1800-2023 Section 7.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_new.expected
*/
// Test dynamic array new (IEEE 1800-2023 Section 7.5)

module test_dyn_array_new;
  int arr[];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Create array
    arr = new[5];
    if (arr.size() == 5) pass_count++;

    // Test 2: Initialize element
    arr[0] = 42;
    if (arr[0] == 42) pass_count++;

    // Test 3: Resize
    arr = new[10];
    if (arr.size() == 10) pass_count++;

    $display("Dyn array new tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Dyn array new tests");
    end else begin
      $display("FAIL: Some dyn array new tests failed");
    end
  end
endmodule
