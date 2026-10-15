/*
:name: test_reduction_ops_2
:description: Reduction AND, OR and XOR
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_ops_2.expected
*/
// Reduction AND, OR and XOR
`timescale 1ns/1ps
module test_reduction_ops;
    logic [7:0] val;
    logic r;
    
    initial begin
        val = 8'hFF;
        r = &val; if (!r) $display("FAIL: and reduce FF");
        r = |val; if (!r) $display("FAIL: or reduce FF");
        r = ^val; if (r) $display("FAIL: xor reduce FF");
        
        val = 8'h00;
        r = &val; if (r) $display("FAIL: and reduce 00");
        r = |val; if (r) $display("FAIL: or reduce 00");
        
        val = 8'h01;
        r = ^val; if (!r) $display("FAIL: xor reduce 01");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
