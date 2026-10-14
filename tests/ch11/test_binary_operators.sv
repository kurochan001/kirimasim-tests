/*
:name: test_binary_operators
:description: Binary Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 11.4.7 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_binary_operators.expected
*/
// IEEE 1800-2023 Section 11.4 - Binary Operators Tests
// Tests: Arithmetic, relational, equality, shift operators

module test_binary_operators;
    int pass_count = 0;
    int fail_count = 0;

    int a, b, result;
    logic [7:0] la, lb, lresult;
    logic cond;

    initial begin
        $display("=== IEEE 1800-2023 Binary Operators Tests ===");

        // Test 1: Addition
        $display("Test 1: Addition");
        a = 15;
        b = 7;
        result = a + b;
        if (result == 22) begin
            $display("Test 1 PASS: 15 + 7 = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Subtraction
        $display("Test 2: Subtraction");
        result = a - b;
        if (result == 8) begin
            $display("Test 2 PASS: 15 - 7 = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Multiplication
        $display("Test 3: Multiplication");
        result = a * b;
        if (result == 105) begin
            $display("Test 3 PASS: 15 * 7 = %0d", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Division
        $display("Test 4: Division");
        result = a / b;
        if (result == 2) begin
            $display("Test 4 PASS: 15 / 7 = %0d", result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Modulo
        $display("Test 5: Modulo");
        result = a % b;
        if (result == 1) begin
            $display("Test 5 PASS: 15 %% 7 = %0d", result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Left shift
        $display("Test 6: Left shift");
        la = 8'h01;
        lresult = la << 4;
        if (lresult == 8'h10) begin
            $display("Test 6 PASS: 0x01 << 4 = %h", lresult);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Right shift
        $display("Test 7: Right shift");
        la = 8'h80;
        lresult = la >> 4;
        if (lresult == 8'h08) begin
            $display("Test 7 PASS: 0x80 >> 4 = %h", lresult);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Relational operators
        $display("Test 8: Relational operators");
        a = 10;
        b = 20;
        cond = (a < b) && (a <= 10) && (b > a) && (b >= 20);
        if (cond) begin
            $display("Test 8 PASS: all relational ops correct");
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
