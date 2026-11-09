/*
:name: test_pli_callback_immediate_and_one_shot
:description: A value change callback runs immediately at each change of its object, between the statements of the process that writes it, while a time callback registered once runs once, as an event at its own control point (IEEE 1800-2023 Section 4.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.10 38.36.1 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_callback_immediate_and_one_shot.c
:expected_stdout: @test_pli_callback_immediate_and_one_shot.expected
*/
// IEEE 1800-2023 §4.10: a PLI callback is either executed immediately when a
// given activity occurs, or registered explicitly as a one-shot evaluation
// event. §38.36.1: a cbValueChange callback is called for each value change
// of its object. §38.36.2 and Table 4-1: a cbAfterDelay callback runs after
// its delay, in the Pre-Active region, before the events of that time step.
// $vt_register, called at 0, registers a cbValueChange callback on v, with
// the value asked for as an integer, and a cbAfterDelay callback with a delay
// of 10.
// At 10 the cbAfterDelay callback runs first and sees v=0. The design then
// writes v twice in one process without any timing control in between; each
// write is a change, and its callback runs at once, so its line comes before
// the design's next $display. At 20 v changes again, which calls the value
// change callback again, but the cbAfterDelay callback, being one-shot, does
// not run at 20 or 30.
// The release 5.052 of Verilator does not support user-defined system tasks.

`timescale 1ns/1ns

module test_pli_callback_immediate_and_one_shot;
  int v = 0;

  initial begin
    $vt_register;
    #10;
    $display("design at 10: before the writes");
    v = 1;
    $display("design at 10: after v = 1");
    v = 2;
    $display("design at 10: after v = 2");
    #10 v = 3;
    #10 $display("design at 30: v=%0d", v);
  end
endmodule
