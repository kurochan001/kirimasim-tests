/*
:name: test_lrm_operators_edge_cases
:description: Signed division and modulus, shifts, x in equality and case equality, operand extension
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.5 11.4.10
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_lrm_operators_edge_cases.expected
*/
// IEEE 1800-2023 §11 Operators - Edge Cases
// Tests for operator corner cases with 4-state values, overflow, etc.

module test_lrm_operators_edge_cases;
    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    // Test variables
    logic [31:0] a, b, result;
    logic [7:0] small_val;
    int signed sa, sb, sresult;
    real r1, r2, rresult;

    initial begin
        $display("=== IEEE 1800-2023 §11 Operators Edge Cases ===");

        // Test 1: Modulo with negative operands (§11.4.3)
        test_count++;
        sa = -17;
        sb = 5;
        sresult = sa % sb;
        // IEEE: sign of result matches sign of first operand
        if (sresult == -2) begin
            pass_count++;
            $display("Test 1 PASS: -17 %% 5 = %0d (negative mod)", sresult);
        end else begin
            fail_count++;
            $display("Test 1 FAIL: -17 %% 5 = %0d (expected -2)", sresult);
        end

        // Test 2: Modulo with negative divisor (§11.4.3)
        test_count++;
        sa = 17;
        sb = -5;
        sresult = sa % sb;
        // IEEE: sign of result matches sign of first operand
        if (sresult == 2) begin
            pass_count++;
            $display("Test 2 PASS: 17 %% -5 = %0d (negative divisor)", sresult);
        end else begin
            fail_count++;
            $display("Test 2 FAIL: 17 %% -5 = %0d (expected 2)", sresult);
        end

        // Test 3: Division truncation toward zero (§11.4.3)
        test_count++;
        sa = -17;
        sb = 5;
        sresult = sa / sb;
        // IEEE: truncate toward zero
        if (sresult == -3) begin
            pass_count++;
            $display("Test 3 PASS: -17 / 5 = %0d (truncate toward zero)", sresult);
        end else begin
            fail_count++;
            $display("Test 3 FAIL: -17 / 5 = %0d (expected -3)", sresult);
        end

        // Test 4: Shift with amount >= width (§11.4.10)
        test_count++;
        a = 32'hFFFF_FFFF;
        result = a >> 32;
        if (result == 0) begin
            pass_count++;
            $display("Test 4 PASS: Shift by width gives 0");
        end else begin
            fail_count++;
            $display("Test 4 FAIL: Shift by width = %h (expected 0)", result);
        end

        // Test 5: Arithmetic shift with negative value (§11.4.10)
        test_count++;
        sa = -8;  // 0xFFFFFFF8
        sresult = sa >>> 2;
        // Arithmetic shift preserves sign
        if (sresult == -2) begin
            pass_count++;
            $display("Test 5 PASS: -8 >>> 2 = %0d (sign preserved)", sresult);
        end else begin
            fail_count++;
            $display("Test 5 FAIL: -8 >>> 2 = %0d (expected -2)", sresult);
        end

        // Test 6: Equality with X values (§11.4.5)
        test_count++;
        a = 32'h1234_XXXX;
        b = 32'h1234_XXXX;
        // x bits make the equality ambiguous, so it gives x (11.4.5).
        if ((a == b) === 1'bx) begin
            pass_count++;
            $display("Test 6 PASS: X == X returns X");
        end else begin
            fail_count++;
            $display("Test 6 FAIL: X == X = %b", a == b);
        end

        // Test 7: Case equality with X (§11.4.5)
        test_count++;
        a = 32'h1234_XXXX;
        b = 32'h1234_XXXX;
        if (a === b) begin
            pass_count++;
            $display("Test 7 PASS: X === X returns 1 (case equal)");
        end else begin
            fail_count++;
            $display("Test 7 FAIL: X === X should be 1");
        end

        // Test 8: Wildcard equality (§11.4.6)
        test_count++;
        a = 32'h1234_5678;
        b = 32'h1234_XXXX;
        if (a ==? b) begin
            pass_count++;
            $display("Test 8 PASS: Wildcard equality with X");
        end else begin
            fail_count++;
            $display("Test 8 FAIL: Wildcard equality failed");
        end

        // Test 9: Power operator with zero exponent (§11.4.4)
        test_count++;
        r1 = 5.0;
        rresult = r1 ** 0;
        if (rresult == 1.0) begin
            pass_count++;
            $display("Test 9 PASS: 5.0 ** 0 = %0f", rresult);
        end else begin
            fail_count++;
            $display("Test 9 FAIL: 5.0 ** 0 = %0f (expected 1.0)", rresult);
        end

        // Test 10: Unary minus on unsigned (§11.4.2)
        test_count++;
        a = 32'd5;
        result = -a;
        // Unary minus on unsigned wraps around
        if (result == 32'hFFFF_FFFB) begin
            pass_count++;
            $display("Test 10 PASS: -5u = 0x%h (wrap)", result);
        end else begin
            fail_count++;
            $display("Test 10 FAIL: -5u = 0x%h", result);
        end

        // Test 11: Reduction XOR for parity (§11.4.9)
        test_count++;
        a = 32'hFFFF_FFFF;
        if (^a == 0) begin
            pass_count++;
            $display("Test 11 PASS: ^(all 1s) = 0 (even parity)");
        end else begin
            fail_count++;
            $display("Test 11 FAIL: ^(all 1s) = %0d", ^a);
        end

        // Test 12: Reduction with X propagation (§11.4.9)
        test_count++;
        a = 32'h0000_000X;
        result = |a;
        if (result === 1'bx) begin
            pass_count++;
            $display("Test 12 PASS: |(...X) = X (X propagation)");
        end else begin
            fail_count++;
            $display("Test 12 FAIL: |(...X) = %b", result);
        end

        // Test 13: Concatenation with different widths (§11.4.12)
        test_count++;
        small_val = 8'hAB;
        result = {24'h0, small_val};
        if (result == 32'h0000_00AB) begin
            pass_count++;
            $display("Test 13 PASS: Concatenation zero-extends");
        end else begin
            fail_count++;
            $display("Test 13 FAIL: {0, 8'hAB} = 0x%h", result);
        end

        // Test 14: Replication operator (§11.4.12)
        test_count++;
        small_val = 8'hAB;
        result = {4{small_val}};
        if (result == 32'hABAB_ABAB) begin
            pass_count++;
            $display("Test 14 PASS: {4{8'hAB}} = 0x%h", result);
        end else begin
            fail_count++;
            $display("Test 14 FAIL: {4{8'hAB}} = 0x%h", result);
        end

        // Test 15: Conditional with different types (§11.4.11)
        test_count++;
        begin
            logic [15:0] cond_small;
            logic [31:0] cond_large;
            logic [31:0] cond_result;
            cond_small = 16'hABCD;
            cond_large = 32'h1234_5678;
            cond_result = 1'b1 ? cond_small : cond_large;
            // Result should be extended to larger type
            if (cond_result == 32'h0000_ABCD) begin
                pass_count++;
                $display("Test 15 PASS: Conditional type extension");
            end else begin
                fail_count++;
                $display("Test 15 FAIL: Conditional = 0x%h", cond_result);
            end
        end

        // Summary
        $display("\n=== Summary ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
