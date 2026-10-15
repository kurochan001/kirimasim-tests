/*
:name: test_streaming_advanced
:description: Streaming Operator Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_advanced.expected
*/
// IEEE 1800-2023 Section 11.4.14 - Streaming Operator Tests
// Tests: Basic pack operations

module test_streaming_advanced;
    int pass_count = 0;
    int fail_count = 0;

    logic [31:0] packed_val;
    logic [7:0] bytes[4];

    initial begin
        $display("=== IEEE 1800-2023 Streaming Tests ===");

        // Test 1: Stream pack bytes to 32-bit
        $display("Test 1: Stream pack bytes to 32-bit");
        bytes = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
        packed_val = {>>{bytes}};
        if (packed_val == 32'hAABBCCDD) begin
            $display("Test 1 PASS: packed_val=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h, expected AABBCCDD", packed_val);
            fail_count++;
        end

        // Test 2: Left-to-right streaming (byte reversal)
        $display("Test 2: Left-to-right streaming");
        bytes = '{8'h11, 8'h22, 8'h33, 8'h44};
        packed_val = {<<8{bytes}};
        if (packed_val == 32'h44332211) begin
            $display("Test 2 PASS: reversed=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h, expected 44332211", packed_val);
            fail_count++;
        end

        // Test 3: Symmetric bit pattern
        $display("Test 3: Symmetric bit pattern");
        bytes[0] = 8'b10000001;  // 0x81
        bytes[1] = 8'b01111110;  // 0x7E
        bytes[2] = 8'b00111100;  // 0x3C
        bytes[3] = 8'b00011000;  // 0x18
        packed_val = {>>{bytes}};
        if (packed_val == 32'h817E3C18) begin
            $display("Test 3 PASS: packed symmetric pattern=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", packed_val);
            fail_count++;
        end

        // Test 4: Pack verification with known values
        $display("Test 4: Pack verification");
        bytes[0] = 8'hDE;
        bytes[1] = 8'hAD;
        bytes[2] = 8'hBE;
        bytes[3] = 8'hEF;
        packed_val = {>>{bytes}};
        // Check bytes are present
        if (packed_val == 32'hDEADBEEF) begin
            $display("Test 4 PASS: packed_val=%h (DEADBEEF)", packed_val);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", packed_val);
            fail_count++;
        end

        // Test 5: Empty array
        $display("Test 5: Zero values");
        bytes = '{8'h00, 8'h00, 8'h00, 8'h00};
        packed_val = {>>{bytes}};
        if (packed_val == 32'h00000000) begin
            $display("Test 5 PASS: zeros packed=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %h", packed_val);
            fail_count++;
        end

        // Test 6: Mixed values
        $display("Test 6: Mixed high/low values");
        bytes = '{8'hFF, 8'h00, 8'hFF, 8'h00};
        packed_val = {>>{bytes}};
        // Should have alternating bytes
        if (packed_val == 32'hFF00FF00) begin
            $display("Test 6 PASS: packed_val=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", packed_val);
            fail_count++;
        end

        // Test 7: Single byte pack
        $display("Test 7: Single element");
        bytes[0] = 8'hAB;
        bytes[1] = 8'h00;
        bytes[2] = 8'h00;
        bytes[3] = 8'h00;
        packed_val = {>>{bytes}};
        // {>>{}} puts bytes[0] in the most significant byte (11.4.14.2)
        if (packed_val == 32'hAB000000) begin
            $display("Test 7 PASS: packed contains AB, val=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", packed_val);
            fail_count++;
        end

        // Test 8: Full range
        $display("Test 8: Full range values");
        bytes = '{8'h01, 8'h23, 8'h45, 8'h67};
        packed_val = {>>{bytes}};
        if (packed_val == 32'h01234567) begin
            $display("Test 8 PASS: packed_val=%h", packed_val);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", packed_val);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
