/*
:name: test_package_and_hierarchy_scope
:description: Package import, hierarchical reference and a block variable that hides a module variable (IEEE 1800-2023 Sections 26.3, 23.6 and 23.9)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 23.6 23.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_and_hierarchy_scope.expected
*/
`timescale 1ns/1ps

package pkg_scope;
    int pkg_var = 100;
    function int get_val();
        return pkg_var;
    endfunction
endpackage

module sub_mod;
    int local_var = 50;
endmodule

module test_package_and_hierarchy_scope;
    import pkg_scope::*;

    int mod_var = 25;
    sub_mod sm();

    initial begin
        // Package scope access
        if (pkg_var != 100) $display("FAIL: pkg_var");
        if (get_val() != 100) $display("FAIL: get_val");

        // Module scope
        if (mod_var != 25) $display("FAIL: mod_var");

        // Hierarchical access
        if (sm.local_var != 50) $display("FAIL: sm.local_var");

        // Scope resolution
        begin
            static int mod_var = 10; // Shadow
            if (mod_var != 10) $display("FAIL: shadow");
        end

        if (mod_var != 25) $display("FAIL: unshadow");

        $display("TEST PASSED");
        $finish;
    end
endmodule
