/*
:name: test_queue_push_front
:description: Queue push_front method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_push_front.expected
*/
// Queue push_front method
module test_queue_push_front;
    int q[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Push to empty queue
        q = {};
        q.push_front(10);
        if (q.size() == 1 && q[0] == 10) begin
            $display("Test 1 PASS: push_front to empty queue");
            passed++;
        end else begin
            $display("Test 1 FAIL: push_front to empty queue");
            failed++;
        end

        // Test 2: Push multiple elements
        q.push_front(20);
        if (q.size() == 2 && q[0] == 20 && q[1] == 10) begin
            $display("Test 2 PASS: push_front second element");
            passed++;
        end else begin
            $display("Test 2 FAIL: push_front second element");
            failed++;
        end

        // Test 3: Push third element
        q.push_front(30);
        if (q.size() == 3 && q[0] == 30 && q[1] == 20 && q[2] == 10) begin
            $display("Test 3 PASS: push_front third element");
            passed++;
        end else begin
            $display("Test 3 FAIL: push_front third element, q[0]=%0d q[1]=%0d q[2]=%0d", q[0], q[1], q[2]);
            failed++;
        end

        // Test 4: Push negative value
        q = {};
        q.push_front(-5);
        if (q.size() == 1 && q[0] == -5) begin
            $display("Test 4 PASS: push_front negative value");
            passed++;
        end else begin
            $display("Test 4 FAIL: push_front negative value");
            failed++;
        end

        // Test 5: Push zero
        q = {};
        q.push_front(0);
        q.push_front(100);
        if (q.size() == 2 && q[0] == 100 && q[1] == 0) begin
            $display("Test 5 PASS: push_front with zero");
            passed++;
        end else begin
            $display("Test 5 FAIL: push_front with zero");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
