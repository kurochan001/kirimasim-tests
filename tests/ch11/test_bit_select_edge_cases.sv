/*
:name: test_bit_select_edge_cases
:description: Test: Bit select edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_select_edge_cases.expected
*/
// Test: Bit select edge cases
// IEEE 1800-2023 Section 11.5.1 Vector bit-select
// Tests corner cases: bit selection operations

`timescale 1ns/1ps

module test_bit_select_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] vec;
    logic bit_val;
    int idx;

    initial begin
        $display("TEST: Bit select edge cases");

        // Test 1: LSB select
        begin
            vec = 8'b10101011;
            bit_val = vec[0];
            if (bit_val == 1'b1) begin
                $display("  [PASS] LSB select");
                passed++;
            end else begin
                $display("  [FAIL] LSB: %b", bit_val);
                failed++;
            end
        end

        // Test 2: MSB select
        begin
            vec = 8'b10101011;
            bit_val = vec[7];
            if (bit_val == 1'b1) begin
                $display("  [PASS] MSB select");
                passed++;
            end else begin
                $display("  [FAIL] MSB: %b", bit_val);
                failed++;
            end
        end

        // Test 3: Middle bit select
        begin
            vec = 8'b00010000;
            bit_val = vec[4];
            if (bit_val == 1'b1) begin
                $display("  [PASS] Middle bit select");
                passed++;
            end else begin
                $display("  [FAIL] Middle: %b", bit_val);
                failed++;
            end
        end

        // Test 4: Variable index select
        begin
            vec = 8'b00100000;
            idx = 5;
            bit_val = vec[idx];
            if (bit_val == 1'b1) begin
                $display("  [PASS] Variable index select");
                passed++;
            end else begin
                $display("  [FAIL] VarIdx: %b", bit_val);
                failed++;
            end
        end

        // Test 5: Bit select write
        begin
            vec = 8'b00000000;
            vec[3] = 1'b1;
            if (vec == 8'b00001000) begin
                $display("  [PASS] Bit select write");
                passed++;
            end else begin
                $display("  [FAIL] Write: %b", vec);
                failed++;
            end
        end

        // Test 6: All zeros bit select
        begin
            vec = 8'b00000000;
            bit_val = vec[4];
            if (bit_val == 1'b0) begin
                $display("  [PASS] All zeros bit select");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %b", bit_val);
                failed++;
            end
        end

        // Test 7: All ones bit select
        begin
            vec = 8'hFF;
            bit_val = vec[6];
            if (bit_val == 1'b1) begin
                $display("  [PASS] All ones bit select");
                passed++;
            end else begin
                $display("  [FAIL] Ones: %b", bit_val);
                failed++;
            end
        end

        // Test 8: Multiple bit select
        begin
            vec = 8'b10110100;
            if (vec[7] == 1'b1 && vec[5] == 1'b1 && vec[4] == 1'b1 && vec[2] == 1'b1) begin
                $display("  [PASS] Multiple bit select");
                passed++;
            end else begin
                $display("  [FAIL] MultiBit");
                failed++;
            end
        end

        // Test 9: Bit select expression
        begin
            vec = 8'b11110000;
            idx = 2;
            bit_val = vec[idx + 2];  // vec[4]
            if (bit_val == 1'b1) begin
                $display("  [PASS] Bit select expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %b", bit_val);
                failed++;
            end
        end

        // Test 10: Consecutive bit select
        begin
            vec = 8'b10101010;
            if (vec[1] == 1'b1 && vec[3] == 1'b1 && vec[5] == 1'b1 && vec[7] == 1'b1) begin
                $display("  [PASS] Consecutive bit select");
                passed++;
            end else begin
                $display("  [FAIL] Consec");
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
