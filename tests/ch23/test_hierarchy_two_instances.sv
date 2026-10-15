/*
:name: test_hierarchy_two_instances
:description: Two instances of the same module reached by hierarchical names
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchy_two_instances.expected
*/
`timescale 1ns/1ps
module parent;
    child c1(), c2();
endmodule

module child;
    logic x;
    initial x = 1;
endmodule

module test_hierarchy_two_instances;
    parent p();
    
    initial begin
        #1;
        if (p.c1.x !== 1) $display("FAIL: c1.x");
        if (p.c2.x !== 1) $display("FAIL: c2.x");
        $display("TEST PASSED");
        $finish;
    end
endmodule
