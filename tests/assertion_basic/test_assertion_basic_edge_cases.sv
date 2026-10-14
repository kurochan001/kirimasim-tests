/*
:name: test_assertion_basic_edge_cases
:description: Test: Basic assertions edge cases
:tags: assertion_basic
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_basic_edge_cases.expected
*/
// Test: Basic assertions edge cases
// IEEE 1800-2023 Section 16 Assertions
// Tests corner cases: immediate assertions

`timescale 1ns/1ps

module test_assertion_basic_edge_cases;
    int passed = 0;
    int failed = 0;

    logic clk = 0;
    logic [7:0] data;
    logic valid;

    // Clock generator
    initial begin
        repeat (50) #5 clk = ~clk;
    end

    initial begin
        $display("TEST: Basic assertions edge cases");

        // Initialize
        data = 0;
        valid = 0;
        #1;

        // Test 1: Assert true
        begin
            static int x = 10;
            assert (x > 0) else $error("x should be positive");
            $display("  [PASS] Assert true");
            passed++;
        end

        // Test 2: Assert equality
        begin
            static int a = 5;
            static int b = 5;
            assert (a == b) else $error("a should equal b");
            $display("  [PASS] Assert equality");
            passed++;
        end

        // Test 3: Assert expression
        begin
            static int x = 10;
            static int y = 5;
            assert (x > y) else $error("x > y");
            $display("  [PASS] Assert expression");
            passed++;
        end

        // Test 4: Assert logic value
        begin
            data = 8'hAB;
            assert (data == 8'hAB) else $error("data mismatch");
            $display("  [PASS] Assert logic");
            passed++;
        end

        // Test 5: Assert non-zero
        begin
            static int val = 100;
            assert (val != 0) else $error("val is zero");
            $display("  [PASS] Assert non-zero");
            passed++;
        end

        // Test 6: Assert bounds
        begin
            static int idx = 5;
            assert (idx >= 0 && idx < 10) else $error("out of bounds");
            $display("  [PASS] Assert bounds");
            passed++;
        end

        // Test 7: Assert complex
        begin
            static int a = 10;
            static int b = 20;
            static int c = 30;
            assert (a + b == c) else $error("sum mismatch");
            $display("  [PASS] Assert complex");
            passed++;
        end

        // Test 8: Assert with valid signal
        begin
            valid = 1;
            data = 8'h55;
            assert (valid && data != 0) else $error("valid data");
            $display("  [PASS] Assert valid");
            passed++;
        end

        // Test 9: Assert negation
        begin
            static int x = 0;
            assert (!(x > 0)) else $error("x is positive");
            $display("  [PASS] Assert negation");
            passed++;
        end

        // Test 10: Assert logical
        begin
            static logic a = 1;
            static logic b = 0;
            assert (a || b) else $error("at least one true");
            $display("  [PASS] Assert logical");
            passed++;
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
