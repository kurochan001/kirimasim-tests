/*
:name: test_slices_edge_cases
:description: Reading and writing bit-selects and part-selects of a 16-bit vector
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_slices_edge_cases.expected
*/
// Reading and writing bit-selects and part-selects of a 16-bit vector
// IEEE 1800-2023 Section 11.5.1 Bit-select and part-select
// Tests corner cases: bit select, part select

`timescale 1ns/1ps

module test_slices_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [15:0] data;
    logic [31:0] wide_data;
    logic single_bit;
    logic [7:0] byte_val;

    initial begin
        $display("TEST: Bit/part select edge cases");

        // Test 1: Single bit select read
        begin
            data = 16'b1010_1010_1010_1010;
            if (data[0] == 0 && data[1] == 1) begin
                $display("  [PASS] Bit select read");
                passed++;
            end else begin
                $display("  [FAIL] Bit: %b %b", data[0], data[1]);
                failed++;
            end
        end

        // Test 2: Single bit select write
        begin
            data = 16'h0000;
            data[7] = 1;
            if (data == 16'h0080) begin
                $display("  [PASS] Bit select write");
                passed++;
            end else begin
                $display("  [FAIL] BitW: %h", data);
                failed++;
            end
        end

        // Test 3: Part select read
        begin
            data = 16'hABCD;
            if (data[7:0] == 8'hCD && data[15:8] == 8'hAB) begin
                $display("  [PASS] Part select read");
                passed++;
            end else begin
                $display("  [FAIL] Part: %h %h", data[15:8], data[7:0]);
                failed++;
            end
        end

        // Test 4: Part select write
        begin
            data = 16'h0000;
            data[7:0] = 8'hEF;
            if (data == 16'h00EF) begin
                $display("  [PASS] Part select write");
                passed++;
            end else begin
                $display("  [FAIL] PartW: %h", data);
                failed++;
            end
        end

        // Test 5: MSB access
        begin
            data = 16'h8000;
            if (data[15] == 1) begin
                $display("  [PASS] MSB access");
                passed++;
            end else begin
                $display("  [FAIL] MSB: %b", data[15]);
                failed++;
            end
        end

        // Test 6: LSB access
        begin
            data = 16'h0001;
            if (data[0] == 1) begin
                $display("  [PASS] LSB access");
                passed++;
            end else begin
                $display("  [FAIL] LSB: %b", data[0]);
                failed++;
            end
        end

        // Test 7: Middle byte
        begin
            wide_data = 32'h12345678;
            byte_val = wide_data[23:16];
            if (byte_val == 8'h34) begin
                $display("  [PASS] Middle byte");
                passed++;
            end else begin
                $display("  [FAIL] Mid: %h", byte_val);
                failed++;
            end
        end

        // Test 8: Assign to bit slice
        begin
            data = 16'hFFFF;
            data[11:8] = 4'h0;
            if (data == 16'hF0FF) begin
                $display("  [PASS] Assign to slice");
                passed++;
            end else begin
                $display("  [FAIL] Slice: %h", data);
                failed++;
            end
        end

        // Test 9: Clear bits
        begin
            data = 16'hFFFF;
            data[7:0] = 8'h00;
            if (data == 16'hFF00) begin
                $display("  [PASS] Clear bits");
                passed++;
            end else begin
                $display("  [FAIL] Clear: %h", data);
                failed++;
            end
        end

        // Test 10: Set bits
        begin
            data = 16'h0000;
            data[15:12] = 4'hF;
            if (data == 16'hF000) begin
                $display("  [PASS] Set bits");
                passed++;
            end else begin
                $display("  [FAIL] Set: %h", data);
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
