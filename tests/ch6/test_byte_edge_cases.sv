/*
:name: test_byte_edge_cases
:description: Byte edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 11.4.3 11.4.8 6.24.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_byte_edge_cases.expected
*/
// IEEE 1800-2023 §6.11.2: Byte edge cases
// Tests for 2-state 8-bit signed byte type

module test_byte_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    byte b1, b2;
    byte unsigned bu;

    initial begin
        // Test 1: Default value
        test_count++;
        if (b1 == 0) begin
            pass_count++;
            $display("Test 1 PASS: Default = %0d", b1);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %0d", b1);
        end

        // Test 2: Assignment
        test_count++;
        b1 = 100;
        if (b1 == 100) begin
            pass_count++;
            $display("Test 2 PASS: Assign = %0d", b1);
        end else begin
            $display("Test 2 FAIL: Assign unexpected = %0d", b1);
        end

        // Test 3: Negative value
        test_count++;
        b1 = -50;
        if (b1 < 0) begin
            pass_count++;
            $display("Test 3 PASS: Negative = %0d", b1);
        end else begin
            $display("Test 3 FAIL: Negative unexpected = %0d", b1);
        end

        // Test 4: Max positive (127)
        test_count++;
        b1 = 127;
        if (b1 == 127) begin
            pass_count++;
            $display("Test 4 PASS: Max = %0d", b1);
        end else begin
            $display("Test 4 FAIL: Max unexpected = %0d", b1);
        end

        // Test 5: Min negative (-128)
        test_count++;
        b1 = -128;
        if (b1 == -128) begin
            pass_count++;
            $display("Test 5 PASS: Min = %0d", b1);
        end else begin
            $display("Test 5 FAIL: Min unexpected = %0d", b1);
        end

        // Test 6: Addition
        test_count++;
        b1 = 50;
        b2 = 30;
        begin
            static byte sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = b1 + b2;
            if (sum == 80) begin
                pass_count++;
                $display("Test 6 PASS: Sum = %0d", sum);
            end else begin
                $display("Test 6 FAIL: Sum unexpected = %0d", sum);
            end
        end

        // Test 7: Subtraction
        test_count++;
        b1 = 100;
        b2 = 30;
        begin
            static byte diff;
            // Assigned here so the result does not depend on the order of static initializers.
            diff = b1 - b2;
            if (diff == 70) begin
                pass_count++;
                $display("Test 7 PASS: Diff = %0d", diff);
            end else begin
                $display("Test 7 FAIL: Diff unexpected = %0d", diff);
            end
        end

        // Test 8: Multiplication
        test_count++;
        b1 = 10;
        b2 = 5;
        begin
            static byte prod;
            // Assigned here so the result does not depend on the order of static initializers.
            prod = b1 * b2;
            if (prod == 50) begin
                pass_count++;
                $display("Test 8 PASS: Prod = %0d", prod);
            end else begin
                $display("Test 8 FAIL: Prod unexpected = %0d", prod);
            end
        end

        // Test 9: Division
        test_count++;
        b1 = 100;
        b2 = 10;
        begin
            static byte quot;
            // Assigned here so the result does not depend on the order of static initializers.
            quot = b1 / b2;
            if (quot == 10) begin
                pass_count++;
                $display("Test 9 PASS: Quot = %0d", quot);
            end else begin
                $display("Test 9 FAIL: Quot unexpected = %0d", quot);
            end
        end

        // Test 10: Modulo
        test_count++;
        b1 = 47;
        b2 = 10;
        begin
            static byte mod;
            // Assigned here so the result does not depend on the order of static initializers.
            mod = b1 % b2;
            if (mod == 7) begin
                pass_count++;
                $display("Test 10 PASS: Mod = %0d", mod);
            end else begin
                $display("Test 10 FAIL: Mod unexpected = %0d", mod);
            end
        end

        // Test 11: Bitwise AND
        test_count++;
        b1 = 8'hF0;
        b2 = 8'h0F;
        begin
            static byte res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = b1 & b2;
            if (res == 0) begin
                pass_count++;
                $display("Test 11 PASS: AND = %h", res);
            end else begin
                $display("Test 11 FAIL: AND unexpected = %h", res);
            end
        end

        // Test 12: Bitwise OR
        test_count++;
        b1 = 8'hF0;
        b2 = 8'h0F;
        begin
            static byte res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = b1 | b2;
            if (res == 8'hFF) begin
                pass_count++;
                $display("Test 12 PASS: OR = %h", res);
            end else begin
                $display("Test 12 FAIL: OR unexpected = %h", res);
            end
        end

        // Test 13: Bitwise XOR
        test_count++;
        b1 = 8'hAA;
        b2 = 8'hFF;
        begin
            static byte res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = b1 ^ b2;
            if (res == 8'h55) begin
                pass_count++;
                $display("Test 13 PASS: XOR = %h", res);
            end else begin
                $display("Test 13 FAIL: XOR unexpected = %h", res);
            end
        end

        // Test 14: Comparison
        test_count++;
        b1 = 50;
        b2 = 100;
        if (b1 < b2) begin
            pass_count++;
            $display("Test 14 PASS: b1 < b2");
        end else begin
            $display("Test 14 FAIL: Compare unexpected");
        end

        // Test 15: Increment
        test_count++;
        b1 = 99;
        b1++;
        if (b1 == 100) begin
            pass_count++;
            $display("Test 15 PASS: Inc = %0d", b1);
        end else begin
            $display("Test 15 FAIL: Inc unexpected = %0d", b1);
        end

        // Test 16: Decrement
        test_count++;
        b1 = 100;
        b1--;
        if (b1 == 99) begin
            pass_count++;
            $display("Test 16 PASS: Dec = %0d", b1);
        end else begin
            $display("Test 16 FAIL: Dec unexpected = %0d", b1);
        end

        // Test 17: Unsigned byte
        test_count++;
        bu = 255;
        if (bu == 255) begin
            pass_count++;
            $display("Test 17 PASS: Unsigned = %0d", bu);
        end else begin
            $display("Test 17 FAIL: Unsigned unexpected = %0d", bu);
        end

        // Test 18: Cast to int
        test_count++;
        b1 = -1;
        begin
            static int i;
            // Assigned here so the result does not depend on the order of static initializers.
            i = int'(b1);
            if (i == -1) begin
                pass_count++;
                $display("Test 18 PASS: Cast = %0d", i);
            end else begin
                $display("Test 18 FAIL: Cast unexpected = %0d", i);
            end
        end

        $display("=== Byte Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
