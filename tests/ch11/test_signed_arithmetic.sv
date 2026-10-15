/*
:name: test_signed_arithmetic
:description: Signed and unsigned 16-bit arithmetic
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_arithmetic.expected
*/
// Signed and unsigned 16-bit arithmetic
`timescale 1ns/1ps
module test_signed_arithmetic;
    logic signed [15:0] sa, sb, sr;
    logic [15:0] ua, ub, ur;
    
    initial begin
        sa = -100;
        sb = 30;
        sr = sa + sb;
        if (sr != -70) $display("FAIL: signed add");
        
        sr = sa * sb;
        if (sr != -3000) $display("FAIL: signed mul");
        
        sr = sa / sb;
        if (sr != -3) $display("FAIL: signed div");
        
        ua = 100;
        ub = 30;
        ur = ua - ub;
        if (ur != 70) $display("FAIL: unsigned sub");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
