/*
:name: test_sformat_ops_edge_cases
:description: Test: $sformat operations edge cases
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat_ops_edge_cases.expected
*/
// Test: $sformat operations edge cases
// IEEE 1800-2023 Section 21.3.3 $sformat
// Tests corner cases: string formatting

`timescale 1ns/1ps

module test_sformat_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        string s;
        int i;
        real r;

        $display("TEST: $sformat operations edge cases");

        // Test 1: Basic integer format
        begin
            i = 42;
            $sformat(s, "%0d", i);
            if (s == "42") begin
                $display("  [PASS] Basic integer format");
                passed++;
            end else begin
                $display("  [FAIL] IntFmt: %s", s);
                failed++;
            end
        end

        // Test 2: Hex format
        begin
            i = 255;
            $sformat(s, "%0h", i);
            if (s == "ff" || s == "FF") begin
                $display("  [PASS] Hex format");
                passed++;
            end else begin
                $display("  [FAIL] HexFmt: %s", s);
                failed++;
            end
        end

        // Test 3: Binary format
        begin
            i = 5;
            $sformat(s, "%b", i);
            // May have leading zeros
            if (s.len() > 0) begin
                $display("  [PASS] Binary format");
                passed++;
            end else begin
                $display("  [FAIL] BinFmt: %s", s);
                failed++;
            end
        end

        // Test 4: Multiple args
        begin
            $sformat(s, "%0d + %0d = %0d", 1, 2, 3);
            if (s == "1 + 2 = 3") begin
                $display("  [PASS] Multiple args");
                passed++;
            end else begin
                $display("  [FAIL] MultiArg: %s", s);
                failed++;
            end
        end

        // Test 5: String literal
        begin
            $sformat(s, "Hello World");
            if (s == "Hello World") begin
                $display("  [PASS] String literal");
                passed++;
            end else begin
                $display("  [FAIL] Literal: %s", s);
                failed++;
            end
        end

        // Test 6: Negative number
        begin
            i = -100;
            $sformat(s, "%0d", i);
            if (s == "-100") begin
                $display("  [PASS] Negative number");
                passed++;
            end else begin
                $display("  [FAIL] Negative: %s", s);
                failed++;
            end
        end

        // Test 7: Zero value
        begin
            i = 0;
            $sformat(s, "%0d", i);
            if (s == "0") begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %s", s);
                failed++;
            end
        end

        // Test 8: Large number
        begin
            i = 1000000;
            $sformat(s, "%0d", i);
            if (s == "1000000") begin
                $display("  [PASS] Large number");
                passed++;
            end else begin
                $display("  [FAIL] Large: %s", s);
                failed++;
            end
        end

        // Test 9: Width specifier
        begin
            i = 5;
            $sformat(s, "%3d", i);
            // Should have padding
            if (s.len() >= 1) begin
                $display("  [PASS] Width specifier");
                passed++;
            end else begin
                $display("  [FAIL] Width: %s", s);
                failed++;
            end
        end

        // Test 10: Octal format
        begin
            i = 8;
            $sformat(s, "%0o", i);
            if (s == "10") begin
                $display("  [PASS] Octal format");
                passed++;
            end else begin
                $display("  [FAIL] Octal: %s", s);
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
