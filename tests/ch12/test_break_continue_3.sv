/*
:name: test_break_continue_3
:description: Target: break continue
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_break_continue_3.expected
*/
// Target: break continue
`timescale 1ns/1ps
module test_break_continue;
    int i, sum;
    
    initial begin
        sum = 0;
        for (i = 0; i < 20; i++) begin
            if (i == 10) break;
            sum += i;
        end
        if (sum != 45) $display("FAIL: break");
        
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;
            sum += i;
        end
        if (sum != 25) $display("FAIL: continue");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
