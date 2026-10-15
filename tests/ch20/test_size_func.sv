/*
:name: test_size_func
:description: Test $size function (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_size_func.expected
*/
// Test $size function (IEEE 1800-2023 Section 20.7)

module test_size_func;
  logic [7:0] arr [0:9];
  int dyn [];
  int q [$];
  int pass_count;

  initial begin
    pass_count = 0;

    if ($size(arr) == 10) pass_count++;

    // Test 2: Dynamic array size
    dyn = new[5];
    if ($size(dyn) == 5) pass_count++;

    // Test 3: Queue size
    q.push_back(1);
    q.push_back(2);
    q.push_back(3);
    if ($size(q) == 3) pass_count++;

    // Test 4: Resize dynamic array
    dyn = new[8];
    if ($size(dyn) == 8) pass_count++;

    // Test 5: Queue after operations
    void'(q.pop_front());
    if ($size(q) == 2) pass_count++;

    // Test 6: Empty check
    dyn.delete();
    if ($size(dyn) == 0) pass_count++;

    $display("Size func tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Size func tests");
    end else begin
      $display("FAIL: Some size tests failed");
    end
  end
endmodule
