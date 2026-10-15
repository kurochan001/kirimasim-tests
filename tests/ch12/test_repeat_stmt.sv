/*
:name: test_repeat_stmt
:description: Repeat Statement Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_repeat_stmt.expected
*/
// IEEE 1800-2023 Section 12.7.2 - Repeat Statement Tests
module test_repeat_stmt;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int count, sum;

        $display("=== IEEE 1800-2023 Repeat Statement Tests ===");

        // Test 1-8: Repeat tests
        $display("Test 1: Basic repeat");
        count = 0;
        repeat (5) count++;
        if (count == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", count); fail_count++; end

        $display("Test 2: Zero repeat");
        count = 10;
        repeat (0) count = 0;
        if (count == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", count); fail_count++; end

        $display("Test 3: One repeat");
        count = 0;
        repeat (1) count = 100;
        if (count == 100) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", count); fail_count++; end

        $display("Test 4: Sum");
        sum = 0;
        repeat (10) sum = sum + 1;
        if (sum == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        $display("Test 5: Large count");
        count = 0;
        repeat (100) count++;
        if (count == 100) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", count); fail_count++; end

        $display("Test 6: Multiply");
        sum = 1;
        repeat (4) sum = sum * 2;
        if (sum == 16) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", sum); fail_count++; end

        $display("Test 7: Decrement");
        count = 10;
        repeat (3) count--;
        if (count == 7) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", count); fail_count++; end

        $display("Test 8: Add diff");
        sum = 0;
        repeat (5) sum = sum + 2;
        if (sum == 10) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
