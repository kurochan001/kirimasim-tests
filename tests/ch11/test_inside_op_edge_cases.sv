/*
:name: test_inside_op_edge_cases
:description: Test: Inside operator edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_op_edge_cases.expected
*/
// Test: Inside operator edge cases
// IEEE 1800-2023 Section 11.4.13 Inside Operator
// Tests corner cases: inside set membership

`timescale 1ns/1ps

module test_inside_op_edge_cases;
    int passed = 0;
    int failed = 0;

    int val;
    logic result;

    initial begin
        $display("TEST: Inside operator edge cases");

        // Test 1: Inside single value
        begin
            val = 5;
            result = val inside {5};
            if (result == 1) begin
                $display("  [PASS] Inside single");
                passed++;
            end else begin
                $display("  [FAIL] Single: %b", result);
                failed++;
            end
        end

        // Test 2: Inside multiple values
        begin
            val = 3;
            result = val inside {1, 2, 3, 4, 5};
            if (result == 1) begin
                $display("  [PASS] Inside multiple");
                passed++;
            end else begin
                $display("  [FAIL] Mult: %b", result);
                failed++;
            end
        end

        // Test 3: Not inside
        begin
            val = 10;
            result = val inside {1, 2, 3};
            if (result == 0) begin
                $display("  [PASS] Not inside");
                passed++;
            end else begin
                $display("  [FAIL] NotIn: %b", result);
                failed++;
            end
        end

        // Test 4: Inside range
        begin
            val = 5;
            result = val inside {[1:10]};
            if (result == 1) begin
                $display("  [PASS] Inside range");
                passed++;
            end else begin
                $display("  [FAIL] Range: %b", result);
                failed++;
            end
        end

        // Test 5: Outside range
        begin
            val = 15;
            result = val inside {[1:10]};
            if (result == 0) begin
                $display("  [PASS] Outside range");
                passed++;
            end else begin
                $display("  [FAIL] OutR: %b", result);
                failed++;
            end
        end

        // Test 6: Range boundary low
        begin
            val = 1;
            result = val inside {[1:10]};
            if (result == 1) begin
                $display("  [PASS] Range boundary low");
                passed++;
            end else begin
                $display("  [FAIL] BndL: %b", result);
                failed++;
            end
        end

        // Test 7: Range boundary high
        begin
            val = 10;
            result = val inside {[1:10]};
            if (result == 1) begin
                $display("  [PASS] Range boundary high");
                passed++;
            end else begin
                $display("  [FAIL] BndH: %b", result);
                failed++;
            end
        end

        // Test 8: Mixed values and range
        begin
            val = 50;
            result = val inside {1, 2, [10:20], 50, 100};
            if (result == 1) begin
                $display("  [PASS] Mixed values range");
                passed++;
            end else begin
                $display("  [FAIL] Mixed: %b", result);
                failed++;
            end
        end

        // Test 9: Zero inside
        begin
            val = 0;
            result = val inside {0, 1, 2};
            if (result == 1) begin
                $display("  [PASS] Zero inside");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %b", result);
                failed++;
            end
        end

        // Test 10: Negative inside
        begin
            val = -5;
            result = val inside {-10, -5, 0, 5, 10};
            if (result == 1) begin
                $display("  [PASS] Negative inside");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %b", result);
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
