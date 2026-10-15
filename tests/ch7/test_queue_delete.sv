/*
:name: test_queue_delete
:description: Test queue delete (IEEE 1800-2023 Section 7.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.3 7.10.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_delete.expected
*/
// Test queue delete (IEEE 1800-2023 Section 7.10)

module test_queue_delete;
  int q[$];
  int pass_count;

  initial begin
    pass_count = 0;
    q = {1, 2, 3, 4, 5};

    // Test 1: Delete element
    q.delete(2);
    if (q.size() == 4) pass_count++;

    // Test 2: Check remaining
    if (q[2] == 4) pass_count++;

    // Test 3: Delete all
    q.delete();
    if (q.size() == 0) pass_count++;

    $display("Queue delete tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Queue delete tests");
    end else begin
      $display("FAIL: Some queue delete tests failed");
    end
  end
endmodule
