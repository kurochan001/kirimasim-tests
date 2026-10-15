/*
:name: test_scope_resolution_edge_cases
:description: Module, block and nested block variables, and a name hidden by an inner block
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_resolution_edge_cases.expected
*/
// Module, block and nested block variables, and a name hidden by an inner block
// IEEE 1800-2023 Section 6.21 Scope and Name Resolution
// Tests corner cases: local, block, hierarchical scope

`timescale 1ns/1ps

module test_scope_resolution_edge_cases;
    int passed = 0;
    int failed = 0;

    // Module level variables
    int module_var = 100;
    localparam int MODULE_PARAM = 42;

    initial begin
        $display("TEST: Scope resolution edge cases");

        // Test 1: Module level variable
        begin
            if (module_var == 100) begin
                $display("  [PASS] Module level variable");
                passed++;
            end else begin
                $display("  [FAIL] Module var: %0d", module_var);
                failed++;
            end
        end

        // Test 2: Block local variable
        begin
            static int local_var = 200;
            if (local_var == 200) begin
                $display("  [PASS] Block local variable");
                passed++;
            end else begin
                $display("  [FAIL] Local: %0d", local_var);
                failed++;
            end
        end

        // Test 3: Nested block scope
        begin
            static int outer = 10;
            begin
                static int inner = 20;
                if (outer == 10 && inner == 20) begin
                    $display("  [PASS] Nested block scope");
                    passed++;
                end else begin
                    $display("  [FAIL] Nested");
                    failed++;
                end
            end
        end

        // Test 4: Shadow variable
        begin
            static int shadow = 50;
            begin
                static int shadow = 100;
                if (shadow == 100) begin
                    $display("  [PASS] Shadow variable");
                    passed++;
                end else begin
                    $display("  [FAIL] Shadow: %0d", shadow);
                    failed++;
                end
            end
        end

        // Test 5: Module parameter access
        begin
            if (MODULE_PARAM == 42) begin
                $display("  [PASS] Module parameter");
                passed++;
            end else begin
                $display("  [FAIL] Param: %0d", MODULE_PARAM);
                failed++;
            end
        end

        // Test 6: Loop variable scope
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) begin
                sum += i;
            end
            if (sum == 10) begin
                $display("  [PASS] Loop variable scope");
                passed++;
            end else begin
                $display("  [FAIL] Loop: %0d", sum);
                failed++;
            end
        end

        // Test 7: Multiple local variables
        begin
            static int a = 1;
            static int b = 2;
            static int c = 3;
            if (a + b + c == 6) begin
                $display("  [PASS] Multiple locals");
                passed++;
            end else begin
                $display("  [FAIL] Multiple");
                failed++;
            end
        end

        // Test 8: Variable reuse in different blocks
        begin
            static int temp = 10;
            if (temp == 10) begin
                temp = 20;
            end
            if (temp == 20) begin
                $display("  [PASS] Variable reuse");
                passed++;
            end else begin
                $display("  [FAIL] Reuse: %0d", temp);
                failed++;
            end
        end

        // Test 9: Modify module variable
        begin
            module_var = 500;
            if (module_var == 500) begin
                $display("  [PASS] Modify module variable");
                passed++;
            end else begin
                $display("  [FAIL] Modify: %0d", module_var);
                failed++;
            end
        end

        // Test 10: Deep nesting
        begin
            static int level0 = 0;
            begin
                static int level1 = 1;
                begin
                    static int level2 = 2;
                    begin
                        static int level3 = 3;
                        if (level0 + level1 + level2 + level3 == 6) begin
                            $display("  [PASS] Deep nesting");
                            passed++;
                        end else begin
                            $display("  [FAIL] Deep");
                            failed++;
                        end
                    end
                end
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
