/*
:name: test_concat_replicate_2
:description: Concatenation, replication and concatenation of part-selects
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_replicate_2.expected
*/
// Concatenation, replication and concatenation of part-selects
`timescale 1ns/1ps
module test_concat_replicate;
    logic [7:0] a, b;
    logic [15:0] c;
    logic [31:0] d;
    
    initial begin
        a = 8'hAB;
        b = 8'hCD;
        c = {a, b};
        if (c != 16'hABCD) $display("FAIL: concat");
        
        d = {4{a}};
        if (d != 32'hABABABAB) $display("FAIL: replicate");
        
        c = {a[3:0], b[7:4], a[7:4], b[3:0]};
        if (c != 16'hBCAD) $display("FAIL: part select concat");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
