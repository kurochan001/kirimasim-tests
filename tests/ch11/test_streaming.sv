/*
:name: test_streaming
:description: Streaming a word into an unpacked byte array and back
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming.expected
*/
// Streaming a word into an unpacked byte array and back (11.4.14)
`timescale 1ns/1ps
module test_streaming;
    logic [31:0] val;
    logic [7:0] bytes[4];
    logic [31:0] result;
    
    int fails = 0;

    
    initial begin
        val = 32'hAABBCCDD;
        {>>{bytes}} = val;
        
        if (bytes[0] != 8'hAA) begin fails++; $display("FAIL: byte 0"); end
        if (bytes[3] != 8'hDD) begin fails++; $display("FAIL: byte 3"); end
        
        result = {>>{bytes}};
        if (result != 32'hAABBCCDD) begin fails++; $display("FAIL: reconstruct"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
