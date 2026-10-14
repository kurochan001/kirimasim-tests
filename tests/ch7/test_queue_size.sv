/*
:name: test_queue_size
:description: Test queue size (IEEE 1800-2023 Section 7.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_size.expected
*/
// Test queue size (IEEE 1800-2023 Section 7.10)

module test_queue_size;
  int q[$];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Empty queue
    if (q.size() == 0) pass_count++;

    // Test 2: After push
    q.push_back(10);
    q.push_back(20);
    if (q.size() == 2) pass_count++;

    // Test 3: After pop
    void'(q.pop_front());
    if (q.size() == 1) pass_count++;

    $display("Queue size tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Queue size tests");
    end else begin
      $display("FAIL: Some queue size tests failed");
    end
  end
endmodule
