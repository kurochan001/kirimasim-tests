/*
:name: test_while_loop_forms
:description: While loops with various conditions and nesting (IEEE 1800-2023 Section 12.7.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_while_loop_forms.expected
*/
// IEEE 1800-2023 Section 12.7.4 - While Loop Tests
module test_while_loop_forms;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, sum;

        $display("=== IEEE 1800-2023 While Loop Alternative Tests ===");

        // Test 1: While sum
        $display("Test 1: While sum");
        i = 0; sum = 0;
        while (i < 5) begin sum = sum + i; i++; end
        if (sum == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", sum); fail_count++; end

        // Test 2: Count to 10
        $display("Test 2: Count to 10");
        i = 0;
        while (i < 10) i++;
        if (i == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", i); fail_count++; end

        // Test 3: Find threshold
        $display("Test 3: Threshold");
        i = 0;
        while (i * i < 50) i++;
        if (i == 8) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", i); fail_count++; end

        // Test 4: Accumulate
        $display("Test 4: Accumulate");
        i = 1; sum = 0;
        while (i <= 5) begin sum = sum + i; i++; end
        if (sum == 15) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        // Test 5: Power series
        $display("Test 5: Power");
        i = 1; sum = 0;
        while (i <= 64) begin sum = sum + i; i = i * 2; end
        if (sum == 127) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", sum); fail_count++; end

        // Test 6: Zero iterations
        $display("Test 6: Zero iter");
        sum = 100;
        while (0) sum = 0;
        if (sum == 100) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", sum); fail_count++; end

        // Test 7: Multiple conditions
        $display("Test 7: Multi cond");
        i = 0; sum = 0;
        while ((i < 10) && (sum < 20)) begin sum = sum + i; i++; end
        if (sum == 21) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", sum); fail_count++; end

        // Test 8: Nested while
        $display("Test 8: Nested");
        i = 0; sum = 0;
        while (i < 3) begin
            int j;
            j = 0;
            while (j < 3) begin sum++; j++; end
            i++;
        end
        if (sum == 9) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
