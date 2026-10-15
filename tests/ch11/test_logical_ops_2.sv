/*
:name: test_logical_ops_2
:description: Logical operators on 1-bit and int operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logical_ops_2.expected
*/
// Logical operators on 1-bit and int operands
`timescale 1ns/1ps
module test_logical_ops;
    logic a, b, c;
    int x, y;
    
    initial begin
        a = 1; b = 0;
        c = a && b; if (c) $display("FAIL: and");
        c = a || b; if (!c) $display("FAIL: or");
        c = !a; if (c) $display("FAIL: not");
        
        x = 5; y = 0;
        c = x && y; if (c) $display("FAIL: int and");
        c = x || y; if (!c) $display("FAIL: int or");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
