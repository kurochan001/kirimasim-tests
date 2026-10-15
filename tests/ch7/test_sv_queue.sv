/*
:name: test_sv_queue
:description: Queues: push, pop, insert, delete and the $ index
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sv_queue.expected
*/
// Queues: push, pop, insert, delete and the $ index
module test_sv_queue;

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    int q[$];

    // Check 1: initial size
    if (q.size() == 0) begin pass_cnt++; $display("PASS: initial size == 0"); end
    else begin fail_cnt++; $display("FAIL: initial size = %0d", q.size()); end

    // Check 2: push_back
    q.push_back(10);
    q.push_back(20);
    q.push_back(30);
    if (q.size() == 3) begin pass_cnt++; $display("PASS: size after 3 push_back == 3"); end
    else begin fail_cnt++; $display("FAIL: size = %0d", q.size()); end

    // Check 3: element access
    if (q[0] == 10 && q[1] == 20 && q[2] == 30) begin pass_cnt++; $display("PASS: elements 10,20,30"); end
    else begin fail_cnt++; $display("FAIL: q = %0d,%0d,%0d", q[0], q[1], q[2]); end

    // Check 4: pop_front
    begin
      int v;
      v = q.pop_front();
      if (v == 10 && q.size() == 2) begin pass_cnt++; $display("PASS: pop_front == 10"); end
      else begin fail_cnt++; $display("FAIL: pop_front = %0d, size = %0d", v, q.size()); end
    end

    // Check 5: insert at index 1
    q.insert(1, 25);
    if (q[0] == 20 && q[1] == 25 && q[2] == 30) begin pass_cnt++; $display("PASS: insert(1,25)"); end
    else begin fail_cnt++; $display("FAIL: after insert q = %0d,%0d,%0d", q[0], q[1], q[2]); end

    // Check 6: delete at index 1
    q.delete(1);
    if (q.size() == 2 && q[0] == 20 && q[1] == 30) begin pass_cnt++; $display("PASS: delete(1)"); end
    else begin fail_cnt++; $display("FAIL: after delete q = %0d,%0d", q[0], q[1]); end

    // Check 7: push_front
    q.push_front(5);
    if (q[0] == 5) begin pass_cnt++; $display("PASS: push_front(5)"); end
    else begin fail_cnt++; $display("FAIL: q[0] = %0d", q[0]); end

    // Check 8: pop_back
    begin
      int v;
      v = q.pop_back();
      if (v == 30 && q.size() == 2) begin pass_cnt++; $display("PASS: pop_back == 30"); end
      else begin fail_cnt++; $display("FAIL: pop_back = %0d, size = %0d", v, q.size()); end
    end

    // Check 9: queue with $ index (last element)
    q.push_back(99);
    if (q[$] == 99) begin pass_cnt++; $display("PASS: q[$] == 99"); end
    else begin fail_cnt++; $display("FAIL: q[$] = %0d", q[$]); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
