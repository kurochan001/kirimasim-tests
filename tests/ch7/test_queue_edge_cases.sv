/*
:name: test_queue_edge_cases
:description: Test: Queue edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_edge_cases.expected
*/
// Test: Queue edge cases
// IEEE 1800-2023 Section 7.10 Queues
// Tests corner cases: bounded queues, assignment, negative indices, array methods

`timescale 1ns/1ps

module test_queue_edge_cases;
    int passed = 0;
    int failed = 0;

    // Various queue types
    int unbounded_q[$];
    int bounded_q[$:5];  // Highest index 5: at most 6 elements (7.10)
    string str_q[$];
    logic [7:0] logic_q[$];

    initial begin
        $display("TEST: Queue edge cases");

        // Test 1: Empty queue size
        if (unbounded_q.size() == 0) begin
            $display("  [PASS] Empty queue size is 0");
            passed++;
        end else begin
            $display("  [FAIL] Empty queue size should be 0");
            failed++;
        end

        // Test 2: Bounded queue - within limit
        bounded_q = '{1, 2, 3, 4, 5};
        if (bounded_q.size() == 5) begin
            $display("  [PASS] Bounded queue accepts up to bound elements");
            passed++;
        end else begin
            $display("  [FAIL] Bounded queue should accept bound elements");
            failed++;
        end

        // Test 3: Queue assignment creates copy
        begin
            static int q1[$] = '{10, 20, 30};
            int q2[$];
            q2 = q1;
            q1[0] = 100;  // Modify original
            if (q2[0] == 10) begin
                $display("  [PASS] Queue assignment creates deep copy");
                passed++;
            end else begin
                $display("  [FAIL] Queue assignment should be deep copy");
                failed++;
            end
        end

        // Test 4: Negative index access (from end)
        begin
            static int q[$] = '{1, 2, 3, 4, 5};
            // Note: SystemVerilog doesn't support negative indexing like Python
            // This test verifies the last element access via $
            if (q[$] == 5) begin
                $display("  [PASS] q[$] returns last element");
                passed++;
            end else begin
                $display("  [FAIL] q[$] should return last element");
                failed++;
            end
        end

        // Test 5: String queue
        str_q.push_back("hello");
        str_q.push_back("world");
        if (str_q[0] == "hello" && str_q[1] == "world") begin
            $display("  [PASS] String queue works correctly");
            passed++;
        end else begin
            $display("  [FAIL] String queue should work");
            failed++;
        end

        // Test 6: Logic vector queue
        logic_q.push_back(8'hAB);
        logic_q.push_back(8'hCD);
        if (logic_q[0] == 8'hAB && logic_q[1] == 8'hCD) begin
            $display("  [PASS] Logic vector queue works");
            passed++;
        end else begin
            $display("  [FAIL] Logic vector queue should work");
            failed++;
        end

        // Test 7: pop_front on single element
        begin
            static int q[$] = '{42};
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = q.pop_front();
            if (val == 42 && q.size() == 0) begin
                $display("  [PASS] pop_front on single element works");
                passed++;
            end else begin
                $display("  [FAIL] pop_front on single element should work");
                failed++;
            end
        end

        // Test 8: pop_back on single element
        begin
            static int q[$] = '{99};
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = q.pop_back();
            if (val == 99 && q.size() == 0) begin
                $display("  [PASS] pop_back on single element works");
                passed++;
            end else begin
                $display("  [FAIL] pop_back on single element should work");
                failed++;
            end
        end

        // Test 9: insert at beginning
        begin
            static int q[$] = '{2, 3, 4};
            q.insert(0, 1);
            if (q[0] == 1 && q.size() == 4) begin
                $display("  [PASS] insert at index 0 works");
                passed++;
            end else begin
                $display("  [FAIL] insert at index 0 should work");
                failed++;
            end
        end

        // Test 10: insert at end
        begin
            static int q[$] = '{1, 2, 3};
            q.insert(3, 4);  // Insert at size position = append
            if (q[3] == 4 && q.size() == 4) begin
                $display("  [PASS] insert at end works");
                passed++;
            end else begin
                $display("  [FAIL] insert at end should work");
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
