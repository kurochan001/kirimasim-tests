/*
:name: test_member_access_struct_array
:description: Member access of an unpacked struct and elements of a fixed-size array
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_struct_array.expected
*/
`timescale 1ns/1ps
module test_member_access_struct_array;
    typedef struct { int x; int y; } point_t;
    point_t p;
    int arr[5];
    
    int fails = 0;

    
    initial begin
        p.x = 10;
        p.y = 20;
        if (p.x != 10) begin fails++; $display("FAIL: p.x"); end
        if (p.y != 20) begin fails++; $display("FAIL: p.y"); end
        
        foreach (arr[i]) arr[i] = i * 3;
        if (arr[3] != 9) begin fails++; $display("FAIL: arr[3]"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
