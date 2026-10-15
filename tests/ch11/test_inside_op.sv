/*
:name: test_inside_op
:description: Inside Operator Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_op.expected
*/
// IEEE 1800-2023 Section 11.4.13 - Inside Operator Tests
module test_inside_op;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int val;
        logic result;

        $display("=== IEEE 1800-2023 Inside Operator Tests ===");

        // Test 1: In set
        $display("Test 1: In set");
        val = 5;
        result = val inside {1, 3, 5, 7, 9};
        if (result == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Not in set
        $display("Test 2: Not in set");
        val = 4;
        result = val inside {1, 3, 5, 7, 9};
        if (result == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: In range
        $display("Test 3: In range");
        val = 50;
        result = val inside {[10:100]};
        if (result == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Below range
        $display("Test 4: Below range");
        val = 5;
        result = val inside {[10:100]};
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Above range
        $display("Test 5: Above range");
        val = 150;
        result = val inside {[10:100]};
        if (result == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Range boundary low
        $display("Test 6: Range low");
        val = 10;
        result = val inside {[10:20]};
        if (result == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Range boundary high
        $display("Test 7: Range high");
        val = 20;
        result = val inside {[10:20]};
        if (result == 1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Mixed set and range
        $display("Test 8: Mixed");
        val = 15;
        result = val inside {1, 2, [10:20], 99};
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
