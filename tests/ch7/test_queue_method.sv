/*
:name: test_queue_method
:description: Queue Method Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_method.expected
*/
// IEEE 1800-2023 Section 7.10 - Queue Method Tests
module test_queue_method;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int q[$];
        int val;

        $display("=== IEEE 1800-2023 Queue Method Tests ===");

        $display("Test 1: Empty queue");
        if (q.size() == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", q.size()); fail_count++; end

        $display("Test 2: Push back");
        q.push_back(10);
        q.push_back(20);
        q.push_back(30);
        if (q.size() == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", q.size()); fail_count++; end

        $display("Test 3: Front");
        if (q[0] == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", q[0]); fail_count++; end

        $display("Test 4: Back");
        if (q[$] == 30) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", q[$]); fail_count++; end

        $display("Test 5: Pop front");
        val = q.pop_front();
        if (val == 10 && q.size() == 2) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: val=%0d, size=%0d", val, q.size()); fail_count++; end

        $display("Test 6: Pop back");
        val = q.pop_back();
        if (val == 30 && q.size() == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: val=%0d, size=%0d", val, q.size()); fail_count++; end

        $display("Test 7: Remaining element");
        if (q[0] == 20) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", q[0]); fail_count++; end

        $display("Test 8: Delete all");
        q.delete();
        if (q.size() == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", q.size()); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
