/*
:name: test_streaming_right
:description: Test: Right streaming {>>}
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.1 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_right.expected
*/
// Test: Right streaming {>>}
module test_streaming_right;
    logic [31:0] data;
    logic [31:0] result;
    logic [7:0] bytes [4];
    logic [7:0] unpacked_bytes [4];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic right streaming (byte order reversal)
        data = 32'h12345678;
        result = {>>{data}};
        if (result == 32'h12345678) begin
            $display("PASS: Test 1 - Basic right streaming");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x12345678, got 0x%h", result);
            fail_count++;
        end

        // Test 2: Right streaming with byte slice size
        data = 32'hAABBCCDD;
        {>>{bytes}} = data;
        if (bytes[0] == 8'hAA && bytes[1] == 8'hBB &&
            bytes[2] == 8'hCC && bytes[3] == 8'hDD) begin
            $display("PASS: Test 2 - Right streaming to byte array");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - bytes[0]=0x%h, [1]=0x%h, [2]=0x%h, [3]=0x%h",
                     bytes[0], bytes[1], bytes[2], bytes[3]);
            fail_count++;
        end

        // Test 3: Right streaming from byte array
        unpacked_bytes[0] = 8'h11;
        unpacked_bytes[1] = 8'h22;
        unpacked_bytes[2] = 8'h33;
        unpacked_bytes[3] = 8'h44;
        result = {>>{unpacked_bytes}};
        if (result == 32'h11223344) begin
            $display("PASS: Test 3 - Right streaming from byte array");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0x11223344, got 0x%h", result);
            fail_count++;
        end

        // Test 4: Streaming with explicit slice size
        data = 32'hDEADBEEF;
        {>>8{bytes}} = data;
        if (bytes[0] == 8'hDE && bytes[1] == 8'hAD &&
            bytes[2] == 8'hBE && bytes[3] == 8'hEF) begin
            $display("PASS: Test 4 - Explicit slice size streaming");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - bytes[0]=0x%h, [1]=0x%h, [2]=0x%h, [3]=0x%h",
                     bytes[0], bytes[1], bytes[2], bytes[3]);
            fail_count++;
        end

        // Test 5: Verify streaming preserves MSB-first order
        data = 32'hCAFEBABE;
        result = {>>8{data}};
        if (result == 32'hCAFEBABE) begin
            $display("PASS: Test 5 - MSB-first preservation");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xCAFEBABE, got 0x%h", result);
            fail_count++;
        end

        // Summary
        $display("Streaming Right: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
