/*
:name: test_queue_size_2
:description: Queue size method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_size_2.expected
*/
// Queue size method
module test_queue_size;
    int q[$];
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Empty queue size
        q = {};
        if (q.size() == 0) begin
            $display("Test 1 PASS: empty queue size");
            passed++;
        end else begin
            $display("Test 1 FAIL: empty queue size, got %0d", q.size());
            failed++;
        end

        // Test 2: Single element queue
        q = '{10};
        if (q.size() == 1) begin
            $display("Test 2 PASS: single element size");
            passed++;
        end else begin
            $display("Test 2 FAIL: single element size");
            failed++;
        end

        // Test 3: Multiple elements
        q = '{10, 20, 30, 40, 50};
        if (q.size() == 5) begin
            $display("Test 3 PASS: five elements size");
            passed++;
        end else begin
            $display("Test 3 FAIL: five elements size");
            failed++;
        end

        // Test 4: Size after push
        q = '{1, 2};
        q.push_back(3);
        if (q.size() == 3) begin
            $display("Test 4 PASS: size after push");
            passed++;
        end else begin
            $display("Test 4 FAIL: size after push");
            failed++;
        end

        // Test 5: Size after pop
        q = '{1, 2, 3, 4};
        void'(q.pop_front());
        if (q.size() == 3) begin
            $display("Test 5 PASS: size after pop");
            passed++;
        end else begin
            $display("Test 5 FAIL: size after pop");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
