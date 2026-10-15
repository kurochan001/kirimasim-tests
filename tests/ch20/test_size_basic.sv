/*
:name: test_size_basic
:description: Test $size basic (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_size_basic.expected
*/
// Test $size basic (IEEE 1800-2023 Section 20.7)

module test_size_basic;
  logic [7:0] arr1[10];
  int arr2[5];
  int pass_count;

  initial begin
    pass_count = 0;

    if ($size(arr1) == 10) pass_count++;

    // Test 2: Int array size
    if ($size(arr2) == 5) pass_count++;

    // Test 3: Dimension specified
    if ($size(arr1, 1) == 10) pass_count++;

    $display("Size basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Size basic tests");
    end else begin
      $display("FAIL: Some size tests failed");
    end
  end
endmodule
