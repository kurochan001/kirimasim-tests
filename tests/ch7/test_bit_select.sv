/*
:name: test_bit_select
:description: Bit-select and part-select
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_select.expected
*/
// IEEE 1800-2023 Section 7.4: Bit-select and part-select
module test_bit_select;
    logic [31:0] word;
    logic [7:0] byte_val;
    logic bit_val;
    int idx;

    initial begin
        word = 32'hDEADBEEF;

        // Single bit select
        bit_val = word[0];
        if (bit_val == 1'b1)
            $display("PASS: word[0] = 1");
        else
            $display("FAIL: word[0] = %b", bit_val);

        bit_val = word[31];
        if (bit_val == 1'b1)
            $display("PASS: word[31] = 1");
        else
            $display("FAIL: word[31] = %b", bit_val);

        // Part select (constant)
        byte_val = word[7:0];
        if (byte_val == 8'hEF)
            $display("PASS: word[7:0] = 0xEF");
        else
            $display("FAIL: word[7:0] = 0x%h", byte_val);

        byte_val = word[31:24];
        if (byte_val == 8'hDE)
            $display("PASS: word[31:24] = 0xDE");
        else
            $display("FAIL: word[31:24] = 0x%h", byte_val);

        // Variable bit select
        // 0xDEADBEEF bit 4 = 0 (0xEF = 1110_1111, bit 4 is 0)
        idx = 4;
        bit_val = word[idx];
        if (bit_val == 1'b0)
            $display("PASS: word[idx=4] = 0");
        else
            $display("FAIL: word[idx=4] = %b", bit_val);

        // Indexed part select (+:)
        idx = 8;
        byte_val = word[idx +: 8];
        if (byte_val == 8'hBE)
            $display("PASS: word[8 +: 8] = 0xBE");
        else
            $display("FAIL: word[8 +: 8] = 0x%h", byte_val);

        // Indexed part select (-:)
        idx = 23;
        byte_val = word[idx -: 8];
        if (byte_val == 8'hAD)
            $display("PASS: word[23 -: 8] = 0xAD");
        else
            $display("FAIL: word[23 -: 8] = 0x%h", byte_val);

        $display("TEST PASSED: bit select tests completed");
        $finish;
    end
endmodule
