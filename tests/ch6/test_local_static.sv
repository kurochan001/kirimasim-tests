/*
:name: test_local_static
:description: A static variable in a function keeps its value between calls
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_static.expected
*/
// A static variable in a function keeps its value between calls
`timescale 1ns/1ps
module test_local_static;
    function int counter();
        static int count = 0;
        count++;
        return count;
    endfunction
    
    initial begin
        if (counter() != 1) $display("FAIL: call 1");
        if (counter() != 2) $display("FAIL: call 2");
        if (counter() != 3) $display("FAIL: call 3");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
