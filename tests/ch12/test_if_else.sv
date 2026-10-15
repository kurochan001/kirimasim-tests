/*
:name: test_if_else
:description: Conditional statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else.expected
*/
// IEEE 1800-2023 Section 12.4: Conditional statements
module test_if_else;
    int a, b, c;

    initial begin
        a = 10;
        b = 20;

        // Simple if
        if (a < b)
            c = 1;
        if (c == 1)
            $display("PASS: simple if");
        else
            $display("FAIL: simple if");

        // If-else
        if (a > b)
            c = 2;
        else
            c = 3;
        if (c == 3)
            $display("PASS: if-else");
        else
            $display("FAIL: if-else");

        // If-else-if chain
        if (a == 5)
            c = 10;
        else if (a == 10)
            c = 20;
        else if (a == 15)
            c = 30;
        else
            c = 40;
        if (c == 20)
            $display("PASS: if-else-if chain");
        else
            $display("FAIL: if-else-if");

        // Nested if
        if (a > 5) begin
            if (a < 15)
                c = 100;
        end
        if (c == 100)
            $display("PASS: nested if");
        else
            $display("FAIL: nested if");

        $display("TEST PASSED: if-else tests completed");
        $finish;
    end
endmodule
