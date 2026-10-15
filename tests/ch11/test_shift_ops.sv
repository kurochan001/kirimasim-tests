/*
:name: test_shift_ops
:description: Logical and arithmetic shifts on 16-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_ops.expected
*/
// Logical and arithmetic shifts on 16-bit values
`timescale 1ns/1ps
module test_shift_ops;
    logic [15:0] val;
    logic signed [15:0] sval;
    
    initial begin
        val = 16'h00F0;
        val = val << 4;
        if (val != 16'h0F00) $display("FAIL: lsl");
        
        val = val >> 8;
        if (val != 16'h000F) $display("FAIL: lsr");
        
        sval = -16;
        sval = sval >>> 2;
        if (sval != -4) $display("FAIL: asr");
        
        val = 16'h8001;
        val = val <<< 1;
        if (val != 16'h0002) $display("FAIL: asl");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
