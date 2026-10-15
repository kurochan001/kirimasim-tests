/*
:name: test_queue_ops_adv_edge_cases
:description: Test: Queue advanced operations edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2 7.10.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_ops_adv_edge_cases.expected
*/
// Test: Queue advanced operations edge cases
// IEEE 1800-2023 Section 7.10 Queue operations
// Tests corner cases: advanced queue operations

`timescale 1ns/1ps

module test_queue_ops_adv_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int q[$];
        int q2[$];
        int val;

        $display("TEST: Queue advanced operations edge cases");

        // Test 1: Queue push_back multiple
        begin
            q.delete();
            for (int i = 0; i < 5; i++) begin
                q.push_back(i * 10);
            end
            if (q.size() == 5) begin
                $display("  [PASS] Queue push_back multiple");
                passed++;
            end else begin
                $display("  [FAIL] PushMulti: %0d", q.size());
                failed++;
            end
        end

        // Test 2: Queue pop_front
        begin
            q = '{10, 20, 30, 40, 50};
            val = q.pop_front();
            if (val == 10 && q.size() == 4) begin
                $display("  [PASS] Queue pop_front");
                passed++;
            end else begin
                $display("  [FAIL] PopFront: %0d", val);
                failed++;
            end
        end

        // Test 3: Queue pop_back
        begin
            q = '{10, 20, 30, 40, 50};
            val = q.pop_back();
            if (val == 50 && q.size() == 4) begin
                $display("  [PASS] Queue pop_back");
                passed++;
            end else begin
                $display("  [FAIL] PopBack: %0d", val);
                failed++;
            end
        end

        // Test 4: Queue push_front
        begin
            q.delete();
            q.push_back(20);
            q.push_front(10);
            if (q[0] == 10 && q[1] == 20) begin
                $display("  [PASS] Queue push_front");
                passed++;
            end else begin
                $display("  [FAIL] PushFront");
                failed++;
            end
        end

        // Test 5: Queue insert
        begin
            q = '{10, 30, 40};
            q.insert(1, 20);
            if (q[0] == 10 && q[1] == 20 && q[2] == 30) begin
                $display("  [PASS] Queue insert");
                passed++;
            end else begin
                $display("  [FAIL] Insert");
                failed++;
            end
        end

        // Test 6: Queue delete by index
        begin
            q = '{10, 20, 30, 40};
            q.delete(1);  // Delete element at index 1
            if (q.size() == 3 && q[0] == 10 && q[1] == 30) begin
                $display("  [PASS] Queue delete by index");
                passed++;
            end else begin
                $display("  [FAIL] DelIdx");
                failed++;
            end
        end

        // Test 7: Queue copy
        begin
            q = '{1, 2, 3, 4, 5};
            q2 = q;
            if (q2.size() == 5 && q2[0] == 1 && q2[4] == 5) begin
                $display("  [PASS] Queue copy");
                passed++;
            end else begin
                $display("  [FAIL] Copy");
                failed++;
            end
        end

        // Test 8: Queue bounded
        begin
            int bq[$:3];  // Max 4 elements
            bq.push_back(1);
            bq.push_back(2);
            bq.push_back(3);
            bq.push_back(4);
            if (bq.size() == 4) begin
                $display("  [PASS] Queue bounded");
                passed++;
            end else begin
                $display("  [FAIL] Bounded: %0d", bq.size());
                failed++;
            end
        end

        // Test 9: Queue sum
        begin
            q = '{1, 2, 3, 4, 5};
            val = q.sum();
            if (val == 15) begin
                $display("  [PASS] Queue sum");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", val);
                failed++;
            end
        end

        // Test 10: Queue empty check
        begin
            q.delete();
            if (q.size() == 0) begin
                $display("  [PASS] Queue empty check");
                passed++;
            end else begin
                $display("  [FAIL] Empty: %0d", q.size());
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
