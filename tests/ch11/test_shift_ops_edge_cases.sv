/*
:name: test_shift_ops_edge_cases
:description: Logical and arithmetic shifts, a variable amount and chained shifts
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_ops_edge_cases.expected
*/
// Logical and arithmetic shifts, a variable amount and chained shifts
// IEEE 1800-2023 Section 11.4.10 Shift operators
// Tests corner cases: shift operations

`timescale 1ns/1ps

module test_shift_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] vec;
    logic signed [7:0] svec;
    logic [7:0] result;

    initial begin
        $display("TEST: Shift operations edge cases");

        // Test 1: Left shift by 1
        begin
            vec = 8'b00000001;
            result = vec << 1;
            if (result == 8'b00000010) begin
                $display("  [PASS] Left shift by 1");
                passed++;
            end else begin
                $display("  [FAIL] LSh1: %b", result);
                failed++;
            end
        end

        // Test 2: Right shift by 1
        begin
            vec = 8'b10000000;
            result = vec >> 1;
            if (result == 8'b01000000) begin
                $display("  [PASS] Right shift by 1");
                passed++;
            end else begin
                $display("  [FAIL] RSh1: %b", result);
                failed++;
            end
        end

        // Test 3: Left shift by 4
        begin
            vec = 8'b00001111;
            result = vec << 4;
            if (result == 8'b11110000) begin
                $display("  [PASS] Left shift by 4");
                passed++;
            end else begin
                $display("  [FAIL] LSh4: %b", result);
                failed++;
            end
        end

        // Test 4: Right shift by 4
        begin
            vec = 8'b11110000;
            result = vec >> 4;
            if (result == 8'b00001111) begin
                $display("  [PASS] Right shift by 4");
                passed++;
            end else begin
                $display("  [FAIL] RSh4: %b", result);
                failed++;
            end
        end

        // Test 5: Shift by 0
        begin
            vec = 8'b10101010;
            result = vec << 0;
            if (result == 8'b10101010) begin
                $display("  [PASS] Shift by 0");
                passed++;
            end else begin
                $display("  [FAIL] Sh0: %b", result);
                failed++;
            end
        end

        // Test 6: Shift out all bits
        begin
            vec = 8'b11111111;
            result = vec << 8;
            if (result == 8'b00000000) begin
                $display("  [PASS] Shift out all bits");
                passed++;
            end else begin
                $display("  [FAIL] ShOut: %b", result);
                failed++;
            end
        end

        // Test 7: Arithmetic right shift positive
        begin
            svec = 8'sb01000000;  // +64
            result = svec >>> 2;
            if (result == 8'b00010000) begin
                $display("  [PASS] Arithmetic right shift positive");
                passed++;
            end else begin
                $display("  [FAIL] ArshPos: %b", result);
                failed++;
            end
        end

        // Test 8: Arithmetic right shift negative
        begin
            svec = 8'sb10000000;  // -128
            svec = svec >>> 2;
            if (svec == 8'sb11100000) begin
                $display("  [PASS] Arithmetic right shift negative");
                passed++;
            end else begin
                $display("  [FAIL] ArshNeg: %b", svec);
                failed++;
            end
        end

        // Test 9: Variable shift amount
        begin
            static int shift_amt = 3;
            vec = 8'b00000001;
            result = vec << shift_amt;
            if (result == 8'b00001000) begin
                $display("  [PASS] Variable shift amount");
                passed++;
            end else begin
                $display("  [FAIL] VarSh: %b", result);
                failed++;
            end
        end

        // Test 10: Chained shifts
        begin
            vec = 8'b00001111;
            result = (vec << 2) >> 1;
            if (result == 8'b00011110) begin
                $display("  [PASS] Chained shifts");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %b", result);
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
