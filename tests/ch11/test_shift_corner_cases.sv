/*
:name: test_shift_corner_cases
:description: Logical and arithmetic shifts by 0, by the width and more, and by a negative amount
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_corner_cases.expected
*/
// IEEE 1800-2023 §11.4.10: Shift operator corner cases
// Tests for <<, >>, <<<, >>> with edge values

module test_shift_corner_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, result;
    logic signed [7:0] sa, sresult;
    logic [31:0] wide;

    initial begin
        // Test 1: Left shift by 0
        test_count++;
        a = 8'hAB;
        result = a << 0;
        if (result == 8'hAB) begin
            pass_count++;
            $display("Test 1 PASS: AB << 0 = %h", result);
        end else begin
            $display("Test 1 FAIL: result = %h", result);
        end

        // Test 2: Right shift by 0
        test_count++;
        a = 8'hAB;
        result = a >> 0;
        if (result == 8'hAB) begin
            pass_count++;
            $display("Test 2 PASS: AB >> 0 = %h", result);
        end else begin
            $display("Test 2 FAIL: result = %h", result);
        end

        // Test 3: Left shift by width
        test_count++;
        a = 8'hAB;
        result = a << 8;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 3 PASS: AB << 8 = %h", result);
        end else begin
            $display("Test 3 FAIL: result = %h", result);
        end

        // Test 4: Right shift by width
        test_count++;
        a = 8'hAB;
        result = a >> 8;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 4 PASS: AB >> 8 = %h", result);
        end else begin
            $display("Test 4 FAIL: result = %h", result);
        end

        // Test 5: Left shift overflow
        test_count++;
        a = 8'hFF;
        result = a << 4;
        if (result == 8'hF0) begin
            pass_count++;
            $display("Test 5 PASS: FF << 4 = %h", result);
        end else begin
            $display("Test 5 FAIL: result = %h", result);
        end

        // Test 6: Right shift of all ones
        test_count++;
        a = 8'hFF;
        result = a >> 4;
        if (result == 8'h0F) begin
            pass_count++;
            $display("Test 6 PASS: FF >> 4 = %h", result);
        end else begin
            $display("Test 6 FAIL: result = %h", result);
        end

        // Test 7: Arithmetic right shift of positive
        test_count++;
        sa = 8'h40;  // +64
        sresult = sa >>> 2;
        if (sresult == 8'h10) begin  // +16
            pass_count++;
            $display("Test 7 PASS: +64 >>> 2 = %h", sresult);
        end else begin
            $display("Test 7 FAIL: result = %h", sresult);
        end

        // Test 8: Arithmetic right shift of negative
        test_count++;
        sa = 8'h80;  // -128
        sresult = sa >>> 2;
        if (sresult == 8'hE0) begin  // Sign extended
            pass_count++;
            $display("Test 8 PASS: -128 >>> 2 = %h (sign extended)", sresult);
        end else begin
            $display("Test 8 FAIL: Arithmetic shift wrong = %h", sresult);
        end

        // Test 9: Arithmetic left shift
        test_count++;
        sa = 8'hF0;  // -16
        sresult = sa <<< 2;
        if (sresult == 8'hC0) begin
            pass_count++;
            $display("Test 9 PASS: F0 <<< 2 = %h", sresult);
        end else begin
            $display("Test 9 FAIL: result = %h", sresult);
        end

        // Test 10: Shift amount larger than width
        test_count++;
        a = 8'hFF;
        result = a << 16;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 10 PASS: FF << 16 = %h", result);
        end else begin
            $display("Test 10 FAIL: Large shift wrong = %h", result);
        end

        // Test 11: Shift by 1
        test_count++;
        a = 8'h01;
        result = a << 1;
        if (result == 8'h02) begin
            pass_count++;
            $display("Test 11 PASS: 01 << 1 = %h", result);
        end else begin
            $display("Test 11 FAIL: result = %h", result);
        end

        // Test 12: Shift high bit out
        test_count++;
        a = 8'h80;
        result = a << 1;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 12 PASS: 80 << 1 = %h", result);
        end else begin
            $display("Test 12 FAIL: result = %h", result);
        end

        // Test 13: Chained shifts
        test_count++;
        a = 8'hFF;
        result = (a << 4) >> 4;
        if (result == 8'h0F) begin
            pass_count++;
            $display("Test 13 PASS: (FF<<4)>>4 = %h", result);
        end else begin
            $display("Test 13 FAIL: Chained shifts wrong = %h", result);
        end

        // Test 14: Wide value shift
        test_count++;
        wide = 32'h12345678;
        wide = wide << 16;
        if (wide == 32'h56780000) begin
            pass_count++;
            $display("Test 14 PASS: 32-bit << 16 = %h", wide);
        end else begin
            $display("Test 14 FAIL: result = %h", wide);
        end

        // Test 15: Variable shift amount
        test_count++;
        a = 8'h80;
        begin
            static int shift_amt = 3;
            result = a >> shift_amt;
            if (result == 8'h10) begin
                pass_count++;
                $display("Test 15 PASS: Variable shift = %h", result);
            end else begin
                $display("Test 15 FAIL: result = %h", result);
            end
        end

        // Test 16: Zero shifted
        test_count++;
        a = 8'h00;
        result = a << 4;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 16 PASS: 00 << 4 = %h", result);
        end else begin
            $display("Test 16 FAIL: result = %h", result);
        end

        // Test 17: Single bit shift
        test_count++;
        begin
            static logic [0:0] single = 1'b1;
            static logic [0:0] sr;
            // Assigned here so the result does not depend on the order of static initializers.
            sr = single >> 1;
            if (sr == 1'b0) begin
                pass_count++;
                $display("Test 17 PASS: Single bit >> 1 = %b", sr);
            end else begin
                $display("Test 17 FAIL: result = %b", sr);
            end
        end

        // Test 18: Negative shift amount (unsigned interpretation)
        test_count++;
        a = 8'hAB;
        begin
            static int neg = -1;
            // The right operand of a shift is always unsigned (11.4.10), so -1
            // is a shift by 2**32-1 and every bit is shifted out.
            result = a << neg;
            if (result == 8'h00) begin
                pass_count++;
                $display("Test 18 PASS: Shift by -1 as unsigned = %h", result);
            end else begin
                $display("Test 18 FAIL: result = %h", result);
            end
        end

        // Test 19: Shift with expression
        test_count++;
        a = 8'h01;
        result = a << (2 + 1);
        if (result == 8'h08) begin
            pass_count++;
            $display("Test 19 PASS: 01 << (2+1) = %h", result);
        end else begin
            $display("Test 19 FAIL: result = %h", result);
        end

        // Test 20: Power of 2 via shift
        test_count++;
        result = 8'h01 << 7;
        if (result == 8'h80) begin
            pass_count++;
            $display("Test 20 PASS: 1 << 7 = %h", result);
        end else begin
            $display("Test 20 FAIL: result = %h", result);
        end

        $display("=== Shift Corner Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
