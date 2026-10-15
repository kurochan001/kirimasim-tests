/*
:name: test_bitwise_corner_cases
:description: Bitwise AND, OR, XOR and NOT, including x and z operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bitwise_corner_cases.expected
*/
// IEEE 1800-2023 §11.4: Bitwise operator corner cases
// Tests for AND, OR, XOR, NOT with X/Z values

module test_bitwise_corner_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b, result;
    logic [3:0] x_val, z_val, mixed;

    initial begin
        // Test 1: AND with all zeros
        test_count++;
        a = 8'hFF;
        b = 8'h00;
        result = a & b;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 1 PASS: FF & 00 = %h", result);
        end else begin
            $display("Test 1 FAIL: result = %h", result);
        end

        // Test 2: AND with all ones
        test_count++;
        a = 8'hFF;
        b = 8'hFF;
        result = a & b;
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 2 PASS: FF & FF = %h", result);
        end else begin
            $display("Test 2 FAIL: result = %h", result);
        end

        // Test 3: OR with all zeros
        test_count++;
        a = 8'h00;
        b = 8'h00;
        result = a | b;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 3 PASS: 00 | 00 = %h", result);
        end else begin
            $display("Test 3 FAIL: result = %h", result);
        end

        // Test 4: OR with mixed values
        test_count++;
        a = 8'hAA;
        b = 8'h55;
        result = a | b;
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 4 PASS: AA | 55 = %h", result);
        end else begin
            $display("Test 4 FAIL: result = %h", result);
        end

        // Test 5: XOR with same values
        test_count++;
        a = 8'hAB;
        b = 8'hAB;
        result = a ^ b;
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 5 PASS: AB ^ AB = %h", result);
        end else begin
            $display("Test 5 FAIL: result = %h", result);
        end

        // Test 6: XOR with complement
        test_count++;
        a = 8'hAA;
        b = 8'h55;
        result = a ^ b;
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 6 PASS: AA ^ 55 = %h", result);
        end else begin
            $display("Test 6 FAIL: result = %h", result);
        end

        // Test 7: NOT operation
        test_count++;
        a = 8'hAA;
        result = ~a;
        if (result == 8'h55) begin
            pass_count++;
            $display("Test 7 PASS: ~AA = %h", result);
        end else begin
            $display("Test 7 FAIL: result = %h", result);
        end

        // Test 8: NOT of zeros
        test_count++;
        a = 8'h00;
        result = ~a;
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 8 PASS: ~00 = %h", result);
        end else begin
            $display("Test 8 FAIL: result = %h", result);
        end

        // Test 9: AND with X (1 & X = X)
        test_count++;
        x_val = 4'b1111;
        mixed = 4'bxxxx;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = x_val & mixed;
            if (r === 4'bxxxx) begin
                pass_count++;
                $display("Test 9 PASS: 1 & X = X");
            end else begin
                $display("Test 9 FAIL: 1 & X wrong");
            end
        end

        // Test 10: AND with X (0 & X = 0)
        test_count++;
        x_val = 4'b0000;
        mixed = 4'bxxxx;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = x_val & mixed;
            if (r === 4'b0000) begin
                pass_count++;
                $display("Test 10 PASS: 0 & X = 0");
            end else begin
                $display("Test 10 FAIL: 0 & X wrong");
            end
        end

        // Test 11: OR with X (0 | X = X)
        test_count++;
        x_val = 4'b0000;
        mixed = 4'bxxxx;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = x_val | mixed;
            if (r === 4'bxxxx) begin
                pass_count++;
                $display("Test 11 PASS: 0 | X = X");
            end else begin
                $display("Test 11 FAIL: 0 | X unexpected");
            end
        end

        // Test 12: OR with X (1 | X = 1)
        test_count++;
        x_val = 4'b1111;
        mixed = 4'bxxxx;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = x_val | mixed;
            if (r === 4'b1111) begin
                pass_count++;
                $display("Test 12 PASS: 1 | X = 1");
            end else begin
                $display("Test 12 FAIL: 1 | X wrong");
            end
        end

        // Test 13: XOR with X
        test_count++;
        x_val = 4'b1010;
        mixed = 4'bxxxx;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = x_val ^ mixed;
            if (r === 4'bxxxx) begin
                pass_count++;
                $display("Test 13 PASS: value ^ X = X");
            end else begin
                $display("Test 13 FAIL: XOR with X unexpected");
            end
        end

        // Test 14: NOT of X
        test_count++;
        mixed = 4'bxxxx;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = ~mixed;
            if (r === 4'bxxxx) begin
                pass_count++;
                $display("Test 14 PASS: ~X = X");
            end else begin
                $display("Test 14 FAIL: NOT X unexpected");
            end
        end

        // Test 15: AND with Z
        test_count++;
        z_val = 4'bzzzz;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = 4'b1111 & z_val;
            // z behaves as x in a bitwise operation (11.4.8).
            if (r === 4'bxxxx) begin
                pass_count++;
                $display("Test 15 PASS: AND with Z = X");
            end else begin
                $display("Test 15 FAIL: AND with Z = %b", r);
            end
        end

        // Test 16: OR with Z
        test_count++;
        z_val = 4'bzzzz;
        begin
            static logic [3:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = 4'b0000 | z_val;
            // z behaves as x in a bitwise operation (11.4.8).
            if (r === 4'bxxxx) begin
                pass_count++;
                $display("Test 16 PASS: OR with Z = X");
            end else begin
                $display("Test 16 FAIL: OR with Z = %b", r);
            end
        end

        // Test 17: NAND operation
        test_count++;
        a = 8'hFF;
        b = 8'hFF;
        result = ~(a & b);
        if (result == 8'h00) begin
            pass_count++;
            $display("Test 17 PASS: NAND(FF,FF) = %h", result);
        end else begin
            $display("Test 17 FAIL: result = %h", result);
        end

        // Test 18: NOR operation
        test_count++;
        a = 8'h00;
        b = 8'h00;
        result = ~(a | b);
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 18 PASS: NOR(00,00) = %h", result);
        end else begin
            $display("Test 18 FAIL: result = %h", result);
        end

        // Test 19: XNOR operation
        test_count++;
        a = 8'hAA;
        b = 8'hAA;
        result = ~(a ^ b);
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 19 PASS: XNOR(AA,AA) = %h", result);
        end else begin
            $display("Test 19 FAIL: result = %h", result);
        end

        // Test 20: Chained operations
        test_count++;
        a = 8'hF0;
        b = 8'h0F;
        result = (a & 8'hAA) | (b & 8'h55);
        if (result == 8'hA5) begin
            pass_count++;
            $display("Test 20 PASS: Chained ops = %h", result);
        end else begin
            $display("Test 20 FAIL: result = %h", result);
        end

        $display("=== Bitwise Corner Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
