/*
:name: test_queue_methods_basic
:description: Test for queue methods (IEEE 1800-2023 Section 7.10.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_methods_basic.expected
*/
// Test for queue methods
// IEEE 1800-2023 §7.10

module test_queue_methods_basic;
    int q[$];
    int val;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: push_back
        test_count++;
        q.push_back(10);
        q.push_back(20);
        if (q.size() == 2) begin
            $display("Test 1: push_back PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL size=%0d", q.size());
        end

        // Test 2: push_front
        test_count++;
        q.push_front(5);
        if (q[0] == 5) begin
            $display("Test 2: push_front PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL q[0]=%0d", q[0]);
        end

        // Test 3: pop_back
        test_count++;
        val = q.pop_back();
        if (val == 20) begin
            $display("Test 3: pop_back PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL val=%0d", val);
        end

        // Test 4: pop_front
        test_count++;
        val = q.pop_front();
        if (val == 5) begin
            $display("Test 4: pop_front PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL val=%0d", val);
        end

        // Test 5: insert
        test_count++;
        q.push_back(30);
        q.insert(1, 25);
        if (q[1] == 25) begin
            $display("Test 5: insert PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL q[1]=%0d", q[1]);
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
