/*
:name: test_vpi_named_event_waiters_lifetime
:description: vpiWaitingProcesses of a named event gives the threads of every static and dynamic process waiting on it; named events and named event arrays of a class are reached from the class definition and lead back to it, and give vpiAutomatic and vpiAllocScheme according to whether they are static class properties (IEEE 1800-2023 Sections 37.27 and 37.31)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.27 37.31 37.3.7 37.33 37.44 9.7 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_named_event_waiters_lifetime.c
:expected_stdout: @test_vpi_named_event_waiters_lifetime.expected
*/
// IEEE 1800-2023 §37.27 detail 1: vpiWaitingProcesses gives all the processes
// waiting on a named event, static or dynamic, as their threads (37.44). At 1
// three processes wait on ev: an initial procedure and an always procedure
// (static), and a branch of fork...join_none (a dynamic process, 9.7) whose
// parent process waits on ev2. The two static threads have no parent thread;
// vpiParent of the dynamic one is the thread waiting on ev2. vpi_put_value
// triggers ev (38.34): all three resume, and at 2 only the always procedure,
// which waits again, is a waiting process of ev.
// §37.31: a class defn iterates its named events and named event arrays, both
// static and non-static (detail 1), and each leads back to it with
// vpiClassDefn. §37.27 detail 4 and §37.3.7: vpiAutomatic is FALSE for a
// static object and TRUE for a non-static one; ev and the static class
// properties sce and scea are static, ce and cea are not. vpiAllocScheme of
// those obtained from the class object of obj (37.33 detail 6) is
// vpiDynamicScheme for ce and cea, which are part of the object, and
// vpiOtherScheme for the static ones and for ev. Lists are sorted by name.

`timescale 1ns/1ns

module test_vpi_named_event_waiters_lifetime;
  class evc;
    event ce;
    static event sce;
    event cea [0:1];
    static event scea [0:2];
  endclass

  event ev, ev2;
  evc obj;
  int r_initial = 0, r_always = 0, r_fork = 0;

  initial @(ev) r_initial = 1;

  always @(ev) r_always++;

  initial begin
    fork
      @(ev) r_fork = 1;
    join_none
    @(ev2);
  end

  initial begin
    obj = new;
    #1 $vt_waiters;
    #1 $display("resumed: initial %0d, always %0d, fork branch %0d", r_initial, r_always, r_fork);
    $vt_after;
  end
endmodule
