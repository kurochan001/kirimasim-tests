/*
:name: test_arithmetic
:description: Arithmetic operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic.expected
*/
// IEEE 1800-2023 Section 11.4.3: Arithmetic operators
module test_arithmetic;
    int a, b, result;
    real r1, r2, r_result;

    initial begin
        a = 15; b = 4;

        // Addition
        result = a + b;
        if (result == 19)
            $display("PASS: 15 + 4 = 19");
        else
            $display("FAIL: + = %0d", result);

        // Subtraction
        result = a - b;
        if (result == 11)
            $display("PASS: 15 - 4 = 11");
        else
            $display("FAIL: - = %0d", result);

        // Multiplication
        result = a * b;
        if (result == 60)
            $display("PASS: 15 * 4 = 60");
        else
            $display("FAIL: * = %0d", result);

        // Division
        result = a / b;
        if (result == 3)
            $display("PASS: 15 / 4 = 3");
        else
            $display("FAIL: / = %0d", result);

        // Modulus
        result = a % b;
        if (result == 3)
            $display("PASS: 15 %% 4 = 3");
        else
            $display("FAIL: %% = %0d", result);

        // Power
        a = 2; b = 8;
        result = a ** b;
        if (result == 256)
            $display("PASS: 2 ** 8 = 256");
        else
            $display("FAIL: ** = %0d", result);

        // Real arithmetic
        r1 = 3.5; r2 = 2.0;
        r_result = r1 + r2;
        if (r_result == 5.5)
            $display("PASS: 3.5 + 2.0 = 5.5");
        else
            $display("FAIL: real + = %f", r_result);

        $display("TEST PASSED: arithmetic tests completed");
        $finish;
    end
endmodule
