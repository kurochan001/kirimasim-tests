/*
:name: test_generate_for
:description: A loop generate construct driving array elements
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_for.expected
*/
// A loop generate construct driving array elements
`timescale 1ns/1ps
module test_generate_for;
    genvar i;
    logic [7:0] arr[4];
    
    generate
        for (i = 0; i < 4; i++) begin : gen_block
            assign arr[i] = i * 16;
        end
    endgenerate
    
    initial begin
        #1;
        if (arr[0] != 0) $display("FAIL: arr[0]");
        if (arr[1] != 16) $display("FAIL: arr[1]");
        if (arr[2] != 32) $display("FAIL: arr[2]");
        if (arr[3] != 48) $display("FAIL: arr[3]");
        $display("TEST PASSED");
        $finish;
    end
endmodule
