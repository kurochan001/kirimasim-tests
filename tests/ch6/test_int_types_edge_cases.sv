/*
:name: test_int_types_edge_cases
:description: Test: Integer types edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 5.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_int_types_edge_cases.expected
*/
// Test: Integer types edge cases
// IEEE 1800-2023 Section 6.11 Integer data types
// Tests corner cases: byte, shortint, int, longint

`timescale 1ns/1ps

module test_int_types_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        byte b;
        shortint si;
        int i;
        longint li;

        $display("TEST: Integer types edge cases");

        // Test 1: Byte max positive
        begin
            b = 127;
            if (b == 127) begin
                $display("  [PASS] Byte max positive");
                passed++;
            end else begin
                $display("  [FAIL] ByteMax: %0d", b);
                failed++;
            end
        end

        // Test 2: Byte min negative
        begin
            b = -128;
            if (b == -128) begin
                $display("  [PASS] Byte min negative");
                passed++;
            end else begin
                $display("  [FAIL] ByteMin: %0d", b);
                failed++;
            end
        end

        // Test 3: Shortint max
        begin
            si = 32767;
            if (si == 32767) begin
                $display("  [PASS] Shortint max");
                passed++;
            end else begin
                $display("  [FAIL] ShortMax: %0d", si);
                failed++;
            end
        end

        // Test 4: Shortint min
        begin
            si = -32768;
            if (si == -32768) begin
                $display("  [PASS] Shortint min");
                passed++;
            end else begin
                $display("  [FAIL] ShortMin: %0d", si);
                failed++;
            end
        end

        // Test 5: Int max
        begin
            i = 2147483647;
            if (i == 2147483647) begin
                $display("  [PASS] Int max");
                passed++;
            end else begin
                $display("  [FAIL] IntMax: %0d", i);
                failed++;
            end
        end

        // Test 6: Int min
        begin
            i = -2147483648;
            if (i == -2147483648) begin
                $display("  [PASS] Int min");
                passed++;
            end else begin
                $display("  [FAIL] IntMin: %0d", i);
                failed++;
            end
        end

        // Test 7: Longint positive
        begin
            // An unsized decimal that needs more than 32 bits gets enough bits for
            // its value (5.7.1), so it matches the sized constant on the right.
            li = 1000000000000;
            if (li == 64'sd1000000000000) begin
                $display("  [PASS] Longint positive: %0d", li);
                passed++;
            end else begin
                $display("  [FAIL] LongPos: %0d", li);
                failed++;
            end
        end

        // Test 8: Longint negative
        begin
            li = -1000000000000;
            if (li == -64'sd1000000000000) begin
                $display("  [PASS] Longint negative: %0d", li);
                passed++;
            end else begin
                $display("  [FAIL] LongNeg: %0d", li);
                failed++;
            end
        end

        // Test 9: Type promotion byte to int
        begin
            b = 100;
            i = b;
            if (i == 100) begin
                $display("  [PASS] Type promotion byte to int");
                passed++;
            end else begin
                $display("  [FAIL] Promote: %0d", i);
                failed++;
            end
        end

        // Test 10: Type truncation int to byte
        begin
            i = 300;
            b = i;
            // Only the low 8 bits are kept: 300 is 9'h12C, so b is 8'h2C = 44
            if (b == 44) begin
                $display("  [PASS] Type truncation int to byte");
                passed++;
            end else begin
                $display("  [FAIL] Trunc: %0d", b);
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
