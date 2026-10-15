/*
:name: test_loop_break
:description: Loop Break Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_break.expected
*/
// IEEE 1800-2023 Section 12.8 - Loop Break Tests
module test_loop_break;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, count, sum;

        $display("=== IEEE 1800-2023 Loop Break Tests ===");

        // Test 1: Basic break
        $display("Test 1: Basic break");
        count = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 5) break;
            count++;
        end
        if (count == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", count); fail_count++; end

        // Test 2: While break
        $display("Test 2: While break");
        i = 0;
        count = 0;
        while (i < 100) begin
            if (i == 3) break;
            count++;
            i++;
        end
        if (count == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", count); fail_count++; end

        // Test 3: No break
        $display("Test 3: No break");
        count = 0;
        for (i = 0; i < 4; i++) begin
            count++;
        end
        if (count == 4) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", count); fail_count++; end

        // Test 4: Break at start
        $display("Test 4: Break start");
        count = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 0) break;
            count++;
        end
        if (count == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", count); fail_count++; end

        // Test 5: Sum with break
        $display("Test 5: Sum break");
        sum = 0;
        for (i = 1; i <= 10; i++) begin
            sum = sum + i;
            if (sum > 10) break;
        end
        if (sum == 15) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", sum); fail_count++; end

        // Test 6: Value at break
        $display("Test 6: Value break");
        for (i = 0; i < 100; i++) begin
            if (i == 7) break;
        end
        if (i == 7) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", i); fail_count++; end

        // Test 7: Repeat break
        $display("Test 7: Repeat break");
        count = 0;
        repeat (100) begin
            if (count == 6) break;
            count++;
        end
        if (count == 6) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", count); fail_count++; end

        // Test 8: Final sum
        $display("Test 8: Final sum");
        sum = 0;
        for (i = 0; i < 100; i++) begin
            sum = sum + 1;
            if (sum == 8) break;
        end
        if (sum == 8) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
