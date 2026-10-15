/*
:name: test_shift_corner_2
:description: Logical and arithmetic shifts by constant and variable amounts
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_corner_2.expected
*/
// Logical and arithmetic shifts by constant and variable amounts
`timescale 1ns/1ps

module test_shift_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Logical left shift
    task test_logical_left();
        static logic [7:0] val = 8'h01;
        logic [7:0] result;

        result = val << 4;

        if (result == 8'h10) begin
            $display("PASS: Logical left shift works");
            pass_count++;
        end else begin
            $display("FAIL: Logical left shift failed (result: %h)", result);
            fail_count++;
        end
    endtask

    // Test 2: Logical right shift
    task test_logical_right();
        static logic [7:0] val = 8'h80;
        logic [7:0] result;

        result = val >> 4;

        if (result == 8'h08) begin
            $display("PASS: Logical right shift works");
            pass_count++;
        end else begin
            $display("FAIL: Logical right shift failed (result: %h)", result);
            fail_count++;
        end
    endtask

    // Test 3: Arithmetic left shift
    task test_arith_left();
        static logic signed [7:0] val = 8'sh01;
        logic signed [7:0] result;

        result = val <<< 4;

        if (result == 8'sh10) begin
            $display("PASS: Arithmetic left shift works");
            pass_count++;
        end else begin
            $display("FAIL: Arithmetic left shift failed");
            fail_count++;
        end
    endtask

    // Test 4: Arithmetic right shift (positive)
    task test_arith_right_pos();
        static logic signed [7:0] val = 8'sh40;  // +64
        logic signed [7:0] result;

        result = val >>> 2;

        if (result == 8'sh10) begin  // +16
            $display("PASS: Arithmetic right shift (positive) works");
            pass_count++;
        end else begin
            $display("FAIL: Arithmetic right shift (positive) failed");
            fail_count++;
        end
    endtask

    // Test 5: Arithmetic right shift (negative)
    task test_arith_right_neg();
        static logic signed [7:0] val = 8'shF0;  // -16
        logic signed [7:0] result;

        result = val >>> 2;

        if (result == 8'shFC) begin  // -4 with sign extension
            $display("PASS: Arithmetic right shift (negative) works");
            pass_count++;
        end else begin
            $display("FAIL: Arith right shift result: %h", result);
            fail_count++;
        end
    endtask

    // Test 6: Shift by zero
    task test_shift_zero();
        static logic [7:0] val = 8'hAB;
        logic [7:0] result;

        result = val << 0;

        if (result == 8'hAB) begin
            $display("PASS: Shift by zero works");
            pass_count++;
        end else begin
            $display("FAIL: Shift by zero failed");
            fail_count++;
        end
    endtask

    // Test 7: Shift by full width
    task test_shift_full_width();
        static logic [7:0] val = 8'hFF;
        logic [7:0] result;

        result = val << 8;

        if (result == 8'h00) begin
            $display("PASS: Shift by full width works");
            pass_count++;
        end else begin
            $display("FAIL: Full width shift result: %h", result);
            fail_count++;
        end
    endtask

    // Test 8: Shift by variable amount
    task test_variable_shift();
        static logic [7:0] val = 8'h01;
        int shift_amt;
        logic [7:0] result;

        shift_amt = 3;
        result = val << shift_amt;

        if (result == 8'h08) begin
            $display("PASS: Variable shift amount works");
            pass_count++;
        end else begin
            $display("FAIL: Variable shift failed (result: %h)", result);
            fail_count++;
        end
    endtask

    // Test 9: Wide value shift
    task test_wide_shift();
        static logic [31:0] val = 32'h00000001;
        logic [31:0] result;

        result = val << 24;

        if (result == 32'h01000000) begin
            $display("PASS: Wide value shift works");
            pass_count++;
        end else begin
            $display("FAIL: Wide shift failed (result: %h)", result);
            fail_count++;
        end
    endtask

    // Test 10: Shift in expression
    task test_shift_in_expr();
        static logic [7:0] a = 8'h0F;
        static logic [7:0] b = 8'h01;
        logic [7:0] result;

        result = (a << 4) | b;

        if (result == 8'hF1) begin
            $display("PASS: Shift in expression works");
            pass_count++;
        end else begin
            $display("FAIL: Shift in expression failed");
            fail_count++;
        end
    endtask

    // Test 11: Chain of shifts
    task test_chain_shifts();
        static logic [7:0] val = 8'hAB;
        logic [7:0] result;

        result = (val << 4) >> 4;

        if (result == 8'h0B) begin
            $display("PASS: Chain of shifts works");
            pass_count++;
        end else begin
            $display("FAIL: Chain shift result: %h", result);
            fail_count++;
        end
    endtask

    // Test 12: Shift and mask
    task test_shift_mask();
        static logic [7:0] val = 8'hFF;
        logic [7:0] result;
        static int bit_pos = 3;

        result = (val >> bit_pos) & 8'h01;

        if (result == 8'h01) begin
            $display("PASS: Shift and mask works");
            pass_count++;
        end else begin
            $display("FAIL: Shift and mask failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Shift Operators Corner Cases Test ===");

        test_logical_left();
        test_logical_right();
        test_arith_left();
        test_arith_right_pos();
        test_arith_right_neg();
        test_shift_zero();
        test_shift_full_width();
        test_variable_shift();
        test_wide_shift();
        test_shift_in_expr();
        test_chain_shifts();
        test_shift_mask();

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
