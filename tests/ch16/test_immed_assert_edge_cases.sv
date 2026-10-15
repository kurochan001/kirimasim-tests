/*
:name: test_immed_assert_edge_cases
:description: Test: Immediate assertion edge cases
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immed_assert_edge_cases.expected
*/
// Test: Immediate assertion edge cases
// IEEE 1800-2023 Section 16.3 Immediate Assertions
// Tests corner cases: immediate assertions

`timescale 1ns/1ps

module test_immed_assert_edge_cases;
    int passed = 0;
    int failed = 0;

    int value;
    logic [7:0] data;
    logic flag;

    initial begin
        $display("TEST: Immediate assertion edge cases");

        // Test 1: Assert constant true
        begin
            assert (1) else $error("True failed");
            $display("  [PASS] Assert constant true");
            passed++;
        end

        // Test 2: Assert variable condition
        begin
            value = 10;
            assert (value > 0) else $error("Value not positive");
            $display("  [PASS] Assert variable condition");
            passed++;
        end

        // Test 3: Assert equality
        begin
            data = 8'hAB;
            assert (data == 8'hAB) else $error("Data mismatch");
            $display("  [PASS] Assert equality");
            passed++;
        end

        // Test 4: Assert inequality
        begin
            value = 5;
            assert (value != 0) else $error("Value is zero");
            $display("  [PASS] Assert inequality");
            passed++;
        end

        // Test 5: Assert comparison
        begin
            value = 100;
            assert (value >= 50 && value <= 150) else $error("Out of range");
            $display("  [PASS] Assert comparison");
            passed++;
        end

        // Test 6: Assert logical AND
        begin
            static int a = 1, b = 1;
            assert (a && b) else $error("AND failed");
            $display("  [PASS] Assert logical AND");
            passed++;
        end

        // Test 7: Assert logical OR
        begin
            static int a = 1, b = 0;
            assert (a || b) else $error("OR failed");
            $display("  [PASS] Assert logical OR");
            passed++;
        end

        // Test 8: Assert negation
        begin
            flag = 0;
            assert (!flag) else $error("Negation failed");
            $display("  [PASS] Assert negation");
            passed++;
        end

        // Test 9: Assert complex expression
        begin
            static int x = 10, y = 20;
            assert ((x + y) == 30) else $error("Sum mismatch");
            $display("  [PASS] Assert complex expression");
            passed++;
        end

        // Test 10: Assert bit operations
        begin
            data = 8'b10101010;
            assert ((data & 8'h0F) == 8'h0A) else $error("Bit op failed");
            $display("  [PASS] Assert bit operations");
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
    end
endmodule
