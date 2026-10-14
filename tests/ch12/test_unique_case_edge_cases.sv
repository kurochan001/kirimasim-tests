/*
:name: test_unique_case_edge_cases
:description: Test: Unique/priority case edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_case_edge_cases.expected
*/
// Test: Unique/priority case edge cases
// IEEE 1800-2023 Section 12.5.3 Unique and Priority
// Tests corner cases: unique case, priority case

`timescale 1ns/1ps

module test_unique_case_edge_cases;
    int passed = 0;
    int failed = 0;

    int sel;
    int result;

    initial begin
        $display("TEST: Unique/priority case edge cases");

        // Test 1: Unique case match first
        begin
            sel = 0;
            unique case (sel)
                0: result = 100;
                1: result = 200;
                2: result = 300;
                default: result = -1;
            endcase
            if (result == 100) begin
                $display("  [PASS] Unique case first");
                passed++;
            end else begin
                $display("  [FAIL] First: %0d", result);
                failed++;
            end
        end

        // Test 2: Unique case match middle
        begin
            sel = 1;
            unique case (sel)
                0: result = 100;
                1: result = 200;
                2: result = 300;
                default: result = -1;
            endcase
            if (result == 200) begin
                $display("  [PASS] Unique case middle");
                passed++;
            end else begin
                $display("  [FAIL] Middle: %0d", result);
                failed++;
            end
        end

        // Test 3: Unique case match last
        begin
            sel = 2;
            unique case (sel)
                0: result = 100;
                1: result = 200;
                2: result = 300;
                default: result = -1;
            endcase
            if (result == 300) begin
                $display("  [PASS] Unique case last");
                passed++;
            end else begin
                $display("  [FAIL] Last: %0d", result);
                failed++;
            end
        end

        // Test 4: Unique case default
        begin
            sel = 99;
            unique case (sel)
                0: result = 100;
                1: result = 200;
                2: result = 300;
                default: result = -1;
            endcase
            if (result == -1) begin
                $display("  [PASS] Unique case default");
                passed++;
            end else begin
                $display("  [FAIL] Default: %0d", result);
                failed++;
            end
        end

        // Test 5: Priority case first
        begin
            sel = 0;
            priority case (sel)
                0: result = 10;
                1: result = 20;
                default: result = 0;
            endcase
            if (result == 10) begin
                $display("  [PASS] Priority case first");
                passed++;
            end else begin
                $display("  [FAIL] PriFirst: %0d", result);
                failed++;
            end
        end

        // Test 6: Priority case second
        begin
            sel = 1;
            priority case (sel)
                0: result = 10;
                1: result = 20;
                default: result = 0;
            endcase
            if (result == 20) begin
                $display("  [PASS] Priority case second");
                passed++;
            end else begin
                $display("  [FAIL] PriSec: %0d", result);
                failed++;
            end
        end

        // Test 7: Priority case default
        begin
            sel = 5;
            priority case (sel)
                0: result = 10;
                1: result = 20;
                default: result = 0;
            endcase
            if (result == 0) begin
                $display("  [PASS] Priority default");
                passed++;
            end else begin
                $display("  [FAIL] PriDef: %0d", result);
                failed++;
            end
        end

        // Test 8: Case with expressions
        begin
            static int a = 2;
            static int b = 3;
            sel = a + b;
            unique case (sel)
                4: result = 40;
                5: result = 50;
                6: result = 60;
                default: result = 0;
            endcase
            if (result == 50) begin
                $display("  [PASS] Case with expr");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
                failed++;
            end
        end

        // Test 9: Negative selector
        begin
            sel = -1;
            unique case (sel)
                -1: result = 1;
                0: result = 0;
                1: result = 11;
                default: result = -99;
            endcase
            if (result == 1) begin
                $display("  [PASS] Negative selector");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", result);
                failed++;
            end
        end

        // Test 10: Zero selector
        begin
            sel = 0;
            unique case (sel)
                0: result = 1000;
                default: result = 0;
            endcase
            if (result == 1000) begin
                $display("  [PASS] Zero selector");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", result);
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
