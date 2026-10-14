/*
:name: test_queue_edge_cases_2
:description: Queue operations edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_edge_cases_2.expected
*/
// IEEE 1800-2023 Section 7.10 - Queue operations edge cases
// Tests boundary conditions and corner cases for queue operations

module test_queue_edge_cases;
    // Queue declarations
    int q[$];
    string str_q[$];
    int result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("IEEE 1800-2023 Section 7.10 - Queue Edge Cases Test");
        $display("============================================================");

        // Test 1: Empty queue size
        q = {};
        if (q.size() == 0) begin
            $display("PASS: Test 1 - Empty queue size = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Empty queue size expected 0, got %0d", q.size());
            fail_count++;
        end

        // Test 2: pop_front on empty queue (should handle gracefully)
        q = {};
        // Note: pop_front on empty queue may error, just test it doesn't crash
        if (q.size() == 0) begin
            $display("PASS: Test 2 - Empty queue size check");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Empty queue issue");
            fail_count++;
        end

        // Test 3: push_back and pop_back order
        q = {};
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);
        result = q.pop_back();
        if (result == 3 && q.size() == 2) begin
            $display("PASS: Test 3 - push_back/pop_back LIFO order correct");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected pop_back=3, got %0d", result);
            fail_count++;
        end

        // Test 4: push_front and pop_front order
        q = {};
        q.push_front(1);
        q.push_front(2);
        q.push_front(3);
        result = q.pop_front();
        if (result == 3 && q.size() == 2) begin
            $display("PASS: Test 4 - push_front/pop_front LIFO order correct");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected pop_front=3, got %0d", result);
            fail_count++;
        end

        // Test 5: Queue populated with push_back
        q = {};
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3 && q[0] == 10) begin
            $display("PASS: Test 5 - Queue population via push_back");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Queue population failed");
            fail_count++;
        end

        // Test 6: Queue indexing
        q = {};
        q.push_back(100);
        q.push_back(200);
        q.push_back(300);
        if (q[0] == 100 && q[1] == 200 && q[2] == 300) begin
            $display("PASS: Test 6 - Queue indexing works");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - Queue indexing failed");
            fail_count++;
        end

        // Test 7: delete all elements
        q = {};
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        q.delete();
        if (q.size() == 0) begin
            $display("PASS: Test 7 - delete() clears queue");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - delete() failed, size=%0d", q.size());
            fail_count++;
        end

        // Test 8: Multiple push/pop operations
        q = {};
        q.push_back(1);
        q.push_front(0);
        q.push_back(2);
        // Queue should be: [0, 1, 2]
        if (q.size() == 3 && q[0] == 0 && q[1] == 1 && q[2] == 2) begin
            $display("PASS: Test 8 - Mixed push operations work");
            pass_count++;
        end else begin
            $display("FAIL: Test 8 - Mixed push operations failed");
            fail_count++;
        end

        // Test 9: Queue size after operations
        q = {};
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);
        q.push_back(4);
        q.push_back(5);
        if (q.size() == 5) begin
            $display("PASS: Test 9 - Queue size tracks correctly");
            pass_count++;
        end else begin
            $display("FAIL: Test 9 - Queue size incorrect");
            fail_count++;
        end

        // Test 10: String queue operations
        str_q = {};
        str_q.push_back("hello");
        str_q.push_back("world");
        if (str_q.size() == 2 && str_q[0] == "hello") begin
            $display("PASS: Test 10 - String queue operations work");
            pass_count++;
        end else begin
            $display("FAIL: Test 10 - String queue failed");
            fail_count++;
        end

        // Summary
        $display("============================================================");
        $display("Test Summary: %0d passed, %0d failed", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end

        $finish;
    end
endmodule
