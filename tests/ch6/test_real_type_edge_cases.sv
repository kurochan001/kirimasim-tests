/*
:name: test_real_type_edge_cases
:description: real arithmetic, comparison and casting
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_type_edge_cases.expected
*/
// IEEE 1800-2023 §6.12: Real type edge cases
// Tests for real number types

module test_real_type_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    real r1, r2, result;
    realtime rt;
    shortreal sr;

    initial begin
        r1 = 0.0;
        r2 = 0.0;
        #1;

        // Test 1: Basic assignment
        test_count++;
        r1 = 3.14159;
        if (r1 > 3.14 && r1 < 3.15) begin
            pass_count++;
            $display("Test 1 PASS: r1 = %f", r1);
        end else begin
            $display("Test 1 FAIL: Assign unexpected");
        end

        // Test 2: Addition
        test_count++;
        r1 = 1.5;
        r2 = 2.5;
        result = r1 + r2;
        if (result == 4.0) begin
            pass_count++;
            $display("Test 2 PASS: 1.5+2.5 = %f", result);
        end else begin
            $display("Test 2 FAIL: Add unexpected = %f", result);
        end

        // Test 3: Multiplication
        test_count++;
        result = r1 * r2;
        if (result == 3.75) begin
            pass_count++;
            $display("Test 3 PASS: 1.5*2.5 = %f", result);
        end else begin
            $display("Test 3 FAIL: Mult unexpected = %f", result);
        end

        // Test 4: Division
        test_count++;
        result = r2 / r1;
        if (result > 1.66 && result < 1.67) begin
            pass_count++;
            $display("Test 4 PASS: 2.5/1.5 = %f", result);
        end else begin
            $display("Test 4 FAIL: Div unexpected = %f", result);
        end

        // Test 5: Negative
        test_count++;
        r1 = -5.5;
        if (r1 < 0) begin
            pass_count++;
            $display("Test 5 PASS: Negative = %f", r1);
        end else begin
            $display("Test 5 FAIL: Neg unexpected = %f", r1);
        end

        // Test 6: Zero
        test_count++;
        r1 = 0.0;
        if (r1 == 0.0) begin
            pass_count++;
            $display("Test 6 PASS: Zero = %f", r1);
        end else begin
            $display("Test 6 FAIL: Zero unexpected = %f", r1);
        end

        // Test 7: Large number
        test_count++;
        r1 = 1.0e10;
        if (r1 > 9e9) begin
            pass_count++;
            $display("Test 7 PASS: Large = %e", r1);
        end else begin
            $display("Test 7 FAIL: Large unexpected");
        end

        // Test 8: Small number
        test_count++;
        r1 = 1.0e-10;
        if (r1 < 1e-9) begin
            pass_count++;
            $display("Test 8 PASS: Small = %e", r1);
        end else begin
            $display("Test 8 FAIL: Small unexpected");
        end

        // Test 9: Cast from int
        test_count++;
        begin
            static int i = 42;
            r1 = real'(i);
            if (r1 == 42.0) begin
                pass_count++;
                $display("Test 9 PASS: Cast int = %f", r1);
            end else begin
                $display("Test 9 FAIL: Cast unexpected = %f", r1);
            end
        end

        // Test 10: Comparison
        test_count++;
        r1 = 1.5;
        r2 = 2.5;
        if (r1 < r2) begin
            pass_count++;
            $display("Test 10 PASS: 1.5 < 2.5");
        end else begin
            $display("Test 10 FAIL: Cmp unexpected");
        end

        $display("=== Real Type Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
