/*
:name: test_param_basic_edge_cases
:description: Untyped, typed and string parameters used in expressions and a range
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_basic_edge_cases.expected
*/
// Untyped, typed and string parameters used in expressions and a range
// IEEE 1800-2023 Section 6.20 Parameters
// Tests corner cases: parameter declarations

`timescale 1ns/1ps

module test_param_basic_edge_cases;
    int passed = 0;
    int failed = 0;

    parameter WIDTH = 8;
    parameter DEPTH = 16;
    parameter string NAME = "test";
    parameter int MAX_VAL = 100;
    parameter logic [7:0] INIT_VAL = 8'hAA;

    initial begin
        int w;
        $display("TEST: Parameter basic edge cases");

        // Test 1: Integer parameter
        begin
            if (WIDTH == 8) begin
                $display("  [PASS] Integer parameter");
                passed++;
            end else begin
                $display("  [FAIL] Width: %0d", WIDTH);
                failed++;
            end
        end

        // Test 2: Second parameter
        begin
            if (DEPTH == 16) begin
                $display("  [PASS] Second parameter");
                passed++;
            end else begin
                $display("  [FAIL] Depth: %0d", DEPTH);
                failed++;
            end
        end

        // Test 3: String parameter
        begin
            if (NAME == "test") begin
                $display("  [PASS] String parameter");
                passed++;
            end else begin
                $display("  [FAIL] Name: %s", NAME);
                failed++;
            end
        end

        // Test 4: Typed parameter
        begin
            if (MAX_VAL == 100) begin
                $display("  [PASS] Typed parameter");
                passed++;
            end else begin
                $display("  [FAIL] MaxVal: %0d", MAX_VAL);
                failed++;
            end
        end

        // Test 5: Logic parameter
        begin
            if (INIT_VAL == 8'hAA) begin
                $display("  [PASS] Logic parameter");
                passed++;
            end else begin
                $display("  [FAIL] InitVal: %0h", INIT_VAL);
                failed++;
            end
        end

        // Test 6: Parameter in expression
        begin
            w = WIDTH * 2;
            if (w == 16) begin
                $display("  [PASS] Parameter in expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", w);
                failed++;
            end
        end

        // Test 7: Parameter arithmetic
        begin
            if (WIDTH + DEPTH == 24) begin
                $display("  [PASS] Parameter arithmetic");
                passed++;
            end else begin
                $display("  [FAIL] Arith: %0d", WIDTH + DEPTH);
                failed++;
            end
        end

        // Test 8: Parameter multiply
        begin
            if (WIDTH * DEPTH == 128) begin
                $display("  [PASS] Parameter multiply");
                passed++;
            end else begin
                $display("  [FAIL] Mul: %0d", WIDTH * DEPTH);
                failed++;
            end
        end

        // Test 9: Parameter comparison
        begin
            if (WIDTH < DEPTH) begin
                $display("  [PASS] Parameter comparison");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 10: Parameter in array size
        begin
            logic [WIDTH-1:0] arr;
            arr = 8'hFF;
            if (arr == 8'hFF) begin
                $display("  [PASS] Parameter in array size");
                passed++;
            end else begin
                $display("  [FAIL] ArrSize: %0h", arr);
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
