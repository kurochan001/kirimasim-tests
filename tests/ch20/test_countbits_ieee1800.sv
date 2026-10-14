/*
:name: test_countbits_ieee1800
:description: Test for $countbits IEEE 1800-2023 §20.9
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_countbits_ieee1800.expected
*/
// Test for $countbits IEEE 1800-2023 §20.9
// $countbits(expression, control_bit, ...)

`timescale 1ns/1ps

module test_countbits_ieee1800;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] test_vec;
    logic [7:0] test_xz;
    int result;

    initial begin
        $display("=== $countbits IEEE 1800-2023 §20.9 Test ===");
        $display("");

        // Test 1: $countbits with '1 (count ones)
        $display("--- Test 1: $countbits(8'b10110100, '1) ---");
        test_vec = 8'b10110100;
        result = $countbits(test_vec, 1'b1);
        $display("  Result: %0d (expected: 4)", result);
        if (result == 4) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 2: $countbits with '0 (count zeros)
        $display("");
        $display("--- Test 2: $countbits(8'b10110100, '0) ---");
        result = $countbits(test_vec, 1'b0);
        $display("  Result: %0d (expected: 4)", result);
        if (result == 4) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 3: $countbits with 'x (count X bits)
        $display("");
        $display("--- Test 3: $countbits with X bits ---");
        test_xz = 8'b10xx_zz01;
        result = $countbits(test_xz, 1'bx);
        $display("  Input: 8'b10xx_zz01");
        $display("  Result: %0d (expected: 2)", result);
        if (result == 2) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 4: $countbits with 'z (count Z bits)
        $display("");
        $display("--- Test 4: $countbits with Z bits ---");
        result = $countbits(test_xz, 1'bz);
        $display("  Input: 8'b10xx_zz01");
        $display("  Result: %0d (expected: 2)", result);
        if (result == 2) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 5: $countones (should be equivalent to $countbits(x, '1))
        $display("");
        $display("--- Test 5: $countones vs $countbits ---");
        test_vec = 8'b11110000;
        result = $countones(test_vec);
        $display("  $countones(8'b11110000) = %0d", result);
        if (result == 4) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 6: Multiple control bits - count both 0s and 1s
        // $countbits(expr, '0, '1) should count both 0s and 1s
        $display("");
        $display("--- Test 6: $countbits(8'b10xx_zz01, '0, '1) ---");
        test_xz = 8'b10xx_zz01;
        result = $countbits(test_xz, 1'b0, 1'b1);
        $display("  Input: 8'b10xx_zz01 (2 ones, 2 zeros, 2 X, 2 Z)");
        $display("  Result: %0d (expected: 4 = 2 ones + 2 zeros)", result);
        if (result == 4) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 7: Count all bit types
        $display("");
        $display("--- Test 7: $countbits(8'b10xx_zz01, '0, '1, 'x, 'z) ---");
        result = $countbits(test_xz, 1'b0, 1'b1, 1'bx, 1'bz);
        $display("  Input: 8'b10xx_zz01");
        $display("  Result: %0d (expected: 8 = all bits)", result);
        if (result == 8) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Test 8: Count only X and Z
        $display("");
        $display("--- Test 8: $countbits(8'b10xx_zz01, 'x, 'z) ---");
        result = $countbits(test_xz, 1'bx, 1'bz);
        $display("  Input: 8'b10xx_zz01");
        $display("  Result: %0d (expected: 4 = 2 X + 2 Z)", result);
        if (result == 4) begin
            $display("  PASS");
            pass_count++;
        end else begin
            $display("  FAIL");
            fail_count++;
        end

        // Summary
        $display("");
        $display("=== Summary ===");
        $display("  PASS: %0d", pass_count);
        $display("  FAIL: %0d", fail_count);

        if (fail_count == 0) begin
            $display("");
            $display("TEST PASSED");
        end else begin
            $display("");
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
