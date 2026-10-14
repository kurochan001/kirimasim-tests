/*
:name: test_casex_casez_wildcard
:description: casex/casez Wildcard Matching Test
:tags: case
:type: simulation
:lrm: 1800-2023 12.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_casex_casez_wildcard.expected
*/
// IEEE 1800-2023 §12.5.2 casex/casez Wildcard Matching Test

module test_casex_casez_wildcard;
    logic [3:0] data;
    int passed = 0;
    int failed = 0;
    string result;

    initial begin
        $display("=== casex/casez Wildcard Test (IEEE 1800-2023 §12.5.2) ===");

        // Test 1: casez with Z wildcard in pattern
        data = 4'b1010;
        result = "";
        casez (data)
            4'b1???: result = "match_1xxx";
            4'b0???: result = "match_0xxx";
            default: result = "no_match";
        endcase
        if (result == "match_1xxx") begin
            $display("PASS: casez 1010 matched 1??? pattern");
            passed++;
        end else begin
            $display("FAIL: casez 1010 did not match 1??? (got: %s)", result);
            failed++;
        end

        // Test 2: casez with Z in data
        data = 4'b10z1;
        result = "";
        casez (data)
            4'b1001: result = "match_1001";
            4'b1011: result = "match_1011";
            default: result = "no_match";
        endcase
        // Z in data acts as wildcard - should match either 1001 or 1011 (first match wins)
        if (result == "match_1001") begin
            $display("PASS: casez 10z1 matched first pattern 1001");
            passed++;
        end else begin
            $display("FAIL: casez 10z1 did not match as expected (got: %s)", result);
            failed++;
        end

        // Test 3: casex with X wildcard in pattern
        data = 4'b1100;
        result = "";
        casex (data)
            4'b11xx: result = "match_11xx";
            4'b10xx: result = "match_10xx";
            default: result = "no_match";
        endcase
        if (result == "match_11xx") begin
            $display("PASS: casex 1100 matched 11xx pattern");
            passed++;
        end else begin
            $display("FAIL: casex 1100 did not match 11xx (got: %s)", result);
            failed++;
        end

        // Test 4: casex with X in data
        data = 4'b1x00;
        result = "";
        casex (data)
            4'b1100: result = "match_1100";
            4'b1000: result = "match_1000";
            default: result = "no_match";
        endcase
        // X in data acts as wildcard - should match either 1100 or 1000 (first match wins)
        if (result == "match_1100") begin
            $display("PASS: casex 1x00 matched first pattern 1100");
            passed++;
        end else begin
            $display("FAIL: casex 1x00 did not match as expected (got: %s)", result);
            failed++;
        end

        // Test 5: casez with specific value
        data = 4'b0101;
        result = "";
        casez (data)
            4'b0101: result = "exact_match";
            4'b01??: result = "partial_match";
            default: result = "no_match";
        endcase
        if (result == "exact_match") begin
            $display("PASS: casez 0101 exact match");
            passed++;
        end else begin
            $display("FAIL: casez 0101 did not exact match (got: %s)", result);
            failed++;
        end

        // Test 6: casex with Z treated as wildcard
        data = 4'b1z10;
        result = "";
        casex (data)
            4'b1010: result = "match_1010";
            4'b1110: result = "match_1110";
            default: result = "no_match";
        endcase
        // In casex, Z in data is treated as wildcard (like X)
        if (result == "match_1010") begin
            $display("PASS: casex 1z10 matched 1010 (Z as wildcard)");
            passed++;
        end else begin
            $display("FAIL: casex 1z10 did not match as expected (got: %s)", result);
            failed++;
        end

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
