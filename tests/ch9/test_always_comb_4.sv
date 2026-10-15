/*
:name: test_always_comb_4
:description: always_comb computing a sum and a difference that follow their inputs
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_4.expected
*/
// always_comb computing a sum and a difference that follow their inputs
`timescale 1ns/1ps
module test_always_comb;
    logic [7:0] a, b;
    logic [8:0] sum;
    logic [7:0] diff;
    
    always_comb begin
        sum = a + b;
        diff = a - b;
    end
    
    initial begin
        a = 100; b = 50;
        #1;
        if (sum != 150) $display("FAIL: sum");
        if (diff != 50) $display("FAIL: diff");
        
        a = 200;
        #1;
        if (sum != 250) $display("FAIL: sum 2");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
