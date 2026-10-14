/*
:name: test_queue_basic_edge_cases
:description: Queue basic edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_basic_edge_cases.expected
*/
// IEEE 1800-2023 §7.10: Queue basic edge cases
// Tests for queue operations

module test_queue_basic_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int q[$];
    string sq[$];

    initial begin
        // Test 1: Empty queue size
        test_count++;
        if (q.size() == 0) begin
            pass_count++;
            $display("Test 1 PASS: Empty size = %0d", q.size());
        end else begin
            $display("Test 1 FAIL: Empty unexpected = %0d", q.size());
        end

        // Test 2: Push back
        test_count++;
        q.push_back(10);
        if (q.size() == 1 && q[0] == 10) begin
            pass_count++;
            $display("Test 2 PASS: Push back = %0d", q[0]);
        end else begin
            $display("Test 2 FAIL: Push unexpected");
        end

        // Test 3: Multiple push
        test_count++;
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3) begin
            pass_count++;
            $display("Test 3 PASS: Multi push size = %0d", q.size());
        end else begin
            $display("Test 3 FAIL: Multi unexpected = %0d", q.size());
        end

        // Test 4: Push front
        test_count++;
        q.push_front(5);
        if (q[0] == 5) begin
            pass_count++;
            $display("Test 4 PASS: Push front = %0d", q[0]);
        end else begin
            $display("Test 4 FAIL: Front unexpected = %0d", q[0]);
        end

        // Test 5: Pop back
        test_count++;
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = q.pop_back();
            if (val == 30) begin
                pass_count++;
                $display("Test 5 PASS: Pop back = %0d", val);
            end else begin
                $display("Test 5 FAIL: Pop unexpected = %0d", val);
            end
        end

        // Test 6: Pop front
        test_count++;
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = q.pop_front();
            if (val == 5) begin
                pass_count++;
                $display("Test 6 PASS: Pop front = %0d", val);
            end else begin
                $display("Test 6 FAIL: Front unexpected = %0d", val);
            end
        end

        // Test 7: Index access
        test_count++;
        if (q[0] == 10 && q[1] == 20) begin
            pass_count++;
            $display("Test 7 PASS: Index q[0]=%0d q[1]=%0d", q[0], q[1]);
        end else begin
            $display("Test 7 FAIL: Index unexpected");
        end

        // Test 8: Insert
        test_count++;
        q.insert(1, 15);
        if (q[1] == 15) begin
            pass_count++;
            $display("Test 8 PASS: Insert = %0d", q[1]);
        end else begin
            $display("Test 8 FAIL: Insert unexpected = %0d", q[1]);
        end

        // Test 9: Delete
        test_count++;
        q.delete(1);
        if (q[1] == 20) begin
            pass_count++;
            $display("Test 9 PASS: After delete q[1] = %0d", q[1]);
        end else begin
            $display("Test 9 FAIL: Delete unexpected");
        end

        // Test 10: Clear queue
        test_count++;
        q.delete();
        if (q.size() == 0) begin
            pass_count++;
            $display("Test 10 PASS: Clear size = %0d", q.size());
        end else begin
            $display("Test 10 FAIL: Clear unexpected = %0d", q.size());
        end

        $display("=== Queue Basic Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
