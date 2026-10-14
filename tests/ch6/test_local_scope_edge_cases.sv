/*
:name: test_local_scope_edge_cases
:description: Test: Local scope edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_scope_edge_cases.expected
*/
// Test: Local scope edge cases
// IEEE 1800-2023 Section 6.21 Scope and lifetime
// Tests corner cases: local variable scoping

`timescale 1ns/1ps

module test_local_scope_edge_cases;
    int passed = 0;
    int failed = 0;

    int global_x = 100;

    initial begin
        $display("TEST: Local scope edge cases");

        // Test 1: Local shadows global
        begin
            static int global_x = 50;
            if (global_x == 50) begin
                $display("  [PASS] Local shadows global");
                passed++;
            end else begin
                $display("  [FAIL] Shadow: %0d", global_x);
                failed++;
            end
        end

        // Test 2: Nested scopes
        begin
            static int a = 1;
            begin
                static int b = 2;
                if (a == 1 && b == 2) begin
                    $display("  [PASS] Nested scopes");
                    passed++;
                end else begin
                    $display("  [FAIL] Nested: %0d %0d", a, b);
                    failed++;
                end
            end
        end

        // Test 3: Loop variable scope
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) sum += i;
            if (sum == 10) begin
                $display("  [PASS] Loop variable scope");
                passed++;
            end else begin
                $display("  [FAIL] LoopVar: %0d", sum);
                failed++;
            end
        end

        // Test 4: Multiple same-name in sequence
        begin
            begin
                static int val = 10;
                if (val == 10) begin
                    $display("  [PASS] Block 1 local");
                    passed++;
                end else begin
                    $display("  [FAIL] Block1: %0d", val);
                    failed++;
                end
            end
            begin
                static int val = 20;
                if (val == 20) begin
                    $display("  [PASS] Block 2 local");
                    passed++;
                end else begin
                    $display("  [FAIL] Block2: %0d", val);
                    failed++;
                end
            end
        end

        // Test 5: Sequential local scopes independent
        begin
            int result1, result2;
            begin
                static int local_val = 111;
                result1 = local_val;
            end
            begin
                static int local_val = 222;
                result2 = local_val;
            end
            if (result1 == 111 && result2 == 222) begin
                $display("  [PASS] Sequential local scopes");
                passed++;
            end else begin
                $display("  [FAIL] Sequential: %0d %0d", result1, result2);
                failed++;
            end
        end

        // Test 6: Local initialization
        begin
            static int x = 42;
            if (x == 42) begin
                $display("  [PASS] Local initialization");
                passed++;
            end else begin
                $display("  [FAIL] Init: %0d", x);
                failed++;
            end
        end

        // Test 7: Multiple locals in one scope
        begin
            static int a = 1;
            static int b = 2;
            static int c = 3;
            if (a + b + c == 6) begin
                $display("  [PASS] Multiple locals");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", a + b + c);
                failed++;
            end
        end

        // Test 8: Local with assignment
        begin
            int val;
            val = 55;
            if (val == 55) begin
                $display("  [PASS] Local assignment");
                passed++;
            end else begin
                $display("  [FAIL] Assign: %0d", val);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        $finish;
        end
    end
endmodule
