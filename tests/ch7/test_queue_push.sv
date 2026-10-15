/*
:name: test_queue_push
:description: Queue Push/Pop Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_push.expected
*/
// IEEE 1800-2023 Section 7.10 - Queue Push/Pop Tests
module test_queue_push;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int q[$];
        int val;

        $display("=== IEEE 1800-2023 Queue Push/Pop Tests ===");

        // Test 1: Push back
        $display("Test 1: Push back");
        q.push_back(10);
        if (q.size() == 1 && q[0] == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Push front
        $display("Test 2: Push front");
        q.push_front(5);
        if (q.size() == 2 && q[0] == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Pop front
        $display("Test 3: Pop front");
        val = q.pop_front();
        if (val == 5 && q.size() == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", val); fail_count++; end

        // Test 4: Pop back
        $display("Test 4: Pop back");
        val = q.pop_back();
        if (val == 10 && q.size() == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", val); fail_count++; end

        // Test 5: Multiple push
        $display("Test 5: Multiple");
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);
        if (q.size() == 3) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", q.size()); fail_count++; end

        // Test 6: Order check
        $display("Test 6: Order");
        if (q[0] == 1 && q[1] == 2 && q[2] == 3) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Delete
        $display("Test 7: Delete");
        q.delete();
        if (q.size() == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", q.size()); fail_count++; end

        // Test 8: Re-add
        $display("Test 8: Re-add");
        q.push_back(100);
        if (q.size() == 1 && q[0] == 100) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
