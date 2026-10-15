/*
:name: test_real_math_simple
:description: $sqrt, $pow, $ln and $exp
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_math_simple.expected
*/
`timescale 1ns/1ps
module test_real_math_simple;
    real r, result;
    
    initial begin
        r = 2.0;
        result = $sqrt(r * 2.0);
        if (result < 1.99 || result > 2.01) $display("FAIL: sqrt");
        
        result = $pow(r, 3.0);
        if (result < 7.99 || result > 8.01) $display("FAIL: pow");
        
        result = $ln(r);
        if (result < 0.69 || result > 0.70) $display("FAIL: ln");
        
        result = $exp(1.0);
        if (result < 2.71 || result > 2.72) $display("FAIL: exp");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
