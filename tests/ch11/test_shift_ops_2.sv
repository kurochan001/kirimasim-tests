/*
:name: test_shift_ops_2
:description: Logical and arithmetic shifts, including a shift by a negative int
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_ops_2.expected
*/
// Logical and arithmetic shifts, including a shift by a negative int

module test_shift_ops;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    logic [7:0] va, vresult;
    logic [15:0] wa;
    logic [31:0] da;
    logic signed [7:0] sa;
    logic signed [31:0] sd;
    int shift_amt;

    initial begin
        // Test 1: Left shift by 1
        va = 8'h01;
        vresult = va << 1;
        if (vresult == 8'h02) begin
            $display("Test 1 PASSED: 0x01 << 1 = 0x02");
            pass_count++;
        end else $display("Test 1 FAILED: 0x01 << 1 = %h", vresult);

        // Test 2: Left shift by 4
        va = 8'h0F;
        vresult = va << 4;
        if (vresult == 8'hF0) begin
            $display("Test 2 PASSED: 0x0F << 4 = 0xF0");
            pass_count++;
        end else $display("Test 2 FAILED: 0x0F << 4 = %h", vresult);

        // Test 3: Right shift by 1
        va = 8'h80;
        vresult = va >> 1;
        if (vresult == 8'h40) begin
            $display("Test 3 PASSED: 0x80 >> 1 = 0x40");
            pass_count++;
        end else $display("Test 3 FAILED: 0x80 >> 1 = %h", vresult);

        // Test 4: Right shift by 4
        va = 8'hF0;
        vresult = va >> 4;
        if (vresult == 8'h0F) begin
            $display("Test 4 PASSED: 0xF0 >> 4 = 0x0F");
            pass_count++;
        end else $display("Test 4 FAILED: 0xF0 >> 4 = %h", vresult);

        // Test 5: Shift by 0 (identity)
        va = 8'hAB;
        vresult = va << 0;
        if (vresult == 8'hAB) begin
            $display("Test 5 PASSED: 0xAB << 0 = 0xAB");
            pass_count++;
        end else $display("Test 5 FAILED: 0xAB << 0 = %h", vresult);

        // Test 6: Left shift overflow
        va = 8'hFF;
        vresult = va << 4;
        if (vresult == 8'hF0) begin
            $display("Test 6 PASSED: 0xFF << 4 = 0xF0 (overflow)");
            pass_count++;
        end else $display("Test 6 FAILED: 0xFF << 4 = %h", vresult);

        // Test 7: Right shift to zero
        va = 8'h0F;
        vresult = va >> 8;
        if (vresult == 8'h00) begin
            $display("Test 7 PASSED: 0x0F >> 8 = 0x00");
            pass_count++;
        end else $display("Test 7 FAILED: 0x0F >> 8 = %h", vresult);

        // Test 8: Arithmetic left shift (signed)
        sa = 8'sh05;
        if ((sa <<< 2) == 8'sh14) begin
            $display("Test 8 PASSED: 5 <<< 2 = 20");
            pass_count++;
        end else $display("Test 8 FAILED: 5 <<< 2 = %0d", sa <<< 2);

        // Test 9: Arithmetic right shift - positive
        sa = 8'sh40;
        if ((sa >>> 2) == 8'sh10) begin
            $display("Test 9 PASSED: 64 >>> 2 = 16");
            pass_count++;
        end else $display("Test 9 FAILED: 64 >>> 2 = %0d", sa >>> 2);

        // Test 10: Arithmetic right shift - negative (sign extension)
        sa = 8'shF0;  // -16 in signed
        if ((sa >>> 2) == 8'shFC) begin
            $display("Test 10 PASSED: -16 >>> 2 = -4 (sign extended)");
            pass_count++;
        end else $display("Test 10 FAILED: -16 >>> 2 = %h", sa >>> 2);

        // Test 11: Logical right shift on signed (no sign extension)
        sa = 8'shF0;
        if ((sa >> 2) == 8'h3C) begin
            $display("Test 11 PASSED: 0xF0 >> 2 = 0x3C (logical)");
            pass_count++;
        end else $display("Test 11 FAILED: 0xF0 >> 2 = %h", sa >> 2);

        // Test 12: 16-bit left shift
        wa = 16'h00FF;
        if ((wa << 8) == 16'hFF00) begin
            $display("Test 12 PASSED: 0x00FF << 8 = 0xFF00");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: 32-bit left shift
        da = 32'h00000001;
        if ((da << 31) == 32'h80000000) begin
            $display("Test 13 PASSED: 1 << 31 = 0x80000000");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Variable shift amount
        va = 8'h01;
        shift_amt = 3;
        vresult = va << shift_amt;
        if (vresult == 8'h08) begin
            $display("Test 14 PASSED: 0x01 << 3 (variable) = 0x08");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Shift by full width
        va = 8'hFF;
        vresult = va << 8;
        if (vresult == 8'h00) begin
            $display("Test 15 PASSED: 0xFF << 8 = 0x00");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Chained shifts
        va = 8'h01;
        vresult = (va << 2) << 2;
        if (vresult == 8'h10) begin
            $display("Test 16 PASSED: (0x01 << 2) << 2 = 0x10");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Left then right shift
        va = 8'h0F;
        vresult = (va << 4) >> 4;
        if (vresult == 8'h0F) begin
            $display("Test 17 PASSED: (0x0F << 4) >> 4 = 0x0F");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: 32-bit arithmetic right shift negative
        sd = -64;
        if ((sd >>> 3) == -8) begin
            $display("Test 18 PASSED: -64 >>> 3 = -8");
            pass_count++;
        end else $display("Test 18 FAILED: -64 >>> 3 = %0d", sd >>> 3);

        // Test 19: Large shift on small value
        va = 8'h01;
        vresult = va << 7;
        if (vresult == 8'h80) begin
            $display("Test 19 PASSED: 0x01 << 7 = 0x80");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Alternating pattern shift
        va = 8'hAA;
        vresult = va >> 1;
        if (vresult == 8'h55) begin
            $display("Test 20 PASSED: 0xAA >> 1 = 0x55");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Multiply by power of 2 via shift
        da = 32'd100;
        if ((da << 3) == 32'd800) begin
            $display("Test 21 PASSED: 100 << 3 = 800 (multiply by 8)");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Divide by power of 2 via shift
        da = 32'd800;
        if ((da >> 3) == 32'd100) begin
            $display("Test 22 PASSED: 800 >> 3 = 100 (divide by 8)");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Shift with expression
        va = 8'h01;
        shift_amt = 2;
        vresult = va << (shift_amt + 1);
        if (vresult == 8'h08) begin
            $display("Test 23 PASSED: 0x01 << (2+1) = 0x08");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: The shift amount is always unsigned (11.4.10), so -1 is a
        // shift by 2**32-1 and every bit is shifted out.
        va = 8'hFF;
        shift_amt = -1;
        vresult = va << shift_amt;
        if (vresult == 8'h00) begin
            $display("Test 24 PASSED: 0xFF << -1 = 0x00 (amount is unsigned)");
            pass_count++;
        end else $display("Test 24 FAILED: 0xFF << -1 = %h", vresult);

        // Test 25: All bits set arithmetic right shift
        sd = -1;  // All bits 1
        if ((sd >>> 4) == -1) begin
            $display("Test 25 PASSED: -1 >>> 4 = -1 (all 1s preserved)");
            pass_count++;
        end else $display("Test 25 FAILED");

        $display("PASS: shift_ops (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
