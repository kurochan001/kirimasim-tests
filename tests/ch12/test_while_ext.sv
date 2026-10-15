/*
:name: test_while_ext
:description: While Loop Extended Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_while_ext.expected
*/
// IEEE 1800-2023 Section 12.7.4 - While Loop Extended Tests
module test_while_ext;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, count, sum;

        $display("=== IEEE 1800-2023 While Loop Extended Tests ===");

        $display("Test 1: Basic while");
        i = 0;
        count = 0;
        while (i < 5) begin
            count++;
            i++;
        end
        if (count == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", count); fail_count++; end

        $display("Test 2: No execute");
        count = 0;
        i = 10;
        while (i < 5) begin
            count++;
        end
        if (count == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", count); fail_count++; end

        $display("Test 3: Sum loop");
        sum = 0;
        i = 1;
        while (i <= 5) begin
            sum = sum + i;
            i++;
        end
        if (sum == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", sum); fail_count++; end

        $display("Test 4: Countdown");
        count = 0;
        i = 3;
        while (i > 0) begin
            count++;
            i--;
        end
        if (count == 3) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", count); fail_count++; end

        $display("Test 5: Compound cond");
        sum = 0;
        i = 0;
        while (i < 10 && sum < 5) begin
            sum = sum + 1;
            i++;
        end
        if (sum == 5) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", sum); fail_count++; end

        $display("Test 6: Single iteration");
        count = 0;
        i = 0;
        while (i < 1) begin
            count++;
            i++;
        end
        if (count == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", count); fail_count++; end

        $display("Test 7: Break in while");
        count = 0;
        i = 0;
        while (i < 100) begin
            count++;
            if (i == 2) break;
            i++;
        end
        if (count == 3) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", count); fail_count++; end

        $display("Test 8: Final value");
        i = 0;
        while (i < 10) begin
            i = i + 2;
        end
        if (i == 10) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", i); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
