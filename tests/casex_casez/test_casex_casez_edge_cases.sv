/*
:name: test_casex_casez_edge_cases
:description: Test: Casex/casez edge cases
:tags: casex_casez
:type: simulation
:lrm: 1800-2023 12.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_casex_casez_edge_cases.expected
*/
// Test: Casex/casez edge cases
// IEEE 1800-2023 Section 12.5.4 Set Membership Case Statement
// Tests corner cases: casex, casez

`timescale 1ns/1ps

module test_casex_casez_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [3:0] sel;
    int result;

    initial begin
        $display("TEST: Casex/casez edge cases");

        // Test 1: Casez exact match
        begin
            sel = 4'b0001;
            casez (sel)
                4'b0001: result = 1;
                4'b0010: result = 2;
                default: result = 0;
            endcase
            if (result == 1) begin
                $display("  [PASS] Casez exact");
                passed++;
            end else begin
                $display("  [FAIL] CZE: %0d", result);
                failed++;
            end
        end

        // Test 2: Casez with wildcard
        begin
            sel = 4'b1010;
            casez (sel)
                4'b1???: result = 10;
                4'b0???: result = 20;
                default: result = 0;
            endcase
            if (result == 10) begin
                $display("  [PASS] Casez wildcard");
                passed++;
            end else begin
                $display("  [FAIL] CZW: %0d", result);
                failed++;
            end
        end

        // Test 3: Casez default
        begin
            sel = 4'b1111;
            casez (sel)
                4'b0000: result = 1;
                4'b0001: result = 2;
                default: result = 99;
            endcase
            if (result == 99) begin
                $display("  [PASS] Casez default");
                passed++;
            end else begin
                $display("  [FAIL] CZD: %0d", result);
                failed++;
            end
        end

        // Test 4: Casez partial wildcard
        begin
            sel = 4'b1100;
            casez (sel)
                4'b11??: result = 11;
                4'b10??: result = 10;
                default: result = 0;
            endcase
            if (result == 11) begin
                $display("  [PASS] Casez partial");
                passed++;
            end else begin
                $display("  [FAIL] CZP: %0d", result);
                failed++;
            end
        end

        // Test 5: Casex exact match
        begin
            sel = 4'b0010;
            casex (sel)
                4'b0001: result = 1;
                4'b0010: result = 2;
                default: result = 0;
            endcase
            if (result == 2) begin
                $display("  [PASS] Casex exact");
                passed++;
            end else begin
                $display("  [FAIL] CXE: %0d", result);
                failed++;
            end
        end

        // Test 6: Casex with X wildcard
        begin
            sel = 4'b0111;
            casex (sel)
                4'b0xxx: result = 100;
                4'b1xxx: result = 200;
                default: result = 0;
            endcase
            if (result == 100) begin
                $display("  [PASS] Casex X wildcard");
                passed++;
            end else begin
                $display("  [FAIL] CXX: %0d", result);
                failed++;
            end
        end

        // Test 7: Casex default
        begin
            sel = 4'b1111;
            casex (sel)
                4'b0000: result = 1;
                4'b0001: result = 2;
                default: result = 77;
            endcase
            if (result == 77) begin
                $display("  [PASS] Casex default");
                passed++;
            end else begin
                $display("  [FAIL] CXD: %0d", result);
                failed++;
            end
        end

        // Test 8: Casez first match
        begin
            sel = 4'b0000;
            casez (sel)
                4'b0000: result = 1;
                4'b????: result = 2;
                default: result = 0;
            endcase
            if (result == 1) begin
                $display("  [PASS] Casez first match");
                passed++;
            end else begin
                $display("  [FAIL] CZFM: %0d", result);
                failed++;
            end
        end

        // Test 9: Casez nibble patterns
        begin
            sel = 4'b0101;
            casez (sel)
                4'b0?0?: result = 5;
                4'b?1?1: result = 6;
                default: result = 0;
            endcase
            if (result == 5) begin
                $display("  [PASS] Casez patterns");
                passed++;
            end else begin
                $display("  [FAIL] CZPat: %0d", result);
                failed++;
            end
        end

        // Test 10: Casez all wildcards
        begin
            sel = 4'b1010;
            casez (sel)
                4'b1111: result = 1;
                4'b????: result = 2;
                default: result = 0;
            endcase
            if (result == 2) begin
                $display("  [PASS] Casez all wildcards");
                passed++;
            end else begin
                $display("  [FAIL] CZAW: %0d", result);
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
