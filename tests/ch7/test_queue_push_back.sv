/*
:name: test_queue_push_back
:description: Queue push_back method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_push_back.expected
*/
// Queue push_back method
module test_queue_push_back;
    int q[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Push to empty queue
        q = {};
        q.push_back(10);
        if (q.size() == 1 && q[0] == 10) begin
            $display("Test 1 PASS: push_back to empty queue");
            passed++;
        end else begin
            $display("Test 1 FAIL: push_back to empty queue");
            failed++;
        end

        // Test 2: Push multiple elements
        q.push_back(20);
        if (q.size() == 2 && q[0] == 10 && q[1] == 20) begin
            $display("Test 2 PASS: push_back second element");
            passed++;
        end else begin
            $display("Test 2 FAIL: push_back second element");
            failed++;
        end

        // Test 3: Push third element
        q.push_back(30);
        if (q.size() == 3 && q[0] == 10 && q[1] == 20 && q[2] == 30) begin
            $display("Test 3 PASS: push_back third element");
            passed++;
        end else begin
            $display("Test 3 FAIL: push_back third element");
            failed++;
        end

        // Test 4: Push negative value
        q = {};
        q.push_back(-5);
        if (q.size() == 1 && q[0] == -5) begin
            $display("Test 4 PASS: push_back negative value");
            passed++;
        end else begin
            $display("Test 4 FAIL: push_back negative value");
            failed++;
        end

        // Test 5: Push zero
        q = {};
        q.push_back(0);
        q.push_back(100);
        if (q.size() == 2 && q[0] == 0 && q[1] == 100) begin
            $display("Test 5 PASS: push_back with zero");
            passed++;
        end else begin
            $display("Test 5 FAIL: push_back with zero");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
