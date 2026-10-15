/*
:name: test_struct_ops
:description: Unpacked struct member assignment, copy and assignment pattern
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_ops.expected
*/
`timescale 1ns/1ps
module test_struct_ops;
    typedef struct {
        int x;
        int y;
        logic [7:0] data;
    } point_t;
    
    point_t p1, p2;
    
    int fails = 0;

    
    initial begin
        p1.x = 10;
        p1.y = 20;
        p1.data = 8'hAB;
        
        if (p1.x != 10) begin fails++; $display("FAIL: x"); end
        if (p1.y != 20) begin fails++; $display("FAIL: y"); end
        if (p1.data != 8'hAB) begin fails++; $display("FAIL: data"); end
        
        p2 = p1;
        if (p2.x != 10) begin fails++; $display("FAIL: copy x"); end
        
        p2 = '{30, 40, 8'hCD};
        if (p2.x != 30) begin fails++; $display("FAIL: literal x"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
