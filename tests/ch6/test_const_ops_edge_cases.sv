/*
:name: test_const_ops_edge_cases
:description: Test: Const operations edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.6 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_const_ops_edge_cases.expected
*/
// Test: Const operations edge cases
// IEEE 1800-2023 Section 6.20.5 Constants
// Tests corner cases: const declarations and operations

`timescale 1ns/1ps

module test_const_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        const static int CONST_INT = 42;
        const static string CONST_STR = "constant";
        const static logic [7:0] CONST_BYTE = 8'hFF;

        $display("TEST: Const operations edge cases");

        // Test 1: Const int value
        begin
            if (CONST_INT == 42) begin
                $display("  [PASS] Const int value");
                passed++;
            end else begin
                $display("  [FAIL] ConstInt: %0d", CONST_INT);
                failed++;
            end
        end

        // Test 2: Const string value
        begin
            if (CONST_STR == "constant") begin
                $display("  [PASS] Const string value");
                passed++;
            end else begin
                $display("  [FAIL] ConstStr: %s", CONST_STR);
                failed++;
            end
        end

        // Test 3: Const byte value
        begin
            if (CONST_BYTE == 8'hFF) begin
                $display("  [PASS] Const byte value");
                passed++;
            end else begin
                $display("  [FAIL] ConstByte: %0h", CONST_BYTE);
                failed++;
            end
        end

        // Test 4: Const in expression
        begin
            static int x;
            // Assigned here so the result does not depend on the order of static initializers.
            x = CONST_INT * 2;
            if (x == 84) begin
                $display("  [PASS] Const in expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", x);
                failed++;
            end
        end

        // Test 5: Const comparison
        begin
            if (CONST_INT > 40) begin
                $display("  [PASS] Const comparison");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 6: Const byte operations
        begin
            static logic [7:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = CONST_BYTE & 8'h0F;
            if (result == 8'h0F) begin
                $display("  [PASS] Const byte operations");
                passed++;
            end else begin
                $display("  [FAIL] ByteOp: %0h", result);
                failed++;
            end
        end

        // Test 7: Multiple consts
        begin
            const static int A = 10;
            const static int B = 20;
            if (A + B == 30) begin
                $display("  [PASS] Multiple consts");
                passed++;
            end else begin
                $display("  [FAIL] MultiConst");
                failed++;
            end
        end

        // Test 8: Const in condition
        begin
            if (CONST_INT == 42) begin
                $display("  [PASS] Const in condition");
                passed++;
            end else begin
                $display("  [FAIL] CondConst");
                failed++;
            end
        end

        // Test 9: Nested scope const
        begin
            const static int LOCAL = 99;
            begin
                if (LOCAL == 99) begin
                    $display("  [PASS] Nested scope const");
                    passed++;
                end else begin
                    $display("  [FAIL] Nested");
                    failed++;
                end
            end
        end

        // Test 10: Const string length
        begin
            if (CONST_STR.len() == 8) begin
                $display("  [PASS] Const string length");
                passed++;
            end else begin
                $display("  [FAIL] StrLen: %0d", CONST_STR.len());
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
