/*
:name: test_complex_condition_3
:description: if statements with compound and nested conditions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_complex_condition_3.expected
*/
`timescale 1ns/1ps

module test_complex_condition;
    logic a, b, c, d;
    logic [3:0] x, y;

    initial begin
        // Simple conditions
        a = 1; b = 0; c = 1; d = 0;

        // Complex boolean expressions
        if ((a && b) || (c && d))
            $display("FAIL: (a&&b)||(c&&d) should be false");

        if ((a || b) && (c || d))
            $display("PASS: (a||b)&&(c||d) is true");

        // Nested conditions
        begin
            logic result;
            result = a ? (b ? c : d) : (c ? d : a);
            if (result)
                $display("FAIL: nested ternary");
        end

        // Comparison chains
        x = 5; y = 10;
        if (x < y && y < 15)
            $display("PASS: chained comparison");

        // Mixed conditions
        if ((x > 0) && (y > 0) && ((x + y) < 20))
            $display("PASS: mixed condition");

        // Short-circuit evaluation
        if (a || b)
            $display("PASS: short-circuit OR");

        if (!b && a)
            $display("PASS: short-circuit AND");

        $display("TEST PASSED");
        $finish;
    end
endmodule
