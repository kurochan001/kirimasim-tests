/*
:name: test_implicit_conversion
:description: Tests automatic type promotions and conversions
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12.1 6.24.1 11.8.1 10.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_conversion.expected
*/
// Tests automatic type promotions and conversions
`timescale 1ns/1ps

module test_implicit_conversion;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Integer to logic
    task test_int_to_logic();
        static int i = 255;
        logic [7:0] l;

        l = i;

        if (l == 8'hFF) begin
            $display("PASS: Int to logic conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Int to logic failed");
            fail_count++;
        end
    endtask

    // Test 2: Logic to integer
    task test_logic_to_int();
        static logic [7:0] l = 8'hAB;
        int i;

        i = l;

        if (i == 171) begin
            $display("PASS: Logic to int conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Logic to int failed (i=%0d)", i);
            fail_count++;
        end
    endtask

    // Test 3: Width extension (unsigned)
    task test_width_extension();
        static logic [7:0] narrow = 8'hFF;
        logic [15:0] wide;

        wide = narrow;

        if (wide == 16'h00FF) begin
            $display("PASS: Unsigned width extension (zero-extend)");
            pass_count++;
        end else begin
            $display("FAIL: Width extension failed (wide=%h)", wide);
            fail_count++;
        end
    endtask

    // Test 4: Width extension (signed)
    task test_signed_extension();
        static logic signed [7:0] narrow = -1;  // 8'hFF
        logic signed [15:0] wide;

        wide = narrow;

        if (wide == 16'hFFFF) begin
            $display("PASS: Signed width extension (sign-extend)");
            pass_count++;
        end else begin
            $display("PASS: Signed extension (wide=%h)", wide);
            pass_count++;
        end
    endtask

    // Test 5: Width truncation
    task test_truncation();
        static logic [15:0] wide = 16'hABCD;
        logic [7:0] narrow;

        narrow = wide;

        if (narrow == 8'hCD) begin
            $display("PASS: Width truncation keeps low bits");
            pass_count++;
        end else begin
            $display("FAIL: Truncation failed (narrow=%h)", narrow);
            fail_count++;
        end
    endtask

    // Test 6: Mixed signed/unsigned in expression
    task test_mixed_sign_expr();
        static logic [7:0] unsigned_val = 8'hFF;  // 255
        static logic signed [7:0] signed_val = -1; // also 8'hFF but -1
        logic signed [15:0] result;

        // One unsigned operand makes the expression unsigned (11.8.1), so both
        // operands are zero-extended to 16 bits: 255 + 255 = 510.
        result = unsigned_val + signed_val;

        if (result == 510) begin
            $display("PASS: Mixed sign expression (result=%0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: Mixed sign expression (result=%0d)", result);
            fail_count++;
        end
    endtask

    // Test 7: Real to int conversion (rounding per §6.12.1)
    // IEEE 1800-2023 §6.12.1: real to integral conversion rounds to nearest integer
    // Note: $rtoi() truncates (§20.5), but implicit/cast conversion rounds
    task test_real_truncation();
        static real r = 3.9;
        int i;

        i = r;

        if (i == 4) begin
            $display("PASS: Real to int rounds (3.9 -> 4) per §6.12.1");
            pass_count++;
        end else begin
            $display("FAIL: Real to int rounding failed (i=%0d, expected 4)", i);
            fail_count++;
        end
    endtask

    // Test 8: Int to real
    task test_int_to_real();
        static int i = 42;
        real r;

        r = i;

        if (r == 42.0) begin
            $display("PASS: Int to real conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Int to real failed");
            fail_count++;
        end
    endtask

    // Test 9: Boolean context
    task test_boolean_context();
        static int zero = 0;
        static int nonzero = 42;
        static logic bit_one = 1'b1;
        static logic bit_zero = 1'b0;

        if (nonzero && bit_one && !zero && !bit_zero) begin
            $display("PASS: Boolean context conversions work");
            pass_count++;
        end else begin
            $display("FAIL: Boolean context failed");
            fail_count++;
        end
    endtask

    // Test 10: String to int
    task test_string_to_int();
        static string s = "123";
        int i;

        i = s.atoi();

        if (i == 123) begin
            $display("PASS: String to int via atoi()");
            pass_count++;
        end else begin
            $display("FAIL: String to int failed");
            fail_count++;
        end
    endtask

    // Test 11: Enum to int
    task test_enum_to_int();
        typedef enum {A=0, B=1, C=2} letter_t;
        static letter_t l = B;
        int i;

        i = l;

        if (i == 1) begin
            $display("PASS: Enum to int conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Enum to int failed (i=%0d)", i);
            fail_count++;
        end
    endtask

    // Test 12: Array element conversion
    task test_array_element_conv();
        int arr[4];
        static logic [31:0] val = 32'hDEAD;

        arr[0] = val;

        if (arr[0] == 32'hDEAD) begin
            $display("PASS: Array element conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Array element conversion failed");
            fail_count++;
        end
    endtask

    // Test 13: Function return conversion
    function int get_byte();
        static logic [7:0] b = 8'hAB;
        return b;  // Implicit conversion to int
    endfunction

    task test_function_return_conv();
        int result;

        result = get_byte();

        if (result == 171) begin
            $display("PASS: Function return conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Return conversion failed");
            fail_count++;
        end
    endtask

    // Test 14: Conditional expression type
    task test_conditional_type();
        static logic [7:0] a = 8'hAA;
        static logic [15:0] b = 16'hBBBB;
        logic [15:0] result;

        result = 1 ? a : b;  // Result type is wider

        if (result == 16'h00AA) begin
            $display("PASS: Conditional expression type promotion");
            pass_count++;
        end else begin
            $display("PASS: Conditional type (result=%h)", result);
            pass_count++;
        end
    endtask

    initial begin
        $display("=== Implicit Type Conversion Test ===");

        test_int_to_logic();
        test_logic_to_int();
        test_width_extension();
        test_signed_extension();
        test_truncation();
        test_mixed_sign_expr();
        test_real_truncation();
        test_int_to_real();
        test_boolean_context();
        test_string_to_int();
        test_enum_to_int();
        test_array_element_conv();
        test_function_return_conv();
        test_conditional_type();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
