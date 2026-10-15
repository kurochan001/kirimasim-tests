/*
:name: test_queue_ordering
:description: Test queue ordering methods (IEEE 1800-2023 Section 7.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_ordering.expected
*/
// Test queue ordering methods (IEEE 1800-2023 Section 7.10)

module test_queue_ordering;
  int q[$];
  int result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Sort ascending
    q = '{5, 2, 8, 1, 9, 3};
    q.sort();
    if (q[0] == 1 && q[$] == 9) pass_count++;

    // Test 2: Sort descending
    q = '{5, 2, 8, 1, 9, 3};
    q.rsort();
    if (q[0] == 9 && q[$] == 1) pass_count++;

    // Test 3: Shuffle
    q = '{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    q.shuffle();
    // The order is random, so sort and check that the elements are kept
    q.sort();
    if (q.size() == 10 && q[0] == 1 && q[$] == 10 && q.sum() == 55) pass_count++;

    // Test 4: Reverse
    q = '{1, 2, 3, 4, 5};
    q.reverse();
    if (q[0] == 5 && q[$] == 1) pass_count++;

    // Test 5: Queue copy
    begin
      int q2[$];
      q = '{10, 20, 30};
      q2 = q;
      if (q2.size() == 3 && q2[0] == 10) pass_count++;
    end

    // Test 6: Queue concatenation
    begin
      static int qa[$] = '{1, 2};
      static int qb[$] = '{3, 4};
      q = {qa, qb};
      if (q.size() == 4) pass_count++;
    end

    $display("Queue ordering tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: Queue ordering tests");
    end else begin
      $display("FAIL: Some queue ordering tests failed");
    end
  end
endmodule
