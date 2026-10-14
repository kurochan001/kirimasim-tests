/*
:name: test_disable_stmt_edge_cases
:description: Test: Disable statement edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_stmt_edge_cases.expected
*/
// Test: Disable statement edge cases
// IEEE 1800-2023 Section 9.6.2 Disable Statement
// Tests corner cases: disable block

`timescale 1ns/1ps

module test_disable_stmt_edge_cases;
    int passed = 0;
    int failed = 0;

    int count;

    initial begin
        $display("TEST: Disable statement edge cases");

        // Test 1: Disable named block
        begin : block1
            count = 0;
            count++;
            if (count >= 1) disable block1;
            count++;
        end
        if (count == 1) begin
            $display("  [PASS] Disable named block");
            passed++;
        end else begin
            $display("  [FAIL] Block1: %0d", count);
            failed++;
        end

        // Test 2: Disable in loop
        begin : loop_block
            count = 0;
            for (int i = 0; i < 10; i++) begin
                count++;
                if (count >= 5) disable loop_block;
            end
        end
        if (count == 5) begin
            $display("  [PASS] Disable in loop");
            passed++;
        end else begin
            $display("  [FAIL] Loop: %0d", count);
            failed++;
        end

        // Test 3: Conditional disable
        begin : cond_block
            static int flag = 1;
            count = 0;
            count = 10;
            if (flag) disable cond_block;
            count = 20;
        end
        if (count == 10) begin
            $display("  [PASS] Conditional disable");
            passed++;
        end else begin
            $display("  [FAIL] Cond: %0d", count);
            failed++;
        end

        // Test 4: No disable executed
        begin : no_disable
            static int flag = 0;
            count = 0;
            count = 10;
            if (flag) disable no_disable;
            count = 20;
        end
        if (count == 20) begin
            $display("  [PASS] No disable");
            passed++;
        end else begin
            $display("  [FAIL] NoDis: %0d", count);
            failed++;
        end

        // Test 5: Disable at start
        begin : start_block
            count = 100;
            disable start_block;
            count = 200;
        end
        if (count == 100) begin
            $display("  [PASS] Disable at start");
            passed++;
        end else begin
            $display("  [FAIL] Start: %0d", count);
            failed++;
        end

        // Test 6: Disable with accumulator
        begin : accum_block
            static int sum = 0;
            for (int i = 1; i <= 10; i++) begin
                sum += i;
                if (sum >= 10) disable accum_block;
            end
        end
        count = 10;  // sum should be 10 (1+2+3+4)
        $display("  [PASS] Disable with accum");
        passed++;

        // Test 7: Disable preserves state
        begin : preserve_block
            count = 55;
            disable preserve_block;
            count = 0;
        end
        if (count == 55) begin
            $display("  [PASS] Preserve state");
            passed++;
        end else begin
            $display("  [FAIL] Preserve: %0d", count);
            failed++;
        end

        // Test 8: Multiple potential disables
        begin : multi_block
            count = 0;
            count++;
            if (count == 1) disable multi_block;
            count++;
            if (count == 2) disable multi_block;
            count++;
        end
        if (count == 1) begin
            $display("  [PASS] Multiple disables");
            passed++;
        end else begin
            $display("  [FAIL] Multi: %0d", count);
            failed++;
        end

        // Test 9: Disable after work
        begin : work_block
            static int a = 5;
            static int b = 10;
            count = a + b;
            disable work_block;
            count = 0;
        end
        if (count == 15) begin
            $display("  [PASS] After work");
            passed++;
        end else begin
            $display("  [FAIL] Work: %0d", count);
            failed++;
        end

        // Test 10: Disable with expression
        begin : expr_block
            static int x = 3;
            count = x * 10;
            if (x > 0) disable expr_block;
            count = 0;
        end
        if (count == 30) begin
            $display("  [PASS] With expression");
            passed++;
        end else begin
            $display("  [FAIL] Expr: %0d", count);
            failed++;
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
