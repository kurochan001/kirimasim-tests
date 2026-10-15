/*
:name: test_queue_methods_sequence
:description: A sequence of queue method calls
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_sequence.expected
*/
// IEEE 1800-2023 Section 7.10 - A sequence of queue method calls
// Tests: push, pop, insert, delete, size
module test_queue_methods_sequence;
    int passed = 0;
    int failed = 0;
    int q[$];
    int val;

    initial begin
        // Test empty queue
        if (q.size() == 0) passed++; else begin failed++; $display("FAIL: empty size"); end

        // Test push_back
        q.push_back(10);
        if (q.size() == 1) passed++; else begin failed++; $display("FAIL: push_back size"); end
        if (q[0] == 10) passed++; else begin failed++; $display("FAIL: push_back val"); end

        // Test push_front
        q.push_front(5);
        if (q.size() == 2) passed++; else begin failed++; $display("FAIL: push_front size"); end
        if (q[0] == 5) passed++; else begin failed++; $display("FAIL: push_front val"); end

        // Test pop_back
        val = q.pop_back();
        if (val == 10) passed++; else begin failed++; $display("FAIL: pop_back = %0d", val); end
        if (q.size() == 1) passed++; else begin failed++; $display("FAIL: pop_back size"); end

        // Test pop_front
        q.push_back(20);
        val = q.pop_front();
        if (val == 5) passed++; else begin failed++; $display("FAIL: pop_front = %0d", val); end

        // Test insert
        q = '{1, 2, 3, 4, 5};
        q.insert(2, 100);
        if (q[2] == 100) passed++; else begin failed++; $display("FAIL: insert val"); end
        if (q.size() == 6) passed++; else begin failed++; $display("FAIL: insert size"); end

        // Test delete
        q.delete(2);
        if (q.size() == 5) passed++; else begin failed++; $display("FAIL: delete size"); end
        if (q[2] == 3) passed++; else begin failed++; $display("FAIL: delete order"); end

        // Test delete all
        q.delete();
        if (q.size() == 0) passed++; else begin failed++; $display("FAIL: delete all"); end

        // Test multiple push
        for (int i = 0; i < 10; i++) begin
            q.push_back(i);
        end
        if (q.size() == 10) passed++; else begin failed++; $display("FAIL: multi push size"); end

        // Test indexed access
        if (q[5] == 5) passed++; else begin failed++; $display("FAIL: indexed"); end

        // Test assignment
        q[3] = 999;
        if (q[3] == 999) passed++; else begin failed++; $display("FAIL: assignment"); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d queue methods tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
