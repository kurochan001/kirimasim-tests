/*
:name: test_streaming_operators
:description: Streaming Operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_operators.expected
*/
// IEEE 1800-2023 §11.4.14 Streaming Operators
// Tests {>>{}} and {<<{}} streaming operators

module test_streaming_operators;
    int pass_count = 0;
    int fail_count = 0;

    logic [31:0] data;
    logic [7:0] bytes[4];
    logic [15:0] words[2];
    logic [7:0] byte0, byte1, byte2, byte3;

    initial begin
        // Test 1: Pack bytes into word (right-to-left)
        bytes[0] = 8'h11;
        bytes[1] = 8'h22;
        bytes[2] = 8'h33;
        bytes[3] = 8'h44;
        data = {>>{bytes}};
        // Right streaming: bytes[0] in MSB position
        if (data == 32'h11223344) begin
            $display("PASS: Right stream pack - data=0x%h", data);
            pass_count++;
        end else begin
            $display("FAIL: Right stream pack - data=0x%h (expected 0x11223344)", data);
            fail_count++;
        end

        // Test 2: Unpack word to bytes (right-to-left)
        data = 32'hAABBCCDD;
        {>>{bytes}} = data;
        if (bytes[0] == 8'hAA && bytes[1] == 8'hBB &&
            bytes[2] == 8'hCC && bytes[3] == 8'hDD) begin
            $display("PASS: Right stream unpack");
            pass_count++;
        end else begin
            $display("FAIL: Right stream unpack - bytes={%h,%h,%h,%h}",
                     bytes[0], bytes[1], bytes[2], bytes[3]);
            fail_count++;
        end

        // Test 3: Left stream pack (byte order reversal)
        // IEEE 1800-2023 §11.4.14: {<<8{}} reverses byte order
        bytes[0] = 8'h01;
        bytes[1] = 8'h02;
        bytes[2] = 8'h04;
        bytes[3] = 8'h08;
        data = {<<8{bytes}};
        // Left streaming with 8-bit slice packs in reverse byte order
        // Expected: bytes[3]|bytes[2]|bytes[1]|bytes[0] = 0x08040201
        if (data == 32'h08040201) begin
            $display("PASS: Left stream pack - data=0x%h", data);
            pass_count++;
        end else begin
            $display("FAIL: Left stream pack - data=0x%h (expected 0x08040201)", data);
            fail_count++;
        end

        // Test 4: Stream with slice size
        data = 32'h12345678;
        {>>{byte0, byte1, byte2, byte3}} = data;
        if (byte0 == 8'h12 && byte1 == 8'h34 &&
            byte2 == 8'h56 && byte3 == 8'h78) begin
            $display("PASS: Stream to individual bytes");
            pass_count++;
        end else begin
            $display("FAIL: Stream to bytes - {%h,%h,%h,%h}",
                     byte0, byte1, byte2, byte3);
            fail_count++;
        end

        // Test 5: Stream words
        data = 32'hABCD1234;
        {>>{words}} = data;
        if (words[0] == 16'hABCD && words[1] == 16'h1234) begin
            $display("PASS: Stream to words");
            pass_count++;
        end else begin
            $display("FAIL: Stream to words - {%h,%h}", words[0], words[1]);
            fail_count++;
        end

        // Test 6: Pack words into data
        words[0] = 16'hFEDC;
        words[1] = 16'hBA98;
        data = {>>{words}};
        if (data == 32'hFEDCBA98) begin
            $display("PASS: Pack words to data");
            pass_count++;
        end else begin
            $display("FAIL: Pack words - data=0x%h", data);
            fail_count++;
        end

        $display("");
        $display("=== Streaming Operators Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
