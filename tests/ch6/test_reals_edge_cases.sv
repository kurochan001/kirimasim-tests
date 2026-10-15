/*
:name: test_reals_edge_cases
:description: real arithmetic and casts between real and int
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reals_edge_cases.expected
*/
// real arithmetic and casts between real and int
// IEEE 1800-2023 Section 6.12 Real Numbers
// Tests corner cases: real arithmetic, comparisons, casting

`timescale 1ns/1ps

module test_reals_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Real numbers edge cases");

        // Test 1: Real assignment
        begin
            static real r = 3.14159;
            if (r > 3.14 && r < 3.15) begin
                $display("  [PASS] Real assignment");
                passed++;
            end else begin
                $display("  [FAIL] Real assign: %f", r);
                failed++;
            end
        end

        // Test 2: Real addition
        begin
            static real a = 1.5;
            static real b = 2.5;
            static real c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = a + b;
            if (c == 4.0) begin
                $display("  [PASS] Real addition");
                passed++;
            end else begin
                $display("  [FAIL] Addition: %f", c);
                failed++;
            end
        end

        // Test 3: Real subtraction
        begin
            static real a = 5.5;
            static real b = 2.5;
            static real c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = a - b;
            if (c == 3.0) begin
                $display("  [PASS] Real subtraction");
                passed++;
            end else begin
                $display("  [FAIL] Subtraction: %f", c);
                failed++;
            end
        end

        // Test 4: Real multiplication
        begin
            static real a = 2.5;
            static real b = 4.0;
            static real c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = a * b;
            if (c == 10.0) begin
                $display("  [PASS] Real multiplication");
                passed++;
            end else begin
                $display("  [FAIL] Multiplication: %f", c);
                failed++;
            end
        end

        // Test 5: Real division
        begin
            static real a = 10.0;
            static real b = 4.0;
            static real c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = a / b;
            if (c == 2.5) begin
                $display("  [PASS] Real division");
                passed++;
            end else begin
                $display("  [FAIL] Division: %f", c);
                failed++;
            end
        end

        // Test 6: Real comparison
        begin
            static real a = 1.5;
            static real b = 2.5;
            if (a < b && b > a) begin
                $display("  [PASS] Real comparison");
                passed++;
            end else begin
                $display("  [FAIL] Comparison");
                failed++;
            end
        end

        // Test 7: Negative real
        begin
            static real r = -3.5;
            if (r < 0) begin
                $display("  [PASS] Negative real");
                passed++;
            end else begin
                $display("  [FAIL] Negative: %f", r);
                failed++;
            end
        end

        // Test 8: Real to int cast
        begin
            static real r = 7.9;
            static int i;
            // Assigned here so the result does not depend on the order of static initializers.
            i = int'(r);
            if (i == 8) begin
                $display("  [PASS] Real to int cast (round)");
                passed++;
            end else begin
                $display("  [FAIL] Cast: %0d", i);
                failed++;
            end
        end

        // Test 9: Int to real cast
        begin
            static int i = 42;
            static real r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = real'(i);
            if (r == 42.0) begin
                $display("  [PASS] Int to real cast");
                passed++;
            end else begin
                $display("  [FAIL] Int to real: %f", r);
                failed++;
            end
        end

        // Test 10: Real in conditional
        begin
            static real val = 0.5;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = (val > 0.0) ? 1 : 0;
            if (result == 1) begin
                $display("  [PASS] Real in conditional");
                passed++;
            end else begin
                $display("  [FAIL] Conditional");
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $fatal(1, "TEST FAILED");
        end
    end
endmodule
