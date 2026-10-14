/*
:name: test_local_var_edge_cases_2
:description: Test: Local variable edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_var_edge_cases_2.expected
*/
// Test: Local variable edge cases
// IEEE 1800-2023 Section 6.21 Scope and lifetime
// Tests corner cases: local variables

`timescale 1ns/1ps

module test_local_var_edge_cases;
    int passed = 0;
    int failed = 0;

    int module_var = 100;

    initial begin
        $display("TEST: Local variable edge cases");

        // Test 1: Simple local var
        begin
            static int local_var = 42;
            if (local_var == 42) begin
                $display("  [PASS] Simple local var");
                passed++;
            end else begin
                $display("  [FAIL] Simple: %0d", local_var);
                failed++;
            end
        end

        // Test 2: Module var access
        begin
            if (module_var == 100) begin
                $display("  [PASS] Module var access");
                passed++;
            end else begin
                $display("  [FAIL] ModVar: %0d", module_var);
                failed++;
            end
        end

        // Test 3: Local different from module
        begin
            static int x = 50;
            if (x == 50 && module_var == 100) begin
                $display("  [PASS] Local different from module");
                passed++;
            end else begin
                $display("  [FAIL] Diff: x=%0d mod=%0d", x, module_var);
                failed++;
            end
        end

        // Test 4: Local var modification
        begin
            static int local_var = 10;
            local_var = local_var + 5;
            if (local_var == 15) begin
                $display("  [PASS] Local var modification");
                passed++;
            end else begin
                $display("  [FAIL] Modify: %0d", local_var);
                failed++;
            end
        end

        // Test 5: Multiple local vars
        begin
            static int a = 1;
            static int b = 2;
            static int c = 3;
            if (a + b + c == 6) begin
                $display("  [PASS] Multiple local vars");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", a + b + c);
                failed++;
            end
        end

        // Test 6: Nested scope
        begin
            static int outer = 10;
            begin
                static int inner = 20;
                if (outer + inner == 30) begin
                    $display("  [PASS] Nested scope");
                    passed++;
                end else begin
                    $display("  [FAIL] Nested: %0d", outer + inner);
                    failed++;
                end
            end
        end

        // Test 7: Loop variable
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) begin
                sum = sum + i;
            end
            if (sum == 10) begin
                $display("  [PASS] Loop variable");
                passed++;
            end else begin
                $display("  [FAIL] Loop: %0d", sum);
                failed++;
            end
        end

        // Test 8: Local array
        begin
            int arr[3];
            arr[0] = 1;
            arr[1] = 2;
            arr[2] = 3;
            if (arr[0] + arr[1] + arr[2] == 6) begin
                $display("  [PASS] Local array");
                passed++;
            end else begin
                $display("  [FAIL] Array");
                failed++;
            end
        end

        // Test 9: Local var in conditional
        begin
            static int result = 0;
            if (1) begin
                static int cond_var = 50;
                result = cond_var;
            end
            if (result == 50) begin
                $display("  [PASS] Local var in conditional");
                passed++;
            end else begin
                $display("  [FAIL] Cond: %0d", result);
                failed++;
            end
        end

        // Test 10: Initialized local vars
        begin
            static int a = 10;
            static int b;
            static int c;
            // Assigned here so the result does not depend on the order of static initializers.
            b = a + 5;
            c = b * 2;
            if (c == 30) begin
                $display("  [PASS] Initialized local vars");
                passed++;
            end else begin
                $display("  [FAIL] Init: %0d", c);
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
        end
    end
endmodule
