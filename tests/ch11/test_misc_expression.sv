/*
:name: test_misc_expression
:description: Comparison, conditional operator, increment and decrement
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.11 11.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_misc_expression.expected
*/
`timescale 1ns/1ps
module test_misc_expression;
    int a, b;
    logic cond;
    
    initial begin
        a = 5; b = 10;
        cond = (a < b);
        if (!cond) $display("FAIL: comparison");
        
        // Ternary expression
        a = cond ? 100 : 200;
        if (a != 100) $display("FAIL: ternary");
        
        // Increment/decrement
        a = 10;
        a++;
        if (a != 11) $display("FAIL: increment");
        a--;
        if (a != 10) $display("FAIL: decrement");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
