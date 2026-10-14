/*
:name: test_int_literal_edge_cases
:description: Test: Integer literal edge cases
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_int_literal_edge_cases.expected
*/
// Test: Integer literal edge cases
// IEEE 1800-2023 Section 5.7 Numbers
// Tests corner cases: integer literals

`timescale 1ns/1ps

module test_int_literal_edge_cases;
    int passed = 0;
    int failed = 0;

    int val;
    logic [31:0] lval;

    initial begin
        $display("TEST: Integer literal edge cases");

        // Test 1: Decimal literal
        begin
            val = 12345;
            if (val == 12345) begin
                $display("  [PASS] Decimal literal");
                passed++;
            end else begin
                $display("  [FAIL] Dec: %0d", val);
                failed++;
            end
        end

        // Test 2: Hex literal
        begin
            lval = 32'hABCD1234;
            if (lval == 32'hABCD1234) begin
                $display("  [PASS] Hex literal");
                passed++;
            end else begin
                $display("  [FAIL] Hex: %h", lval);
                failed++;
            end
        end

        // Test 3: Binary literal
        begin
            lval = 32'b10101010;
            if (lval == 8'hAA) begin
                $display("  [PASS] Binary literal");
                passed++;
            end else begin
                $display("  [FAIL] Bin: %b", lval);
                failed++;
            end
        end

        // Test 4: Octal literal
        begin
            lval = 32'o77;
            if (lval == 63) begin
                $display("  [PASS] Octal literal");
                passed++;
            end else begin
                $display("  [FAIL] Oct: %0d", lval);
                failed++;
            end
        end

        // Test 5: Zero value
        begin
            val = 0;
            lval = 32'h0;
            if (val == 0 && lval == 0) begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero");
                failed++;
            end
        end

        // Test 6: Negative value
        begin
            val = -100;
            if (val == -100) begin
                $display("  [PASS] Negative value");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", val);
                failed++;
            end
        end

        // Test 7: Size prefix
        begin
            lval = 8'd255;
            if (lval == 255) begin
                $display("  [PASS] Size prefix");
                passed++;
            end else begin
                $display("  [FAIL] Size: %0d", lval);
                failed++;
            end
        end

        // Test 8: Underscore separator
        begin
            val = 1_000_000;
            if (val == 1000000) begin
                $display("  [PASS] Underscore separator");
                passed++;
            end else begin
                $display("  [FAIL] Under: %0d", val);
                failed++;
            end
        end

        // Test 9: Large value
        begin
            lval = 32'hFFFFFFFF;
            if (lval == 32'hFFFFFFFF) begin
                $display("  [PASS] Large value");
                passed++;
            end else begin
                $display("  [FAIL] Large: %h", lval);
                failed++;
            end
        end

        // Test 10: Mixed base comparison
        begin
            if (16 == 32'h10 && 16 == 32'o20 && 16 == 32'b10000) begin
                $display("  [PASS] Mixed base comparison");
                passed++;
            end else begin
                $display("  [FAIL] MixedBase");
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
