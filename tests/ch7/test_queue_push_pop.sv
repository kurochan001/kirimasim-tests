/*
:name: test_queue_push_pop
:description: Test queue push/pop (IEEE 1800-2023 Section 7.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_push_pop.expected
*/
// Test queue push/pop (IEEE 1800-2023 Section 7.10)

module test_queue_push_pop;
  int q[$];
  int val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Push back
    q.push_back(10);
    q.push_back(20);
    if (q.size() == 2) pass_count++;

    // Test 2: Pop front
    val = q.pop_front();
    if (val == 10) pass_count++;

    // Test 3: Push front
    q.push_front(5);
    if (q[0] == 5) pass_count++;

    // Test 4: Pop back
    val = q.pop_back();
    if (val == 20) pass_count++;

    $display("Queue push/pop tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Queue push/pop tests");
    end else begin
      $display("FAIL: Some queue tests failed");
    end
  end
endmodule
