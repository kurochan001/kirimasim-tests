/*
:name: test_queue_pop_back
:description: Queue pop_back method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_pop_back.expected
*/
// Queue pop_back method
module test_queue_pop_back;
    int q[$];
    int val;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Pop from single element queue
        q = '{10};
        val = q.pop_back();
        if (val == 10 && q.size() == 0) begin
            $display("Test 1 PASS: pop_back single element");
            passed++;
        end else begin
            $display("Test 1 FAIL: pop_back single element, val=%0d size=%0d", val, q.size());
            failed++;
        end

        // Test 2: Pop from multiple element queue
        q = '{10, 20, 30};
        val = q.pop_back();
        if (val == 30 && q.size() == 2 && q[1] == 20) begin
            $display("Test 2 PASS: pop_back last of three");
            passed++;
        end else begin
            $display("Test 2 FAIL: pop_back last of three");
            failed++;
        end

        // Test 3: Pop second element
        val = q.pop_back();
        if (val == 20 && q.size() == 1 && q[0] == 10) begin
            $display("Test 3 PASS: pop_back second element");
            passed++;
        end else begin
            $display("Test 3 FAIL: pop_back second element");
            failed++;
        end

        // Test 4: Pop last remaining element
        val = q.pop_back();
        if (val == 10 && q.size() == 0) begin
            $display("Test 4 PASS: pop_back last remaining");
            passed++;
        end else begin
            $display("Test 4 FAIL: pop_back last remaining");
            failed++;
        end

        // Test 5: Pop negative value
        q = '{100, -5};
        val = q.pop_back();
        if (val == -5 && q.size() == 1 && q[0] == 100) begin
            $display("Test 5 PASS: pop_back negative value");
            passed++;
        end else begin
            $display("Test 5 FAIL: pop_back negative value");
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
