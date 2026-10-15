/*
:name: test_comparison_corner_cases
:description: Equality, case equality, relational and wildcard operators, including x operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comparison_corner_cases.expected
*/
// IEEE 1800-2023 §11.4: Comparison operator corner cases
// Tests for ==, !=, ===, !==, <, >, <=, >= with edge values

module test_comparison_corner_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b;
    logic [3:0] x_val, z_val;
    int si1, si2;
    int unsigned ui1, ui2;

    initial begin
        // Test 1: Equal values
        test_count++;
        a = 8'hAB;
        b = 8'hAB;
        if (a == b) begin
            pass_count++;
            $display("Test 1 PASS: AB == AB");
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: Not equal values
        test_count++;
        a = 8'hAB;
        b = 8'hCD;
        if (a != b) begin
            pass_count++;
            $display("Test 2 PASS: AB != CD");
        end else begin
            $display("Test 2 FAIL");
        end

        // Test 3: Case equality with X
        test_count++;
        x_val = 4'bxxxx;
        if (x_val === 4'bxxxx) begin
            pass_count++;
            $display("Test 3 PASS: X === X");
        end else begin
            $display("Test 3 FAIL");
        end

        // Test 4: Case equality with Z
        test_count++;
        z_val = 4'bzzzz;
        if (z_val === 4'bzzzz) begin
            pass_count++;
            $display("Test 4 PASS: Z === Z");
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Case inequality
        test_count++;
        x_val = 4'bxxxx;
        z_val = 4'bzzzz;
        if (x_val !== z_val) begin
            pass_count++;
            $display("Test 5 PASS: X !== Z");
        end else begin
            $display("Test 5 FAIL");
        end

        // Test 6: Logical equality with X (result is X)
        test_count++;
        x_val = 4'bxxxx;
        begin
            static logic result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = (x_val == 4'b0000);
            // All bits are x, so the equality is ambiguous and gives x (11.4.5).
            if (result === 1'bx) begin
                pass_count++;
                $display("Test 6 PASS: X == 0 gives X");
            end else begin
                $display("Test 6 FAIL");
            end
        end

        // Test 7: Less than
        test_count++;
        si1 = 10;
        si2 = 20;
        if (si1 < si2) begin
            pass_count++;
            $display("Test 7 PASS: 10 < 20");
        end else begin
            $display("Test 7 FAIL");
        end

        // Test 8: Greater than
        test_count++;
        si1 = 30;
        si2 = 20;
        if (si1 > si2) begin
            pass_count++;
            $display("Test 8 PASS: 30 > 20");
        end else begin
            $display("Test 8 FAIL");
        end

        // Test 9: Less than or equal
        test_count++;
        si1 = 20;
        si2 = 20;
        if (si1 <= si2) begin
            pass_count++;
            $display("Test 9 PASS: 20 <= 20");
        end else begin
            $display("Test 9 FAIL");
        end

        // Test 10: Greater than or equal
        test_count++;
        si1 = 20;
        si2 = 20;
        if (si1 >= si2) begin
            pass_count++;
            $display("Test 10 PASS: 20 >= 20");
        end else begin
            $display("Test 10 FAIL");
        end

        // Test 11: Signed comparison (negative values)
        test_count++;
        si1 = -10;
        si2 = -5;
        if (si1 < si2) begin
            pass_count++;
            $display("Test 11 PASS: -10 < -5");
        end else begin
            $display("Test 11 FAIL");
        end

        // Test 12: Signed vs unsigned boundary
        test_count++;
        si1 = -1;
        ui1 = 32'hFFFFFFFF;
        // When compared, -1 sign extends to match unsigned
        if ($signed(ui1) == si1) begin
            pass_count++;
            $display("Test 12 PASS: Signed/unsigned comparison");
        end else begin
            $display("Test 12 FAIL: Signed/unsigned wrong");
        end

        // Test 13: Zero comparisons
        test_count++;
        si1 = 0;
        si2 = 0;
        if (si1 == si2 && si1 >= si2 && si1 <= si2) begin
            pass_count++;
            $display("Test 13 PASS: Zero comparisons");
        end else begin
            $display("Test 13 FAIL");
        end

        // Test 14: Max int comparison
        test_count++;
        si1 = 32'h7FFFFFFF;
        si2 = 32'h7FFFFFFF;
        if (si1 == si2) begin
            pass_count++;
            $display("Test 14 PASS: INT_MAX == INT_MAX");
        end else begin
            $display("Test 14 FAIL");
        end

        // Test 15: Min int comparison
        test_count++;
        si1 = 32'h80000000;
        si2 = 32'h80000000;
        if (si1 == si2) begin
            pass_count++;
            $display("Test 15 PASS: INT_MIN == INT_MIN");
        end else begin
            $display("Test 15 FAIL");
        end

        // Test 16: Different width comparison
        test_count++;
        a = 8'hFF;
        begin
            static logic [15:0] wide = 16'h00FF;
            if (a == wide[7:0]) begin
                pass_count++;
                $display("Test 16 PASS: Different width comparison");
            end else begin
                $display("Test 16 FAIL");
            end
        end

        // Test 17: Wildcard equality (==?)
        test_count++;
        a = 8'b1010_1010;
        if (a ==? 8'b1x1x_1x1x) begin
            pass_count++;
            $display("Test 17 PASS: Wildcard equality");
        end else begin
            $display("Test 17 FAIL");
        end

        // Test 18: Wildcard inequality (!=?)
        test_count++;
        a = 8'b1010_1010;
        if (a !=? 8'b0x0x_0x0x) begin
            pass_count++;
            $display("Test 18 PASS: Wildcard inequality");
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: String comparison
        test_count++;
        begin
            static string s1 = "abc";
            static string s2 = "abc";
            static string s3 = "abd";
            if (s1 == s2 && s1 != s3 && s1 < s3) begin
                pass_count++;
                $display("Test 19 PASS: String comparison");
            end else begin
                $display("Test 19 FAIL");
            end
        end

        // Test 20: Real comparison
        test_count++;
        begin
            static real r1 = 3.14;
            static real r2 = 3.14;
            static real r3 = 2.71;
            if (r1 == r2 && r1 > r3) begin
                pass_count++;
                $display("Test 20 PASS: Real comparison");
            end else begin
                $display("Test 20 FAIL");
            end
        end

        $display("=== Comparison Corner Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
