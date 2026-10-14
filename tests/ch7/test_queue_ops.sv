/*
:name: test_queue_ops
:description: Test for queue operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_ops.expected
*/
// Test for queue operations
// IEEE 1800-2023 §7.10

module test_queue_ops;
    int q[$];
    int val;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Push back
        test_count++;
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3) begin
            $display("Test 1: push_back PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL size=%0d", q.size());
        end

        // Test 2: Push front
        test_count++;
        q.push_front(5);
        if (q[0] == 5) begin
            $display("Test 2: push_front PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL q[0]=%0d", q[0]);
        end

        // Test 3: Pop back
        test_count++;
        val = q.pop_back();
        if (val == 30) begin
            $display("Test 3: pop_back PASS val=%0d", val);
            pass_count++;
        end else begin
            $display("Test 3: FAIL val=%0d", val);
        end

        // Test 4: Pop front
        test_count++;
        val = q.pop_front();
        if (val == 5) begin
            $display("Test 4: pop_front PASS val=%0d", val);
            pass_count++;
        end else begin
            $display("Test 4: FAIL val=%0d", val);
        end

        // Test 5: Insert
        test_count++;
        q.insert(1, 15);
        if (q[1] == 15) begin
            $display("Test 5: insert PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL q[1]=%0d", q[1]);
        end

        // Test 6: Delete
        test_count++;
        q.delete(1);
        $display("Test 6: delete PASS size=%0d", q.size());
        pass_count++;

        // Test 7: Queue size
        test_count++;
        if (q.size() == 2) begin
            $display("Test 7: size PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL size=%0d", q.size());
        end

        // Test 8: Clear queue
        test_count++;
        q.delete();
        if (q.size() == 0) begin
            $display("Test 8: delete all PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL size=%0d", q.size());
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
