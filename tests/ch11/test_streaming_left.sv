/*
:name: test_streaming_left
:description: Test: Left streaming {<<}
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_left.expected
*/
// Test: Left streaming {<<}
module test_streaming_left;
    logic [31:0] data;
    logic [31:0] result;
    logic [7:0] bytes [4];
    logic [7:0] unpacked_bytes [4];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic left streaming (bit reversal)
        data = 32'h12345678;
        result = {<<{data}};
        // Bit reversal of 0x12345678 = 0x1E6A2C48
        if (result == 32'h1E6A2C48) begin
            $display("PASS: Test 1 - Basic left streaming (bit reversal)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x1E6A2C48, got 0x%h", result);
            fail_count++;
        end

        // Test 2: Left streaming with byte slice (byte reversal)
        data = 32'hAABBCCDD;
        result = {<<8{data}};
        if (result == 32'hDDCCBBAA) begin
            $display("PASS: Test 2 - Byte reversal with left streaming");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0xDDCCBBAA, got 0x%h", result);
            fail_count++;
        end

        // Test 3: Left streaming to byte array
        data = 32'h11223344;
        {<<8{bytes}} = data;
        if (bytes[0] == 8'h44 && bytes[1] == 8'h33 &&
            bytes[2] == 8'h22 && bytes[3] == 8'h11) begin
            $display("PASS: Test 3 - Left streaming to byte array");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - bytes[0]=0x%h, [1]=0x%h, [2]=0x%h, [3]=0x%h",
                     bytes[0], bytes[1], bytes[2], bytes[3]);
            fail_count++;
        end

        // Test 4: Left streaming from byte array
        unpacked_bytes[0] = 8'hAA;
        unpacked_bytes[1] = 8'hBB;
        unpacked_bytes[2] = 8'hCC;
        unpacked_bytes[3] = 8'hDD;
        result = {<<8{unpacked_bytes}};
        if (result == 32'hDDCCBBAA) begin
            $display("PASS: Test 4 - Left streaming from byte array");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0xDDCCBBAA, got 0x%h", result);
            fail_count++;
        end

        // Test 5: Nibble reversal
        data = 32'h12345678;
        result = {<<4{data}};
        if (result == 32'h87654321) begin
            $display("PASS: Test 5 - Nibble reversal");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0x87654321, got 0x%h", result);
            fail_count++;
        end

        // Summary
        $display("Streaming Left: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
