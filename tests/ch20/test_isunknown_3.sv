/*
:name: test_isunknown_3
:description: $isunknown of known, all-x and partly x values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_isunknown_3.expected
*/
// $isunknown of known, all-x and partly x values
`timescale 1ns/1ps
module test_isunknown;
    logic [7:0] val;
    logic r;
    
    initial begin
        val = 8'hAB;
        r = $isunknown(val);
        if (r) $display("FAIL: not unknown");
        
        val = 8'bxxxx_xxxx;
        r = $isunknown(val);
        if (!r) $display("FAIL: should be unknown");
        
        val = 8'b1010_x010;
        r = $isunknown(val);
        if (!r) $display("FAIL: partial unknown");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
