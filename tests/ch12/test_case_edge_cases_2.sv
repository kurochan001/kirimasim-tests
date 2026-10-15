/*
:name: test_case_edge_cases_2
:description: Test: Case statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.4 12.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_edge_cases_2.expected
*/
// Test: Case statement edge cases
// IEEE 1800-2023 Section 12.5 Case Statements
// Tests corner cases: unique, priority, case inside, ranges, enum

`timescale 1ns/1ps

module test_case_edge_cases;
    int passed = 0;
    int failed = 0;

    typedef enum {STATE_IDLE, STATE_RUN, STATE_DONE, STATE_ERROR} state_t;

    initial begin
        $display("TEST: Case statement edge cases");

        // Test 1: Case with enum type
        begin
            static state_t st = STATE_RUN;
            int result;
            case (st)
                STATE_IDLE: result = 0;
                STATE_RUN: result = 1;
                STATE_DONE: result = 2;
                STATE_ERROR: result = 3;
            endcase
            if (result == 1) begin
                $display("  [PASS] Case with enum works");
                passed++;
            end else begin
                $display("  [FAIL] Case with enum should select STATE_RUN");
                failed++;
            end
        end

        // Test 2: Case inside with set membership (not ranges)
        begin
            static int val = 50;
            int result;
            case (val) inside
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9: result = 1;
                50: result = 3;
                default: result = 0;
            endcase
            if (result == 3) begin
                $display("  [PASS] Case inside with set membership works");
                passed++;
            end else begin
                $display("  [FAIL] Case inside should select 50");
                failed++;
            end
        end

        // Test 3: Case inside with multiple values
        begin
            static int val = 10;
            int result;
            case (val) inside
                1, 2, 3: result = 1;
                10, 11, 12: result = 2;
                default: result = 0;
            endcase
            if (result == 2) begin
                $display("  [PASS] Case inside multiple values works");
                passed++;
            end else begin
                $display("  [FAIL] Case inside should match 10");
                failed++;
            end
        end

        // Test 4: Case inside default fallback
        begin
            static int val = 100;
            int result;
            case (val) inside
                1, 2, 3: result = 1;
                10, 11, 12: result = 2;
                default: result = 99;
            endcase
            if (result == 99) begin
                $display("  [PASS] Case inside default fallback works");
                passed++;
            end else begin
                $display("  [FAIL] Case inside should fall back to default");
                failed++;
            end
        end

        // Test 5: Unique case (all values covered)
        begin
            static logic [1:0] sel = 2'b01;
            int result;
            unique case (sel)
                2'b00: result = 0;
                2'b01: result = 1;
                2'b10: result = 2;
                2'b11: result = 3;
            endcase
            if (result == 1) begin
                $display("  [PASS] Unique case works");
                passed++;
            end else begin
                $display("  [FAIL] Unique case should select 01");
                failed++;
            end
        end

        // Test 6: Priority case
        begin
            static logic [3:0] val = 4'b1100;
            int result;
            priority case (1'b1)
                val[3]: result = 3;
                val[2]: result = 2;
                val[1]: result = 1;
                val[0]: result = 0;
                default: result = -1;
            endcase
            if (result == 3) begin
                $display("  [PASS] Priority case selects highest priority");
                passed++;
            end else begin
                $display("  [FAIL] Priority case should select bit 3");
                failed++;
            end
        end

        // Test 7: Nested case statements
        begin
            static int a = 1, b = 2;
            int result;
            case (a)
                0: result = 0;
                1: begin
                    case (b)
                        0: result = 10;
                        1: result = 11;
                        2: result = 12;
                        default: result = 19;
                    endcase
                end
                default: result = 99;
            endcase
            if (result == 12) begin
                $display("  [PASS] Nested case statements work");
                passed++;
            end else begin
                $display("  [FAIL] Nested case should return 12");
                failed++;
            end
        end

        // Test 8: Case with negative values
        begin
            static int val = -1;
            int result;
            case (val)
                -2: result = 1;
                -1: result = 2;
                0: result = 3;
                1: result = 4;
                default: result = 0;
            endcase
            if (result == 2) begin
                $display("  [PASS] Case with negative values works");
                passed++;
            end else begin
                $display("  [FAIL] Case should match -1");
                failed++;
            end
        end

        // Test 9: Case with large values
        begin
            static int val = 32'h7FFFFFFF;  // Max positive int
            int result;
            case (val)
                32'h7FFFFFFE: result = 1;
                32'h7FFFFFFF: result = 2;
                default: result = 0;
            endcase
            if (result == 2) begin
                $display("  [PASS] Case with max int works");
                passed++;
            end else begin
                $display("  [FAIL] Case should match max int");
                failed++;
            end
        end

        // Test 10: Case with multiple defaults (only last should apply)
        // Note: IEEE allows only one default, this tests single default
        begin
            static int val = 100;
            int result;
            case (val)
                0: result = 1;
                1: result = 2;
                2: result = 3;
                default: result = -1;
            endcase
            if (result == -1) begin
                $display("  [PASS] Case default correctly selected");
                passed++;
            end else begin
                $display("  [FAIL] Default should be selected for 100");
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
