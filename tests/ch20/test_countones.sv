/*
:name: test_countones
:description: $countones on 8-bit values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countones.expected
*/
// $countones on 8-bit values
`timescale 1ns/1ps
module test_countones;
    logic [7:0] val;
    int count;
    
    initial begin
        val = 8'b10101010;
        count = $countones(val);
        if (count != 4) $display("FAIL: countones 0xAA");
        
        val = 8'b11111111;
        count = $countones(val);
        if (count != 8) $display("FAIL: countones 0xFF");
        
        val = 8'b00000000;
        count = $countones(val);
        if (count != 0) $display("FAIL: countones 0x00");
        
        val = 8'b10000001;
        count = $countones(val);
        if (count != 2) $display("FAIL: countones 0x81");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
