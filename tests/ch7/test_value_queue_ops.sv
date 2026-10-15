/*
:name: test_value_queue_ops
:description: Test for queue value operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_queue_ops.expected
*/
// Test for queue value operations
// IEEE 1800-2023 §7.10: Queues
module test_value_queue_ops;
    int fails = 0;

    initial begin
        int q[$];
        int val;

        // Push operations
        q.push_back(10);
        q.push_back(20);
        q.push_front(5);
        if (q.size() != 3) begin fails++; $display("FAIL: Size after push"); end
        if (q[0] != 5) begin fails++; $display("FAIL: push_front"); end

        // Pop operations
        val = q.pop_front();
        if (val != 5) begin fails++; $display("FAIL: pop_front val"); end
        if (q.size() != 2) begin fails++; $display("FAIL: Size after pop"); end

        val = q.pop_back();
        if (val != 20) begin fails++; $display("FAIL: pop_back val"); end

        // Insert/delete
        q = '{1, 2, 3, 4, 5};
        q.insert(2, 99);
        if (q[2] != 99) begin fails++; $display("FAIL: insert"); end

        q.delete(2);
        if (q[2] != 3) begin fails++; $display("FAIL: delete"); end

        // Sum
        q = '{10, 20, 30, 20, 40};
        val = q.sum();
        if (val != 120) begin fails++; $display("FAIL: sum %0d", val); end

        if (fails == 0) $display("PASS: Queue value operations");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
