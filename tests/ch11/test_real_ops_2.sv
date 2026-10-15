/*
:name: test_real_ops_2
:description: real addition, subtraction, multiplication and division
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_ops_2.expected
*/
// real addition, subtraction, multiplication and division
`timescale 1ns/1ps
module test_real_ops;
    real a, b, r;
    
    initial begin
        a = 10.5;
        b = 3.5;
        
        r = a + b;
        if (r != 14.0) $display("FAIL: add");
        
        r = a - b;
        if (r != 7.0) $display("FAIL: sub");
        
        r = a * b;
        if (r < 36.7 || r > 36.8) $display("FAIL: mul");
        
        r = a / b;
        if (r != 3.0) $display("FAIL: div");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
