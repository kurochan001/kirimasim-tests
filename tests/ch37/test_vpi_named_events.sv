/*
:name: test_vpi_named_events
:description: a module gives its named events and named event arrays; an element of an event array, reached by index, is an array member with its index and the array as parent; vpiWaitingProcesses gives the processes waiting on an event, and vpi_put_value triggers it (IEEE 1800-2023 Section 37.27)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.27 38.34 38.19 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_named_events.c
:expected_stdout: @test_vpi_named_events.expected
*/
// IEEE 1800-2023 §37.27: vpi_iterate(vpiNamedEvent, module) gives the named
// events of the module and vpi_iterate(vpiNamedEventArray, module) its arrays
// of named events; vpi_handle_by_index (§38.19) on an array gives an element,
// whose vpiArrayMember is true, whose vpiParent is the array and whose
// vpiIndex iteration gives its index (detail 2); vpiArrayMember of a plain
// event is false. vpiWaitingProcesses gives the threads waiting on the event
// (detail 1). §38.34: vpi_put_value on a named event triggers it, with no
// value needed, so the waiting processes resume (§15.5.1). At 1, two
// processes wait on go; $vt_events counts them and triggers go; at 2 the
// test prints how many resumed and $vt_waiting counts the waiters again.

module test_vpi_named_events;
  event go, done;
  event lane [0:2];
  int resumed = 0;

  initial begin
    @(go) resumed++;
  end

  initial begin
    @(go) resumed++;
  end

  initial begin
    #1 $vt_events;
    #1 $display("resumed: %0d", resumed);
    $vt_waiting;
  end
endmodule
