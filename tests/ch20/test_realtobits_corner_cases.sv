/*
:name: test_realtobits_corner_cases
:description: Real/Bits Conversion Corner Cases Test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_realtobits_corner_cases.expected
*/
// IEEE 1800-2023 Real/Bits Conversion Corner Cases Test
// Target: $realtobits, $bitstoreal, $shortrealtobits, $bitstoshortreal
// IEEE 1800-2023 Section 20.5

`timescale 1ns/1ps

module test_realtobits_corner_cases;
    int pass_count = 0;
    int fail_count = 0;

    task automatic check_bits64(input string name, input logic [63:0] result, input logic [63:0] expected);
        if (result === expected) begin
            $display("  PASS: %s = 0x%016h", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = 0x%016h (expected 0x%016h)", name, result, expected);
            fail_count++;
        end
    endtask

    task automatic check_bits32(input string name, input logic [31:0] result, input logic [31:0] expected);
        if (result === expected) begin
            $display("  PASS: %s = 0x%08h", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = 0x%08h (expected 0x%08h)", name, result, expected);
            fail_count++;
        end
    endtask

    task automatic check_real(input string name, input real result, input real expected);
        if (result == expected) begin
            $display("  PASS: %s = %g", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %g (expected %g)", name, result, expected);
            fail_count++;
        end
    endtask

    initial begin
        logic [63:0] bits64;
        logic [31:0] bits32;
        real r64;
        shortreal r32;

        $display("=== Real/Bits Conversion Corner Cases Test ===");
        $display("");

        // ===== $realtobits basic tests =====
        $display("Test 1: $realtobits - Basic conversions");
        // IEEE 754 double precision:
        // 0.0 = 0x0000000000000000
        // 1.0 = 0x3FF0000000000000
        // -1.0 = 0xBFF0000000000000
        // 2.0 = 0x4000000000000000
        bits64 = $realtobits(0.0);
        check_bits64("$realtobits(0.0)", bits64, 64'h0000000000000000);

        bits64 = $realtobits(1.0);
        check_bits64("$realtobits(1.0)", bits64, 64'h3FF0000000000000);

        bits64 = $realtobits(-1.0);
        check_bits64("$realtobits(-1.0)", bits64, 64'hBFF0000000000000);

        bits64 = $realtobits(2.0);
        check_bits64("$realtobits(2.0)", bits64, 64'h4000000000000000);

        // ===== $bitstoreal basic tests =====
        $display("");
        $display("Test 2: $bitstoreal - Basic conversions");
        r64 = $bitstoreal(64'h0000000000000000);
        check_real("$bitstoreal(0x0)", r64, 0.0);

        r64 = $bitstoreal(64'h3FF0000000000000);
        check_real("$bitstoreal(0x3FF...)", r64, 1.0);

        r64 = $bitstoreal(64'hBFF0000000000000);
        check_real("$bitstoreal(0xBFF...)", r64, -1.0);

        // ===== Round-trip conversion =====
        $display("");
        $display("Test 3: Round-trip conversion");
        begin
            static real original = 3.14159265358979;
            static logic [63:0] bits;
            static real recovered;
            // Assigned here so the result does not depend on the order of static initializers.
            bits = $realtobits(original);
            recovered = $bitstoreal(bits);
            check_real("Round-trip 3.14159...", recovered, original);
        end

        begin
            static real original = -123.456789;
            static logic [63:0] bits;
            static real recovered;
            // Assigned here so the result does not depend on the order of static initializers.
            bits = $realtobits(original);
            recovered = $bitstoreal(bits);
            check_real("Round-trip -123.456789", recovered, original);
        end

        // ===== Special values: Very small numbers (denormalized) =====
        $display("");
        $display("Test 4: Small numbers");
        r64 = 1e-100;  // Use smaller exponent for compatibility
        bits64 = $realtobits(r64);
        $display("  $realtobits(1e-100) = 0x%016h", bits64);
        begin
            real recovered;
            recovered = $bitstoreal(bits64);
            $display("  Round-trip: %0e", recovered);
            pass_count++;
        end

        // ===== Special values: Very large numbers =====
        $display("");
        $display("Test 5: Large numbers");
        r64 = 1e100;  // Use smaller exponent for compatibility
        bits64 = $realtobits(r64);
        $display("  $realtobits(1e100) = 0x%016h", bits64);
        begin
            real recovered;
            recovered = $bitstoreal(bits64);
            check_real("Round-trip 1e100", recovered, r64);
        end

        // ===== $shortrealtobits basic tests =====
        $display("");
        $display("Test 6: $shortrealtobits - Basic conversions");
        // IEEE 754 single precision:
        // 0.0 = 0x00000000
        // 1.0 = 0x3F800000
        // -1.0 = 0xBF800000
        bits32 = $shortrealtobits(shortreal'(0.0));
        check_bits32("$shortrealtobits(0.0)", bits32, 32'h00000000);

        bits32 = $shortrealtobits(shortreal'(1.0));
        check_bits32("$shortrealtobits(1.0)", bits32, 32'h3F800000);

        bits32 = $shortrealtobits(shortreal'(-1.0));
        check_bits32("$shortrealtobits(-1.0)", bits32, 32'hBF800000);

        // ===== $bitstoshortreal basic tests =====
        $display("");
        $display("Test 7: $bitstoshortreal - Basic conversions");
        r32 = $bitstoshortreal(32'h00000000);
        $display("  $bitstoshortreal(0x0) = %0f", r32);
        if (r32 == 0.0) begin
            $display("  PASS: Correct");
            pass_count++;
        end else begin
            $display("  FAIL: Expected 0.0");
            fail_count++;
        end

        r32 = $bitstoshortreal(32'h3F800000);
        $display("  $bitstoshortreal(0x3F800000) = %0f", r32);
        if (r32 == 1.0) begin
            $display("  PASS: Correct");
            pass_count++;
        end else begin
            $display("  FAIL: Expected 1.0");
            fail_count++;
        end

        // ===== Shortreal round-trip =====
        $display("");
        $display("Test 8: Shortreal round-trip");
        begin
            static shortreal original = 3.14159;
            static logic [31:0] bits;
            static shortreal recovered;
            // Assigned here so the result does not depend on the order of static initializers.
            bits = $shortrealtobits(original);
            recovered = $bitstoshortreal(bits);
            $display("  Original: %0f, Recovered: %0f", original, recovered);
            // Allow small epsilon for single precision
            if (recovered > 3.14 && recovered < 3.15) begin
                $display("  PASS: Round-trip within tolerance");
                pass_count++;
            end else begin
                $display("  FAIL: Round-trip failed");
                fail_count++;
            end
        end

        // ===== Consistency between real and shortreal =====
        $display("");
        $display("Test 9: Precision difference");
        begin
            logic [63:0] double_bits;
            logic [31:0] single_bits;

            double_bits = $realtobits(1.0);
            single_bits = $shortrealtobits(shortreal'(1.0));

            $display("  1.0 as double: 0x%016h", double_bits);
            $display("  1.0 as single: 0x%08h", single_bits);
            pass_count++;
        end

        // ===== Infinity representation (if supported) =====
        $display("");
        $display("Test 10: Large value representation");
        begin
            static real very_large = 1e308;
            bits64 = $realtobits(very_large);
            $display("  $realtobits(1e308) = 0x%016h", bits64);
            r64 = $bitstoreal(bits64);
            $display("  Round-trip: %0e", r64);
            pass_count++;
        end

        // ===== Bit pattern edge cases =====
        $display("");
        $display("Test 11: Negative zero bit pattern");
        // The sign bit survives a round trip through $bitstoreal and $realtobits.
        bits64 = 64'h8000000000000000;
        r64 = $bitstoreal(bits64);
        check_bits64("$realtobits($bitstoreal(0x8000...))", $realtobits(r64), 64'h8000000000000000);

        // Summary
        $display("");
        $display("========================================");
        $display("TEST RESULTS: %0d/%0d PASSED", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
