/*
:name: test_expr_unary_2
:description: Unary expressions test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.7 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_unary_2.expected
*/
// Unary expressions test
module test_expr_unary;
    int a, result;
    logic [7:0] byte_val;
    logic bit_result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Unary minus
        a = 10;
        result = -a;
        if (result == -10) begin
            $display("PASS: Unary minus -10 = -10");
            pass_count++;
        end else begin
            $display("FAIL: Unary minus, expected -10, got %0d", result);
            fail_count++;
        end

        // Test 2: Unary plus (identity)
        a = 25;
        result = +a;
        if (result == 25) begin
            $display("PASS: Unary plus +25 = 25");
            pass_count++;
        end else begin
            $display("FAIL: Unary plus, expected 25, got %0d", result);
            fail_count++;
        end

        // Test 3: Logical NOT
        a = 0;
        bit_result = !a;
        if (bit_result == 1'b1) begin
            $display("PASS: Logical NOT !0 = 1");
            pass_count++;
        end else begin
            $display("FAIL: Logical NOT, expected 1, got %b", bit_result);
            fail_count++;
        end

        // Test 4: Bitwise NOT
        byte_val = 8'h0F;
        byte_val = ~byte_val;
        if (byte_val == 8'hF0) begin
            $display("PASS: Bitwise NOT ~0x0F = 0xF0");
            pass_count++;
        end else begin
            $display("FAIL: Bitwise NOT, expected 0xF0, got 0x%02X", byte_val);
            fail_count++;
        end

        // Test 5: Double negation
        a = 5;
        result = -(-a);
        if (result == 5) begin
            $display("PASS: Double negation -(-5) = 5");
            pass_count++;
        end else begin
            $display("FAIL: Double negation, expected 5, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("Unary expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All unary expression tests passed");
        else $display("FAIL: Some unary expression tests failed");
        $finish;
    end
endmodule
