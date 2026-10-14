/*
:name: test_expr_unary
:description: Test for unary operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.7 11.4.8 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_unary.expected
*/
// Test for unary operators
// IEEE 1800-2023 §11.4.3, §11.4.7, §11.4.8 and §11.4.9: Unary operators
module test_expr_unary;
    initial begin
        static int a = 10;
        static int b = -5;
        static logic [7:0] c = 8'hAA;

        // Arithmetic negation
        if (-a != -10) $display("FAIL: Negation");

        // Logical not
        if (!a != 0) $display("FAIL: Logical not");
        if (!0 != 1) $display("FAIL: Logical not zero");

        // Bitwise not
        if (~c != 8'h55) $display("FAIL: Bitwise not");

        // Reduction operators
        if (&8'hFF != 1) $display("FAIL: Reduction AND");
        if (|8'h00 != 0) $display("FAIL: Reduction OR");
        if (^8'hAA != 0) $display("FAIL: Reduction XOR");

        $display("PASS: Unary operators");
        $finish;
    end
endmodule
