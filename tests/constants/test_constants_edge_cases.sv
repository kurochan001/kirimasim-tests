/*
:name: test_constants_edge_cases
:description: Test: Constants edge cases
:tags: constants
:type: simulation
:lrm: 1800-2023 5.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constants_edge_cases.expected
*/
// Test: Constants edge cases
// IEEE 1800-2023 Section 5.7 Numbers
// Tests corner cases: literals, parameters, constant expressions

`timescale 1ns/1ps

module test_constants_edge_cases;
    int passed = 0;
    int failed = 0;

    // Constant parameters
    localparam int CONST_INT = 100;
    localparam logic [7:0] CONST_LOGIC = 8'hAB;
    localparam real CONST_REAL = 3.14;
    localparam string CONST_STR = "hello";
    localparam int CONST_EXPR = 10 * 5 + 2;

    initial begin
        $display("TEST: Constants edge cases");

        // Test 1: Integer literal
        begin
            static int val = 42;
            if (val == 42) begin
                $display("  [PASS] Integer literal");
                passed++;
            end else begin
                $display("  [FAIL] Int lit: %0d", val);
                failed++;
            end
        end

        // Test 2: Hex literal
        begin
            static logic [7:0] val = 8'hFF;
            if (val == 255) begin
                $display("  [PASS] Hex literal");
                passed++;
            end else begin
                $display("  [FAIL] Hex: %h", val);
                failed++;
            end
        end

        // Test 3: Binary literal
        begin
            static logic [3:0] val = 4'b1010;
            if (val == 10) begin
                $display("  [PASS] Binary literal");
                passed++;
            end else begin
                $display("  [FAIL] Bin: %b", val);
                failed++;
            end
        end

        // Test 4: Octal literal
        begin
            static logic [8:0] val = 9'o777;
            if (val == 511) begin
                $display("  [PASS] Octal literal");
                passed++;
            end else begin
                $display("  [FAIL] Oct: %o", val);
                failed++;
            end
        end

        // Test 5: Localparam integer
        begin
            if (CONST_INT == 100) begin
                $display("  [PASS] Localparam integer");
                passed++;
            end else begin
                $display("  [FAIL] Param int: %0d", CONST_INT);
                failed++;
            end
        end

        // Test 6: Localparam logic
        begin
            if (CONST_LOGIC == 8'hAB) begin
                $display("  [PASS] Localparam logic");
                passed++;
            end else begin
                $display("  [FAIL] Param logic: %h", CONST_LOGIC);
                failed++;
            end
        end

        // Test 7: Constant expression
        begin
            if (CONST_EXPR == 52) begin
                $display("  [PASS] Constant expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", CONST_EXPR);
                failed++;
            end
        end

        // Test 8: Negative constant
        begin
            static int val = -50;
            if (val == -50) begin
                $display("  [PASS] Negative constant");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", val);
                failed++;
            end
        end

        // Test 9: Zero literal
        begin
            static int val = 0;
            if (val == 0) begin
                $display("  [PASS] Zero literal");
                passed++;
            end else begin
                $display("  [FAIL] Zero");
                failed++;
            end
        end

        // Test 10: Underscore in literal
        begin
            static int val = 1_000_000;
            if (val == 1000000) begin
                $display("  [PASS] Underscore literal");
                passed++;
            end else begin
                $display("  [FAIL] Underscore: %0d", val);
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
