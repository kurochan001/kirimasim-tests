/*
:name: test_signed_overflow
:description: Signed overflow wrap-around in 8- to 64-bit arithmetic
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_overflow.expected
*/
// Signed overflow wrap-around in 8- to 64-bit arithmetic
module test_signed_overflow;
    int pass_count = 0;
    int total_tests = 10;

    // Test variables
    logic signed [7:0] s8_a, s8_b, s8_result;
    logic signed [31:0] s32_a, s32_b, s32_result;
    int int_a, int_b, int_result;
    shortint short_a, short_b, short_result;
    longint long_a, long_b, long_result;

    initial begin
        // Test 1: 8-bit signed positive overflow
        s8_a = 8'sd127;  // Max positive
        s8_b = 8'sd1;
        s8_result = s8_a + s8_b;
        if (s8_result == -128) begin
            $display("PASS: 8-bit signed positive overflow wraps to -128");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit signed overflow: expected -128, got %0d", s8_result);
        end

        // Test 2: 8-bit signed negative overflow
        s8_a = -8'sd128;  // Min negative
        s8_b = -8'sd1;
        s8_result = s8_a + s8_b;
        if (s8_result == 127) begin
            $display("PASS: 8-bit signed negative overflow wraps to 127");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit signed neg overflow: expected 127, got %0d", s8_result);
        end

        // Test 3: 32-bit signed max + 1
        s32_a = 32'sh7FFFFFFF;  // Max positive
        s32_b = 32'sd1;
        s32_result = s32_a + s32_b;
        if (s32_result == -32'sd2147483648) begin
            $display("PASS: 32-bit signed max overflow");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit signed max overflow: got %0d", s32_result);
        end

        // Test 4: 32-bit signed min - 1
        s32_a = 32'sh80000000;  // Min negative
        s32_b = -32'sd1;
        s32_result = s32_a + s32_b;
        if (s32_result == 32'sh7FFFFFFF) begin
            $display("PASS: 32-bit signed min underflow");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit signed min underflow: got %0d", s32_result);
        end

        // Test 5: int type overflow
        int_a = 2147483647;
        int_b = 1;
        int_result = int_a + int_b;
        if (int_result == 32'sh80000000) begin  // -2**31
            $display("PASS: int type overflow wraps correctly");
            pass_count++;
        end else begin
            $display("FAIL: int overflow: got %0d", int_result);
        end

        // Test 6: Signed multiplication overflow
        s8_a = 8'sd64;
        s8_b = 8'sd4;
        s8_result = s8_a * s8_b;
        // 64 * 4 = 256, wraps in 8-bit signed
        if (s8_result == 8'sd0) begin
            $display("PASS: Signed multiplication overflow");
            pass_count++;
        end else begin
            $display("FAIL: Signed mult overflow: got %0d", s8_result);
        end

        // Test 7: Shortint overflow
        short_a = 16'sd32767;
        short_b = 16'sd1;
        short_result = short_a + short_b;
        if (short_result == -32768) begin
            $display("PASS: Shortint overflow wraps correctly");
            pass_count++;
        end else begin
            $display("FAIL: Shortint overflow: got %0d", short_result);
        end

        // Test 8: Longint overflow test (just verify it computes)
        long_a = 64'sh7FFFFFFFFFFFFFFF;
        long_b = 64'sd1;
        long_result = long_a + long_b;
        // Wraps to the most negative value
        if (long_result == 64'sh8000000000000000) begin
            $display("PASS: Longint overflow wraps (result=%0d)", long_result);
            pass_count++;
        end else begin
            $display("FAIL: Longint overflow (result=%0d)", long_result);
        end

        // Test 9: Signed negation overflow
        s8_a = -8'sd128;
        s8_result = -s8_a;
        // -(-128) in 8-bit signed stays -128
        if (s8_result == -128) begin
            $display("PASS: Signed negation overflow at min value");
            pass_count++;
        end else begin
            $display("FAIL: Signed negation overflow: got %0d", s8_result);
        end

        // Test 10: Signed subtraction overflow
        s8_a = 8'sd100;
        s8_b = -8'sd50;
        s8_result = s8_a - s8_b;  // 100 - (-50) = 150, overflows
        // 150 in 8-bit signed wraps
        if (s8_result == -106) begin
            $display("PASS: Signed subtraction overflow");
            pass_count++;
        end else begin
            $display("FAIL: Signed subtraction overflow: got %0d", s8_result);
        end

        $display("PASS: signed_overflow (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
