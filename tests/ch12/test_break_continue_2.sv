/*
:name: test_break_continue_2
:description: Break and Continue Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_continue_2.expected
*/
// IEEE 1800-2023 Section 12.8 - Break and Continue Tests
module test_break_continue;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, sum;

        $display("=== IEEE 1800-2023 Break Continue Tests ===");

        // Test 1: Break in for
        $display("Test 1: Break in for");
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i == 5) break;
            sum++;
        end
        if (sum == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", sum); fail_count++; end

        // Test 2: Continue in for
        $display("Test 2: Continue in for");
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;
            sum++;
        end
        if (sum == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", sum); fail_count++; end

        // Test 3: Break in while
        $display("Test 3: Break in while");
        i = 0; sum = 0;
        while (i < 100) begin
            if (sum >= 10) break;
            sum = sum + i;
            i++;
        end
        if (sum == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", sum); fail_count++; end

        // Test 4: Continue in while
        $display("Test 4: Continue in while");
        i = 0; sum = 0;
        while (i < 10) begin
            i++;
            if (i <= 5) continue;
            sum++;
        end
        if (sum == 5) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        // Test 5: Early break
        $display("Test 5: Early break");
        sum = 0;
        for (i = 0; i < 100; i++) begin
            break;
            sum = 100;
        end
        if (sum == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", sum); fail_count++; end

        // Test 6: Skip evens
        $display("Test 6: Skip evens");
        sum = 0;
        for (i = 1; i <= 10; i++) begin
            if (i % 2 == 0) continue;
            sum = sum + i;
        end
        if (sum == 25) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", sum); fail_count++; end

        // Test 7: Break first match
        $display("Test 7: First match");
        sum = -1;
        for (i = 0; i < 10; i++) begin
            if (i * i > 30) begin sum = i; break; end
        end
        if (sum == 6) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", sum); fail_count++; end

        // Test 8: Mixed break continue
        $display("Test 8: Mixed");
        sum = 0;
        for (i = 0; i < 20; i++) begin
            if (i % 3 == 0) continue;
            if (i > 10) break;
            sum++;
        end
        if (sum == 7) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
