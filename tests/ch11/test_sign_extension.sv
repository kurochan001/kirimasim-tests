/*
:name: test_sign_extension
:description: Sign extension of signed values in assignments and expressions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.2 10.7 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sign_extension.expected
*/
// Sign extension of signed values in assignments and expressions
module test_sign_extension;
    int pass_count = 0;
    int total_tests = 12;

    // Test variables
    logic signed [7:0] s8;
    logic signed [15:0] s16;
    logic signed [31:0] s32;
    logic signed [63:0] s64;
    logic [7:0] u8;
    logic [15:0] u16;
    logic [31:0] u32;
    int int_val;

    initial begin
        // Test 1: Sign extend positive value
        s8 = 8'sd127;
        s16 = s8;
        if (s16 == 16'sd127) begin
            $display("PASS: Sign extend positive preserves value");
            pass_count++;
        end else begin
            $display("FAIL: Sign extend positive: expected 127, got %0d", s16);
        end

        // Test 2: Sign extend negative value
        s8 = -8'sd128;
        s16 = s8;
        if (s16 == -16'sd128) begin
            $display("PASS: Sign extend negative preserves value");
            pass_count++;
        end else begin
            $display("FAIL: Sign extend negative: expected -128, got %0d", s16);
        end

        // Test 3: Sign extend -1
        s8 = -8'sd1;
        s32 = s8;
        if (s32 == -32'sd1) begin
            $display("PASS: Sign extend -1 to 32-bit");
            pass_count++;
        end else begin
            $display("FAIL: Sign extend -1: expected -1, got %0d", s32);
        end

        // Test 4: Sign extend narrow negative to 64-bit
        s8 = -8'sd10;
        s64 = s8;
        if (s64 == -64'sd10) begin
            $display("PASS: Sign extend -10 to 64-bit");
            pass_count++;
        end else begin
            $display("FAIL: Sign extend -10: expected -10, got %0d", s64);
        end

        // Test 5: Unsigned to signed (no sign extension)
        u8 = 8'h80;  // 128 unsigned, but bit pattern is negative in signed
        s16 = $signed(u8);
        // After signing, 8'h80 = -128, then sign extended
        if (s16 == -16'sd128) begin
            $display("PASS: $signed then extend");
            pass_count++;
        end else begin
            $display("FAIL: $signed extend: expected -128, got %0d", s16);
        end

        // Test 6: Zero at MSB position
        s8 = 8'sb0111_1111;  // +127
        s16 = s8;
        if (s16 == 16'h007F) begin
            $display("PASS: Zero MSB extends with zeros");
            pass_count++;
        end else begin
            $display("FAIL: Zero MSB extend: expected 0x007F, got 0x%h", s16);
        end

        // Test 7: One at MSB position
        s8 = 8'sb1000_0000;  // -128
        s16 = s8;
        if (s16 == 16'hFF80) begin
            $display("PASS: One MSB extends with ones");
            pass_count++;
        end else begin
            $display("FAIL: One MSB extend: expected 0xFF80, got 0x%h", s16);
        end

        // Test 8: Sign extension in arithmetic
        s8 = -8'sd5;
        s16 = 16'sd100;
        s32 = s8 + s16;
        if (s32 == 32'sd95) begin
            $display("PASS: Sign extension in addition");
            pass_count++;
        end else begin
            $display("FAIL: Sign extend add: expected 95, got %0d", s32);
        end

        // Test 9: Sign extension in comparison
        s8 = -8'sd1;
        s16 = -16'sd1;
        if (s8 == s16) begin
            $display("PASS: Sign extended comparison equal");
            pass_count++;
        end else begin
            $display("FAIL: Sign extended comparison failed");
        end

        // Test 10: Explicit $signed
        u8 = 8'hF0;  // 240 unsigned
        int_val = $signed(u8);
        if (int_val == -16) begin
            $display("PASS: $signed with extension");
            pass_count++;
        end else begin
            $display("FAIL: $signed: expected -16, got %0d", int_val);
        end

        // Test 11: Explicit $unsigned
        s8 = -8'sd1;  // 0xFF
        u16 = $unsigned(s8);
        if (u16 == 16'h00FF) begin
            $display("PASS: $unsigned prevents sign extension");
            pass_count++;
        end else begin
            $display("FAIL: $unsigned: expected 0x00FF, got 0x%h", u16);
        end

        // Test 12: Mixed signed/unsigned operation
        s8 = -8'sd10;
        u8 = 8'h0A;  // 10
        s16 = s8 + $signed(u8);
        if (s16 == 16'sd0) begin
            $display("PASS: Mixed signed/unsigned with extension");
            pass_count++;
        end else begin
            $display("FAIL: Mixed sign: expected 0, got %0d", s16);
        end

        $display("PASS: sign_extension (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
