/*
:name: test_integer_edge_cases
:description: Integer edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_integer_edge_cases.expected
*/
// IEEE 1800-2023 §6.11: Integer edge cases
// Tests for 4-state 32-bit signed integer type

module test_integer_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    integer i1, i2;

    initial begin
        // Test 1: Default value (integer is 4-state, so it starts as x: 6.8)
        test_count++;
        if (i1 === 'x) begin
            pass_count++;
            $display("Test 1 PASS: Default = %h", i1);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %h", i1);
        end

        // Test 2: Assignment
        test_count++;
        i1 = 12345678;
        if (i1 == 12345678) begin
            pass_count++;
            $display("Test 2 PASS: Assign = %0d", i1);
        end else begin
            $display("Test 2 FAIL: Assign unexpected = %0d", i1);
        end

        // Test 3: Negative value
        test_count++;
        i1 = -1000000;
        if (i1 == -1000000) begin
            pass_count++;
            $display("Test 3 PASS: Negative = %0d", i1);
        end else begin
            $display("Test 3 FAIL: Negative unexpected = %0d", i1);
        end

        // Test 4: Max positive
        test_count++;
        i1 = 2147483647;
        if (i1 == 2147483647) begin
            pass_count++;
            $display("Test 4 PASS: Max = %0d", i1);
        end else begin
            $display("Test 4 FAIL: Max unexpected = %0d", i1);
        end

        // Test 5: Min negative
        test_count++;
        i1 = -2147483648;
        if (i1 == -2147483648) begin
            pass_count++;
            $display("Test 5 PASS: Min = %0d", i1);
        end else begin
            $display("Test 5 FAIL: Min unexpected = %0d", i1);
        end

        // Test 6: Addition
        test_count++;
        i1 = 1000000;
        i2 = 2000000;
        begin
            static integer sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = i1 + i2;
            if (sum == 3000000) begin
                pass_count++;
                $display("Test 6 PASS: Sum = %0d", sum);
            end else begin
                $display("Test 6 FAIL: Sum unexpected = %0d", sum);
            end
        end

        // Test 7: Subtraction
        test_count++;
        i1 = 5000000;
        i2 = 2000000;
        begin
            static integer diff;
            // Assigned here so the result does not depend on the order of static initializers.
            diff = i1 - i2;
            if (diff == 3000000) begin
                pass_count++;
                $display("Test 7 PASS: Diff = %0d", diff);
            end else begin
                $display("Test 7 FAIL: Diff unexpected = %0d", diff);
            end
        end

        // Test 8: Multiplication
        test_count++;
        i1 = 1000;
        i2 = 2000;
        begin
            static integer prod;
            // Assigned here so the result does not depend on the order of static initializers.
            prod = i1 * i2;
            if (prod == 2000000) begin
                pass_count++;
                $display("Test 8 PASS: Prod = %0d", prod);
            end else begin
                $display("Test 8 FAIL: Prod unexpected = %0d", prod);
            end
        end

        // Test 9: Division
        test_count++;
        i1 = 1000000;
        i2 = 1000;
        begin
            static integer quot;
            // Assigned here so the result does not depend on the order of static initializers.
            quot = i1 / i2;
            if (quot == 1000) begin
                pass_count++;
                $display("Test 9 PASS: Quot = %0d", quot);
            end else begin
                $display("Test 9 FAIL: Quot unexpected = %0d", quot);
            end
        end

        // Test 10: Modulo
        test_count++;
        i1 = 1234567;
        i2 = 1000;
        begin
            static integer mod;
            // Assigned here so the result does not depend on the order of static initializers.
            mod = i1 % i2;
            if (mod == 567) begin
                pass_count++;
                $display("Test 10 PASS: Mod = %0d", mod);
            end else begin
                $display("Test 10 FAIL: Mod unexpected = %0d", mod);
            end
        end

        // Test 11: Bitwise AND
        test_count++;
        i1 = 32'hFFFF_0000;
        i2 = 32'h0FFF_F000;
        begin
            static integer res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = i1 & i2;
            if (res == 32'h0FFF_0000) begin
                pass_count++;
                $display("Test 11 PASS: AND = %h", res);
            end else begin
                $display("Test 11 FAIL: AND unexpected = %h", res);
            end
        end

        // Test 12: Bitwise OR
        test_count++;
        i1 = 32'hFF00_0000;
        i2 = 32'h00FF_0000;
        begin
            static integer res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = i1 | i2;
            if (res == 32'hFFFF_0000) begin
                pass_count++;
                $display("Test 12 PASS: OR = %h", res);
            end else begin
                $display("Test 12 FAIL: OR unexpected = %h", res);
            end
        end

        // Test 13: Shift left
        test_count++;
        i1 = 1;
        begin
            static integer res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = i1 << 16;
            if (res == 65536) begin
                pass_count++;
                $display("Test 13 PASS: Shl = %0d", res);
            end else begin
                $display("Test 13 FAIL: Shl unexpected = %0d", res);
            end
        end

        // Test 14: Shift right (arithmetic)
        test_count++;
        i1 = -4;
        begin
            static integer res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = i1 >>> 1;
            if (res == -2) begin
                pass_count++;
                $display("Test 14 PASS: AShr = %0d", res);
            end else begin
                $display("Test 14 FAIL: AShr unexpected = %0d", res);
            end
        end

        // Test 15: Comparison
        test_count++;
        i1 = 1000;
        i2 = 2000;
        if (i1 < i2) begin
            pass_count++;
            $display("Test 15 PASS: i1 < i2");
        end else begin
            $display("Test 15 FAIL: Compare unexpected");
        end

        // Test 16: Increment
        test_count++;
        i1 = 999999;
        i1++;
        if (i1 == 1000000) begin
            pass_count++;
            $display("Test 16 PASS: Inc = %0d", i1);
        end else begin
            $display("Test 16 FAIL: Inc unexpected = %0d", i1);
        end

        // Test 17: Decrement
        test_count++;
        i1 = 1000000;
        i1--;
        if (i1 == 999999) begin
            pass_count++;
            $display("Test 17 PASS: Dec = %0d", i1);
        end else begin
            $display("Test 17 FAIL: Dec unexpected = %0d", i1);
        end

        // Test 18: Negative division
        test_count++;
        i1 = -100;
        i2 = 3;
        begin
            static integer quot;
            // Assigned here so the result does not depend on the order of static initializers.
            quot = i1 / i2;
            // Integer division truncates toward zero (11.4.2)
            if (quot == -33) begin
                pass_count++;
                $display("Test 18 PASS: NegDiv = %0d", quot);
            end else begin
                $display("Test 18 FAIL: NegDiv = %0d", quot);
            end
        end

        $display("=== Integer Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
