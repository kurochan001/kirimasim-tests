/*
:name: test_unary_operators
:description: Unary Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unary_operators.expected
*/
// IEEE 1800-2023 Section 11.4 - Unary Operators Tests
// Tests: Unary plus, minus, NOT, reduction operators

module test_unary_operators;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] val8;
    logic [3:0] val4;
    int signed_val;
    logic result_bit;

    initial begin
        $display("=== IEEE 1800-2023 Unary Operators Tests ===");

        // Test 1: Unary plus
        $display("Test 1: Unary plus");
        signed_val = +42;
        if (signed_val == 42) begin
            $display("Test 1 PASS: +42 = %0d", signed_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Unary minus
        $display("Test 2: Unary minus");
        signed_val = -42;
        if (signed_val == -42) begin
            $display("Test 2 PASS: -42 = %0d", signed_val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Bitwise NOT
        $display("Test 3: Bitwise NOT");
        val8 = 8'h0F;
        val8 = ~val8;
        if (val8 == 8'hF0) begin
            $display("Test 3 PASS: ~0x0F = %h", val8);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", val8);
            fail_count++;
        end

        // Test 4: Logical NOT
        $display("Test 4: Logical NOT");
        val8 = 8'h00;
        if (!val8) begin
            $display("Test 4 PASS: !0 is true");
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Reduction AND
        $display("Test 5: Reduction AND");
        val8 = 8'hFF;
        result_bit = &val8;
        if (result_bit == 1'b1) begin
            $display("Test 5 PASS: &0xFF = %b", result_bit);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Reduction OR
        $display("Test 6: Reduction OR");
        val8 = 8'h01;
        result_bit = |val8;
        if (result_bit == 1'b1) begin
            $display("Test 6 PASS: |0x01 = %b", result_bit);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Reduction XOR
        $display("Test 7: Reduction XOR");
        val4 = 4'b1010;  // Even number of 1s
        result_bit = ^val4;
        if (result_bit == 1'b0) begin
            $display("Test 7 PASS: ^0b1010 = %b (even parity)", result_bit);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Reduction XNOR
        $display("Test 8: Reduction XNOR");
        val4 = 4'b1010;
        result_bit = ~^val4;
        if (result_bit == 1'b1) begin
            $display("Test 8 PASS: ~^0b1010 = %b", result_bit);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
