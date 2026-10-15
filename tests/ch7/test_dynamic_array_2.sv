/*
:name: test_dynamic_array_2
:description: Dynamic array new[], resize with copy, size() and delete()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_2.expected
*/
// Dynamic array new[], resize with copy, size() and delete()
`timescale 1ns/1ps
module test_dynamic_array;
    int dyn[];
    int size_val;
    
    initial begin
        dyn = new[10];
        size_val = dyn.size();
        if (size_val != 10) $display("FAIL: size");
        
        foreach (dyn[i]) dyn[i] = i;
        if (dyn[5] != 5) $display("FAIL: access");
        
        dyn = new[20](dyn);
        if (dyn.size() != 20) $display("FAIL: resize");
        if (dyn[5] != 5) $display("FAIL: preserved value");
        
        dyn.delete();
        if (dyn.size() != 0) $display("FAIL: delete");
        
        $display("TEST PASSED");
        $finish;
    end
endmodule
