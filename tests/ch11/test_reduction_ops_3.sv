/*
:name: test_reduction_ops_3
:description: All reduction operators on 4- to 32-bit values and part-selects
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_ops_3.expected
*/
// All reduction operators on 4- to 32-bit values and part-selects

module test_reduction_ops;
    int pass_count = 0;
    int total_tests = 30;

    // Test variables
    logic [7:0] data8;
    logic [15:0] data16;
    logic [31:0] data32;
    logic [3:0] nibble;
    logic result;

    initial begin
        // Test 1: Reduction AND - all ones
        data8 = 8'hFF;
        result = &data8;
        if (result == 1'b1) begin
            $display("Test 1 PASSED: &8'hFF = 1");
            pass_count++;
        end else $display("Test 1 FAILED: &8'hFF = %b", result);

        // Test 2: Reduction AND - one zero
        data8 = 8'hFE;
        result = &data8;
        if (result == 1'b0) begin
            $display("Test 2 PASSED: &8'hFE = 0");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Reduction AND - all zeros
        data8 = 8'h00;
        result = &data8;
        if (result == 1'b0) begin
            $display("Test 3 PASSED: &8'h00 = 0");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Reduction OR - all zeros
        data8 = 8'h00;
        result = |data8;
        if (result == 1'b0) begin
            $display("Test 4 PASSED: |8'h00 = 0");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Reduction OR - one bit set
        data8 = 8'h01;
        result = |data8;
        if (result == 1'b1) begin
            $display("Test 5 PASSED: |8'h01 = 1");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Reduction OR - all ones
        data8 = 8'hFF;
        result = |data8;
        if (result == 1'b1) begin
            $display("Test 6 PASSED: |8'hFF = 1");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Reduction XOR - even number of ones
        data8 = 8'b11001100;  // 4 ones
        result = ^data8;
        if (result == 1'b0) begin
            $display("Test 7 PASSED: ^8'b11001100 = 0 (even parity)");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Reduction XOR - odd number of ones
        data8 = 8'b11001101;  // 5 ones
        result = ^data8;
        if (result == 1'b1) begin
            $display("Test 8 PASSED: ^8'b11001101 = 1 (odd parity)");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Reduction XOR - single one
        data8 = 8'b00000001;
        result = ^data8;
        if (result == 1'b1) begin
            $display("Test 9 PASSED: ^8'b00000001 = 1");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Reduction XOR - all zeros
        data8 = 8'h00;
        result = ^data8;
        if (result == 1'b0) begin
            $display("Test 10 PASSED: ^8'h00 = 0");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Reduction NAND - all ones
        data8 = 8'hFF;
        result = ~&data8;
        if (result == 1'b0) begin
            $display("Test 11 PASSED: ~&8'hFF = 0");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Reduction NAND - one zero
        data8 = 8'hFE;
        result = ~&data8;
        if (result == 1'b1) begin
            $display("Test 12 PASSED: ~&8'hFE = 1");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Reduction NOR - all zeros
        data8 = 8'h00;
        result = ~|data8;
        if (result == 1'b1) begin
            $display("Test 13 PASSED: ~|8'h00 = 1");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Reduction NOR - one bit set
        data8 = 8'h80;
        result = ~|data8;
        if (result == 1'b0) begin
            $display("Test 14 PASSED: ~|8'h80 = 0");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Reduction XNOR - even parity
        data8 = 8'b11110000;  // 4 ones
        result = ~^data8;
        if (result == 1'b1) begin
            $display("Test 15 PASSED: ~^8'b11110000 = 1 (even parity inverted)");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Reduction XNOR - odd parity
        data8 = 8'b11110001;  // 5 ones
        result = ~^data8;
        if (result == 1'b0) begin
            $display("Test 16 PASSED: ~^8'b11110001 = 0 (odd parity inverted)");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: 16-bit reduction AND
        data16 = 16'hFFFF;
        result = &data16;
        if (result == 1'b1) begin
            $display("Test 17 PASSED: &16'hFFFF = 1");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: 16-bit reduction OR
        data16 = 16'h0001;
        result = |data16;
        if (result == 1'b1) begin
            $display("Test 18 PASSED: |16'h0001 = 1");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: 32-bit reduction AND
        data32 = 32'hFFFFFFFF;
        result = &data32;
        if (result == 1'b1) begin
            $display("Test 19 PASSED: &32'hFFFFFFFF = 1");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: 32-bit reduction XOR (even)
        data32 = 32'hAAAAAAAA;  // 16 ones
        result = ^data32;
        if (result == 1'b0) begin
            $display("Test 20 PASSED: ^32'hAAAAAAAA = 0");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Nibble reduction AND
        nibble = 4'b1111;
        result = &nibble;
        if (result == 1'b1) begin
            $display("Test 21 PASSED: &4'b1111 = 1");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Nibble reduction OR
        nibble = 4'b0000;
        result = |nibble;
        if (result == 1'b0) begin
            $display("Test 22 PASSED: |4'b0000 = 0");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Reduction in expression
        data8 = 8'hFF;
        if (&data8 && |data8) begin
            $display("Test 23 PASSED: reduction in expression");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Reduction as condition
        data8 = 8'h00;
        if (~|data8) begin
            $display("Test 24 PASSED: ~|0 as condition");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Chained reduction
        data8 = 8'hAA;
        result = ^(data8 & 8'hF0);  // 2 ones -> even
        if (result == 1'b0) begin
            $display("Test 25 PASSED: chained reduction");
            pass_count++;
        end else $display("Test 25 FAILED");

        // Test 26: Reduction on part select
        data16 = 16'hFF00;
        result = &data16[15:8];
        if (result == 1'b1) begin
            $display("Test 26 PASSED: &data16[15:8] = 1");
            pass_count++;
        end else $display("Test 26 FAILED");

        // Test 27: Reduction on lower byte
        data16 = 16'hFF00;
        result = |data16[7:0];
        if (result == 1'b0) begin
            $display("Test 27 PASSED: |data16[7:0] = 0");
            pass_count++;
        end else $display("Test 27 FAILED");

        // Test 28: XOR parity check
        data8 = 8'b10101010;  // 4 ones
        result = ^data8;
        if (result == 1'b0) begin
            $display("Test 28 PASSED: parity of 0xAA = 0 (even)");
            pass_count++;
        end else $display("Test 28 FAILED");

        // Test 29: XNOR parity check
        data8 = 8'b10101010;
        result = ~^data8;
        if (result == 1'b1) begin
            $display("Test 29 PASSED: XNOR parity of 0xAA = 1");
            pass_count++;
        end else $display("Test 29 FAILED");

        // Test 30: Complex expression with multiple reductions
        data8 = 8'hF0;
        nibble = 4'hF;
        result = (&nibble) & (|data8);
        if (result == 1'b1) begin
            $display("Test 30 PASSED: (&4'hF) & (|8'hF0) = 1");
            pass_count++;
        end else $display("Test 30 FAILED");

        $display("PASS: reduction_ops (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
