/*
:name: test_expr_logical
:description: Test for logical operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_logical.expected
*/
// Test for logical operators
// IEEE 1800-2023 §11.4.7: Logical operators
module test_expr_logical;
    initial begin
        static int a = 5, b = 0, c = 10;
        logic result;

        // Logical AND
        result = (a && c);
        if (result != 1) $display("FAIL: Logical AND true");
        result = (a && b);
        if (result != 0) $display("FAIL: Logical AND false");

        // Logical OR
        result = (a || b);
        if (result != 1) $display("FAIL: Logical OR true");
        result = (b || 0);
        if (result != 0) $display("FAIL: Logical OR false");

        // Short-circuit evaluation
        result = (b && (c/b));  // Should not divide by zero
        if (result != 0) $display("FAIL: Short-circuit AND");

        result = (a || (c/b));  // Should not divide by zero
        if (result != 1) $display("FAIL: Short-circuit OR");

        // Logical NOT
        if (!a != 0) $display("FAIL: Logical NOT non-zero");
        if (!b != 1) $display("FAIL: Logical NOT zero");

        $display("PASS: Logical operators");
        $finish;
    end
endmodule
