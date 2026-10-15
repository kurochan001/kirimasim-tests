/*
:name: test_real_ops_edge_cases
:description: real arithmetic, comparison and conversion with $rtoi and $itor
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_ops_edge_cases.expected
*/
// real arithmetic, comparison and conversion with $rtoi and $itor
// IEEE 1800-2023 Section 6.12 Real, shortreal, and realtime
// Tests corner cases: real number operations

`timescale 1ns/1ps

module test_real_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        real r1, r2, r3;
        shortreal sr;
        int i;
        logic [63:0] bits;

        $display("TEST: Real number operations edge cases");

        // Test 1: Real assignment
        begin
            r1 = 3.14159;
            if (r1 > 3.14 && r1 < 3.15) begin
                $display("  [PASS] Real assignment");
                passed++;
            end else begin
                $display("  [FAIL] Assign: %f", r1);
                failed++;
            end
        end

        // Test 2: Real addition
        begin
            r1 = 1.5;
            r2 = 2.5;
            r3 = r1 + r2;
            if (r3 > 3.9 && r3 < 4.1) begin
                $display("  [PASS] Real addition");
                passed++;
            end else begin
                $display("  [FAIL] Add: %f", r3);
                failed++;
            end
        end

        // Test 3: Real subtraction
        begin
            r1 = 5.5;
            r2 = 2.5;
            r3 = r1 - r2;
            if (r3 > 2.9 && r3 < 3.1) begin
                $display("  [PASS] Real subtraction");
                passed++;
            end else begin
                $display("  [FAIL] Sub: %f", r3);
                failed++;
            end
        end

        // Test 4: Real multiplication
        begin
            r1 = 2.0;
            r2 = 3.0;
            r3 = r1 * r2;
            if (r3 > 5.9 && r3 < 6.1) begin
                $display("  [PASS] Real multiplication");
                passed++;
            end else begin
                $display("  [FAIL] Mul: %f", r3);
                failed++;
            end
        end

        // Test 5: Real division
        begin
            r1 = 10.0;
            r2 = 4.0;
            r3 = r1 / r2;
            if (r3 > 2.4 && r3 < 2.6) begin
                $display("  [PASS] Real division");
                passed++;
            end else begin
                $display("  [FAIL] Div: %f", r3);
                failed++;
            end
        end

        // Test 6: Real to int conversion
        begin
            r1 = 42.7;
            i = $rtoi(r1);
            if (i == 42) begin
                $display("  [PASS] Real to int conversion");
                passed++;
            end else begin
                $display("  [FAIL] RtoI: %0d", i);
                failed++;
            end
        end

        // Test 7: Int to real conversion
        begin
            i = 100;
            r1 = $itor(i);
            if (r1 > 99.9 && r1 < 100.1) begin
                $display("  [PASS] Int to real conversion");
                passed++;
            end else begin
                $display("  [FAIL] ItoR: %f", r1);
                failed++;
            end
        end

        // Test 8: Real comparison
        begin
            r1 = 1.0;
            r2 = 2.0;
            if (r1 < r2 && r2 > r1) begin
                $display("  [PASS] Real comparison");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 9: Real negation
        begin
            r1 = 5.0;
            r2 = -r1;
            if (r2 < -4.9 && r2 > -5.1) begin
                $display("  [PASS] Real negation");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %f", r2);
                failed++;
            end
        end

        // Test 10: Real zero
        begin
            r1 = 0.0;
            if (r1 == 0.0) begin
                $display("  [PASS] Real zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %f", r1);
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
