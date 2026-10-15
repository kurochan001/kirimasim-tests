/*
:name: test_onehot_2
:description: $onehot and $onehot0
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_onehot_2.expected
*/
// $onehot and $onehot0
`timescale 1ns/1ps
module test_onehot;
    logic [7:0] val;
    logic r;
    
    initial begin
        val = 8'b00000001;
        r = $onehot(val);
        if (!r) $display("FAIL: onehot 1");
        
        val = 8'b00001000;
        r = $onehot(val);
        if (!r) $display("FAIL: onehot 8");
        
        val = 8'b00000011;
        r = $onehot(val);
        if (r) $display("FAIL: not onehot");
        
        val = 8'b00000000;
        r = $onehot0(val);
        if (!r) $display("FAIL: onehot0 zero");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
