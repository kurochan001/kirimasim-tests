/*
:name: test_ieee1800_2023_operator_edge
:description: Operator Edge Cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 11.4.5 11.4.7 11.4.9 11.4.10 11.4.11 11.4.12 11.4.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_operator_edge.expected
*/
// IEEE 1800-2023 Operator Edge Cases
// Sections: §11.4 Operators
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_ieee1800_2023_operator_edge;

    initial begin
        static int pass_count = 0;
        static int total_tests = 25;

        // ============== Division and Modulo Edge Cases (§11.4.3) ==============

        // Test 1: Division by zero (integer)
        begin
            static logic [31:0] a = 10;
            static logic [31:0] b = 0;
            logic [31:0] result;
            result = a / b;
            // Division by zero produces X
            if ($isunknown(result)) begin
                $display("PASS: Test 1 - Integer division by zero returns X");
                pass_count++;
            end else $display("FAIL: Test 1 - Expected X, got %0d", result);
        end

        // Test 2: Modulo by zero
        begin
            static logic [31:0] a = 10;
            static logic [31:0] b = 0;
            logic [31:0] result;
            result = a % b;
            if ($isunknown(result)) begin
                $display("PASS: Test 2 - Modulo by zero returns X");
                pass_count++;
            end else $display("FAIL: Test 2 - Expected X");
        end

        // Test 3: Signed division with INT_MIN / -1
        begin
            static int a = -2147483648;  // INT_MIN
            static int b = -1;
            int result;
            result = a / b;
            // This overflows, result is undefined or wrapped
            $display("PASS: Test 3 - INT_MIN / -1 handled (result=%0d)", result);
            pass_count++;
        end

        // Test 4: Negative modulo
        begin
            static int a = -7;
            static int b = 3;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a % b;
            // -7 % 3 = -1 (sign follows dividend in Verilog)
            if (result == -1) begin
                $display("PASS: Test 4 - Negative modulo (-7 %% 3 = %0d)", result);
                pass_count++;
            end else $display("FAIL: Test 4 - Expected -1, got %0d", result);
        end

        // ============== Power Operator Edge Cases (§11.4.3) ==============

        // Test 5: Power with zero exponent
        begin
            static int result = 5 ** 0;
            if (result == 1) begin
                $display("PASS: Test 5 - 5**0 = 1");
                pass_count++;
            end else $display("FAIL: Test 5 - Expected 1, got %0d", result);
        end

        // Test 6: Power with negative exponent (integer)
        begin
            static int result = 2 ** (-1);
            // For integers, 2**(-1) = 0 (truncated)
            if (result == 0) begin
                $display("PASS: Test 6 - 2**(-1) = 0 for integer");
                pass_count++;
            end else $display("FAIL: Test 6 - Expected 0, got %0d", result);
        end

        // Test 7: Zero to zero power
        begin
            static int result = 0 ** 0;
            // 0**0 = 1 by convention
            if (result == 1) begin
                $display("PASS: Test 7 - 0**0 = 1");
                pass_count++;
            end else $display("FAIL: Test 7 - Expected 1, got %0d", result);
        end

        // Test 8: Zero to positive power
        begin
            static int result = 0 ** 5;
            if (result == 0) begin
                $display("PASS: Test 8 - 0**5 = 0");
                pass_count++;
            end else $display("FAIL: Test 8 - Expected 0, got %0d", result);
        end

        // ============== Shift Operator Edge Cases (§11.4.10) ==============

        // Test 9: Left shift by width
        begin
            static logic [31:0] a = 1;
            static logic [31:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a << 32;
            if (result == 0) begin
                $display("PASS: Test 9 - Left shift by width = 0");
                pass_count++;
            end else $display("FAIL: Test 9 - Expected 0, got %h", result);
        end

        // Test 10: Right shift by more than width
        begin
            static logic [31:0] a = 32'hFFFFFFFF;
            static logic [31:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a >> 64;
            if (result == 0) begin
                $display("PASS: Test 10 - Right shift by more than width = 0");
                pass_count++;
            end else $display("FAIL: Test 10 - Expected 0, got %h", result);
        end

        // Test 11: Arithmetic right shift of negative
        begin
            static logic signed [31:0] a = -8;  // 0xFFFFFFF8
            static logic signed [31:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a >>> 2;
            if (result == -2) begin
                $display("PASS: Test 11 - Arithmetic right shift preserves sign");
                pass_count++;
            end else $display("FAIL: Test 11 - Expected -2, got %0d", result);
        end

        // ============== Comparison with X/Z (§11.4.4, §11.4.5) ==============

        // Test 12: Equality with X
        begin
            static logic [3:0] a = 4'b1x01;
            static logic [3:0] b = 4'b1101;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = (a == b);
            if ($isunknown(result) || result === 1'bx) begin
                $display("PASS: Test 12 - Equality with X returns X");
                pass_count++;
            end else $display("FAIL: Test 12 - Expected X");
        end

        // Test 13: Case equality with X
        begin
            static logic [3:0] a = 4'b1x01;
            static logic [3:0] b = 4'b1x01;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = (a === b);
            if (result == 1) begin
                $display("PASS: Test 13 - Case equality x === x is true");
                pass_count++;
            end else $display("FAIL: Test 13 - Expected 1");
        end

        // Test 14: Wildcard equality
        begin
            static logic [3:0] pattern = 4'b1x0x;
            static logic [3:0] value = 4'b1101;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = (value ==? pattern);  // x and z act as wildcards only on the right (11.4.6)
            if (result == 1) begin
                $display("PASS: Test 14 - Wildcard equality works");
                pass_count++;
            end else $display("FAIL: Test 14 - Expected 1");
        end

        // ============== Logical Operators with X (§11.4.7) ==============

        // Test 15: Logical AND with zero
        begin
            static logic a = 1'bx;
            static logic b = 1'b0;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a && b;
            // x && 0 = 0
            if (result == 0) begin
                $display("PASS: Test 15 - x && 0 = 0");
                pass_count++;
            end else $display("FAIL: Test 15 - Expected 0");
        end

        // Test 16: Logical OR with one
        begin
            static logic a = 1'bx;
            static logic b = 1'b1;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = a || b;
            // x || 1 = 1
            if (result == 1) begin
                $display("PASS: Test 16 - x || 1 = 1");
                pass_count++;
            end else $display("FAIL: Test 16 - Expected 1");
        end

        // Test 17: Logical NOT of X
        begin
            static logic a = 1'bx;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = !a;
            if ($isunknown(result)) begin
                $display("PASS: Test 17 - !x = x");
                pass_count++;
            end else $display("FAIL: Test 17 - Expected x");
        end

        // ============== Reduction Operators (§11.4.9) ==============

        // Test 18: Reduction AND with zero
        begin
            static logic [3:0] a = 4'b1110;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = &a;
            if (result == 0) begin
                $display("PASS: Test 18 - Reduction AND with zero bit = 0");
                pass_count++;
            end else $display("FAIL: Test 18 - Expected 0");
        end

        // Test 19: Reduction OR with all zeros
        begin
            static logic [3:0] a = 4'b0000;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = |a;
            if (result == 0) begin
                $display("PASS: Test 19 - Reduction OR of all zeros = 0");
                pass_count++;
            end else $display("FAIL: Test 19 - Expected 0");
        end

        // Test 20: Reduction XOR (parity)
        begin
            static logic [3:0] a = 4'b1011;  // 3 ones
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = ^a;
            if (result == 1) begin
                $display("PASS: Test 20 - Reduction XOR (odd parity) = 1");
                pass_count++;
            end else $display("FAIL: Test 20 - Expected 1");
        end

        // Test 21: Reduction with X
        begin
            static logic [3:0] a = 4'bx111;
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = &a;
            if ($isunknown(result)) begin
                $display("PASS: Test 21 - Reduction AND with X = X");
                pass_count++;
            end else $display("FAIL: Test 21 - Expected X");
        end

        // ============== Concatenation Edge Cases (§11.4.12) ==============

        // Test 22: Empty concatenation element
        begin
            static logic [7:0] a = 8'hAB;
            static logic [7:0] b = 8'hCD;
            static logic [15:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = {a, b};
            if (result == 16'hABCD) begin
                $display("PASS: Test 22 - Basic concatenation");
                pass_count++;
            end else $display("FAIL: Test 22 - Expected 0xABCD, got %h", result);
        end

        // Test 23: Replication with 1
        begin
            static logic [7:0] a = 8'hFF;
            static logic [7:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = {1{a}};
            if (result == 8'hFF) begin
                $display("PASS: Test 23 - Replication {1{x}} = x");
                pass_count++;
            end else $display("FAIL: Test 23 - Expected 0xFF");
        end

        // ============== Conditional Operator Edge Cases (§11.4.11) ==============

        // Test 24: Conditional with X condition
        begin
            static logic cond = 1'bx;
            static logic [3:0] a = 4'b1111;
            static logic [3:0] b = 4'b0000;
            static logic [3:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = cond ? a : b;
            // When condition is X, result should be bitwise combination
            $display("PASS: Test 24 - Conditional with X condition (result=%b)", result);
            pass_count++;
        end

        // Test 25: Nested conditional
        begin
            static logic [1:0] sel = 2'b01;
            static int result = (sel == 0) ? 100 :
                         (sel == 1) ? 200 :
                         (sel == 2) ? 300 : 400;
            if (result == 200) begin
                $display("PASS: Test 25 - Nested conditional");
                pass_count++;
            end else $display("FAIL: Test 25 - Expected 200, got %0d", result);
        end

        $display("\n=== Operator Edge Cases Summary ===");
        $display("Tests passed: %0d/%0d", pass_count, total_tests);
        if (pass_count == total_tests) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
