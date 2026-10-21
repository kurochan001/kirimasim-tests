/*
:name: test_vpi_frames_threads_alloc
:description: while a called task runs, its caller's frame, in the same thread, is not the active frame; vpiAllocScheme and vpiHasActual tell an automatic variable of a frame, the same variable of the task declaration, a static variable and a class object property apart; cbCreateObj counts new objects and cbEndOfObject the end of a frame (IEEE 1800-2023 Sections 37.43, 37.44, 37.3.8, 37.61 and 37.3.7)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 37.44 37.3.8 37.61 37.3.7 37.33 37.12 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_frames_threads_alloc.c
:expected_stdout: @test_vpi_frames_threads_alloc.expected
*/
// IEEE 1800-2023 §37.43 detail 4: vpi_handle(vpiFrame, NULL) gives the active
// frame, and a thread has at most one active frame at a time. §37.44 detail 1:
// a thread activates a new frame for each task it enters, so the frames of
// inner and of its caller outer lead with vpiThread to the same thread, and
// the frame of outer is not active (vpiActive 0) while inner runs. §37.3.7:
// vpiAutomatic is 1 for the automatic variable loc and 0 for the module
// variable sv; vpiAllocScheme is vpiAutomaticScheme for loc, which belongs to
// the frame, vpiDynamicScheme for the property v of the object of c (part of
// a class object, §37.33), and vpiOtherScheme for sv. §37.61 detail 3:
// vpiHasActual is TRUE for loc obtained from the frame and for the static sv,
// and FALSE for loc obtained from the task declaration (vpiVariables of the
// task, §37.12). §37.3.8, §38.36.1: cbCreateObj, placed on the class typespec
// of c, comes after each of the two constructor calls, and cbEndOfObject on
// the frame of inner comes, as cbEndOfFrame would, when inner completes at 1.

`timescale 1ns/1ns

module test_vpi_frames_threads_alloc;
  class item;
    int v;
  endclass

  item c, d;
  int sv = 5;

  task automatic inner(input int n);
    int loc;
    loc = n * 3;
    $vt_check;
    #1;
  endtask

  task automatic outer(input int a);
    int t;
    t = a + 1;
    inner(t);
  endtask

  initial begin
    $vt_setup;
    c = new;
    d = new;
    c.v = 7;
    outer(1);
    #1 $vt_report;
  end
endmodule
