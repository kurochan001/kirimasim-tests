/*
:name: test_queue_insert_2
:description: Queue insert at index method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_insert_2.expected
*/
// Queue insert at index method
module test_queue_insert;
    int q[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Insert at beginning
        q = '{20, 30};
        q.insert(0, 10);
        if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
            $display("Test 1 PASS: insert at beginning");
            passed++;
        end else begin
            $display("Test 1 FAIL: insert at beginning");
            failed++;
        end

        // Test 2: Insert in middle
        q = '{10, 30};
        q.insert(1, 20);
        if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
            $display("Test 2 PASS: insert in middle");
            passed++;
        end else begin
            $display("Test 2 FAIL: insert in middle");
            failed++;
        end

        // Test 3: Insert at end
        q = '{10, 20};
        q.insert(2, 30);
        if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
            $display("Test 3 PASS: insert at end");
            passed++;
        end else begin
            $display("Test 3 FAIL: insert at end");
            failed++;
        end

        // Test 4: Insert into empty queue
        q = {};
        q.insert(0, 50);
        if (q.size() == 1 && q[0] == 50) begin
            $display("Test 4 PASS: insert into empty queue");
            passed++;
        end else begin
            $display("Test 4 FAIL: insert into empty queue");
            failed++;
        end

        // Test 5: Insert negative value
        q = '{1, 3};
        q.insert(1, -2);
        if (q.size() == 3 && q[1] == -2) begin
            $display("Test 5 PASS: insert negative value");
            passed++;
        end else begin
            $display("Test 5 FAIL: insert negative value");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
