/*
:name: test_real_literal_edge_cases
:description: Test: Real literal edge cases
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.2 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_literal_edge_cases.expected
*/
// Test: Real literal edge cases
// IEEE 1800-2023 Section 5.7.2 Real Literal
// Tests corner cases: real literals

`timescale 1ns/1ps

module test_real_literal_edge_cases;
    int passed = 0;
    int failed = 0;

    real r;

    initial begin
        $display("TEST: Real literal edge cases");

        // Test 1: Simple real
        begin
            r = 3.14;
            if (r > 3.13 && r < 3.15) begin
                $display("  [PASS] Simple real");
                passed++;
            end else begin
                $display("  [FAIL] Simple: %f", r);
                failed++;
            end
        end

        // Test 2: Scientific notation
        begin
            r = 1.5e3;
            if (r == 1500.0) begin
                $display("  [PASS] Scientific notation");
                passed++;
            end else begin
                $display("  [FAIL] Sci: %f", r);
                failed++;
            end
        end

        // Test 3: Negative exponent
        begin
            r = 1.5e-2;
            if (r > 0.014 && r < 0.016) begin
                $display("  [PASS] Negative exponent");
                passed++;
            end else begin
                $display("  [FAIL] NegExp: %f", r);
                failed++;
            end
        end

        // Test 4: Zero real
        begin
            r = 0.0;
            if (r == 0.0) begin
                $display("  [PASS] Zero real");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %f", r);
                failed++;
            end
        end

        // Test 5: Negative real
        begin
            r = -2.5;
            if (r < -2.4 && r > -2.6) begin
                $display("  [PASS] Negative real");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %f", r);
                failed++;
            end
        end

        // Test 6: Integer to real
        begin
            r = 42;
            if (r == 42.0) begin
                $display("  [PASS] Integer to real");
                passed++;
            end else begin
                $display("  [FAIL] IntReal: %f", r);
                failed++;
            end
        end

        // Test 7: Real addition
        begin
            static real a = 1.5;
            static real b = 2.5;
            r = a + b;
            if (r == 4.0) begin
                $display("  [PASS] Real addition");
                passed++;
            end else begin
                $display("  [FAIL] Add: %f", r);
                failed++;
            end
        end

        // Test 8: Real multiplication
        begin
            r = 2.5 * 4.0;
            if (r == 10.0) begin
                $display("  [PASS] Real multiplication");
                passed++;
            end else begin
                $display("  [FAIL] Mult: %f", r);
                failed++;
            end
        end

        // Test 9: Real comparison
        begin
            static real a = 1.0;
            static real b = 2.0;
            if (a < b) begin
                $display("  [PASS] Real comparison");
                passed++;
            end else begin
                $display("  [FAIL] Compare failed");
                failed++;
            end
        end

        // Test 10: Large real
        begin
            r = 1.0e10;
            if (r > 9.9e9) begin
                $display("  [PASS] Large real");
                passed++;
            end else begin
                $display("  [FAIL] Large: %e", r);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
