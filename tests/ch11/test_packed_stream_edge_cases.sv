/*
:name: test_packed_stream_edge_cases
:description: Test: Packed streaming operations edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_stream_edge_cases.expected
*/
// Test: Packed streaming operations edge cases
// IEEE 1800-2023 Section 11.4.14 Streaming operators
// Tests corner cases: streaming operator operations

`timescale 1ns/1ps

module test_packed_stream_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        logic [31:0] data;
        logic [7:0] bytes [4];
        logic [15:0] words [2];

        $display("TEST: Packed streaming operations edge cases");

        // Test 1: Stream right to bytes
        begin
            data = 32'hDEADBEEF;
            {>>{bytes}} = data;
            if (bytes[0] == 8'hDE && bytes[3] == 8'hEF) begin
                $display("  [PASS] Stream right to bytes");
                passed++;
            end else begin
                $display("  [FAIL] RightBytes: %h %h", bytes[0], bytes[3]);
                failed++;
            end
        end

        // Test 2: Stream left to bytes (byte-level reversal)
        // IEEE 1800-2023 §11.4.14: {<<8{}} reverses byte order
        begin
            data = 32'hCAFEBABE;
            {<<8{bytes}} = data;
            if (bytes[0] == 8'hBE && bytes[3] == 8'hCA) begin
                $display("  [PASS] Stream left to bytes");
                passed++;
            end else begin
                $display("  [FAIL] LeftBytes: %h %h", bytes[0], bytes[3]);
                failed++;
            end
        end

        // Test 3: Bytes to stream right
        begin
            bytes[0] = 8'h11;
            bytes[1] = 8'h22;
            bytes[2] = 8'h33;
            bytes[3] = 8'h44;
            data = {>>{bytes}};
            if (data == 32'h11223344) begin
                $display("  [PASS] Bytes to stream right");
                passed++;
            end else begin
                $display("  [FAIL] BytesToRight: %h", data);
                failed++;
            end
        end

        // Test 4: Bytes to stream left (byte-level reversal)
        // IEEE 1800-2023 §11.4.14: {<<8{}} reverses byte order
        begin
            bytes[0] = 8'hAA;
            bytes[1] = 8'hBB;
            bytes[2] = 8'hCC;
            bytes[3] = 8'hDD;
            data = {<<8{bytes}};
            if (data == 32'hDDCCBBAA) begin
                $display("  [PASS] Bytes to stream left");
                passed++;
            end else begin
                $display("  [FAIL] BytesToLeft: %h", data);
                failed++;
            end
        end

        // Test 5: Stream to words
        begin
            data = 32'h12345678;
            {>>{words}} = data;
            if (words[0] == 16'h1234 && words[1] == 16'h5678) begin
                $display("  [PASS] Stream to words");
                passed++;
            end else begin
                $display("  [FAIL] Words: %h %h", words[0], words[1]);
                failed++;
            end
        end

        // Test 6: Reuse bytes for 16-bit data
        begin
            data = 32'h0000ABCD;
            {>>{bytes}} = data;
            if (bytes[2] == 8'hAB && bytes[3] == 8'hCD) begin
                $display("  [PASS] 16-bit in 32-bit stream");
                passed++;
            end else begin
                $display("  [FAIL] 16in32: %h %h", bytes[2], bytes[3]);
                failed++;
            end
        end

        // Test 7: Stream alternating pattern
        begin
            data = 32'h55555555;
            {>>{bytes}} = data;
            if (bytes[0] == 8'h55 && bytes[1] == 8'h55) begin
                $display("  [PASS] Alternating pattern");
                passed++;
            end else begin
                $display("  [FAIL] Alt: %h", bytes[0]);
                failed++;
            end
        end

        // Test 8: All zeros stream
        begin
            data = 32'h0;
            {>>{bytes}} = data;
            if (bytes[0] == 0 && bytes[1] == 0 && bytes[2] == 0 && bytes[3] == 0) begin
                $display("  [PASS] All zeros stream");
                passed++;
            end else begin
                $display("  [FAIL] Zeros");
                failed++;
            end
        end

        // Test 9: All ones stream
        begin
            data = 32'hFFFFFFFF;
            {>>{bytes}} = data;
            if (bytes[0] == 8'hFF && bytes[3] == 8'hFF) begin
                $display("  [PASS] All ones stream");
                passed++;
            end else begin
                $display("  [FAIL] Ones: %h", bytes[0]);
                failed++;
            end
        end

        // Test 10: Round trip
        begin
            static logic [31:0] original = 32'hA5A5A5A5;
            logic [31:0] result;
            {>>{bytes}} = original;
            result = {>>{bytes}};
            if (result == original) begin
                $display("  [PASS] Round trip");
                passed++;
            end else begin
                $display("  [FAIL] RoundTrip: %h", result);
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
        $finish;
        end
    end
endmodule
