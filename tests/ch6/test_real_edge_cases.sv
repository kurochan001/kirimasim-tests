/*
:name: test_real_edge_cases
:description: real, shortreal and realtime arithmetic, casts and comparisons
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_edge_cases.expected
*/
// IEEE 1800-2023 §6.12: Real type edge cases
// Tests for real, shortreal, realtime

module test_real_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    real r1, r2, r_result;
    shortreal sr;
    realtime rt;

    initial begin
        // Test 1: Basic real assignment
        test_count++;
        r1 = 3.14159;
        if (r1 > 3.14 && r1 < 3.15) begin
            pass_count++;
            $display("Test 1 PASS: real = %f", r1);
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: Real addition
        test_count++;
        r1 = 1.5;
        r2 = 2.5;
        r_result = r1 + r2;
        if (r_result == 4.0) begin
            pass_count++;
            $display("Test 2 PASS: 1.5 + 2.5 = %f", r_result);
        end else begin
            $display("Test 2 FAIL: Addition unexpected = %f", r_result);
        end

        // Test 3: Real subtraction
        test_count++;
        r_result = r2 - r1;
        if (r_result == 1.0) begin
            pass_count++;
            $display("Test 3 PASS: 2.5 - 1.5 = %f", r_result);
        end else begin
            $display("Test 3 FAIL: Subtraction unexpected = %f", r_result);
        end

        // Test 4: Real multiplication
        test_count++;
        r1 = 2.0;
        r2 = 3.0;
        r_result = r1 * r2;
        if (r_result == 6.0) begin
            pass_count++;
            $display("Test 4 PASS: 2.0 * 3.0 = %f", r_result);
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Real division
        test_count++;
        r1 = 10.0;
        r2 = 4.0;
        r_result = r1 / r2;
        if (r_result == 2.5) begin
            pass_count++;
            $display("Test 5 PASS: 10.0 / 4.0 = %f", r_result);
        end else begin
            $display("Test 5 FAIL: Division unexpected = %f", r_result);
        end

        // Test 6: Negative real
        test_count++;
        r1 = -5.5;
        if (r1 < 0) begin
            pass_count++;
            $display("Test 6 PASS: Negative = %f", r1);
        end else begin
            $display("Test 6 FAIL");
        end

        // Test 7: Real comparison
        test_count++;
        r1 = 3.14;
        r2 = 2.71;
        if (r1 > r2) begin
            pass_count++;
            $display("Test 7 PASS: 3.14 > 2.71");
        end else begin
            $display("Test 7 FAIL");
        end

        // Test 8: Shortreal
        test_count++;
        sr = 1.5;
        if (sr > 1.0 && sr < 2.0) begin
            pass_count++;
            $display("Test 8 PASS: shortreal = %f", sr);
        end else begin
            $display("Test 8 FAIL: shortreal unexpected");
        end

        // Test 9: Realtime
        test_count++;
        rt = $realtime;
        // No time has passed yet.
        if (rt == 0.0) begin
            pass_count++;
            $display("Test 9 PASS: realtime = %f", rt);
        end else begin
            $display("Test 9 FAIL: realtime = %f", rt);
        end

        // Test 10: Real to int
        test_count++;
        r1 = 5.7;
        begin
            static int i;
            // Assigned here so the result does not depend on the order of static initializers.
            i = int'(r1);
            // Conversion to an integer rounds to the nearest value (6.12.1).
            if (i == 6) begin
                pass_count++;
                $display("Test 10 PASS: int'(5.7) = %0d", i);
            end else begin
                $display("Test 10 FAIL: Cast unexpected = %0d", i);
            end
        end

        // Test 11: Int to real
        test_count++;
        begin
            static int i = 42;
            r1 = real'(i);
            if (r1 == 42.0) begin
                pass_count++;
                $display("Test 11 PASS: real'(42) = %f", r1);
            end else begin
                $display("Test 11 FAIL: Cast unexpected = %f", r1);
            end
        end

        // Test 12: Scientific notation
        test_count++;
        r1 = 1.5e3;
        if (r1 == 1500.0) begin
            pass_count++;
            $display("Test 12 PASS: 1.5e3 = %f", r1);
        end else begin
            $display("Test 12 FAIL: Scientific unexpected = %f", r1);
        end

        // Test 13: Small real
        test_count++;
        r1 = 0.001;
        if (r1 < 0.01 && r1 > 0.0) begin
            pass_count++;
            $display("Test 13 PASS: small = %f", r1);
        end else begin
            $display("Test 13 FAIL");
        end

        // Test 14: Zero real
        test_count++;
        r1 = 0.0;
        if (r1 == 0.0) begin
            pass_count++;
            $display("Test 14 PASS: zero = %f", r1);
        end else begin
            $display("Test 14 FAIL");
        end

        // Test 15: Real in expression
        test_count++;
        r_result = 2.0 * 3.14159 * 5.0;
        if (r_result > 31.0 && r_result < 32.0) begin
            pass_count++;
            $display("Test 15 PASS: 2*pi*5 = %f", r_result);
        end else begin
            $display("Test 15 FAIL: Expression unexpected = %f", r_result);
        end

        // Test 16: Real comparison equal
        test_count++;
        r1 = 1.0;
        r2 = 1.0;
        if (r1 == r2) begin
            pass_count++;
            $display("Test 16 PASS: 1.0 == 1.0");
        end else begin
            $display("Test 16 FAIL");
        end

        // Test 17: Real chain ops
        test_count++;
        r_result = 10.0 + 5.0 - 3.0;
        if (r_result == 12.0) begin
            pass_count++;
            $display("Test 17 PASS: 10+5-3 = %f", r_result);
        end else begin
            $display("Test 17 FAIL: Chain unexpected = %f", r_result);
        end

        // Test 18: Large real
        test_count++;
        r1 = 1.0e10;
        if (r1 > 1.0e9) begin
            pass_count++;
            $display("Test 18 PASS: Large = %e", r1);
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: Negative multiply
        test_count++;
        r_result = -2.0 * 3.0;
        if (r_result == -6.0) begin
            pass_count++;
            $display("Test 19 PASS: -2*3 = %f", r_result);
        end else begin
            $display("Test 19 FAIL");
        end

        $display("=== Real Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
