/*
:name: test_cast_corner
:description: Tests static and dynamic casts, type conversions
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.24.2 6.12.1 6.19.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_corner.expected
*/
// Tests static and dynamic casts, type conversions
`timescale 1ns/1ps

module test_cast_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Size cast
    task test_size_cast();
        static logic [31:0] wide = 32'hDEADBEEF;
        logic [7:0] narrow;

        narrow = 8'(wide);

        if (narrow == 8'hEF) begin
            $display("PASS: Size cast to narrower works");
            pass_count++;
        end else begin
            $display("FAIL: Size cast failed (result=%h)", narrow);
            fail_count++;
        end
    endtask

    // Test 2: Sign cast
    task test_sign_cast();
        static logic [7:0] unsigned_val = 8'hFF;
        logic signed [7:0] signed_val;

        signed_val = signed'(unsigned_val);

        if (signed_val == -1) begin
            $display("PASS: Signed cast works (0xFF = -1)");
            pass_count++;
        end else begin
            $display("FAIL: Signed cast failed (result=%0d)", signed_val);
            fail_count++;
        end
    endtask

    // Test 3: Unsigned cast
    task test_unsigned_cast();
        static logic signed [7:0] signed_val = -1;
        logic [7:0] unsigned_val;

        unsigned_val = unsigned'(signed_val);

        if (unsigned_val == 8'hFF) begin
            $display("PASS: Unsigned cast works (-1 = 0xFF)");
            pass_count++;
        end else begin
            $display("FAIL: Unsigned cast failed");
            fail_count++;
        end
    endtask

    // Test 4: Type cast
    typedef logic [15:0] word_t;

    task test_type_cast();
        static logic [15:0] val = 16'hCAFE;
        word_t typed_val;

        typed_val = word_t'(val);

        if (typed_val == 16'hCAFE) begin
            $display("PASS: Type cast works");
            pass_count++;
        end else begin
            $display("FAIL: Type cast failed");
            fail_count++;
        end
    endtask

    // Test 5: $cast function (static)
    class BaseClass;
        int value = 10;
    endclass

    class DerivedClass extends BaseClass;
        int extra = 20;
    endclass

    task test_static_cast();
        BaseClass base;
        static DerivedClass derived = new();
        DerivedClass result;

        base = derived;  // Upcast

        if ($cast(result, base)) begin
            if (result.extra == 20) begin
                $display("PASS: $cast downcast works");
                pass_count++;
            end else begin
                $display("FAIL: $cast wrong value");
                fail_count++;
            end
        end else begin
            $display("FAIL: $cast should have succeeded");
            fail_count++;
        end
    endtask

    // Test 6: $cast failure
    task test_cast_failure();
        static BaseClass base = new();
        DerivedClass derived;

        if (!$cast(derived, base)) begin
            $display("PASS: $cast correctly fails for base-only object");
            pass_count++;
        end else begin
            $display("FAIL: $cast should have failed");
            fail_count++;
        end
    endtask

    // Test 7: Real to int cast
    task test_real_to_int();
        static real r = 3.7;
        int i;

        i = int'(r);

        // Converting real to integer rounds to the nearest integer (6.12.1)
        if (i == 4) begin
            $display("PASS: Real to int cast rounds (3.7 -> 4)");
            pass_count++;
        end else begin
            $display("FAIL: Real to int (result=%0d)", i);
            fail_count++;
        end
    endtask

    // Test 8: Int to real cast
    task test_int_to_real();
        static int i = 42;
        real r;

        r = real'(i);

        if (r == 42.0) begin
            $display("PASS: Int to real cast works");
            pass_count++;
        end else begin
            $display("FAIL: Int to real failed");
            fail_count++;
        end
    endtask

    // Test 9: Enum cast
    typedef enum {RED=0, GREEN=1, BLUE=2} color_t;

    task test_enum_cast();
        color_t c;
        static int val = 1;

        if ($cast(c, val)) begin
            if (c == GREEN) begin
                $display("PASS: Enum cast works (1 -> GREEN)");
                pass_count++;
            end else begin
                $display("FAIL: Enum cast wrong value");
                fail_count++;
            end
        end else begin
            $display("FAIL: Enum cast failed");
            fail_count++;
        end
    endtask

    // Test 10: Invalid enum cast
    task test_invalid_enum_cast();
        color_t c;
        static int val = 99;  // Not a valid enum value

        if (!$cast(c, val)) begin
            $display("PASS: Invalid enum cast correctly fails");
            pass_count++;
        end else begin
            $display("FAIL: Invalid enum cast succeeded (result=%s)", c.name());
            fail_count++;
        end
    endtask

    // Test 11: Width extension cast
    task test_width_extension();
        static logic [7:0] narrow = 8'hAB;
        logic [31:0] wide;

        wide = 32'(narrow);

        if (wide == 32'h000000AB) begin
            $display("PASS: Width extension cast works");
            pass_count++;
        end else begin
            $display("FAIL: Width extension failed (result=%h)", wide);
            fail_count++;
        end
    endtask

    // Test 12: Cast in expression
    task test_cast_in_expr();
        static logic [7:0] a = 8'hF0;
        static logic [7:0] b = 8'h10;
        logic signed [15:0] result;

        result = signed'({8'b0, a}) + signed'({8'b0, b});

        // 16'h00F0 + 16'h0010 = 256
        if (result == 256) begin
            $display("PASS: Cast in expression works (result=%0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: Cast in expression (result=%0d)", result);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Cast Expressions Corner Cases Test ===");

        test_size_cast();
        test_sign_cast();
        test_unsigned_cast();
        test_type_cast();
        test_static_cast();
        test_cast_failure();
        test_real_to_int();
        test_int_to_real();
        test_enum_cast();
        test_invalid_enum_cast();
        test_width_extension();
        test_cast_in_expr();

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
