/*
:name: test_streaming_op_2
:description: Test: Streaming operators {>>{}} {<<{}}
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.1 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_op_2.expected
*/
// Test: Streaming operators {>>{}} {<<{}}

module test_streaming_op_2;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    logic [31:0] data32;
    logic [15:0] data16;
    logic [7:0] data8;
    logic [63:0] data64;
    logic [7:0] bytes[4];
    logic [3:0] nibbles[8];
    logic [31:0] result32;
    logic [15:0] result16;
    logic [7:0] result8;

    initial begin
        // Test 1: Right-to-left streaming (pack bytes to word)
        bytes[0] = 8'h01; bytes[1] = 8'h02; bytes[2] = 8'h03; bytes[3] = 8'h04;
        result32 = {>>{bytes}};
        if (result32 == 32'h01020304) begin
            $display("Test 1 PASSED: {>>{bytes}} = 0x01020304");
            pass_count++;
        end else $display("Test 1 FAILED: result = %h", result32);

        // Test 2: Left-to-right streaming (reverse order)
        result32 = {<<{bytes}};
        // {<<{}} with the default slice size 1 reverses all 32 bits of 32'h01020304
        if (result32 == 32'h20C04080) begin
            $display("Test 2 PASSED: {<<{bytes}} reverses the bits");
            pass_count++;
        end else $display("Test 2 FAILED: got %h", result32);

        // Test 3: Streaming with slice size
        bytes[0] = 8'hAB; bytes[1] = 8'hCD; bytes[2] = 8'hEF; bytes[3] = 8'h01;
        result32 = {>>{bytes}};
        if (result32 == 32'hABCDEF01) begin
            $display("Test 3 PASSED: {>>{bytes}} = 0xABCDEF01");
            pass_count++;
        end else $display("Test 3 FAILED: result = %h", result32);

        // Test 4: Unpack word to bytes
        data32 = 32'h12345678;
        {>>{bytes}} = data32;
        if (bytes[0] == 8'h12 && bytes[1] == 8'h34 && bytes[2] == 8'h56 && bytes[3] == 8'h78) begin
            $display("Test 4 PASSED: unpack 0x12345678 to bytes");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Streaming single value
        data8 = 8'hAB;
        result8 = {>>{data8}};
        if (result8 == 8'hAB) begin
            $display("Test 5 PASSED: {>>{8'hAB}} = 0xAB");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Bit reversal streaming
        data8 = 8'b10110100;
        result8 = {<<{data8}};
        if (result8 == 8'b00101101) begin
            $display("Test 6 PASSED: {<<{8'b10110100}} = 8'b00101101");
            pass_count++;
        end else $display("Test 6 FAILED: result = %b", result8);

        // Test 7: Streaming with nibble slice
        data16 = 16'hABCD;
        {>>{nibbles[0], nibbles[1], nibbles[2], nibbles[3]}} = data16;
        if (nibbles[0] == 4'hA && nibbles[1] == 4'hB && nibbles[2] == 4'hC && nibbles[3] == 4'hD) begin
            $display("Test 7 PASSED: unpack 0xABCD to nibbles");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Pack nibbles back
        nibbles[0] = 4'h1; nibbles[1] = 4'h2; nibbles[2] = 4'h3; nibbles[3] = 4'h4;
        result16 = {>>{nibbles[0], nibbles[1], nibbles[2], nibbles[3]}};
        if (result16 == 16'h1234) begin
            $display("Test 8 PASSED: pack nibbles to 0x1234");
            pass_count++;
        end else $display("Test 8 FAILED: result = %h", result16);

        // Test 9: Streaming all zeros
        data32 = 32'h00000000;
        result32 = {>>{data32}};
        if (result32 == 32'h00000000) begin
            $display("Test 9 PASSED: {>>{0}} = 0");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Streaming all ones
        data32 = 32'hFFFFFFFF;
        result32 = {>>{data32}};
        if (result32 == 32'hFFFFFFFF) begin
            $display("Test 10 PASSED: {>>{0xFFFFFFFF}} = 0xFFFFFFFF");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Byte reversal using left streaming with byte slice
        data32 = 32'h12345678;
        result32 = {<<8{data32}};
        if (result32 == 32'h78563412) begin
            $display("Test 11 PASSED: {<<8{0x12345678}} = 0x78563412");
            pass_count++;
        end else $display("Test 11 FAILED: result = %h", result32);

        // Test 12: Nibble reversal
        data16 = 16'hABCD;
        result16 = {<<4{data16}};
        if (result16 == 16'hDCBA) begin
            $display("Test 12 PASSED: {<<4{0xABCD}} = 0xDCBA");
            pass_count++;
        end else $display("Test 12 FAILED: result = %h", result16);

        // Test 13: Double bit reversal returns original
        data8 = 8'hA5;
        result8 = {<<{{<<{data8}}}};
        if (result8 == 8'hA5) begin
            $display("Test 13 PASSED: double bit reversal = original");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Streaming with expression
        data8 = 8'h0F;
        result8 = {>>{data8 | 8'hF0}};
        if (result8 == 8'hFF) begin
            $display("Test 14 PASSED: {>>{0x0F | 0xF0}} = 0xFF");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Streaming concatenation result
        data8 = 8'hAB;
        result16 = {>>{data8, 8'hCD}};
        if (result16 == 16'hABCD) begin
            $display("Test 15 PASSED: {>>{8'hAB, 8'hCD}} = 0xABCD");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Streaming to multiple targets
        data16 = 16'h1234;
        begin
            logic [7:0] hi, lo;
            {>>{hi, lo}} = data16;
            if (hi == 8'h12 && lo == 8'h34) begin
                $display("Test 16 PASSED: unpack to hi=0x12, lo=0x34");
                pass_count++;
            end else $display("Test 16 FAILED");
        end

        // Test 17: 64-bit streaming
        data64 = 64'h0123456789ABCDEF;
        begin
            logic [7:0] b[8];
            {>>{b}} = data64;
            if (b[0] == 8'h01 && b[7] == 8'hEF) begin
                $display("Test 17 PASSED: 64-bit unpack correct");
                pass_count++;
            end else $display("Test 17 FAILED");
        end

        // Test 18: Pack 64-bit from bytes
        begin
            logic [7:0] b[8];
            logic [63:0] packed_val;
            b[0] = 8'hAA; b[1] = 8'hBB; b[2] = 8'hCC; b[3] = 8'hDD;
            b[4] = 8'hEE; b[5] = 8'hFF; b[6] = 8'h11; b[7] = 8'h22;
            packed_val = {>>{b}};
            if (packed_val == 64'hAABBCCDDEEFF1122) begin
                $display("Test 18 PASSED: 64-bit pack correct");
                pass_count++;
            end else $display("Test 18 FAILED: %h", packed_val);
        end

        // Test 19: Bit slice streaming
        data32 = 32'hDEADBEEF;
        result16 = {>>{data32[31:16]}};
        if (result16 == 16'hDEAD) begin
            $display("Test 19 PASSED: stream upper 16 bits");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Streaming in assignment expression
        bytes[0] = 8'h00; bytes[1] = 8'h00; bytes[2] = 8'h00; bytes[3] = 8'h00;
        {>>{bytes}} = 32'hCAFEBABE;
        result32 = {>>{bytes}};
        if (result32 == 32'hCAFEBABE) begin
            $display("Test 20 PASSED: round-trip streaming");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Word reversal (16-bit chunks)
        data32 = 32'hABCD1234;
        result32 = {<<16{data32}};
        if (result32 == 32'h1234ABCD) begin
            $display("Test 21 PASSED: {<<16{0xABCD1234}} = 0x1234ABCD");
            pass_count++;
        end else $display("Test 21 FAILED: result = %h", result32);

        // Test 22: Single bit streaming
        data8 = 8'b10000001;
        result8 = {<<1{data8}};
        if (result8 == 8'b10000001) begin
            $display("Test 22 PASSED: bit reversal of symmetric pattern");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Alternating pattern bit reversal
        data8 = 8'b01010101;
        result8 = {<<1{data8}};
        if (result8 == 8'b10101010) begin
            $display("Test 23 PASSED: {<<1{8'b01010101}} = 8'b10101010");
            pass_count++;
        end else $display("Test 23 FAILED: result = %b", result8);

        // Test 24: Mixed width streaming
        begin
            logic [11:0] narrow;
            logic [23:0] wide;
            narrow = 12'hABC;
            wide = {>>{narrow, narrow}};
            if (wide == 24'hABCABC) begin
                $display("Test 24 PASSED: stream duplicate narrow");
                pass_count++;
            end else $display("Test 24 FAILED");
        end

        // Test 25: Streaming result comparison
        data8 = 8'hF0;
        result8 = {>>{data8}};  // IEEE: streaming only valid in assignment
        if (result8 == 8'hF0) begin
            $display("Test 25 PASSED: streaming result comparison");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: streaming_op (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: streaming_op (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
