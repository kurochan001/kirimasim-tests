/*
:name: test_signed_operations
:description: Corner Case: Signed vs Unsigned Operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10 11.7 11.8.1 11.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_operations.expected
*/
// Corner Case: Signed vs Unsigned Operations
// Tests sign extension and signed arithmetic edge cases

module test_signed_operations;
    int test_count;
    int pass_count;

    logic signed [7:0] s8;
    logic [7:0] u8;
    logic signed [15:0] s16;
    logic [15:0] u16;
    int result;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Negative number representation
        s8 = -1;
        test_count++;
        if (s8 == 8'hFF && s8 == -1) pass_count++;
        else $display("FAIL: Negative -1 = 0x%0h, int=%0d", s8, s8);

        // Test 2: Sign extension on assignment
        s8 = -10;
        s16 = s8;  // Should sign extend
        test_count++;
        if (s16 == -10 && s16 == 16'hFFF6) pass_count++;
        else $display("FAIL: Sign extension = 0x%0h, int=%0d", s16, s16);

        // Test 3: Unsigned extension
        u8 = 8'hFF;
        u16 = u8;  // Should zero extend
        test_count++;
        if (u16 == 16'h00FF) pass_count++;
        else $display("FAIL: Zero extension = 0x%0h", u16);

        // Test 4: Signed comparison
        s8 = -5;
        u8 = 250;  // Same bit pattern as -6 if signed
        test_count++;
        if (s8 > $signed(u8)) pass_count++;  // -5 > -6
        else $display("FAIL: Signed comparison");

        // Test 5: Signed right shift
        s8 = 8'sb10000000;  // -128
        s8 = s8 >>> 2;  // Arithmetic shift
        test_count++;
        if (s8 == 8'sb11100000) pass_count++;  // -32
        else $display("FAIL: Signed shift = 0x%0h", s8);

        // Test 6: Unsigned right shift
        u8 = 8'b10000000;  // 128
        u8 = u8 >> 2;  // Logical shift
        test_count++;
        if (u8 == 8'b00100000) pass_count++;  // 32
        else $display("FAIL: Unsigned shift = 0x%0h", u8);

        // Test 7: Signed multiplication
        s8 = -10;
        result = s8 * 5;
        test_count++;
        if (result == -50) pass_count++;
        else $display("FAIL: Signed mult = %0d", result);

        // Test 8: Mixed signed/unsigned
        s8 = -1;
        u8 = 10;
        // When mixing, result depends on context
        result = $signed({1'b0, u8}) + s8;  // 10 + (-1) = 9
        test_count++;
        if (result == 9) pass_count++;
        else $display("FAIL: Mixed add = %0d", result);

        $display("Corner Case Signed Operations: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
