/*
:name: test_relational_ops_2
:description: Relational and equality operators on int values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_relational_ops_2.expected
*/
// Relational and equality operators on int values
`timescale 1ns/1ps
module test_relational_ops;
    int a, b;
    logic result;
    
    initial begin
        a = 10; b = 20;
        
        result = (a < b); if (!result) $display("FAIL: lt");
        result = (a <= b); if (!result) $display("FAIL: le");
        result = (a > b); if (result) $display("FAIL: gt");
        result = (a >= b); if (result) $display("FAIL: ge");
        result = (a == b); if (result) $display("FAIL: eq");
        result = (a != b); if (!result) $display("FAIL: ne");
        
        a = 20;
        result = (a == b); if (!result) $display("FAIL: eq2");
        result = (a >= b); if (!result) $display("FAIL: ge2");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
