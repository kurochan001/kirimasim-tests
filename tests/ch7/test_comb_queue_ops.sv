/*
:name: test_comb_queue_ops
:description: Queue operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_queue_ops.expected
*/
// IEEE 1800-2023 §7.10: Queue operations
// Test coverage: push_back, push_front, pop_back, pop_front, size, delete, insert, foreach
module test_comb_queue_ops;
    int pass = 0, fail = 0;
    int q[$];
    string sq[$];
    int temp;

    initial begin
        // Test 1: Empty queue
        if (q.size() == 0) pass++; else begin fail++; $display("FAIL T1: size=%0d exp 0", q.size()); end

        // Test 2: push_back
        q.push_back(10);
        if (q.size() == 1) pass++; else begin fail++; $display("FAIL T2: size=%0d exp 1", q.size()); end
        if (q[0] == 10) pass++; else begin fail++; $display("FAIL T2b: q[0]=%0d exp 10", q[0]); end

        // Test 3: push_front
        q.push_front(5);
        if (q.size() == 2) pass++; else begin fail++; $display("FAIL T3: size=%0d exp 2", q.size()); end
        if (q[0] == 5) pass++; else begin fail++; $display("FAIL T3b: q[0]=%0d exp 5", q[0]); end
        if (q[1] == 10) pass++; else begin fail++; $display("FAIL T3c: q[1]=%0d exp 10", q[1]); end

        // Test 4: pop_back
        temp = q.pop_back();
        if (temp == 10) pass++; else begin fail++; $display("FAIL T4: pop_back=%0d exp 10", temp); end
        if (q.size() == 1) pass++; else begin fail++; $display("FAIL T4b: size=%0d exp 1", q.size()); end
        if (q[0] == 5) pass++; else begin fail++; $display("FAIL T4c: q[0]=%0d exp 5", q[0]); end

        // Test 5: pop_front
        temp = q.pop_front();
        if (temp == 5) pass++; else begin fail++; $display("FAIL T5: pop_front=%0d exp 5", temp); end
        if (q.size() == 0) pass++; else begin fail++; $display("FAIL T5b: size=%0d exp 0", q.size()); end

        // Test 6: Multiple push_back - add 5 elements
        q.push_back(100);
        q.push_back(200);
        q.push_back(300);
        q.push_back(400);
        q.push_back(500);
        if (q.size() == 5) pass++; else begin fail++; $display("FAIL T6: size=%0d exp 5", q.size()); end

        // Test 7: Index access
        if (q[0] == 100) pass++; else begin fail++; $display("FAIL T7a: q[0]=%0d exp 100", q[0]); end
        if (q[1] == 200) pass++; else begin fail++; $display("FAIL T7b: q[1]=%0d exp 200", q[1]); end
        if (q[2] == 300) pass++; else begin fail++; $display("FAIL T7c: q[2]=%0d exp 300", q[2]); end
        if (q[3] == 400) pass++; else begin fail++; $display("FAIL T7d: q[3]=%0d exp 400", q[3]); end
        if (q[4] == 500) pass++; else begin fail++; $display("FAIL T7e: q[4]=%0d exp 500", q[4]); end

        // Test 8: delete - clear queue
        q.delete();
        if (q.size() == 0) pass++; else begin fail++; $display("FAIL T8: size=%0d exp 0 after delete", q.size()); end

        // Test 9: Queue of strings
        sq.push_back("hello");
        sq.push_back("world");
        sq.push_front("start");
        if (sq.size() == 3) pass++; else begin fail++; $display("FAIL T9: sq.size=%0d exp 3", sq.size()); end
        if (sq[0] == "start") pass++; else begin fail++; $display("FAIL T9b: sq[0]=%s exp start", sq[0]); end
        if (sq[1] == "hello") pass++; else begin fail++; $display("FAIL T9c: sq[1]=%s exp hello", sq[1]); end
        if (sq[2] == "world") pass++; else begin fail++; $display("FAIL T9d: sq[2]=%s exp world", sq[2]); end

        // Test 10: insert - insert at position
        q.push_back(10);
        q.push_back(30);
        q.insert(1, 20);  // Insert 20 at index 1
        if (q.size() == 3) pass++; else begin fail++; $display("FAIL T10: size=%0d exp 3", q.size()); end
        if (q[0] == 10) pass++; else begin fail++; $display("FAIL T10b: q[0]=%0d exp 10", q[0]); end
        if (q[1] == 20) pass++; else begin fail++; $display("FAIL T10c: q[1]=%0d exp 20", q[1]); end
        if (q[2] == 30) pass++; else begin fail++; $display("FAIL T10d: q[2]=%0d exp 30", q[2]); end

        // Test 11: Queue in foreach loop
        q.delete();
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);
        q.push_back(4);
        begin
            static int sum = 0;
            static int expected_sum = 10;  // 1+2+3+4
            foreach (q[i]) begin
                sum += q[i];
            end
            if (sum == expected_sum) pass++; else begin fail++; $display("FAIL T11: foreach sum=%0d exp %0d", sum, expected_sum); end
        end

        // Test 12: Queue size after mixed push/pop operations
        q.delete();
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);      // q = [1, 2, 3]
        temp = q.pop_front(); // q = [2, 3]
        q.push_front(10);    // q = [10, 2, 3]
        temp = q.pop_back();  // q = [10, 2]
        q.push_back(20);     // q = [10, 2, 20]
        if (q.size() == 3) pass++; else begin fail++; $display("FAIL T12: size=%0d exp 3", q.size()); end
        if (q[0] == 10) pass++; else begin fail++; $display("FAIL T12b: q[0]=%0d exp 10", q[0]); end
        if (q[1] == 2) pass++; else begin fail++; $display("FAIL T12c: q[1]=%0d exp 2", q[1]); end
        if (q[2] == 20) pass++; else begin fail++; $display("FAIL T12d: q[2]=%0d exp 20", q[2]); end

        // Summary
        $display("queue_ops: pass=%0d fail=%0d", pass, fail);
        if (fail == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
