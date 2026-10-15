/*
:name: test_clog2_3
:description: $clog2 of powers of two and other values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2_3.expected
*/
// $clog2 of powers of two and other values
`timescale 1ns/1ps
module test_clog2;
    int r;
    
    initial begin
        r = $clog2(1);
        if (r != 0) $display("FAIL: clog2(1)");
        
        r = $clog2(2);
        if (r != 1) $display("FAIL: clog2(2)");
        
        r = $clog2(8);
        if (r != 3) $display("FAIL: clog2(8)");
        
        r = $clog2(9);
        if (r != 4) $display("FAIL: clog2(9)");
        
        r = $clog2(256);
        if (r != 8) $display("FAIL: clog2(256)");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
