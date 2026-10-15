/*
:name: test_packed_struct
:description: A packed struct assigned to and from a flat vector
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_struct.expected
*/
// A packed struct assigned to and from a flat vector
`timescale 1ns/1ps
module test_packed_struct;
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [7:0] c;
        logic [7:0] d;
    } quad_t;
    
    quad_t q;
    logic [31:0] flat;
    
    initial begin
        q.a = 8'hAA;
        q.b = 8'hBB;
        q.c = 8'hCC;
        q.d = 8'hDD;
        
        flat = q;
        if (flat != 32'hAABBCCDD) $display("FAIL: to flat");
        
        q = 32'h11223344;
        if (q.a != 8'h11) $display("FAIL: from flat a");
        if (q.d != 8'h44) $display("FAIL: from flat d");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
