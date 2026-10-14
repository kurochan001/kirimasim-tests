/*
:name: test_incr_decr
:description: Increment Decrement Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_incr_decr.expected
*/
// IEEE 1800-2023 Section 11.4.2 - Increment Decrement Tests
module test_incr_decr;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int val;

        $display("=== IEEE 1800-2023 Increment Decrement Tests ===");

        // Test 1: Pre-increment
        $display("Test 1: Pre-inc");
        val = 10;
        ++val;
        if (val == 11) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", val); fail_count++; end

        // Test 2: Post-increment
        $display("Test 2: Post-inc");
        val = 20;
        val++;
        if (val == 21) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", val); fail_count++; end

        // Test 3: Pre-decrement
        $display("Test 3: Pre-dec");
        val = 30;
        --val;
        if (val == 29) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", val); fail_count++; end

        // Test 4: Post-decrement
        $display("Test 4: Post-dec");
        val = 40;
        val--;
        if (val == 39) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", val); fail_count++; end

        // Test 5: Multiple increments
        $display("Test 5: Multi inc");
        val = 0;
        val++;
        val++;
        val++;
        if (val == 3) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", val); fail_count++; end

        // Test 6: Inc from negative
        $display("Test 6: Inc neg");
        val = -5;
        val++;
        if (val == -4) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", val); fail_count++; end

        // Test 7: Dec to negative
        $display("Test 7: Dec to neg");
        val = 1;
        val--;
        val--;
        if (val == -1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", val); fail_count++; end

        // Test 8: Zero inc
        $display("Test 8: Zero inc");
        val = 0;
        val++;
        if (val == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
