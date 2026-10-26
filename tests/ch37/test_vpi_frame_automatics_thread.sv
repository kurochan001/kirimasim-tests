/*
:name: test_vpi_frame_automatics_thread
:description: The active frame gives its automatic variable, event and event array, each leading back to the frame; the frame origin is the task call that activated it, and the thread of the frame is active with the running system task call as its origin (IEEE 1800-2023 Sections 37.43 and 37.44)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 37.44 38.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_frame_automatics_thread.c
:expected_stdout: @test_vpi_frame_automatics_thread.expected
*/
// IEEE 1800-2023 §37.43: a frame represents a dynamically activated procedural
// scope with its locally declared automatic variables, events and event
// arrays (detail 1), which are iterated with vpiAutomatics; each of them has
// the untagged frame relation back to the frame (37.43 diagram). The
// vpiOrigin of a frame is the point in the elaboration hierarchy from which
// the frame was activated (detail 6), here the task call that the parent
// frame is executing (detail 5). §37.44: vpi_handle(vpiFrame, NULL) is the
// active frame of the current thread, and its vpiThread is that thread, whose
// vpiActive is TRUE (37.44 diagram); the thread's vpiOrigin is the statement
// it is executing (37.44 diagram), here the call of $vt_frame, which is also
// vpi_handle(vpiSysTfCall, NULL) (37.42 detail 3). The automaics are sorted
// by name.

`timescale 1ns/1ns

module test_vpi_frame_automatics_thread;
  task automatic worker;
    int count;
    event done;
    event flags [0:1];
    count = 8;
    $vt_frame;
  endtask

  initial begin
    worker;
  end
endmodule
