/*
:name: test_assignment_operators_basic
:description: Simple and compound assignment operators, and array assignment in foreach
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 11.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_operators_basic.expected
*/
`timescale 1ns/1ps
module test_assignment_operators_basic;
    int a, b;
    logic [7:0] arr[4];
    
    initial begin
        a = 10;
        b = a;
        if (b != 10) $display("FAIL: simple assign");
        
        a += 5;
        if (a != 15) $display("FAIL: add assign");
        
        a -= 3;
        if (a != 12) $display("FAIL: sub assign");
        
        a *= 2;
        if (a != 24) $display("FAIL: mul assign");
        
        foreach (arr[i]) arr[i] = i << 2;
        if (arr[2] != 8) $display("FAIL: array assign");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
