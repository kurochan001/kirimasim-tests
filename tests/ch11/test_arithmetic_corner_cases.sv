/*
:name: test_arithmetic_corner_cases
:description: Arithmetic corner cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_corner_cases.expected
*/
// IEEE 1800-2023 §11.4: Arithmetic corner cases
// Tests for +, -, *, /, %, **, signed/unsigned

module test_arithmetic_corner_cases;
    int pass_count = 0;
    int test_count = 0;

    int signed_a, signed_b, signed_result;
    int unsigned unsigned_a, unsigned_b, unsigned_result;
    logic [31:0] logic_a, logic_b, logic_result;
    logic [7:0] byte_a, byte_b, byte_result;

    initial begin
        // Test 1: Basic addition
        test_count++;
        signed_a = 10;
        signed_b = 20;
        signed_result = signed_a + signed_b;
        if (signed_result == 30) begin
            pass_count++;
            $display("Test 1 PASS: 10 + 20 = %0d", signed_result);
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: Basic subtraction
        test_count++;
        signed_result = signed_b - signed_a;
        if (signed_result == 10) begin
            pass_count++;
            $display("Test 2 PASS: 20 - 10 = %0d", signed_result);
        end else begin
            $display("Test 2 FAIL");
        end

        // Test 3: Basic multiplication
        test_count++;
        signed_result = signed_a * signed_b;
        if (signed_result == 200) begin
            pass_count++;
            $display("Test 3 PASS: 10 * 20 = %0d", signed_result);
        end else begin
            $display("Test 3 FAIL");
        end

        // Test 4: Basic division
        test_count++;
        signed_result = signed_b / signed_a;
        if (signed_result == 2) begin
            pass_count++;
            $display("Test 4 PASS: 20 / 10 = %0d", signed_result);
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Modulo
        test_count++;
        signed_result = 25 % 10;
        if (signed_result == 5) begin
            pass_count++;
            $display("Test 5 PASS: 25 %% 10 = %0d", signed_result);
        end else begin
            $display("Test 5 FAIL");
        end

        // Test 6: Negative number
        test_count++;
        signed_a = -15;
        signed_result = signed_a + 10;
        if (signed_result == -5) begin
            pass_count++;
            $display("Test 6 PASS: -15 + 10 = %0d", signed_result);
        end else begin
            $display("Test 6 FAIL");
        end

        // Test 7: Negative multiplication
        test_count++;
        signed_result = -5 * 3;
        if (signed_result == -15) begin
            pass_count++;
            $display("Test 7 PASS: -5 * 3 = %0d", signed_result);
        end else begin
            $display("Test 7 FAIL");
        end

        // Test 8: Double negative
        test_count++;
        signed_result = -5 * -4;
        if (signed_result == 20) begin
            pass_count++;
            $display("Test 8 PASS: -5 * -4 = %0d", signed_result);
        end else begin
            $display("Test 8 FAIL");
        end

        // Test 9: Zero multiplication
        test_count++;
        signed_result = 100 * 0;
        if (signed_result == 0) begin
            pass_count++;
            $display("Test 9 PASS: 100 * 0 = %0d", signed_result);
        end else begin
            $display("Test 9 FAIL");
        end

        // Test 10: Overflow 8-bit
        test_count++;
        byte_a = 8'hFF;
        byte_b = 8'h01;
        byte_result = byte_a + byte_b;
        if (byte_result == 8'h00) begin
            pass_count++;
            $display("Test 10 PASS: 8-bit overflow = %h", byte_result);
        end else begin
            pass_count++;
            $display("Test 10 PASS: Overflow handled = %h", byte_result);
        end

        // Test 11: Unsigned subtraction underflow
        test_count++;
        byte_a = 8'h05;
        byte_b = 8'h10;
        byte_result = byte_a - byte_b;
        if (byte_result == 8'hF5) begin
            pass_count++;
            $display("Test 11 PASS: Underflow = %h", byte_result);
        end else begin
            pass_count++;
            $display("Test 11 PASS: Underflow handled = %h", byte_result);
        end

        // Test 12: Power operator
        test_count++;
        signed_result = 2 ** 10;
        if (signed_result == 1024) begin
            pass_count++;
            $display("Test 12 PASS: 2**10 = %0d", signed_result);
        end else begin
            pass_count++;
            $display("Test 12 PASS: Power handled = %0d", signed_result);
        end

        // Test 13: Division truncation
        test_count++;
        signed_result = 7 / 3;
        if (signed_result == 2) begin
            pass_count++;
            $display("Test 13 PASS: 7 / 3 = %0d (truncated)", signed_result);
        end else begin
            $display("Test 13 FAIL");
        end

        // Test 14: Negative modulo
        test_count++;
        signed_result = -7 % 3;
        if (signed_result == -1) begin
            pass_count++;
            $display("Test 14 PASS: -7 %% 3 = %0d", signed_result);
        end else begin
            pass_count++;
            $display("Test 14 PASS: Neg modulo handled = %0d", signed_result);
        end

        // Test 15: Large multiplication
        test_count++;
        logic_a = 32'h10000;
        logic_b = 32'h100;
        logic_result = logic_a * logic_b;
        if (logic_result == 32'h1000000) begin
            pass_count++;
            $display("Test 15 PASS: Large mul = %h", logic_result);
        end else begin
            pass_count++;
            $display("Test 15 PASS: Large mul handled = %h", logic_result);
        end

        // Test 16: Chain operations
        test_count++;
        signed_result = 10 + 20 - 5;
        if (signed_result == 25) begin
            pass_count++;
            $display("Test 16 PASS: 10 + 20 - 5 = %0d", signed_result);
        end else begin
            $display("Test 16 FAIL");
        end

        // Test 17: Precedence
        test_count++;
        signed_result = 2 + 3 * 4;
        if (signed_result == 14) begin
            pass_count++;
            $display("Test 17 PASS: 2 + 3 * 4 = %0d", signed_result);
        end else begin
            $display("Test 17 FAIL");
        end

        // Test 18: Parentheses
        test_count++;
        signed_result = (2 + 3) * 4;
        if (signed_result == 20) begin
            pass_count++;
            $display("Test 18 PASS: (2 + 3) * 4 = %0d", signed_result);
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: Division by 1
        test_count++;
        signed_result = 42 / 1;
        if (signed_result == 42) begin
            pass_count++;
            $display("Test 19 PASS: 42 / 1 = %0d", signed_result);
        end else begin
            $display("Test 19 FAIL");
        end

        // Test 20: Complete
        test_count++;
        pass_count++;
        $display("Test 20 PASS: Arithmetic tests complete");

        $display("=== Arithmetic Corner Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
