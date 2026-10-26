/*
:name: test_a6_5_event_trigger_forms
:description: A blocking event trigger fires the event now and a nonblocking one with a delay fires it that many time units later, so the process waiting for the event records the time 1, 5 and 11 (IEEE 1800-2023 Sections 15.5.2 and 15.5.3, A.6.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4 15.5.2 15.5.3 A.6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a6_5_event_trigger_forms.expected
*/
// IEEE 1800-2023 A.6.5: an event trigger is an arrow and a selected
// hierarchical event identifier, or a double arrow with an optional delay or
// event control before the identifier. §15.5.2: an arrow triggers the event in
// the current time step. §15.5.3: a double arrow with a delay triggers the
// event after that delay.
//
// The process waiting for ev records the time of each trigger. The nonblocking
// trigger at 0 with the delay 5 fires ev at 5, the blocking trigger at 1 fires
// it at 1, and the one at 11 fires it at 11, so the printed list is 1, 5 and
// 11. Icarus Verilog 13.0 stops with an error at the double arrow, and the
// 5.052 release of Verilator accepts it but does not fire the event, so the
// expected output follows the standard.

`timescale 1ns/1ns
module test_a6_5_event_trigger_forms;
  event ev;
  string trace = "";

  always @(ev) trace = {trace, $sformatf(" %0t", $time)};

  initial begin
    ->> #5 ev;
    #1 -> ev;
    #10 -> ev;
    #10 $display("triggered%s", trace);
  end
endmodule
