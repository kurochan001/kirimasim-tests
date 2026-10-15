/*
:name: test_expr_arithmetic
:description: Test for arithmetic operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_arithmetic.expected
*/
// Test for arithmetic operators
// IEEE 1800-2023 §11.4.3: Arithmetic operators
module test_expr_arithmetic;
    initial begin
        static int a = 15, b = 4;
        int result;

        // Addition
        result = a + b;
        if (result != 19) $display("FAIL: Addition");

        // Subtraction
        result = a - b;
        if (result != 11) $display("FAIL: Subtraction");

        // Multiplication
        result = a * b;
        if (result != 60) $display("FAIL: Multiplication");

        // Division
        result = a / b;
        if (result != 3) $display("FAIL: Division");

        // Modulo
        result = a % b;
        if (result != 3) $display("FAIL: Modulo");

        // Power operator
        result = 2 ** 8;
        if (result != 256) $display("FAIL: Power");

        // Negative numbers
        result = -a + b;
        if (result != -11) $display("FAIL: Negative");

        // Signed division
        result = -15 / 4;
        if (result != -3) $display("FAIL: Signed division");

        $display("PASS: Arithmetic operators");
        $finish;
    end
endmodule
