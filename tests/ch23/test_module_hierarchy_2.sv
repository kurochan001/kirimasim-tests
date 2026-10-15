/*
:name: test_module_hierarchy_2
:description: Hierarchical names into nested instances, including a function call
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_hierarchy_2.expected
*/
`timescale 1ns/1ps

module leaf_mod;
    int leaf_val = 100;
    function int get_val();
        return leaf_val;
    endfunction
endmodule

module mid_mod;
    leaf_mod lm();
    int mid_val = 50;
endmodule

module top_mod;
    mid_mod mm();
    int top_val = 25;
endmodule

module test_module_hierarchy;
    top_mod tm();

    initial begin
        // Test hierarchical access
        if (tm.top_val != 25)
            $display("FAIL: top_val");

        if (tm.mm.mid_val != 50)
            $display("FAIL: mid_val");

        if (tm.mm.lm.leaf_val != 100)
            $display("FAIL: leaf_val");

        // Modify through hierarchy
        tm.mm.lm.leaf_val = 200;
        if (tm.mm.lm.get_val() != 200)
            $display("FAIL: modified leaf_val");

        // Display hierarchy path
        $display("Hierarchy test completed");

        $display("TEST PASSED");
        $finish;
    end
endmodule
