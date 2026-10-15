/*
:name: test_arithmetic_expression
:description: Signed and unsigned 16-bit addition, multiplication and division
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_expression.expected
*/
`timescale 1ns/1ps
module test_arithmetic_expression;
    logic signed [15:0] s1, s2, s3;
    logic [15:0] u1, u2, u3;
    
    initial begin
        // Signed arithmetic
        s1 = -10; s2 = 3;
        s3 = s1 + s2; if (s3 != -7) $display("FAIL: signed add");
        s3 = s1 * s2; if (s3 != -30) $display("FAIL: signed mul");
        s3 = s1 / s2; if (s3 != -3) $display("FAIL: signed div");
        
        // Unsigned arithmetic
        u1 = 100; u2 = 7;
        u3 = u1 + u2; if (u3 != 107) $display("FAIL: unsigned add");
        u3 = u1 * u2; if (u3 != 700) $display("FAIL: unsigned mul");
        u3 = u1 / u2; if (u3 != 14) $display("FAIL: unsigned div");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
