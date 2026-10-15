/*
:name: test_unique_priority_edge_cases
:description: Test: Unique/priority case/if edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3 12.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_priority_edge_cases.expected
*/
// Test: Unique/priority case/if edge cases
// IEEE 1800-2023 Section 12.5 Unique, unique0, and priority
// Tests corner cases: unique and priority constructs

`timescale 1ns/1ps

module test_unique_priority_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int val;
        int result;

        $display("TEST: Unique/priority edge cases");

        // Test 1: Priority case basic
        begin
            val = 2;
            priority case (val)
                1: result = 10;
                2: result = 20;
                3: result = 30;
            endcase
            if (result == 20) begin
                $display("  [PASS] Priority case basic");
                passed++;
            end else begin
                $display("  [FAIL] PrioCase: %0d", result);
                failed++;
            end
        end

        // Test 2: Priority if basic
        begin
            val = 5;
            result = 0;
            priority if (val > 10)
                result = 1;
            else if (val > 3)
                result = 2;
            else
                result = 3;
            if (result == 2) begin
                $display("  [PASS] Priority if basic");
                passed++;
            end else begin
                $display("  [FAIL] PrioIf: %0d", result);
                failed++;
            end
        end

        // Test 3: Unique case basic
        begin
            val = 3;
            unique case (val)
                1: result = 100;
                2: result = 200;
                3: result = 300;
                default: result = 0;
            endcase
            if (result == 300) begin
                $display("  [PASS] Unique case basic");
                passed++;
            end else begin
                $display("  [FAIL] UniqueCase: %0d", result);
                failed++;
            end
        end

        // Test 4: Unique if basic
        begin
            val = 1;
            result = 0;
            unique if (val == 1)
                result = 10;
            else if (val == 2)
                result = 20;
            else
                result = 30;
            if (result == 10) begin
                $display("  [PASS] Unique if basic");
                passed++;
            end else begin
                $display("  [FAIL] UniqueIf: %0d", result);
                failed++;
            end
        end

        // Test 5: Priority case with default
        begin
            val = 99;
            priority case (val)
                1: result = 1;
                2: result = 2;
                default: result = 99;
            endcase
            if (result == 99) begin
                $display("  [PASS] Priority case with default");
                passed++;
            end else begin
                $display("  [FAIL] PrioDef: %0d", result);
                failed++;
            end
        end

        // Test 6: Unique case first match
        begin
            val = 1;
            unique case (val)
                1: result = 11;
                2: result = 22;
                3: result = 33;
                default: result = 0;
            endcase
            if (result == 11) begin
                $display("  [PASS] Unique case first match");
                passed++;
            end else begin
                $display("  [FAIL] UniqueFirst: %0d", result);
                failed++;
            end
        end

        // Test 7: Priority if else
        begin
            val = 0;
            priority if (val > 0)
                result = 1;
            else
                result = 0;
            if (result == 0) begin
                $display("  [PASS] Priority if else");
                passed++;
            end else begin
                $display("  [FAIL] PrioElse: %0d", result);
                failed++;
            end
        end

        // Test 8: Nested priority case
        begin
            val = 2;
            priority case (val)
                1: result = 1;
                2: begin
                    priority case (1)
                        0: result = 20;
                        1: result = 21;
                    endcase
                end
            endcase
            if (result == 21) begin
                $display("  [PASS] Nested priority case");
                passed++;
            end else begin
                $display("  [FAIL] NestedPrio: %0d", result);
                failed++;
            end
        end

        // Test 9: Unique case zero
        begin
            val = 0;
            unique case (val)
                0: result = 0;
                1: result = 1;
                default: result = 99;
            endcase
            if (result == 0) begin
                $display("  [PASS] Unique case zero");
                passed++;
            end else begin
                $display("  [FAIL] UniqueZero: %0d", result);
                failed++;
            end
        end

        // Test 10: Priority if chain
        begin
            val = 50;
            priority if (val >= 100)
                result = 100;
            else if (val >= 50)
                result = 50;
            else if (val >= 25)
                result = 25;
            else
                result = 0;
            if (result == 50) begin
                $display("  [PASS] Priority if chain");
                passed++;
            end else begin
                $display("  [FAIL] PrioChain: %0d", result);
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
