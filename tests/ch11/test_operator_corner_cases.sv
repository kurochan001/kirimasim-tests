/*
:name: test_operator_corner_cases
:description: Arithmetic, shift, comparison, reduction, concatenation and conditional operators, with x
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.5 11.4.6 11.4.9 11.4.10 11.4.11 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_corner_cases.expected
*/
// IEEE 1800-2023 Operator Corner Cases
// Tests for edge cases in arithmetic, logical, and bitwise operators

module test_operator_corner_cases;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // === Arithmetic Operator Edge Cases ===

        // Test 1: Integer overflow
        begin
            static int max_int = 32'h7FFF_FFFF;
            static int overflow;
            // Assigned here so the result does not depend on the order of static initializers.
            overflow = max_int + 1;
            if (overflow == 32'h8000_0000) begin
                $display("Test 1 PASS: Integer overflow wraps correctly");
                pass_count++;
            end else begin
                $display("Test 1 FAIL: overflow=%h", overflow);
                fail_count++;
            end
        end

        // Test 2: Integer underflow
        begin
            static int min_int = 32'h8000_0000;
            static int underflow;
            // Assigned here so the result does not depend on the order of static initializers.
            underflow = min_int - 1;
            if (underflow == 32'h7FFF_FFFF) begin
                $display("Test 2 PASS: Integer underflow wraps correctly");
                pass_count++;
            end else begin
                $display("Test 2 FAIL: underflow=%h", underflow);
                fail_count++;
            end
        end

        // Test 3: Division by power of 2
        begin
            static int val = 256;
            static int div2;
            static int div4;
            static int div256;
            // Assigned here so the result does not depend on the order of static initializers.
            div2 = val / 2;
            div4 = val / 4;
            div256 = val / 256;
            if (div2 == 128 && div4 == 64 && div256 == 1) begin
                $display("Test 3 PASS: Division by power of 2");
                pass_count++;
            end else begin
                $display("Test 3 FAIL");
                fail_count++;
            end
        end

        // Test 4: Negative division
        begin
            static int neg = -100;
            static int div_result;
            static int mod_result;
            // Assigned here so the result does not depend on the order of static initializers.
            div_result = neg / 3;
            mod_result = neg % 3;
            // IEEE 1800-2023: truncate toward zero
            if (div_result == -33) begin
                $display("Test 4 PASS: Negative division");
                pass_count++;
            end else begin
                $display("Test 4 FAIL: div_result=%0d", div_result);
                fail_count++;
            end
        end

        // Test 5: Modulo with negative operands
        begin
            static int mod1 = -7 % 3;   // -1
            static int mod2 = 7 % -3;   // 1
            static int mod3 = -7 % -3;  // -1
            if (mod1 == -1 && mod2 == 1 && mod3 == -1) begin
                $display("Test 5 PASS: Modulo with negative operands");
                pass_count++;
            end else begin
                $display("Test 5 FAIL: mod1=%0d mod2=%0d mod3=%0d", mod1, mod2, mod3);
                fail_count++;
            end
        end

        // Test 6: Power operator edge cases
        begin
            static int pow0 = 2 ** 0;    // 1
            static int pow1 = 2 ** 1;    // 2
            static int pow10 = 2 ** 10;  // 1024
            static int pow0base = 0 ** 5; // 0
            static int pow1base = 1 ** 100; // 1
            if (pow0 == 1 && pow1 == 2 && pow10 == 1024 &&
                pow0base == 0 && pow1base == 1) begin
                $display("Test 6 PASS: Power operator edge cases");
                pass_count++;
            end else begin
                $display("Test 6 FAIL");
                fail_count++;
            end
        end

        // === Shift Operator Edge Cases ===

        // Test 7: Shift by 0
        begin
            static logic [31:0] val = 32'hDEADBEEF;
            static logic [31:0] lsh0;
            static logic [31:0] rsh0;
            // Assigned here so the result does not depend on the order of static initializers.
            lsh0 = val << 0;
            rsh0 = val >> 0;
            if (lsh0 == val && rsh0 == val) begin
                $display("Test 7 PASS: Shift by 0");
                pass_count++;
            end else begin
                $display("Test 7 FAIL");
                fail_count++;
            end
        end

        // Test 8: Shift by full width
        begin
            static logic [7:0] val = 8'hFF;
            static logic [7:0] lsh8;
            static logic [7:0] rsh8;
            // Assigned here so the result does not depend on the order of static initializers.
            lsh8 = val << 8;
            rsh8 = val >> 8;
            if (lsh8 == 8'h00 && rsh8 == 8'h00) begin
                $display("Test 8 PASS: Shift by full width");
                pass_count++;
            end else begin
                $display("Test 8 FAIL");
                fail_count++;
            end
        end

        // Test 9: Arithmetic right shift with negative
        begin
            static int neg = -128;  // 0xFFFFFF80
            static int arsh;
            // Assigned here so the result does not depend on the order of static initializers.
            arsh = neg >>> 2;  // Should preserve sign
            if (arsh < 0 && arsh == -32) begin
                $display("Test 9 PASS: Arithmetic right shift");
                pass_count++;
            end else begin
                $display("Test 9 FAIL: arsh=%0d", arsh);
                fail_count++;
            end
        end

        // === Comparison Edge Cases ===

        // Test 10: Signed vs unsigned comparison
        begin
            static logic signed [7:0] s_neg = -1;
            static logic [7:0] u_max = 8'hFF;
            static bit s_less;
            static bit u_greater;
            // Assigned here so the result does not depend on the order of static initializers.
            s_less = s_neg < 0;
            u_greater = u_max > 127;
            if (s_less && u_greater) begin
                $display("Test 10 PASS: Signed vs unsigned comparison");
                pass_count++;
            end else begin
                $display("Test 10 FAIL");
                fail_count++;
            end
        end

        // Test 11: Wildcard equality with X
        begin
            static logic [3:0] val = 4'b10x1;
            static logic [3:0] pattern1 = 4'b10?1;
            static logic [3:0] pattern2 = 4'b1011;
            static bit match1;
            static bit match2;
            // Assigned here so the result does not depend on the order of static initializers.
            match1 = (val ==? pattern1);
            match2 = (val ==? pattern2);
            if (match1) begin
                $display("Test 11 PASS: Wildcard equality");
                pass_count++;
            end else begin
                $display("Test 11 FAIL");
                fail_count++;
            end
        end

        // Test 12: Case equality with X/Z
        begin
            static logic [3:0] val1 = 4'bx0z1;
            static logic [3:0] val2 = 4'bx0z1;
            static logic [3:0] val3 = 4'b0011;
            static bit case_eq;
            static bit case_neq;
            // Assigned here so the result does not depend on the order of static initializers.
            case_eq = (val1 === val2);
            case_neq = (val1 !== val3);
            if (case_eq && case_neq) begin
                $display("Test 12 PASS: Case equality with X/Z");
                pass_count++;
            end else begin
                $display("Test 12 FAIL");
                fail_count++;
            end
        end

        // === Reduction Operator Edge Cases ===

        // Test 13: Reduction with all same bits
        begin
            static logic [7:0] all_ones = 8'hFF;
            static logic [7:0] all_zeros = 8'h00;
            static bit and_ones;
            static bit or_zeros;
            static bit xor_ones;
            // Assigned here so the result does not depend on the order of static initializers.
            and_ones = &all_ones;
            or_zeros = |all_zeros;
            xor_ones = ^all_ones;
            if (and_ones == 1 && or_zeros == 0 && xor_ones == 0) begin
                $display("Test 13 PASS: Reduction operators");
                pass_count++;
            end else begin
                $display("Test 13 FAIL");
                fail_count++;
            end
        end

        // Test 14: Reduction with X values
        begin
            static logic [3:0] with_x = 4'b1x01;
            static bit and_x;
            static bit or_x;
            // Assigned here so the result does not depend on the order of static initializers.
            and_x = &with_x;
            or_x = |with_x;
            // AND with x and known 0 or 1 should give defined result
            if (or_x == 1) begin  // At least one 1 bit
                $display("Test 14 PASS: Reduction with X");
                pass_count++;
            end else begin
                $display("Test 14 FAIL");
                fail_count++;
            end
        end

        // === Concatenation Edge Cases ===

        // Test 15: Empty replication
        begin
            static logic [7:0] val = 8'hAB;
            static logic [15:0] rep2;
            static logic [31:0] rep4;
            // Assigned here so the result does not depend on the order of static initializers.
            rep2 = {2{val}};
            rep4 = {4{val}};
            if (rep2 == 16'hABAB && rep4 == 32'hABABABAB) begin
                $display("Test 15 PASS: Replication");
                pass_count++;
            end else begin
                $display("Test 15 FAIL");
                fail_count++;
            end
        end

        // Test 16: Nested concatenation
        begin
            static logic [3:0] a = 4'h1;
            static logic [3:0] b = 4'h2;
            static logic [3:0] c = 4'h3;
            static logic [11:0] nested;
            static logic [11:0] expected = 12'h123;
            // Assigned here so the result does not depend on the order of static initializers.
            nested = {{a, b}, c};
            if (nested == expected) begin
                $display("Test 16 PASS: Nested concatenation");
                pass_count++;
            end else begin
                $display("Test 16 FAIL: nested=%h", nested);
                fail_count++;
            end
        end

        // === Conditional Operator Edge Cases ===

        // Test 17: Nested conditional
        begin
            static int a = 10, b = 20, c = 15;
            static int max;
            // Assigned here so the result does not depend on the order of static initializers.
            max = (a > b) ? ((a > c) ? a : c) : ((b > c) ? b : c);
            if (max == 20) begin
                $display("Test 17 PASS: Nested conditional");
                pass_count++;
            end else begin
                $display("Test 17 FAIL: max=%0d", max);
                fail_count++;
            end
        end

        // Test 18: Conditional with X condition
        begin
            static logic x_cond = 1'bx;
            static logic [3:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = x_cond ? 4'b1111 : 4'b0000;
            // With an x condition the two results are merged bit by bit, and
            // bits that differ become x (11.4.11).
            if (result === 4'bxxxx) begin
                $display("Test 18 PASS: Conditional with X condition");
                pass_count++;
            end else begin
                $display("Test 18 FAIL: result=%b", result);
                fail_count++;
            end
        end

        // Test 19: Increment/decrement edge cases
        begin
            static int val = 32'h7FFF_FFFF;
            val++;
            if (val == 32'h8000_0000) begin
                $display("Test 19 PASS: Increment overflow");
                pass_count++;
            end else begin
                $display("Test 19 FAIL");
                fail_count++;
            end
        end

        // Test 20: Zero operand cases
        begin
            static int zero = 0;
            static int mul_zero;
            static bit or_zero;
            static bit and_zero;
            // Assigned here so the result does not depend on the order of static initializers.
            mul_zero = 12345 * zero;
            or_zero = zero || 0;
            and_zero = zero && 1;
            if (mul_zero == 0 && or_zero == 0 && and_zero == 0) begin
                $display("Test 20 PASS: Zero operand cases");
                pass_count++;
            end else begin
                $display("Test 20 FAIL");
                fail_count++;
            end
        end

        $display("=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end
endmodule
