/*
:name: test_stmt_if_else
:description: Test for if-else statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_if_else.expected
*/
// Test for if-else statements
// IEEE 1800-2023 §12.4: Conditional if-else statement
module test_stmt_if_else;
    initial begin
        static int a = 5, b = 10, c = 5;
        int result;

        // Simple if
        if (a < b) result = 1;
        else result = 0;
        if (result != 1) $display("FAIL: Simple if");

        // If-else chain
        if (a > b) result = 1;
        else if (a == c) result = 2;
        else result = 3;
        if (result != 2) $display("FAIL: If-else chain");

        // Nested if
        if (a <= b) begin
            if (a == c) result = 10;
            else result = 20;
        end
        if (result != 10) $display("FAIL: Nested if");

        // Empty else
        result = 0;
        if (a > b) result = 1;
        if (result != 0) $display("FAIL: Empty else");

        $display("PASS: If-else statements");
        $finish;
    end
endmodule
