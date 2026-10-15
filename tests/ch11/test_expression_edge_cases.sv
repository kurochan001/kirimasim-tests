/*
:name: test_expression_edge_cases
:description: Integer overflow, shifts, division and modulus by zero, power and reductions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_expression_edge_cases.expected
*/
// IEEE 1800-2023 §11: Expression evaluation edge cases
// Tests for overflow, underflow, shift operations, and division

module test_expression_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    // Signed and unsigned values
    logic signed [31:0] s32;
    logic [31:0] u32;
    logic signed [63:0] s64;
    logic [63:0] u64;
    logic [7:0] u8;
    real r;

    initial begin
        // Test 1: Integer overflow (positive)
        test_count++;
        s32 = 32'h7FFFFFFF;  // Max positive
        s32 = s32 + 1;
        if (s32 < 0) begin
            pass_count++;
            $display("Test 1 PASS: Integer overflow wraps to negative (%0d)", s32);
        end else begin
            $display("Test 1 FAIL: Overflow did not wrap, s32=%0d", s32);
        end

        // Test 2: Integer underflow (negative)
        test_count++;
        s32 = 32'h80000000;  // Min negative
        s32 = s32 - 1;
        if (s32 > 0) begin
            pass_count++;
            $display("Test 2 PASS: Integer underflow wraps to positive (%0d)", s32);
        end else begin
            $display("Test 2 FAIL: Underflow did not wrap, s32=%0d", s32);
        end

        // Test 3: Left shift beyond width
        test_count++;
        u32 = 32'h1;
        u32 = u32 << 32;  // Shift by full width
        if (u32 == 0) begin
            pass_count++;
            $display("Test 3 PASS: Left shift by width gives 0");
        end else begin
            $display("Test 3 FAIL: u32=%h", u32);
        end

        // Test 4: Right shift with sign extension
        test_count++;
        s32 = -8;  // 0xFFFFFFF8
        s32 = s32 >>> 2;  // Arithmetic right shift
        if (s32 == -2) begin
            pass_count++;
            $display("Test 4 PASS: Arithmetic right shift preserves sign (%0d)", s32);
        end else begin
            $display("Test 4 FAIL: s32=%0d (expected -2)", s32);
        end

        // Test 5: Logical right shift (no sign extension)
        test_count++;
        u32 = 32'hF0000000;
        u32 = u32 >> 4;
        if (u32 == 32'h0F000000) begin
            pass_count++;
            $display("Test 5 PASS: Logical right shift works (%h)", u32);
        end else begin
            $display("Test 5 FAIL: u32=%h", u32);
        end

        // Test 6: Division by zero
        test_count++;
        u32 = 100;
        u32 = u32 / 0;
        // Integer division by zero gives x (11.4.2).
        if (u32 === 32'bx) begin
            pass_count++;
            $display("Test 6 PASS: Division by zero gives X");
        end else begin
            $display("Test 6 FAIL: result=%h", u32);
        end

        // Test 7: Modulo by zero
        test_count++;
        u32 = 100;
        u32 = u32 % 0;
        // Integer modulus by zero gives x (11.4.2).
        if (u32 === 32'bx) begin
            pass_count++;
            $display("Test 7 PASS: Modulo by zero gives X");
        end else begin
            $display("Test 7 FAIL: result=%h", u32);
        end

        // Test 8: Negative modulo
        test_count++;
        s32 = -7;
        s32 = s32 % 3;
        // IEEE 1800-2023: sign of result matches dividend
        if (s32 == -1) begin
            pass_count++;
            $display("Test 8 PASS: Negative modulo sign matches dividend (%0d)", s32);
        end else begin
            $display("Test 8 FAIL: s32=%0d (expected -1)", s32);
        end

        // Test 9: Power operation
        test_count++;
        u32 = 2 ** 10;
        if (u32 == 1024) begin
            pass_count++;
            $display("Test 9 PASS: Power operation 2**10=%0d", u32);
        end else begin
            $display("Test 9 FAIL: u32=%0d", u32);
        end

        // Test 10: Power with zero exponent
        test_count++;
        u32 = 5 ** 0;
        if (u32 == 1) begin
            pass_count++;
            $display("Test 10 PASS: x**0 = 1 (%0d)", u32);
        end else begin
            $display("Test 10 FAIL: u32=%0d", u32);
        end

        // Test 11: Bit width extension in operations
        test_count++;
        u8 = 8'hFF;
        u32 = u8 + 1;  // Should not overflow due to width extension
        if (u32 == 256) begin
            pass_count++;
            $display("Test 11 PASS: Width extension in addition (%0d)", u32);
        end else begin
            $display("Test 11 FAIL: u32=%0d", u32);
        end

        // Test 12: Concatenation
        test_count++;
        u32 = {16'hABCD, 16'h1234};
        if (u32 == 32'hABCD1234) begin
            pass_count++;
            $display("Test 12 PASS: Concatenation works (%h)", u32);
        end else begin
            $display("Test 12 FAIL: u32=%h", u32);
        end

        // Test 13: Replication
        test_count++;
        u32 = {4{8'hAB}};
        if (u32 == 32'hABABABAB) begin
            pass_count++;
            $display("Test 13 PASS: Replication works (%h)", u32);
        end else begin
            $display("Test 13 FAIL: u32=%h", u32);
        end

        // Test 14: Reduction operators
        test_count++;
        u8 = 8'b10101010;
        if (^u8 == 0 && |u8 == 1 && &u8 == 0) begin
            pass_count++;
            $display("Test 14 PASS: Reduction operators work");
        end else begin
            $display("Test 14 FAIL: ^=%b |=%b &=%b", ^u8, |u8, &u8);
        end

        // Test 15: Real to integer conversion
        test_count++;
        r = 3.7;
        s32 = $rtoi(r);
        if (s32 == 3) begin
            pass_count++;
            $display("Test 15 PASS: Real to int truncates (%0d)", s32);
        end else begin
            $display("Test 15 FAIL: s32=%0d", s32);
        end

        $display("=== Expression Edge Cases Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
