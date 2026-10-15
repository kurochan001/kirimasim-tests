/*
:name: test_math_funcs_2
:description: $sqrt, $ln, $exp, $floor and $ceil
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_funcs_2.expected
*/
// $sqrt, $ln, $exp, $floor and $ceil
`timescale 1ns/1ps
module test_math_funcs;
    real r, result;
    
    initial begin
        r = 4.0;
        result = $sqrt(r);
        if (result < 1.99 || result > 2.01) $display("FAIL: sqrt");
        
        result = $ln(2.718281828);
        if (result < 0.99 || result > 1.01) $display("FAIL: ln");
        
        result = $exp(1.0);
        if (result < 2.71 || result > 2.72) $display("FAIL: exp");
        
        result = $floor(3.7);
        if (result != 3.0) $display("FAIL: floor");
        
        result = $ceil(3.2);
        if (result != 4.0) $display("FAIL: ceil");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
