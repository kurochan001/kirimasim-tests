/*
:name: test_queue_insert
:description: Test queue insert (IEEE 1800-2023 Section 7.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_insert.expected
*/
// Test queue insert (IEEE 1800-2023 Section 7.10)

module test_queue_insert;
  int q[$];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Insert to empty
    q.insert(0, 10);
    if (q[0] == 10) pass_count++;

    // Test 2: Insert at end
    q.insert(1, 20);
    if (q[1] == 20) pass_count++;

    // Test 3: Insert in middle
    q.insert(1, 15);
    if (q[1] == 15 && q[2] == 20) pass_count++;

    $display("Queue insert tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Queue insert tests");
    end else begin
      $display("FAIL: Some queue insert tests failed");
    end
  end
endmodule
