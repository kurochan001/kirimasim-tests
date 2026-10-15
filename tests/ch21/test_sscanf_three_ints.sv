/*
:name: test_sscanf_three_ints
:description: $sscanf reading three integers
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_three_ints.expected
*/
`timescale 1ns/1ps
module test_scanf_utils;
    int a, b, c;
    string s;
    
    initial begin
        s = "10 20 30";
        if ($sscanf(s, "%d %d %d", a, b, c) == 3) begin
            if (a != 10) $display("FAIL: a");
            if (b != 20) $display("FAIL: b");
            if (c != 30) $display("FAIL: c");
        end else $display("FAIL: sscanf");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
