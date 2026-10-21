/*
:name: test_vpi_iterators_time_queue_events
:description: after the events of a time step that come before read-only synchronization, the time queue holds only later times; iterators of the time queue, of callbacks and of arguments give their type and reference handle; vpi_put_value with vpiReturnEvent returns a scheduled event that can be cancelled; the active time format is one tf call; an alias of five nets is four alias statements of the instance with the last net as right-hand side; such objects are not protected (IEEE 1800-2023 Sections 37.84, 37.81, 37.82, 37.76, 37.3.6 and 37.2.1)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.84 37.81 37.82 37.76 37.3.6 37.2.1 37.80 38.34 38.23 20.4.3 K
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_iterators_time_queue_events.c
:expected_stdout: @test_vpi_iterators_time_queue_events.expected
*/
// IEEE 1800-2023 §37.81: the time queue objects come in increasing order of
// time (detail 1), and the current time is part of the iteration only if
// events before read-only synchronization remain (detail 3). From a
// cbReadOnlySynch callback of time 5, after the update of y <= 1, none remain,
// so the objects are those of 20 (x = 1) and 25, where the calling process
// resumes. §37.84, with the comment of vpiIteratorType in vpi_user.h (Annex
// K): the iterator of vpi_iterate(vpiTimeQueue, NULL) is of time queue
// objects and its vpiUse is NULL (detail 2); the iterator of the callbacks on
// x (§37.80) is of callbacks and its vpiUse is x (detail 1), and that of the
// arguments of a call has the call. §37.2.1 g, §38.34: vpi_put_value with
// vpiReturnEvent and a delay returns a handle of type vpiSchedEvent, still
// scheduled (vpiScheduled, Annex K) until vpiCancelEvent removes it from the
// event queue; without the flag it returns NULL. So target gets 4 at 28 and
// never 9. §37.82: vpiActiveTimeFormat gives a tf call, the same object for
// two queries; the $timeformat called has no arguments (§20.4.3), so its
// argument iteration is NULL (§38.23). §37.76: an alias of five nets is four
// alias statements, each with the last net, ws, as its right-hand side, and
// they lead to the module instance with vpiInstance. §37.3.6: none of these
// objects is protected.

`timescale 1ns/1ns

module test_vpi_iterators_time_queue_events;
  wire wp, wq, wr, ws, wt;
  alias wr = wq = wt = wp = ws;
  logic x = 0, y = 0;
  int target = 0;

  initial #20 x = 1;

  initial begin
    #5;
    y <= 1;
    $vt_queue;
    #20;
    $timeformat;
    $vt_objects(target);
    #15 $display("target at 40: %0d", target);
  end
endmodule
