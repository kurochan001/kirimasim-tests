/*
:name: test_sscanf_ops_edge_cases
:description: Test: $sscanf operations edge cases
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_ops_edge_cases.expected
*/
// Test: $sscanf operations edge cases
// IEEE 1800-2023 Section 21.3.4.3 $sscanf
// Tests corner cases: string scanning

`timescale 1ns/1ps

module test_sscanf_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        string s;
        int i1, i2, i3;
        int count;

        $display("TEST: $sscanf operations edge cases");

        // Test 1: Basic integer scan
        begin
            s = "42";
            count = $sscanf(s, "%d", i1);
            if (count == 1 && i1 == 42) begin
                $display("  [PASS] Basic integer scan");
                passed++;
            end else begin
                $display("  [FAIL] IntScan: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 2: Multiple integers
        begin
            s = "10 20 30";
            count = $sscanf(s, "%d %d %d", i1, i2, i3);
            if (count == 3 && i1 == 10 && i2 == 20 && i3 == 30) begin
                $display("  [PASS] Multiple integers");
                passed++;
            end else begin
                $display("  [FAIL] MultiInt: %0d", count);
                failed++;
            end
        end

        // Test 3: Hex scan
        begin
            s = "FF";
            count = $sscanf(s, "%x", i1);
            if (count == 1 && i1 == 255) begin
                $display("  [PASS] Hex scan");
                passed++;
            end else begin
                $display("  [FAIL] HexScan: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 4: Octal scan
        begin
            s = "77";
            count = $sscanf(s, "%o", i1);
            if (count == 1 && i1 == 63) begin
                $display("  [PASS] Octal scan");
                passed++;
            end else begin
                $display("  [FAIL] OctScan: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 5: Binary scan
        begin
            s = "1010";
            count = $sscanf(s, "%b", i1);
            if (count == 1 && i1 == 10) begin
                $display("  [PASS] Binary scan");
                passed++;
            end else begin
                $display("  [FAIL] BinScan: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 6: Negative number
        begin
            s = "-100";
            count = $sscanf(s, "%d", i1);
            if (count == 1 && i1 == -100) begin
                $display("  [PASS] Negative number");
                passed++;
            end else begin
                $display("  [FAIL] Negative: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 7: Zero value
        begin
            s = "0";
            count = $sscanf(s, "%d", i1);
            if (count == 1 && i1 == 0) begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 8: Large number
        begin
            s = "1000000";
            count = $sscanf(s, "%d", i1);
            if (count == 1 && i1 == 1000000) begin
                $display("  [PASS] Large number");
                passed++;
            end else begin
                $display("  [FAIL] Large: %0d", i1);
                failed++;
            end
        end

        // Test 9: With prefix text
        begin
            s = "Value: 123";
            count = $sscanf(s, "Value: %d", i1);
            if (count == 1 && i1 == 123) begin
                $display("  [PASS] With prefix text");
                passed++;
            end else begin
                $display("  [FAIL] Prefix: %0d %0d", count, i1);
                failed++;
            end
        end

        // Test 10: Comma separated
        begin
            s = "5,10,15";
            count = $sscanf(s, "%d,%d,%d", i1, i2, i3);
            if (count == 3 && i1 == 5 && i2 == 10 && i3 == 15) begin
                $display("  [PASS] Comma separated");
                passed++;
            end else begin
                $display("  [FAIL] Comma: %0d", count);
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
