/*
:name: test_vpi_frames_and_threads
:description: vpi_handle(vpiFrame, NULL) gives the active frame of the calling task with its automatic variables, its parent frame, origin, statement and thread, and end-of-frame and end-of-thread callbacks report when they end (IEEE 1800-2023 Section 37.43)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 37.44 37.3.8 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_frames_and_threads.c
:expected_stdout: @test_vpi_frames_and_threads.expected
*/
// IEEE 1800-2023 §37.43: vpi_handle(vpiFrame, NULL) returns the active frame of
// the current thread; vpiAutomatics gives its automatic variables, vpiStmt its
// active statement (here the call of $vt_frame), vpiOrigin the call that
// activated it, vpiParent the frame of the caller, whose vpiStmt is the
// statement that activated the child frame, and vpiThread its thread (37.44),
// here the branch of the fork. §37.3.8, §38.36.1: callbacks follow transient
// objects; cbEndOfFrame comes when the frame of inner ends, at 1, and
// cbEndOfThread when the branch of the fork ends. Of the automatic variables,
// the test prints those declared in the bodies of the tasks.

`timescale 1ns/1ns

module test_vpi_frames_and_threads;
  task automatic inner(input int v);
    int doubled;
    doubled = 2 * v;
    $vt_frame;
    #1;
  endtask

  task automatic outer(input int a);
    int next;
    next = a + 1;
    inner(next);
  endtask

  initial begin
    fork
      outer(4);
    join
    #1 $vt_report;
  end
endmodule
