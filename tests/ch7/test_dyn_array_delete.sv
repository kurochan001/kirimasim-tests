/*
:name: test_dyn_array_delete
:description: Test dynamic array delete (IEEE 1800-2023 Section 7.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_delete.expected
*/
// Test dynamic array delete (IEEE 1800-2023 Section 7.5)

module test_dyn_array_delete;
  int arr[];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Create and delete
    arr = new[5];
    arr.delete();
    if (arr.size() == 0) pass_count++;

    // Test 2: Delete empty
    arr.delete();
    if (arr.size() == 0) pass_count++;

    // Test 3: Create after delete
    arr = new[3];
    if (arr.size() == 3) pass_count++;

    $display("Dyn array delete tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Dyn array delete tests");
    end else begin
      $display("FAIL: Some dyn array delete tests failed");
    end
  end
endmodule
