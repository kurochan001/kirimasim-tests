/*
:name: test_if_else_chain_2
:description: An if-else-if chain inside a loop
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_chain_2.expected
*/
// An if-else-if chain inside a loop
`timescale 1ns/1ps
module test_if_else_chain;
    int val, result;
    
    initial begin
        for (val = 0; val <= 5; val++) begin
            if (val == 0) result = 0;
            else if (val == 1) result = 1;
            else if (val == 2) result = 4;
            else if (val == 3) result = 9;
            else if (val == 4) result = 16;
            else result = 25;
            
            if (result != val * val) $display("FAIL: val=%0d", val);
        end
        $display("TEST PASSED");
        $finish;
    end
endmodule
