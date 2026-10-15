/*
:name: test_conditional_expr_2
:description: The conditional operator with constant and computed operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_expr_2.expected
*/
// The conditional operator with constant and computed operands
`timescale 1ns/1ps
module test_conditional_expr;
    int a, b, r;
    logic sel;
    
    initial begin
        a = 10; b = 20;
        sel = 1;
        
        r = sel ? a : b;
        if (r != 10) $display("FAIL: ternary true");
        
        sel = 0;
        r = sel ? a : b;
        if (r != 20) $display("FAIL: ternary false");
        
        r = (a < b) ? (a + b) : (a - b);
        if (r != 30) $display("FAIL: nested ternary");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
