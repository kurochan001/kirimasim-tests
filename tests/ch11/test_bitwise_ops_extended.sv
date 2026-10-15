/*
:name: test_bitwise_ops_extended
:description: Bitwise AND, OR, XOR and NOT on 32-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_ops_extended.expected
*/
// Bitwise AND, OR, XOR and NOT on 32-bit values
`timescale 1ns/1ps
module test_bitwise_ops_extended;
    reg [31:0] a, b, r;
    
    initial begin
        a = 32'hA5A5A5A5;
        b = 32'h5A5A5A5A;
        
        r = a & b;
        if (r != 0) $display("FAIL: and");
        r = a | b;
        if (r != 32'hFFFFFFFF) $display("FAIL: or");
        r = a ^ b;
        if (r != 32'hFFFFFFFF) $display("FAIL: xor");
        r = ~a;
        if (r != 32'h5A5A5A5A) $display("FAIL: not");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
