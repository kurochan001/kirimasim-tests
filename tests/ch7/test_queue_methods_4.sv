/*
:name: test_queue_methods_4
:description: Queue push_back, pop_front, pop_back, insert, delete methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_4.expected
*/
// Queue push_back, pop_front, pop_back, insert, delete methods
module test_queue_methods;
    int q[$];
    int result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: push_back
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
            $display("PASS: push_back works correctly");
            pass_count++;
        end else begin
            $display("FAIL: push_back - expected [10,20,30], got [%0d,%0d,%0d]", q[0], q[1], q[2]);
            fail_count++;
        end

        // Test 2: pop_front
        result = q.pop_front();
        if (result == 10 && q.size() == 2 && q[0] == 20) begin
            $display("PASS: pop_front works correctly");
            pass_count++;
        end else begin
            $display("FAIL: pop_front - expected 10 and size 2, got %0d and size %0d", result, q.size());
            fail_count++;
        end

        // Test 3: pop_back
        result = q.pop_back();
        if (result == 30 && q.size() == 1 && q[0] == 20) begin
            $display("PASS: pop_back works correctly");
            pass_count++;
        end else begin
            $display("FAIL: pop_back - expected 30 and size 1, got %0d and size %0d", result, q.size());
            fail_count++;
        end

        // Test 4: insert
        q.push_back(40);
        q.push_back(50);
        q.insert(1, 25);  // Insert 25 at index 1
        if (q.size() == 4 && q[0] == 20 && q[1] == 25 && q[2] == 40 && q[3] == 50) begin
            $display("PASS: insert works correctly");
            pass_count++;
        end else begin
            $display("FAIL: insert - expected [20,25,40,50], got [%0d,%0d,%0d,%0d]", q[0], q[1], q[2], q[3]);
            fail_count++;
        end

        // Test 5: delete
        q.delete(1);  // Delete element at index 1 (25)
        if (q.size() == 3 && q[0] == 20 && q[1] == 40 && q[2] == 50) begin
            $display("PASS: delete works correctly");
            pass_count++;
        end else begin
            $display("FAIL: delete - expected [20,40,50], got [%0d,%0d,%0d]", q[0], q[1], q[2]);
            fail_count++;
        end

        // Summary
        $display("Queue methods test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All queue method tests passed");
        $finish;
    end
endmodule
