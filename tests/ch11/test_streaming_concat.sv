/*
:name: test_streaming_concat
:description: Streaming concatenation - pack
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_concat.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming concatenation - pack
module test_streaming_concat;
    logic [7:0] a, b, c, d;
    logic [31:0] result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Stream 4 bytes
        a = 8'hAA; b = 8'hBB; c = 8'hCC; d = 8'hDD;
        result = {>>{a, b, c, d}};
        if (result == 32'hAABBCCDD) begin
            $display("Test 1 PASS: concat 4 bytes = %08h", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", result);
            fail_count++;
        end

        // Test 2: Stream 2 bytes
        a = 8'h12; b = 8'h34;
        result = {>>{a, b}};
        // left-aligned and zero-filled on the right (11.4.14)
        if (result == 32'h12340000) begin
            $display("Test 2 PASS: concat 2 bytes = %08h", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", result);
            fail_count++;
        end

        // Test 3: Stream with all same value
        a = 8'hFF; b = 8'hFF; c = 8'hFF; d = 8'hFF;
        result = {>>{a, b, c, d}};
        if (result == 32'hFFFFFFFF) begin
            $display("Test 3 PASS: concat same = %08h", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %08h", result);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
