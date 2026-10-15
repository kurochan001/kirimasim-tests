/*
:name: test_queue_ops_edge_cases
:description: Test: Queue operations edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_ops_edge_cases.expected
*/
// Test: Queue operations edge cases
// IEEE 1800-2023 Section 7.10 Queues
// Tests corner cases: queue push, pop, size, delete

`timescale 1ns/1ps

module test_queue_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int q[$];

        $display("TEST: Queue operations edge cases");

        // Test 1: Empty queue size
        begin
            if (q.size() == 0) begin
                $display("  [PASS] Empty queue size");
                passed++;
            end else begin
                $display("  [FAIL] Empty: %0d", q.size());
                failed++;
            end
        end

        // Test 2: Push back
        begin
            q.push_back(10);
            if (q.size() == 1 && q[0] == 10) begin
                $display("  [PASS] Push back");
                passed++;
            end else begin
                $display("  [FAIL] PushB: size=%0d val=%0d", q.size(), q[0]);
                failed++;
            end
        end

        // Test 3: Push front
        begin
            q.push_front(5);
            if (q.size() == 2 && q[0] == 5 && q[1] == 10) begin
                $display("  [PASS] Push front");
                passed++;
            end else begin
                $display("  [FAIL] PushF: size=%0d", q.size());
                failed++;
            end
        end

        // Test 4: Pop front
        begin
            int val;
            val = q.pop_front();
            if (val == 5 && q.size() == 1) begin
                $display("  [PASS] Pop front");
                passed++;
            end else begin
                $display("  [FAIL] PopF: val=%0d size=%0d", val, q.size());
                failed++;
            end
        end

        // Test 5: Pop back
        begin
            int val;
            q.push_back(20);
            val = q.pop_back();
            if (val == 20 && q.size() == 1) begin
                $display("  [PASS] Pop back");
                passed++;
            end else begin
                $display("  [FAIL] PopB: val=%0d size=%0d", val, q.size());
                failed++;
            end
        end

        // Test 6: Multiple push
        begin
            q.push_back(30);
            q.push_back(40);
            if (q.size() == 3) begin
                $display("  [PASS] Multiple push");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", q.size());
                failed++;
            end
        end

        // Test 7: Index access
        begin
            if (q[0] == 10 && q[1] == 30 && q[2] == 40) begin
                $display("  [PASS] Index access");
                passed++;
            end else begin
                $display("  [FAIL] Index: %0d %0d %0d", q[0], q[1], q[2]);
                failed++;
            end
        end

        // Test 8: Delete all
        begin
            q.delete();
            if (q.size() == 0) begin
                $display("  [PASS] Delete all");
                passed++;
            end else begin
                $display("  [FAIL] Delete: %0d", q.size());
                failed++;
            end
        end

        // Test 9: Rebuild queue
        begin
            q.push_back(1);
            q.push_back(2);
            q.push_back(3);
            if (q.size() == 3) begin
                $display("  [PASS] Rebuild queue");
                passed++;
            end else begin
                $display("  [FAIL] Rebuild: %0d", q.size());
                failed++;
            end
        end

        // Test 10: Sum elements
        begin
            static int sum = 0;
            for (int i = 0; i < q.size(); i++) begin
                sum = sum + q[i];
            end
            if (sum == 6) begin
                $display("  [PASS] Sum elements");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", sum);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
