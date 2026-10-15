/*
:name: test_union_ops
:description: A packed union of a word and a struct of two halves
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_union_ops.expected
*/
// A packed union of a word and a struct of two halves
`timescale 1ns/1ps
module test_union_ops;
    typedef union packed {
        logic [31:0] word;
        struct packed { logic [15:0] hi; logic [15:0] lo; } halves;
    } word_u;
    
    word_u w;
    
    initial begin
        w.word = 32'hDEADBEEF;
        if (w.halves.hi != 16'hDEAD) $display("FAIL: hi");
        if (w.halves.lo != 16'hBEEF) $display("FAIL: lo");
        
        w.halves.hi = 16'hCAFE;
        if (w.word != 32'hCAFEBEEF) $display("FAIL: modify hi");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
