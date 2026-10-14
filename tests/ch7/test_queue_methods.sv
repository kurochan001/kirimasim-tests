/*
:name: test_queue_methods
:description: Test for IEEE 1800-2023 §7.10: Queue methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods.expected
*/
// Test for IEEE 1800-2023 §7.10: Queue methods

module test_queue_methods;
    int q[$];
    int result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== Queue Methods Test ===");

        // Test size() on empty queue
        result = q.size();
        if (result == 0) begin
            $display("PASS: empty q.size() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: empty q.size() expected 0, got %0d", result);
            fail_count++;
        end

        // Test push_back()
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3 && q[0] == 10 && q[2] == 30) begin
            $display("PASS: push_back() - q = {%0d, %0d, %0d}", q[0], q[1], q[2]);
            pass_count++;
        end else begin
            $display("FAIL: push_back() incorrect");
            fail_count++;
        end

        // Test push_front()
        q.push_front(5);
        if (q.size() == 4 && q[0] == 5) begin
            $display("PASS: push_front(5) - q[0] = %0d", q[0]);
            pass_count++;
        end else begin
            $display("FAIL: push_front() incorrect");
            fail_count++;
        end

        // Test pop_front()
        result = q.pop_front();
        if (result == 5 && q.size() == 3) begin
            $display("PASS: pop_front() = %0d, size = %0d", result, q.size());
            pass_count++;
        end else begin
            $display("FAIL: pop_front() expected 5, got %0d", result);
            fail_count++;
        end

        // Test pop_back()
        result = q.pop_back();
        if (result == 30 && q.size() == 2) begin
            $display("PASS: pop_back() = %0d, size = %0d", result, q.size());
            pass_count++;
        end else begin
            $display("FAIL: pop_back() expected 30, got %0d", result);
            fail_count++;
        end

        // Test insert(index, value)
        q = '{100, 200, 300};
        q.insert(1, 150);
        if (q.size() == 4 && q[1] == 150) begin
            $display("PASS: insert(1, 150) - q = {%0d, %0d, %0d, %0d}",
                     q[0], q[1], q[2], q[3]);
            pass_count++;
        end else begin
            $display("FAIL: insert() incorrect");
            fail_count++;
        end

        // Test delete(index)
        q.delete(1);
        if (q.size() == 3 && q[1] == 200) begin
            $display("PASS: delete(1) - q = {%0d, %0d, %0d}", q[0], q[1], q[2]);
            pass_count++;
        end else begin
            $display("FAIL: delete(1) incorrect");
            fail_count++;
        end

        // Test delete() - clear all
        q.delete();
        if (q.size() == 0) begin
            $display("PASS: delete() cleared queue, size = %0d", q.size());
            pass_count++;
        end else begin
            $display("FAIL: delete() should clear queue");
            fail_count++;
        end

        // Test multiple push/pop operations
        q = {};  // empty queue (7.10.4)
        for (int i = 0; i < 5; i++) begin
            q.push_back(i * 10);
        end
        if (q.size() == 5) begin
            $display("PASS: multiple push_back - size = %0d", q.size());
            pass_count++;
        end else begin
            $display("FAIL: multiple push_back");
            fail_count++;
        end

        // Summary
        $display("\n=== Queue Methods Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
