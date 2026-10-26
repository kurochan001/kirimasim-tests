/*
:name: test_vpi_system_call_decompile
:description: A system function call and a system task call each give vpiDecompile as an equivalent call, their name and whether they are user-defined, for a built-in function, a built-in task and a user-defined task (IEEE 1800-2023 Section 37.42)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.42 37.59
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_system_call_decompile.c
:expected_stdout: @test_vpi_system_call_decompile.expected
*/
// IEEE 1800-2023 §37.42: a system function call and a system task call have
// the string property vpiDecompile (37.42 diagram, called "decompile"), which
// returns a functionally equivalent call whose arguments are decompiled by
// the expression rules (detail 9). The name property is the task or function
// name and vpiUserDefn is true for a user-defined system task or function
// (detail 5). White space between tokens of the returned call is not
// significant, so the application removes it before printing. The task calls
// is never called, so its statements exist only as VPI objects; its vpiStmt
// is an unnamed begin because it has more than one statement (37.12 detail 5).

`timescale 1ns/1ns

module test_vpi_system_call_decompile;
  task calls;
    int x;
    x = $clog2(16);
    $display("hi");
    $vt_marked(3, x);
  endtask

  initial #1 $vt_calls;
endmodule
