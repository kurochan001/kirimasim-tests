/*
:name: test_lexical_numbers
:description: Chapter 5.7: Numbers
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 5.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_lexical_numbers.expected
*/
// IEEE 1800-2023 Chapter 5.7: Numbers
// Test various number literal formats and edge cases

module test_lexical_numbers;
    // §5.7.1 Integer literal constants
    logic [31:0] decimal_simple;
    logic [31:0] decimal_underscore;
    logic [31:0] hex_simple;
    logic [31:0] hex_underscore;
    logic [31:0] octal_simple;
    logic [31:0] binary_simple;
    logic [31:0] sized_decimal;
    logic [31:0] sized_hex;
    logic [31:0] sized_octal;
    logic [31:0] sized_binary;

    // §5.7.1 Signed and unsigned
    logic signed [31:0] signed_val;
    logic [31:0] unsigned_val;

    // §5.7.2 Real literal constants
    real real_simple;
    real real_exponent;
    real real_negative_exp;
    real real_underscore;

    // X and Z values
    logic [7:0] val_with_x;
    logic [7:0] val_with_z;
    logic [7:0] val_with_question;

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test decimal literals
        decimal_simple = 123;
        test_count++;
        if (decimal_simple == 123) pass_count++;
        else $display("FAIL: decimal_simple expected 123, got %0d", decimal_simple);

        decimal_underscore = 1_000_000;
        test_count++;
        if (decimal_underscore == 1000000) pass_count++;
        else $display("FAIL: decimal_underscore expected 1000000, got %0d", decimal_underscore);

        // Test hexadecimal literals
        hex_simple = 'hDEAD;
        test_count++;
        if (hex_simple == 32'hDEAD) pass_count++;
        else $display("FAIL: hex_simple expected 0xDEAD, got 0x%0h", hex_simple);

        hex_underscore = 'hDEAD_BEEF;
        test_count++;
        if (hex_underscore == 32'hDEADBEEF) pass_count++;
        else $display("FAIL: hex_underscore expected 0xDEADBEEF, got 0x%0h", hex_underscore);

        // Test octal literals
        octal_simple = 'o777;
        test_count++;
        if (octal_simple == 32'o777) pass_count++;
        else $display("FAIL: octal_simple expected 0o777, got %0o", octal_simple);

        // Test binary literals
        binary_simple = 'b1010;
        test_count++;
        if (binary_simple == 32'b1010) pass_count++;
        else $display("FAIL: binary_simple expected 0b1010, got %0b", binary_simple);

        // Test sized literals
        sized_decimal = 32'd255;
        test_count++;
        if (sized_decimal == 255) pass_count++;
        else $display("FAIL: sized_decimal expected 255, got %0d", sized_decimal);

        sized_hex = 16'hABCD;
        test_count++;
        if (sized_hex == 16'hABCD) pass_count++;
        else $display("FAIL: sized_hex expected 0xABCD, got 0x%0h", sized_hex);

        sized_octal = 12'o7777;
        test_count++;
        if (sized_octal == 12'o7777) pass_count++;
        else $display("FAIL: sized_octal expected 0o7777, got %0o", sized_octal);

        sized_binary = 8'b1111_0000;
        test_count++;
        if (sized_binary == 8'hF0) pass_count++;
        else $display("FAIL: sized_binary expected 0xF0, got 0x%0h", sized_binary);

        // Test signed literals
        signed_val = -32'sd100;
        test_count++;
        if (signed_val == -100) pass_count++;
        else $display("FAIL: signed_val expected -100, got %0d", signed_val);

        // Test real literals
        real_simple = 3.14;
        test_count++;
        if (real_simple > 3.13 && real_simple < 3.15) pass_count++;
        else $display("FAIL: real_simple expected ~3.14, got %f", real_simple);

        real_exponent = 1.5e3;
        test_count++;
        if (real_exponent == 1500.0) pass_count++;
        else $display("FAIL: real_exponent expected 1500.0, got %f", real_exponent);

        real_negative_exp = 1.5e-2;
        test_count++;
        if (real_negative_exp > 0.014 && real_negative_exp < 0.016) pass_count++;
        else $display("FAIL: real_negative_exp expected ~0.015, got %f", real_negative_exp);

        // Test X and Z values
        val_with_x = 8'b1010_xxxx;
        test_count++;
        if (val_with_x[7:4] == 4'b1010 && $isunknown(val_with_x[3:0])) pass_count++;
        else $display("FAIL: val_with_x upper bits should be 1010");

        val_with_z = 8'b1010_zzzz;
        test_count++;
        if (val_with_z[7:4] == 4'b1010) pass_count++;
        else $display("FAIL: val_with_z upper bits should be 1010");

        val_with_question = 8'b1010_????;
        test_count++;
        if (val_with_question[7:4] == 4'b1010) pass_count++;
        else $display("FAIL: val_with_question upper bits should be 1010");

        // Summary
        $display("Chapter 5.7 Number Literals: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
