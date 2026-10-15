/*
:name: test_loop_continue
:description: Continue Statement Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_continue.expected
*/
// IEEE 1800-2023 Section 12.8 - Continue Statement Tests
module test_loop_continue;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, count, sum;

        $display("=== IEEE 1800-2023 Continue Statement Tests ===");

        $display("Test 1: Skip even");
        sum = 0;
        for (i = 1; i <= 10; i++) begin
            if (i % 2 == 0) continue;
            sum = sum + i;
        end
        if (sum == 25) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", sum); fail_count++; end

        $display("Test 2: Skip odd");
        sum = 0;
        for (i = 1; i <= 10; i++) begin
            if (i % 2 == 1) continue;
            sum = sum + i;
        end
        if (sum == 30) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", sum); fail_count++; end

        $display("Test 3: Skip specific");
        sum = 0;
        for (i = 1; i <= 5; i++) begin
            if (i == 3) continue;
            sum = sum + i;
        end
        if (sum == 12) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", sum); fail_count++; end

        $display("Test 4: No continue");
        sum = 0;
        for (i = 1; i <= 4; i++) begin
            sum = sum + i;
        end
        if (sum == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        $display("Test 5: Count skips");
        count = 0;
        for (i = 0; i < 10; i++) begin
            if (i < 5) continue;
            count++;
        end
        if (count == 5) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", count); fail_count++; end

        $display("Test 6: Skip none");
        count = 0;
        for (i = 0; i < 5; i++) begin
            count++;
        end
        if (count == 5) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", count); fail_count++; end

        $display("Test 7: Skip all but one");
        count = 0;
        for (i = 0; i < 5; i++) begin
            if (i != 2) continue;
            count++;
        end
        if (count == 1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", count); fail_count++; end

        $display("Test 8: While continue");
        sum = 0;
        i = 0;
        while (i < 10) begin
            i++;
            if (i > 5) continue;
            sum = sum + i;
        end
        if (sum == 15) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
