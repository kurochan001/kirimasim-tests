/*
:name: test_function_return_type_event
:description: a function returns an event; a variable assigned the result refers to the same synchronization object, so waiting on it wakes when the original event is triggered (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_return_type_event.expected
*/
// IEEE 1800-2023 13.4 (Syntax 13-2): the return type of a function may be
// event. 6.17: an event variable is a handle to a synchronization object;
// an event assigned another event refers to the same object and compares
// equal to it.
//
// f_ev returns ev. got = f_ev() makes got equal to ev and not to other, and
// $typename of the call gives the keyword event. A forked process waits on
// got; ev is triggered at time 2 and the process wakes at time 2. If f_ev
// returned a copy with its own object, or another type, got == ev would be
// 0 and the waiting process would not wake (woke stays -1).
//
// Icarus Verilog 13.0 does not compile a function that returns an event,
// and release 5.054 of Verilator rejects the assignment from an event as
// unsupported.

`timescale 1ns/1ns

module test_function_return_type_event;
  event ev, other, got;
  int woke = -1;

  function event f_ev();
    return ev;
  endfunction

  initial begin
    got = f_ev();
    $display("same=%0d other=%0d type=%s", got == ev, got == other, $typename(f_ev()));
    fork
      begin
        @(got) woke = $time;
      end
    join_none
    #2 -> ev;
    #1 $display("woke=%0d", woke);
  end
endmodule
