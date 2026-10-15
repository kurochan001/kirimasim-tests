/*
:name: test_bit_select_edge
:description: Corner Case Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_select_edge.expected
*/
// IEEE 1800-2023 Corner Case Tests
// Bit selection and part-select edge cases

module test_bit_select_edge;
    // Test bit and part-select edge cases

    int test_count;
    int pass_count;

    logic [31:0] data;
    logic [7:0] byte_val;
    logic single_bit;
    logic [3:0] nibble;
    int idx;

    initial begin
        test_count = 0;
        pass_count = 0;

        data = 32'hDEAD_BEEF;

        // Test 1: LSB selection
        single_bit = data[0];
        test_count++;
        if (single_bit == 1) pass_count++;
        else $display("FAIL: LSB select - bit=%0b (expected 1)", single_bit);

        // Test 2: MSB selection
        single_bit = data[31];
        test_count++;
        if (single_bit == 1) pass_count++;
        else $display("FAIL: MSB select - bit=%0b (expected 1)", single_bit);

        // Test 3: Part-select [7:0]
        byte_val = data[7:0];
        test_count++;
        if (byte_val == 8'hEF) pass_count++;
        else $display("FAIL: Byte 0 - val=0x%0h (expected 0xEF)", byte_val);

        // Test 4: Part-select [31:24]
        byte_val = data[31:24];
        test_count++;
        if (byte_val == 8'hDE) pass_count++;
        else $display("FAIL: Byte 3 - val=0x%0h (expected 0xDE)", byte_val);

        // Test 5: Variable indexed part select using +:
        idx = 4;
        nibble = data[idx +: 4];  // bits [7:4]
        test_count++;
        if (nibble == 4'hE) pass_count++;
        else $display("FAIL: Variable select - val=0x%0h (expected 0xE)", nibble);

        // Test 6: +: indexed part select
        idx = 8;
        byte_val = data[idx +: 8];  // bits [15:8]
        test_count++;
        if (byte_val == 8'hBE) pass_count++;
        else $display("FAIL: +: select - val=0x%0h (expected 0xBE)", byte_val);

        // Test 7: -: indexed part select
        idx = 23;
        byte_val = data[idx -: 8];  // bits [23:16]
        test_count++;
        if (byte_val == 8'hAD) pass_count++;
        else $display("FAIL: -: select - val=0x%0h (expected 0xAD)", byte_val);

        // Test 8: Single-bit width part select
        idx = 0;
        single_bit = data[idx +: 1];
        test_count++;
        if (single_bit == 1) pass_count++;
        else $display("FAIL: 1-bit +: - val=%0b (expected 1)", single_bit);

        $display("Corner Case Bit Select: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
