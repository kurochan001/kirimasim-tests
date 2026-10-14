/*
:name: test_queue_methods_2
:description: Queue methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_2.expected
*/
// IEEE 1800-2023 §7.10.2: Queue methods
// Tests: size, push_back, push_front, pop_back, pop_front, insert, delete
// Verifies all standard queue manipulation methods

module test_queue_methods;
    int queue_int[$];
    int val;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Queue Methods Test ===");

        // Test 1: Initial size
        if (queue_int.size() == 0) begin
            $display("PASS: Initial size is 0");
            passed++;
        end else begin
            $display("FAIL: Initial size is %0d, expected 0", queue_int.size());
            failed++;
        end

        // Test 2: push_back
        queue_int.push_back(10);
        queue_int.push_back(20);
        queue_int.push_back(30);
        if (queue_int.size() == 3) begin
            $display("PASS: After push_back x3, size is 3");
            passed++;
        end else begin
            $display("FAIL: After push_back x3, size is %0d, expected 3", queue_int.size());
            failed++;
        end

        // Test 3: push_front
        queue_int.push_front(5);
        if (queue_int.size() == 4 && queue_int[0] == 5) begin
            $display("PASS: push_front works, queue[0] = 5");
            passed++;
        end else begin
            $display("FAIL: push_front failed");
            failed++;
        end

        // Test 4: pop_front
        val = queue_int.pop_front();
        if (val == 5 && queue_int.size() == 3) begin
            $display("PASS: pop_front returned 5, size is now 3");
            passed++;
        end else begin
            $display("FAIL: pop_front returned %0d, expected 5", val);
            failed++;
        end

        // Test 5: pop_back
        val = queue_int.pop_back();
        if (val == 30 && queue_int.size() == 2) begin
            $display("PASS: pop_back returned 30, size is now 2");
            passed++;
        end else begin
            $display("FAIL: pop_back returned %0d, expected 30", val);
            failed++;
        end

        // Test 6: insert
        queue_int.insert(1, 15);  // Insert 15 at index 1
        if (queue_int.size() == 3 && queue_int[1] == 15) begin
            $display("PASS: insert(1, 15) works, queue[1] = 15");
            passed++;
        end else begin
            $display("FAIL: insert failed");
            failed++;
        end

        // Test 7: delete element
        queue_int.delete(1);  // Delete at index 1
        if (queue_int.size() == 2) begin
            $display("PASS: delete(1) works, size is now 2");
            passed++;
        end else begin
            $display("FAIL: delete(1) failed, size is %0d", queue_int.size());
            failed++;
        end

        // Test 8: delete all
        queue_int.delete();
        if (queue_int.size() == 0) begin
            $display("PASS: delete() clears queue, size is 0");
            passed++;
        end else begin
            $display("FAIL: delete() failed, size is %0d", queue_int.size());
            failed++;
        end

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
