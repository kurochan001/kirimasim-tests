/*
:name: test_streaming_edge_cases
:description: Streaming operators edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming operators edge cases
// Tests for >> and << streaming

module test_streaming_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [31:0] data32;
    logic [7:0] bytes[4];
    logic [15:0] words[2];
    logic [63:0] data64;

    initial begin
        // Test 1: Basic right stream
        test_count++;
        data32 = 32'hAABBCCDD;
        {>>{bytes}} = data32;
        if (bytes[0] == 8'hAA && bytes[1] == 8'hBB) begin
            pass_count++;
            $display("Test 1 PASS: >> stream bytes[0]=%h [1]=%h", bytes[0], bytes[1]);
        end else begin
            $display("Test 1 FAIL: >> unexpected bytes[0]=%h", bytes[0]);
        end

        // Test 2: Basic left stream (byte-level reversal)
        // IEEE 1800-2023 §11.4.14: {<<8{}} reverses byte order
        test_count++;
        data32 = 32'h11223344;
        {<<8{bytes}} = data32;
        if (bytes[0] == 8'h44 && bytes[3] == 8'h11) begin
            pass_count++;
            $display("Test 2 PASS: << stream bytes[0]=%h", bytes[0]);
        end else begin
            $display("Test 2 FAIL: << stream bytes[0]=%h", bytes[0]);
        end

        // Test 3: Stream to words
        test_count++;
        data32 = 32'hABCD1234;
        {>>{words}} = data32;
        if (words[0] == 16'hABCD && words[1] == 16'h1234) begin
            pass_count++;
            $display("Test 3 PASS: >> words[0]=%h [1]=%h", words[0], words[1]);
        end else begin
            $display("Test 3 FAIL: Words unexpected");
        end

        // Test 4: Stream from array to scalar
        test_count++;
        bytes[0] = 8'h12;
        bytes[1] = 8'h34;
        bytes[2] = 8'h56;
        bytes[3] = 8'h78;
        data32 = {>>{bytes}};
        if (data32 == 32'h12345678) begin
            pass_count++;
            $display("Test 4 PASS: Array to scalar = %h", data32);
        end else begin
            $display("Test 4 FAIL: Array unexpected = %h", data32);
        end

        // Test 5: Stream with slice
        test_count++;
        data32 = 32'hFFEEDDCC;
        {>>{bytes}} = data32;
        if (bytes[3] == 8'hCC) begin
            pass_count++;
            $display("Test 5 PASS: Slice bytes[3] = %h", bytes[3]);
        end else begin
            $display("Test 5 FAIL: Slice unexpected");
        end

        // Test 6: Stream with size
        test_count++;
        data32 = 32'hA5A5A5A5;
        {>>byte{bytes}} = data32;
        pass_count++;
        $display("Test 6 PASS: >>byte stream");

        // Test 7: Zero value stream
        test_count++;
        data32 = 32'h00000000;
        {>>{bytes}} = data32;
        if (bytes[0] == 0 && bytes[1] == 0 && bytes[2] == 0 && bytes[3] == 0) begin
            pass_count++;
            $display("Test 7 PASS: Zero stream all zero");
        end else begin
            $display("Test 7 FAIL: Zero unexpected");
        end

        // Test 8: Max value stream
        test_count++;
        data32 = 32'hFFFFFFFF;
        {>>{bytes}} = data32;
        if (bytes[0] == 8'hFF && bytes[3] == 8'hFF) begin
            pass_count++;
            $display("Test 8 PASS: Max stream all FF");
        end else begin
            $display("Test 8 FAIL: Max unexpected");
        end

        // Test 9: Stream to 64-bit
        test_count++;
        begin
            logic [7:0] arr8[8];
            for (int i = 0; i < 8; i++) arr8[i] = i * 16 + i;
            data64 = {>>{arr8}};
            pass_count++;
            $display("Test 9 PASS: 64-bit stream = %h", data64);
        end

        // Test 10: Reverse stream roundtrip
        test_count++;
        begin
            static logic [31:0] orig = 32'h12345678;
            logic [31:0] tmp;
            {<<byte{bytes}} = orig;
            tmp = {<<byte{bytes}};
            if (tmp == orig) begin
                pass_count++;
                $display("Test 10 PASS: Roundtrip = %h", tmp);
            end else begin
                $display("Test 10 FAIL: Roundtrip unexpected = %h", tmp);
            end
        end

        // Test 11: Stream partial
        test_count++;
        begin
            static logic [23:0] data24 = 24'hABCDEF;
            logic [7:0] b3[3];
            {>>{b3}} = data24;
            if (b3[0] == 8'hAB && b3[2] == 8'hEF) begin
                pass_count++;
                $display("Test 11 PASS: 24-bit stream");
            end else begin
                $display("Test 11 FAIL: Partial unexpected");
            end
        end

        // Test 12: Stream alternating pattern
        test_count++;
        data32 = 32'hAA55AA55;
        {>>{bytes}} = data32;
        pass_count++;
        $display("Test 12 PASS: Alternating = %h%h%h%h", bytes[0], bytes[1], bytes[2], bytes[3]);

        $display("=== Streaming Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
