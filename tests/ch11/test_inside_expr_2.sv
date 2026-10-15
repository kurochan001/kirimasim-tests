/*
:name: test_inside_expr_2
:description: inside with value sets and ranges
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_expr_2.expected
*/
`timescale 1ns/1ps
module test_inside_expr_2;
    int val;
    logic result;
    
    int fails = 0;

    
    initial begin
        val = 5;
        result = (val inside {1, 3, 5, 7, 9});
        if (!result) begin fails++; $display("FAIL: inside set"); end
        
        val = 6;
        result = (val inside {1, 3, 5, 7, 9});
        if (result) begin fails++; $display("FAIL: not inside set"); end
        
        val = 15;
        result = (val inside {[10:20]});
        if (!result) begin fails++; $display("FAIL: inside range"); end
        
        val = 25;
        result = (val inside {[10:20]});
        if (result) begin fails++; $display("FAIL: not inside range"); end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
