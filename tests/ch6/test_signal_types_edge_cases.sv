/*
:name: test_signal_types_edge_cases
:description: logic, bit, integer and int variables and assignments between them
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signal_types_edge_cases.expected
*/
// logic, bit, integer and int variables and assignments between them
// IEEE 1800-2023 Section 6 Data Types
// Tests corner cases: logic, bit, integer types

`timescale 1ns/1ps

module test_signal_types_edge_cases;
    int passed = 0;
    int failed = 0;

    // Different signal types
    logic [7:0] logic_sig;
    bit [7:0] bit_sig;
    logic single_bit;
    bit single_bit2;
    integer int_sig;
    int int_val;

    initial begin
        $display("TEST: Signal types edge cases");

        // Test 1: Logic type assignment
        begin
            logic_sig = 8'hAB;
            if (logic_sig == 8'hAB) begin
                $display("  [PASS] Logic type");
                passed++;
            end else begin
                $display("  [FAIL] Logic: %h", logic_sig);
                failed++;
            end
        end

        // Test 2: Bit type assignment
        begin
            bit_sig = 8'hCD;
            if (bit_sig == 8'hCD) begin
                $display("  [PASS] Bit type");
                passed++;
            end else begin
                $display("  [FAIL] Bit: %h", bit_sig);
                failed++;
            end
        end

        // Test 3: Single bit logic
        begin
            single_bit = 1;
            if (single_bit == 1) begin
                $display("  [PASS] Single bit logic");
                passed++;
            end else begin
                $display("  [FAIL] Single: %b", single_bit);
                failed++;
            end
        end

        // Test 4: Single bit type
        begin
            single_bit2 = 0;
            if (single_bit2 == 0) begin
                $display("  [PASS] Single bit type");
                passed++;
            end else begin
                $display("  [FAIL] Single2: %b", single_bit2);
                failed++;
            end
        end

        // Test 5: Integer type
        begin
            int_sig = 32'h12345678;
            if (int_sig == 32'h12345678) begin
                $display("  [PASS] Integer type");
                passed++;
            end else begin
                $display("  [FAIL] Int: %h", int_sig);
                failed++;
            end
        end

        // Test 6: Int type
        begin
            int_val = 100;
            if (int_val == 100) begin
                $display("  [PASS] Int type");
                passed++;
            end else begin
                $display("  [FAIL] IntVal: %0d", int_val);
                failed++;
            end
        end

        // Test 7: Type conversion logic to bit
        begin
            logic_sig = 8'hFF;
            bit_sig = logic_sig;
            if (bit_sig == 8'hFF) begin
                $display("  [PASS] Logic to bit");
                passed++;
            end else begin
                $display("  [FAIL] L2B: %h", bit_sig);
                failed++;
            end
        end

        // Test 8: Type conversion bit to logic
        begin
            bit_sig = 8'h55;
            logic_sig = bit_sig;
            if (logic_sig == 8'h55) begin
                $display("  [PASS] Bit to logic");
                passed++;
            end else begin
                $display("  [FAIL] B2L: %h", logic_sig);
                failed++;
            end
        end

        // Test 9: Negative integer
        begin
            int_val = -50;
            if (int_val == -50) begin
                $display("  [PASS] Negative integer");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", int_val);
                failed++;
            end
        end

        // Test 10: Logic max value
        begin
            logic_sig = 8'hFF;
            if (logic_sig == 8'hFF) begin
                $display("  [PASS] Logic max value");
                passed++;
            end else begin
                $display("  [FAIL] Max: %h", logic_sig);
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
