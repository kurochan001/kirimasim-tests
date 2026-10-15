/*
:name: test_expr_conditional
:description: Test for conditional expression evaluation
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_conditional.expected
*/
// Test for conditional expression evaluation
// IEEE 1800-2023 §11.4.11: Conditional operator
module test_expr_conditional;
    initial begin
        static int a = 5, b = 10, c;
        static bit sel = 1;

        // Basic ternary
        c = sel ? a : b;
        if (c != 5) $display("FAIL: Basic ternary");

        // Nested ternary
        c = (a > b) ? a : (b > 0) ? b : 0;
        if (c != 10) $display("FAIL: Nested ternary");

        // Ternary with expressions
        c = (a + b > 10) ? a * 2 : b / 2;
        if (c != 10) $display("FAIL: Expression ternary");

        $display("PASS: Conditional expression");
        $finish;
    end
endmodule
