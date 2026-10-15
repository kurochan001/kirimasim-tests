/*
:name: test_case_stmt_edge_cases
:description: Test: Case statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_stmt_edge_cases.expected
*/
// Test: Case statement edge cases
// IEEE 1800-2023 Section 12.5 Case statement
// Tests corner cases: case statement

`timescale 1ns/1ps

module test_case_stmt_edge_cases;
    int passed = 0;
    int failed = 0;

    int sel;
    int result;

    initial begin
        $display("TEST: Case statement edge cases");

        // Test 1: Case first match
        begin
            sel = 0;
            case (sel)
                0: result = 100;
                1: result = 200;
                default: result = 0;
            endcase
            if (result == 100) begin
                $display("  [PASS] Case first match");
                passed++;
            end else begin
                $display("  [FAIL] First: %0d", result);
                failed++;
            end
        end

        // Test 2: Case second match
        begin
            sel = 1;
            case (sel)
                0: result = 100;
                1: result = 200;
                default: result = 0;
            endcase
            if (result == 200) begin
                $display("  [PASS] Case second match");
                passed++;
            end else begin
                $display("  [FAIL] Second: %0d", result);
                failed++;
            end
        end

        // Test 3: Case default
        begin
            sel = 99;
            case (sel)
                0: result = 100;
                1: result = 200;
                default: result = 999;
            endcase
            if (result == 999) begin
                $display("  [PASS] Case default");
                passed++;
            end else begin
                $display("  [FAIL] Default: %0d", result);
                failed++;
            end
        end

        // Test 4: Case multiple values
        begin
            sel = 3;
            case (sel)
                1, 2, 3: result = 123;
                4, 5, 6: result = 456;
                default: result = 0;
            endcase
            if (result == 123) begin
                $display("  [PASS] Case multiple values");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", result);
                failed++;
            end
        end

        // Test 5: Case negative
        begin
            sel = -1;
            case (sel)
                -1: result = 111;
                0: result = 222;
                1: result = 333;
                default: result = 0;
            endcase
            if (result == 111) begin
                $display("  [PASS] Case negative");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", result);
                failed++;
            end
        end

        // Test 6: Case with expression
        begin
            static int a = 5;
            static int b = 3;
            case (a + b)
                7: result = 7;
                8: result = 8;
                9: result = 9;
                default: result = 0;
            endcase
            if (result == 8) begin
                $display("  [PASS] Case with expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
                failed++;
            end
        end

        // Test 7: Case fall through check
        begin
            sel = 0;
            result = 0;
            case (sel)
                0: begin result = 1; end
                1: begin result = 2; end
            endcase
            if (result == 1) begin
                $display("  [PASS] Case fall through check");
                passed++;
            end else begin
                $display("  [FAIL] Fall: %0d", result);
                failed++;
            end
        end

        // Test 8: Case large value
        begin
            sel = 1000;
            case (sel)
                100: result = 1;
                1000: result = 10;
                10000: result = 100;
                default: result = 0;
            endcase
            if (result == 10) begin
                $display("  [PASS] Case large value");
                passed++;
            end else begin
                $display("  [FAIL] Large: %0d", result);
                failed++;
            end
        end

        // Test 9: Case zero
        begin
            sel = 0;
            case (sel)
                0: result = 777;
                default: result = 0;
            endcase
            if (result == 777) begin
                $display("  [PASS] Case zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", result);
                failed++;
            end
        end

        // Test 10: Nested case
        begin
            static int a = 1;
            static int b = 2;
            case (a)
                1: begin
                    case (b)
                        1: result = 11;
                        2: result = 12;
                        default: result = 10;
                    endcase
                end
                default: result = 0;
            endcase
            if (result == 12) begin
                $display("  [PASS] Nested case");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
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
