/*
:name: test_arithmetic_overflow
:description: Corner Case Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_overflow.expected
*/
// IEEE 1800-2023 Corner Case Tests
// Arithmetic overflow and underflow behavior

module test_arithmetic_overflow;
    // Test arithmetic overflow and underflow

    int test_count;
    int pass_count;

    // Signed and unsigned variables
    logic [7:0] u8;
    logic [7:0] u8_result;
    logic signed [7:0] s8;
    logic signed [7:0] s8_result;
    logic [31:0] u32;
    int signed_int;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Unsigned overflow (255 + 1)
        u8 = 8'hFF;
        u8_result = u8 + 1;
        test_count++;
        if (u8_result == 0) pass_count++;
        else $display("FAIL: Unsigned overflow - result=%0d (expected 0)", u8_result);

        // Test 2: Unsigned underflow (0 - 1)
        u8 = 0;
        u8_result = u8 - 1;
        test_count++;
        if (u8_result == 8'hFF) pass_count++;
        else $display("FAIL: Unsigned underflow - result=0x%0h (expected 0xFF)", u8_result);

        // Test 3: Signed overflow (127 + 1)
        s8 = 8'sd127;
        s8_result = s8 + 1;
        test_count++;
        if (s8_result == -128) pass_count++;
        else $display("FAIL: Signed overflow - result=%0d (expected -128)", s8_result);

        // Test 4: Signed underflow (-128 - 1)
        s8 = -8'sd128;
        s8_result = s8 - 1;
        test_count++;
        if (s8_result == 127) pass_count++;
        else $display("FAIL: Signed underflow - result=%0d (expected 127)", s8_result);

        // Test 5: Multiplication overflow
        u8 = 8'd20;
        u8_result = u8 * 8'd20;  // 400 mod 256 = 144
        test_count++;
        if (u8_result == 144) pass_count++;
        else $display("FAIL: Mult overflow - result=%0d (expected 144)", u8_result);

        // Test 6: Large value truncation
        u32 = 32'hFFFF_ABCD;
        u8_result = u32[7:0];
        test_count++;
        if (u8_result == 8'hCD) pass_count++;
        else $display("FAIL: Truncation - result=0x%0h (expected 0xCD)", u8_result);

        $display("Corner Case Arithmetic Overflow: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
