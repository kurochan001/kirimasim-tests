/*
:name: test_shortint_edge_cases
:description: shortint initial value, range limits and arithmetic
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortint_edge_cases.expected
*/
// IEEE 1800-2023 §6.11.2: Shortint edge cases
// Tests for 2-state 16-bit signed shortint type

module test_shortint_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    shortint s1, s2;
    shortint signed ss;
    shortint unsigned su;

    initial begin
        // Test 1: Default value
        test_count++;
        if (s1 == 0) begin
            pass_count++;
            $display("Test 1 PASS: Default = %0d", s1);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %0d", s1);
        end

        // Test 2: Assignment
        test_count++;
        s1 = 1234;
        if (s1 == 1234) begin
            pass_count++;
            $display("Test 2 PASS: Assign = %0d", s1);
        end else begin
            $display("Test 2 FAIL: Assign unexpected = %0d", s1);
        end

        // Test 3: Negative value
        test_count++;
        s1 = -1000;
        if (s1 < 0) begin
            pass_count++;
            $display("Test 3 PASS: Negative = %0d", s1);
        end else begin
            $display("Test 3 FAIL: Negative unexpected = %0d", s1);
        end

        // Test 4: Max positive
        test_count++;
        s1 = 32767;
        if (s1 == 32767) begin
            pass_count++;
            $display("Test 4 PASS: Max = %0d", s1);
        end else begin
            $display("Test 4 FAIL: Max unexpected = %0d", s1);
        end

        // Test 5: Min negative
        test_count++;
        s1 = -32768;
        if (s1 == -32768) begin
            pass_count++;
            $display("Test 5 PASS: Min = %0d", s1);
        end else begin
            $display("Test 5 FAIL: Min unexpected = %0d", s1);
        end

        // Test 6: Addition
        test_count++;
        s1 = 100;
        s2 = 200;
        begin
            static shortint sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = s1 + s2;
            if (sum == 300) begin
                pass_count++;
                $display("Test 6 PASS: Sum = %0d", sum);
            end else begin
                $display("Test 6 FAIL: Sum unexpected = %0d", sum);
            end
        end

        // Test 7: Subtraction
        test_count++;
        s1 = 500;
        s2 = 200;
        begin
            static shortint diff;
            // Assigned here so the result does not depend on the order of static initializers.
            diff = s1 - s2;
            if (diff == 300) begin
                pass_count++;
                $display("Test 7 PASS: Diff = %0d", diff);
            end else begin
                $display("Test 7 FAIL: Diff unexpected = %0d", diff);
            end
        end

        // Test 8: Multiplication
        test_count++;
        s1 = 100;
        s2 = 50;
        begin
            static shortint prod;
            // Assigned here so the result does not depend on the order of static initializers.
            prod = s1 * s2;
            if (prod == 5000) begin
                pass_count++;
                $display("Test 8 PASS: Prod = %0d", prod);
            end else begin
                $display("Test 8 FAIL: Prod unexpected = %0d", prod);
            end
        end

        // Test 9: Division
        test_count++;
        s1 = 1000;
        s2 = 10;
        begin
            static shortint quot;
            // Assigned here so the result does not depend on the order of static initializers.
            quot = s1 / s2;
            if (quot == 100) begin
                pass_count++;
                $display("Test 9 PASS: Quot = %0d", quot);
            end else begin
                $display("Test 9 FAIL: Quot unexpected = %0d", quot);
            end
        end

        // Test 10: Modulo
        test_count++;
        s1 = 123;
        s2 = 10;
        begin
            static shortint mod;
            // Assigned here so the result does not depend on the order of static initializers.
            mod = s1 % s2;
            if (mod == 3) begin
                pass_count++;
                $display("Test 10 PASS: Mod = %0d", mod);
            end else begin
                $display("Test 10 FAIL: Mod unexpected = %0d", mod);
            end
        end

        // Test 11: Comparison
        test_count++;
        s1 = 100;
        s2 = 200;
        if (s1 < s2) begin
            pass_count++;
            $display("Test 11 PASS: Compare s1<s2");
        end else begin
            $display("Test 11 FAIL: Compare unexpected");
        end

        // Test 12: Equality
        test_count++;
        s1 = 42;
        s2 = 42;
        if (s1 == s2) begin
            pass_count++;
            $display("Test 12 PASS: Equal s1==s2");
        end else begin
            $display("Test 12 FAIL: Equal unexpected");
        end

        // Test 13: Bitwise AND
        test_count++;
        s1 = 16'h00FF;
        s2 = 16'hF00F;
        begin
            static shortint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = s1 & s2;
            if (res == 16'h000F) begin
                pass_count++;
                $display("Test 13 PASS: AND = %h", res);
            end else begin
                $display("Test 13 FAIL: AND unexpected = %h", res);
            end
        end

        // Test 14: Bitwise OR
        test_count++;
        s1 = 16'h00F0;
        s2 = 16'h0F00;
        begin
            static shortint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = s1 | s2;
            if (res == 16'h0FF0) begin
                pass_count++;
                $display("Test 14 PASS: OR = %h", res);
            end else begin
                $display("Test 14 FAIL: OR unexpected = %h", res);
            end
        end

        // Test 15: Bitwise XOR
        test_count++;
        s1 = 16'hFFFF;
        s2 = 16'h0F0F;
        begin
            static shortint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = s1 ^ s2;
            if (res == 16'hF0F0) begin
                pass_count++;
                $display("Test 15 PASS: XOR = %h", res);
            end else begin
                $display("Test 15 FAIL: XOR unexpected = %h", res);
            end
        end

        // Test 16: Shift left
        test_count++;
        s1 = 1;
        begin
            static shortint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = s1 << 8;
            if (res == 256) begin
                pass_count++;
                $display("Test 16 PASS: Shift = %0d", res);
            end else begin
                $display("Test 16 FAIL: Shift unexpected = %0d", res);
            end
        end

        // Test 17: Increment
        test_count++;
        s1 = 99;
        s1++;
        if (s1 == 100) begin
            pass_count++;
            $display("Test 17 PASS: Inc = %0d", s1);
        end else begin
            $display("Test 17 FAIL: Inc unexpected = %0d", s1);
        end

        // Test 18: Decrement
        test_count++;
        s1 = 100;
        s1--;
        if (s1 == 99) begin
            pass_count++;
            $display("Test 18 PASS: Dec = %0d", s1);
        end else begin
            $display("Test 18 FAIL: Dec unexpected = %0d", s1);
        end

        $display("=== Shortint Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
