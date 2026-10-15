/*
:name: test_queue_edge_2
:description: Queue edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.1 7.10.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_edge_2.expected
*/
// IEEE 1800-2023 §7.10: Queue edge cases
`timescale 1ns/1ps

module test_queue_edge_2;
  int q[$];
  int q2[$];
  int bounded_q[$:10];
  int val;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Empty queue
    if (q.size() != 0) begin
      $display("FAIL: Initial size should be 0");
      test_passed = 0;
    end

    // Test 2: push_back
    q.push_back(10);
    q.push_back(20);
    q.push_back(30);
    if (q.size() != 3) begin
      $display("FAIL: Size after push_back should be 3");
      test_passed = 0;
    end

    // Test 3: push_front
    q.push_front(5);
    if (q[0] != 5) begin
      $display("FAIL: push_front should add to front");
      test_passed = 0;
    end

    // Test 4: pop_back
    val = q.pop_back();
    if (val != 30) begin
      $display("FAIL: pop_back should return 30");
      test_passed = 0;
    end

    // Test 5: pop_front
    val = q.pop_front();
    if (val != 5) begin
      $display("FAIL: pop_front should return 5");
      test_passed = 0;
    end

    // Test 6: insert at position
    q.insert(1, 15);
    if (q[1] != 15) begin
      $display("FAIL: insert at position 1 failed");
      test_passed = 0;
    end

    // Test 7: delete at position
    q.delete(1);
    if (q.size() != 2) begin
      $display("FAIL: delete should reduce size");
      test_passed = 0;
    end

    // Test 8: Array-style access
    q = '{100, 200, 300, 400};
    if (q[2] != 300) begin
      $display("FAIL: Array-style access failed");
      test_passed = 0;
    end

    // Test 9: Slice access
    q2 = q[1:2];
    if (q2.size() != 2 || q2[0] != 200 || q2[1] != 300) begin
      $display("FAIL: Slice access failed");
      test_passed = 0;
    end

    // Test 10: $ notation (last element)
    if (q[$] != 400) begin
      $display("FAIL: $ notation failed");
      test_passed = 0;
    end

    // Test 11: Access second to last via size
    if (q[q.size()-2] != 300) begin
      $display("FAIL: q[size-2] should be second to last");
      test_passed = 0;
    end

    // Test 12: delete all
    q.delete();
    if (q.size() != 0) begin
      $display("FAIL: delete() should empty queue");
      test_passed = 0;
    end

    // Test 13: Bounded queue
    for (int i = 0; i < 15; i++) begin
      bounded_q.push_back(i);
    end
    // Bounded queue should limit to 11 elements (0:10)
    if (bounded_q.size() > 11) begin
      $display("FAIL: Bounded queue exceeded limit");
      test_passed = 0;
    end

    // Test 14: Queue methods with empty queue
    q = {};
    if (q.size() != 0) begin
      $display("FAIL: Empty literal queue should have size 0");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Queue edge cases");
    end else begin
      $display("FAIL: Some queue tests failed");
    end
    $finish;
  end
endmodule
