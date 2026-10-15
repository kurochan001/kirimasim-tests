/*
:name: test_for_loop_variants
:description: for loops counting up, down and nested
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_variants.expected
*/
// for loops counting up, down and nested
`timescale 1ns/1ps
module test_for_loop_variants;
    int sum, i, j;
    
    initial begin
        sum = 0;
        for (i = 1; i <= 10; i++) sum += i;
        if (sum != 55) $display("FAIL: simple for");
        
        sum = 0;
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 5; j++) begin
                sum += 1;
            end
        end
        if (sum != 25) $display("FAIL: nested for");
        
        sum = 0;
        for (i = 10; i > 0; i -= 2) sum += i;
        if (sum != 30) $display("FAIL: decrement for");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
