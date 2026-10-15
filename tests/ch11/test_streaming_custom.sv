/*
:name: test_streaming_custom
:description: Test: Custom slice streaming
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_custom.expected
*/
// Test: Custom slice streaming
module test_streaming_custom;
    logic [31:0] data;
    logic [31:0] result;
    logic [15:0] halves [2];
    logic [3:0] nibbles [8];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: 16-bit slice streaming (half-word)
        data = 32'hABCD1234;
        result = {<<16{data}};
        if (result == 32'h1234ABCD) begin
            $display("PASS: Test 1 - Half-word reversal");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x1234ABCD, got 0x%h", result);
            fail_count++;
        end

        // Test 2: Streaming to half-word array
        data = 32'hCAFEBABE;
        {<<16{halves}} = data;
        if (halves[0] == 16'hBABE && halves[1] == 16'hCAFE) begin
            $display("PASS: Test 2 - Stream to half-word array");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - halves[0]=0x%h, halves[1]=0x%h", halves[0], halves[1]);
            fail_count++;
        end

        // Test 3: 4-bit (nibble) custom slice
        data = 32'h12345678;
        {<<4{nibbles}} = data;
        if (nibbles[0] == 4'h8 && nibbles[1] == 4'h7 &&
            nibbles[2] == 4'h6 && nibbles[3] == 4'h5 &&
            nibbles[4] == 4'h4 && nibbles[5] == 4'h3 &&
            nibbles[6] == 4'h2 && nibbles[7] == 4'h1) begin
            $display("PASS: Test 3 - Nibble slice to array");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Unexpected nibble values");
            fail_count++;
        end

        // Test 4: Right streaming with 16-bit slice
        data = 32'hDEADBEEF;
        {>>16{halves}} = data;
        if (halves[0] == 16'hDEAD && halves[1] == 16'hBEEF) begin
            $display("PASS: Test 4 - Right stream 16-bit slice");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - halves[0]=0x%h, halves[1]=0x%h", halves[0], halves[1]);
            fail_count++;
        end

        // Test 5: 2-bit custom slice
        data = 32'hF0;  // Binary: 00..0011110000 (32-bit)
        result = {<<2{data}};
        // 2-bit groups reversed over 32 bits: bits[7:4]=1111 move to bits[27:24]
        if (result == 32'h0F000000) begin
            $display("PASS: Test 5 - 2-bit slice streaming");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0x0F, got 0x%h", result);
            fail_count++;
        end

        // Summary
        $display("Streaming Custom: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
