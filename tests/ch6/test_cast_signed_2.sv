/*
:name: test_cast_signed_2
:description: signed' and unsigned' casts, $signed and $unsigned
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 11.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_signed_2.expected
*/
// signed' and unsigned' casts, $signed and $unsigned

module test_cast_signed;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    logic [7:0] u8;
    logic signed [7:0] s8;
    logic [15:0] u16;
    logic signed [15:0] s16;
    logic [31:0] u32;
    logic signed [31:0] s32;
    int i_val;
    bit [31:0] b_val;

    initial begin
        // Test 1: unsigned to signed (positive)
        total_tests++;
        u8 = 8'd100;
        s8 = signed'(u8);
        if (s8 == 100) begin
            pass_count++;
            $display("PASS: unsigned to signed (positive)");
        end else $display("FAIL: u to s positive, got %0d", s8);

        // Test 2: unsigned to signed (becomes negative)
        total_tests++;
        u8 = 8'd200;  // > 127, so negative when signed
        s8 = signed'(u8);
        if (s8 < 0) begin
            pass_count++;
            $display("PASS: unsigned to signed (negative)");
        end else $display("FAIL: u to s negative, got %0d", s8);

        // Test 3: signed to unsigned (positive)
        total_tests++;
        s8 = 8'sd50;
        u8 = unsigned'(s8);
        if (u8 == 50) begin
            pass_count++;
            $display("PASS: signed to unsigned (positive)");
        end else $display("FAIL: s to u positive, got %0d", u8);

        // Test 4: signed to unsigned (negative becomes large)
        total_tests++;
        s8 = -1;
        u8 = unsigned'(s8);
        if (u8 == 255) begin
            pass_count++;
            $display("PASS: signed to unsigned (negative)");
        end else $display("FAIL: s to u negative, got %0d", u8);

        // Test 5: sign extension in wider type
        total_tests++;
        s8 = -50;
        s16 = signed'(s8);
        if (s16 == -50) begin
            pass_count++;
            $display("PASS: sign extension");
        end else $display("FAIL: sign extension, got %0d", s16);

        // Test 6: zero extension with unsigned
        total_tests++;
        u8 = 8'hFF;
        u16 = {8'b0, u8};
        if (u16 == 16'h00FF) begin
            pass_count++;
            $display("PASS: zero extension");
        end else $display("FAIL: zero extension, got %h", u16);

        // Test 7: $signed system function
        total_tests++;
        u32 = 32'hFFFF_FFFF;
        s32 = $signed(u32);
        if (s32 == -1) begin
            pass_count++;
            $display("PASS: $signed system function");
        end else $display("FAIL: $signed, got %0d", s32);

        // Test 8: $unsigned system function
        total_tests++;
        s32 = -1;
        u32 = $unsigned(s32);
        if (u32 == 32'hFFFF_FFFF) begin
            pass_count++;
            $display("PASS: $unsigned system function");
        end else $display("FAIL: $unsigned, got %h", u32);

        // Test 9: cast in expression
        total_tests++;
        u8 = 8'd200;
        i_val = signed'(u8) + 10;
        if (i_val == -46) begin  // -56 + 10 = -46
            pass_count++;
            $display("PASS: cast in expression");
        end else $display("FAIL: cast in expr, got %0d", i_val);

        // Test 10: chained casts
        total_tests++;
        s8 = -100;
        u32 = unsigned'(signed'({24'b0, unsigned'(s8)}));
        if (u32 == 32'd156) begin
            pass_count++;
            $display("PASS: chained casts");
        end else $display("FAIL: chained casts, got %0d", u32);

        // Test 11: max positive value stays positive
        total_tests++;
        u8 = 8'd127;
        s8 = signed'(u8);
        if (s8 == 127) begin
            pass_count++;
            $display("PASS: max positive (127)");
        end else $display("FAIL: max positive, got %0d", s8);

        // Test 12: boundary value (128)
        total_tests++;
        u8 = 8'd128;
        s8 = signed'(u8);
        if (s8 == -128) begin
            pass_count++;
            $display("PASS: boundary (128 -> -128)");
        end else $display("FAIL: boundary, got %0d", s8);

        // Test 13: arithmetic right shift with signed
        total_tests++;
        s32 = -16;
        s32 = s32 >>> 2;
        if (s32 == -4) begin
            pass_count++;
            $display("PASS: arithmetic right shift");
        end else $display("FAIL: arith shift, got %0d", s32);

        // Test 14: logical right shift with unsigned
        total_tests++;
        u32 = 32'hFFFF_FFF0;
        u32 = u32 >> 2;
        if (u32 == 32'h3FFF_FFFC) begin
            pass_count++;
            $display("PASS: logical right shift");
        end else $display("FAIL: logic shift, got %h", u32);

        $display("PASS: cast_signed (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
