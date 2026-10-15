/*
:name: test_array_element_access
:description: Writing and reading 1-D and 2-D unpacked array elements in loops
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_element_access.expected
*/
`timescale 1ns/1ps
module test_array_element_access;
    int arr[10];
    int arr2d[3][4];
    logic [7:0] packed_arr[8];
    
    initial begin
        // 1D array access
        for (int i = 0; i < 10; i++) arr[i] = i * 5;
        if (arr[5] != 25) $display("FAIL: arr[5]");
        
        // 2D array access
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 4; j++)
                arr2d[i][j] = i * 4 + j;
        if (arr2d[2][3] != 11) $display("FAIL: arr2d[2][3]");
        
        // Packed array
        for (int i = 0; i < 8; i++) packed_arr[i] = 8'hF0 + i;
        if (packed_arr[3] != 8'hF3) $display("FAIL: packed_arr[3]");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
