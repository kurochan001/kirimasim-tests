/*
:name: test_vpi_systf_in_fork
:description: A user-defined system task can be called from the branches of fork-join, fork-join_any and fork-join_none, once for each execution of the branch (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9.1 9.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_in_fork.c
:expected_stdout: @test_vpi_systf_in_fork.expected
*/
// IEEE 1800-2023 §36.4: a user-defined system task is called like a built-in
// system task from any procedural code, which includes the statements of the
// branches of a fork (9.3.2). The delays of the branches fix when each call
// runs: join waits for both branches, join_any goes on when the first has
// finished while the second still calls $vt_note at 7, and join_none lets the
// initial procedure go on while its branch calls $vt_note at 5. §36.9.1:
// the application registers $vt_note and $vt_report from
// vlog_startup_routines.

`timescale 1ns/1ns

module test_vpi_systf_in_fork;
  initial begin
    fork
      #2 $vt_note(2);
      #1 $vt_note(1);
    join

    fork
      #1 $vt_note(11);
      #4 $vt_note(14);
    join_any

    fork
      #2 $vt_note(22);
    join_none

    #10 $vt_report;
    $finish;
  end
endmodule
