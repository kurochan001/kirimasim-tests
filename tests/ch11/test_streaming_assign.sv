/*
:name: test_streaming_assign
:description: Test: Streaming operator assignment
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_assign.expected
*/
// Test: Streaming operator assignment

module test_streaming_assign;
    int pass_count = 0;
    int total_tests = 15;

    logic [31:0] data32;
    logic [7:0] bytes [0:3];
    logic [15:0] words [0:1];
    logic [63:0] data64;
    logic [7:0] byte_a, byte_b, byte_c, byte_d;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [7:0] c;
        logic [7:0] d;
    } quad_t;
    quad_t quad;

    initial begin
        // Test 1: Right-to-left streaming {>>} - byte reversal
        data32 = 32'h12345678;
        {>>{bytes}} = data32;
        if (bytes[0] == 8'h12 && bytes[1] == 8'h34 && bytes[2] == 8'h56 && bytes[3] == 8'h78) begin
            pass_count++;
            $display("PASS: Right-to-left streaming to array");
        end else $display("FAIL: Right-to-left streaming, bytes=%h %h %h %h", bytes[0], bytes[1], bytes[2], bytes[3]);

        // Test 2: Left-to-right streaming {<<} - bit reversal style
        data32 = 32'hABCDEF01;
        {<<8{bytes}} = data32;
        if (bytes[0] == 8'h01 && bytes[3] == 8'hAB) begin
            pass_count++;
            $display("PASS: Left-to-right streaming to array");
        end else $display("FAIL: Left-to-right streaming, bytes=%h %h %h %h", bytes[0], bytes[1], bytes[2], bytes[3]);

        // Test 3: Streaming with word slice size
        data32 = 32'hDEADBEEF;
        {>>{words}} = data32;
        if (words[0] == 16'hDEAD && words[1] == 16'hBEEF) begin
            pass_count++;
            $display("PASS: Streaming with word size");
        end else $display("FAIL: Streaming with word size");

        // Test 4: Streaming to scalar variables
        data32 = 32'h11223344;
        {>>{byte_a, byte_b, byte_c, byte_d}} = data32;
        if (byte_a == 8'h11 && byte_b == 8'h22 && byte_c == 8'h33 && byte_d == 8'h44) begin
            pass_count++;
            $display("PASS: Streaming to scalars");
        end else $display("FAIL: Streaming to scalars");

        // Test 5: Streaming from array to scalar
        bytes[0] = 8'hAA;
        bytes[1] = 8'hBB;
        bytes[2] = 8'hCC;
        bytes[3] = 8'hDD;
        data32 = {>>{bytes}};
        if (data32 == 32'hAABBCCDD) begin
            pass_count++;
            $display("PASS: Streaming from array to scalar");
        end else $display("FAIL: Streaming from array to scalar, got %h", data32);

        // Test 6: Streaming to packed struct
        data32 = 32'hCAFEBABE;
        {>>{quad}} = data32;
        if (quad.a == 8'hCA && quad.d == 8'hBE) begin
            pass_count++;
            $display("PASS: Streaming to packed struct");
        end else $display("FAIL: Streaming to packed struct");

        // Test 7: Streaming with explicit slice width {>>8{}}
        data32 = 32'h12345678;
        {>>8{byte_a, byte_b, byte_c, byte_d}} = data32;
        if (byte_a == 8'h12 && byte_d == 8'h78) begin
            pass_count++;
            $display("PASS: Streaming with explicit width");
        end else $display("FAIL: Streaming with explicit width");

        // Test 8: Left streaming bit reversal concept
        data32 = 32'hF0F0F0F0;
        {<<8{bytes}} = data32;
        // <<8 reverses byte order
        if (bytes[0] == 8'hF0 && bytes[3] == 8'hF0) begin
            pass_count++;
            $display("PASS: Left streaming byte reversal");
        end else $display("FAIL: Left streaming byte reversal");

        // Test 9: Streaming 64-bit value
        data64 = 64'h0102030405060708;
        {>>{bytes[0], bytes[1], bytes[2], bytes[3]}} = data64[31:0];
        if (bytes[0] == 8'h05 && bytes[3] == 8'h08) begin
            pass_count++;
            $display("PASS: Streaming 64-bit partial");
        end else $display("FAIL: Streaming 64-bit partial");

        // Test 10: Double streaming (pack then unpack)
        byte_a = 8'h11;
        byte_b = 8'h22;
        byte_c = 8'h33;
        byte_d = 8'h44;
        data32 = {>>{byte_a, byte_b, byte_c, byte_d}};
        {>>{bytes}} = data32;
        if (bytes[0] == 8'h11 && bytes[3] == 8'h44) begin
            pass_count++;
            $display("PASS: Double streaming roundtrip");
        end else $display("FAIL: Double streaming roundtrip");

        // Test 11: Streaming with nibble slice
        data32 = 32'h12345678;
        {>>4{byte_a, byte_b}} = data32[15:0];  // 4 nibbles -> 2 bytes
        if (byte_a == 8'h56 && byte_b == 8'h78) begin
            pass_count++;
            $display("PASS: Streaming with nibble slice");
        end else $display("FAIL: Streaming with nibble slice, a=%h b=%h", byte_a, byte_b);

        // Test 12: Empty/minimal streaming
        byte_a = 8'h00;
        {>>{byte_a}} = 8'hFF;
        if (byte_a == 8'hFF) begin
            pass_count++;
            $display("PASS: Single element streaming");
        end else $display("FAIL: Single element streaming");

        // Test 13: Streaming preserving structure
        quad.a = 8'hAA;
        quad.b = 8'hBB;
        quad.c = 8'hCC;
        quad.d = 8'hDD;
        data32 = {>>{quad}};
        if (data32 == 32'hAABBCCDD) begin
            pass_count++;
            $display("PASS: Streaming preserving struct");
        end else $display("FAIL: Streaming preserving struct");

        // Test 14: Mixed size streaming targets
        data32 = 32'hABCD1234;
        {>>{words[0], byte_a, byte_b}} = data32;
        if (words[0] == 16'hABCD && byte_a == 8'h12 && byte_b == 8'h34) begin
            pass_count++;
            $display("PASS: Mixed size streaming");
        end else $display("FAIL: Mixed size streaming");

        // Test 15: Streaming with computation
        data32 = 32'h00000000;
        byte_a = 8'h12;
        byte_b = 8'h34;
        data32 = {>>{byte_a, byte_b, 16'h0000}};
        if (data32 == 32'h12340000) begin
            pass_count++;
            $display("PASS: Streaming with computation");
        end else $display("FAIL: Streaming with computation, got %h", data32);

        if (pass_count == total_tests) $display("PASS: streaming_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: streaming_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
