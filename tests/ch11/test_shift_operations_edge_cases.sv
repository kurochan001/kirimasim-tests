/*
:name: test_shift_operations_edge_cases
:description: Logical and arithmetic shifts of 8-bit and 16-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_operations_edge_cases.expected
*/
// Logical and arithmetic shifts of 8-bit and 16-bit values
// IEEE 1800-2023 Section 11.4.10 Shift Operators
// Tests corner cases: left/right shift, arithmetic shift

`timescale 1ns/1ps

module test_shift_operations_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] val;
    logic signed [7:0] sval;
    logic [15:0] wide;

    initial begin
        $display("TEST: Shift operations edge cases");

        // Test 1: Left shift by 1
        begin
            val = 8'h01;
            val = val << 1;
            if (val == 8'h02) begin
                $display("  [PASS] Left shift by 1");
                passed++;
            end else begin
                $display("  [FAIL] LSH1: %h", val);
                failed++;
            end
        end

        // Test 2: Left shift by 4
        begin
            val = 8'h0F;
            val = val << 4;
            if (val == 8'hF0) begin
                $display("  [PASS] Left shift by 4");
                passed++;
            end else begin
                $display("  [FAIL] LSH4: %h", val);
                failed++;
            end
        end

        // Test 3: Right shift by 1
        begin
            val = 8'h80;
            val = val >> 1;
            if (val == 8'h40) begin
                $display("  [PASS] Right shift by 1");
                passed++;
            end else begin
                $display("  [FAIL] RSH1: %h", val);
                failed++;
            end
        end

        // Test 4: Right shift by 4
        begin
            val = 8'hF0;
            val = val >> 4;
            if (val == 8'h0F) begin
                $display("  [PASS] Right shift by 4");
                passed++;
            end else begin
                $display("  [FAIL] RSH4: %h", val);
                failed++;
            end
        end

        // Test 5: Left shift overflow
        begin
            val = 8'hFF;
            val = val << 1;
            if (val == 8'hFE) begin
                $display("  [PASS] Left shift overflow");
                passed++;
            end else begin
                $display("  [FAIL] LSHO: %h", val);
                failed++;
            end
        end

        // Test 6: Right shift to zero
        begin
            val = 8'h01;
            val = val >> 1;
            if (val == 8'h00) begin
                $display("  [PASS] Right shift to zero");
                passed++;
            end else begin
                $display("  [FAIL] RSH0: %h", val);
                failed++;
            end
        end

        // Test 7: Shift by zero
        begin
            val = 8'hAB;
            val = val << 0;
            if (val == 8'hAB) begin
                $display("  [PASS] Shift by zero");
                passed++;
            end else begin
                $display("  [FAIL] SH0: %h", val);
                failed++;
            end
        end

        // Test 8: Arithmetic right shift positive
        begin
            sval = 8'h40;
            sval = sval >>> 2;
            if (sval == 8'h10) begin
                $display("  [PASS] Arith right shift pos");
                passed++;
            end else begin
                $display("  [FAIL] ARSHP: %h", sval);
                failed++;
            end
        end

        // Test 9: Arithmetic right shift negative
        begin
            sval = -8;
            sval = sval >>> 1;
            if (sval == -4) begin
                $display("  [PASS] Arith right shift neg");
                passed++;
            end else begin
                $display("  [FAIL] ARSHN: %0d", sval);
                failed++;
            end
        end

        // Test 10: Wide shift
        begin
            wide = 16'h0001;
            wide = wide << 8;
            if (wide == 16'h0100) begin
                $display("  [PASS] Wide shift");
                passed++;
            end else begin
                $display("  [FAIL] Wide: %h", wide);
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
