/*
:name: test_packed_array_2
:description: A packed array assigned to and from a flat vector
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_2.expected
*/
// A packed array assigned to and from a flat vector
`timescale 1ns/1ps
module test_packed_array;
    logic [3:0][7:0] packed_arr;
    logic [31:0] flat;
    
    initial begin
        packed_arr[0] = 8'h11;
        packed_arr[1] = 8'h22;
        packed_arr[2] = 8'h33;
        packed_arr[3] = 8'h44;
        
        flat = packed_arr;
        if (flat != 32'h44332211) $display("FAIL: packed to flat");
        
        packed_arr = 32'hAABBCCDD;
        if (packed_arr[0] != 8'hDD) $display("FAIL: flat to packed");
        if (packed_arr[3] != 8'hAA) $display("FAIL: flat to packed 2");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
