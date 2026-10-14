/*
:name: test_for_loop_2
:description: For Loop Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_2.expected
*/
// IEEE 1800-2023 Section 12.7.1 - For Loop Tests
module test_for_loop;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, sum;

        $display("=== IEEE 1800-2023 For Loop Tests ===");

        // Test 1: Simple for
        $display("Test 1: Simple for");
        sum = 0;
        for (i = 0; i < 5; i++) sum = sum + i;
        if (sum == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", sum); fail_count++; end

        // Test 2: For with step 2
        $display("Test 2: Step 2");
        sum = 0;
        for (i = 0; i < 10; i = i + 2) sum = sum + 1;
        if (sum == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", sum); fail_count++; end

        // Test 3: Reverse for
        $display("Test 3: Reverse");
        sum = 0;
        for (i = 5; i > 0; i--) sum = sum + i;
        if (sum == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", sum); fail_count++; end

        // Test 4: Zero iterations
        $display("Test 4: Zero iter");
        sum = 100;
        for (i = 0; i < 0; i++) sum = 0;
        if (sum == 100) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", sum); fail_count++; end

        // Test 5: Single iteration
        $display("Test 5: Single iter");
        sum = 0;
        for (i = 0; i < 1; i++) sum = 10;
        if (sum == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", sum); fail_count++; end

        // Test 6: Accumulate multiply
        $display("Test 6: Multiply");
        sum = 1;
        for (i = 1; i <= 4; i++) sum = sum * i;
        if (sum == 24) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", sum); fail_count++; end

        // Test 7: Nested for
        $display("Test 7: Nested");
        sum = 0;
        for (i = 0; i < 3; i++) begin
            int j;
            for (j = 0; j < 3; j++) sum = sum + 1;
        end
        if (sum == 9) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", sum); fail_count++; end

        // Test 8: Large count
        $display("Test 8: Large count");
        sum = 0;
        for (i = 0; i < 100; i++) sum = sum + 1;
        if (sum == 100) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
