/*
:name: test_vpi_register_systf_methods
:description: System tasks and functions registered from separate s_vpi_systf_data structures and from a static array ended by a zero entry each keep their own user data and compiletf routine, and two functions sharing one calltf routine tell their registrations apart by the user data (IEEE 1800-2023 Section 38.37.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37.3 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_register_systf_methods.c
:expected_stdout: @test_vpi_register_systf_methods.expected
*/
// IEEE 1800-2023 §38.37.3: several system tasks and functions can be
// registered with one s_vpi_systf_data structure each and one
// vpi_register_systf call per structure, or from a static array of such
// structures whose last entry is 0, in a loop that stops at that entry.
// §38.37.1: the user_data of a registration is the argument of its compiletf
// and calltf routines, and compiletf runs for each call in the source before
// the simulation. One startup routine uses separate structures, the other an
// array whose entries have user data and, for the task, a compiletf routine.
// $vt_separate_func and $vt_listed_func share one calltf routine, which adds
// the number its user data points to: 100 and 200.

module test_vpi_register_systf_methods;
  int r;

  initial begin
    $vt_separate_task;
    r = $vt_separate_func(4);
    $display("$vt_separate_func(4)=%0d", r);
    $vt_listed_task;
    $vt_listed_task;
    r = $vt_listed_func(5);
    $display("$vt_listed_func(5)=%0d", r);
  end
endmodule
