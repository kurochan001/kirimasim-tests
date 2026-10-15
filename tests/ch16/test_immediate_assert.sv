/*
:name: test_immediate_assert
:description: Immediate assertions that pass
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assert.expected
*/
// Immediate assertions that pass
`timescale 1ns/1ps
module test_immediate_assert;
    int val;
    
    initial begin
        val = 10;
        
        assert (val == 10);
        assert (val > 0) else $display("Note: val not positive");
        
        val = 20;
        assert (val == 20);
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
