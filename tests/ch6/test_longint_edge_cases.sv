/*
:name: test_longint_edge_cases
:description: Longint edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_longint_edge_cases.expected
*/
// IEEE 1800-2023 §6.11.2: Longint edge cases
// Tests for 2-state 64-bit signed longint type

module test_longint_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    longint l1, l2;

    initial begin
        // Test 1: Default value
        test_count++;
        if (l1 == 0) begin
            pass_count++;
            $display("Test 1 PASS: Default = %0d", l1);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %0d", l1);
        end

        // Test 2: Assignment
        test_count++;
        l1 = 123456789;
        if (l1 == 123456789) begin
            pass_count++;
            $display("Test 2 PASS: Assign = %0d", l1);
        end else begin
            $display("Test 2 FAIL: Assign unexpected = %0d", l1);
        end

        // Test 3: Large value
        test_count++;
        l1 = 64'h0000_0001_0000_0000;
        if (l1 == 64'h0000_0001_0000_0000) begin
            pass_count++;
            $display("Test 3 PASS: Large = %h", l1);
        end else begin
            $display("Test 3 FAIL: Large unexpected = %h", l1);
        end

        // Test 4: Negative value
        test_count++;
        l1 = -1000000;
        if (l1 < 0) begin
            pass_count++;
            $display("Test 4 PASS: Negative = %0d", l1);
        end else begin
            $display("Test 4 FAIL: Negative unexpected = %0d", l1);
        end

        // Test 5: Addition
        test_count++;
        l1 = 64'h0000_0000_FFFF_FFFF;
        l2 = 1;
        begin
            static longint sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = l1 + l2;
            if (sum == 64'h0000_0001_0000_0000) begin
                pass_count++;
                $display("Test 5 PASS: Sum = %h", sum);
            end else begin
                $display("Test 5 FAIL: Sum unexpected = %h", sum);
            end
        end

        // Test 6: Subtraction
        test_count++;
        l1 = 64'h0000_0001_0000_0000;
        l2 = 1;
        begin
            static longint diff;
            // Assigned here so the result does not depend on the order of static initializers.
            diff = l1 - l2;
            if (diff == 64'h0000_0000_FFFF_FFFF) begin
                pass_count++;
                $display("Test 6 PASS: Diff = %h", diff);
            end else begin
                $display("Test 6 FAIL: Diff unexpected = %h", diff);
            end
        end

        // Test 7: Multiplication
        test_count++;
        l1 = 1000000;
        l2 = 1000;
        begin
            static longint prod;
            // Assigned here so the result does not depend on the order of static initializers.
            prod = l1 * l2;
            if (prod == 1000000000) begin
                pass_count++;
                $display("Test 7 PASS: Prod = %0d", prod);
            end else begin
                $display("Test 7 FAIL: Prod unexpected = %0d", prod);
            end
        end

        // Test 8: Division
        test_count++;
        l1 = 1000000000;
        l2 = 1000000;
        begin
            static longint quot;
            // Assigned here so the result does not depend on the order of static initializers.
            quot = l1 / l2;
            if (quot == 1000) begin
                pass_count++;
                $display("Test 8 PASS: Quot = %0d", quot);
            end else begin
                $display("Test 8 FAIL: Quot unexpected = %0d", quot);
            end
        end

        // Test 9: Bitwise AND
        test_count++;
        l1 = 64'hFFFF_FFFF_0000_0000;
        l2 = 64'h0000_FFFF_FFFF_0000;
        begin
            static longint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = l1 & l2;
            if (res == 64'h0000_FFFF_0000_0000) begin
                pass_count++;
                $display("Test 9 PASS: AND = %h", res);
            end else begin
                $display("Test 9 FAIL: AND unexpected = %h", res);
            end
        end

        // Test 10: Bitwise OR
        test_count++;
        l1 = 64'hFF00_0000_0000_00FF;
        l2 = 64'h00FF_0000_0000_FF00;
        begin
            static longint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = l1 | l2;
            if (res == 64'hFFFF_0000_0000_FFFF) begin
                pass_count++;
                $display("Test 10 PASS: OR = %h", res);
            end else begin
                $display("Test 10 FAIL: OR unexpected = %h", res);
            end
        end

        // Test 11: Shift left
        test_count++;
        l1 = 1;
        begin
            static longint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = l1 << 32;
            if (res == 64'h0000_0001_0000_0000) begin
                pass_count++;
                $display("Test 11 PASS: Shl = %h", res);
            end else begin
                $display("Test 11 FAIL: Shl unexpected = %h", res);
            end
        end

        // Test 12: Shift right
        test_count++;
        l1 = 64'h0000_0001_0000_0000;
        begin
            static longint res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = l1 >> 32;
            if (res == 1) begin
                pass_count++;
                $display("Test 12 PASS: Shr = %0d", res);
            end else begin
                $display("Test 12 FAIL: Shr unexpected = %0d", res);
            end
        end

        // Test 13: Comparison
        test_count++;
        l1 = 64'h0000_0001_0000_0000;
        l2 = 64'h0000_0002_0000_0000;
        if (l1 < l2) begin
            pass_count++;
            $display("Test 13 PASS: l1 < l2");
        end else begin
            $display("Test 13 FAIL: Compare unexpected");
        end

        // Test 14: Equality
        test_count++;
        l1 = 64'hDEAD_BEEF_CAFE_BABE;
        l2 = 64'hDEAD_BEEF_CAFE_BABE;
        if (l1 == l2) begin
            pass_count++;
            $display("Test 14 PASS: l1 == l2");
        end else begin
            $display("Test 14 FAIL: Equal unexpected");
        end

        // Test 15: Increment
        test_count++;
        l1 = 64'h0000_0000_FFFF_FFFF;
        l1++;
        if (l1 == 64'h0000_0001_0000_0000) begin
            pass_count++;
            $display("Test 15 PASS: Inc = %h", l1);
        end else begin
            $display("Test 15 FAIL: Inc unexpected = %h", l1);
        end

        $display("=== Longint Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
