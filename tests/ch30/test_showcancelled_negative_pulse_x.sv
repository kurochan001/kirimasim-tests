/*
:name: test_showcancelled_negative_pulse_x
:description: A negative pulse on a path output declared showcancelled shows x from the earlier to the later of its two scheduled edges with on-event, and from the moment it is detected with on-detect, while without showcancelled or with noshowcancelled the output does not change (IEEE 1800-2023 Section 30.7.4.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7.4.2 30.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_showcancelled_negative_pulse_x.expected
*/
// IEEE 1800-2023 §30.7.4.2: with unequal rise and fall delays, the trailing
// edge of a narrow pulse can be scheduled before its leading edge, a pulse of
// negative width. Normally the leading edge is cancelled and, as the output
// starts and ends at the same value, it does not change. An output named in
// a showcancelled declaration shows such a pulse as x instead: with the
// on-event style the x lasts from the earlier to the later of the two
// scheduled edges, and with the on-detect style (§30.7.4.1) it starts when
// the negative pulse is detected, as Figure 30-7 shows for a buffer;
// noshowcancelled keeps the normal behavior.
//
// Every cell is a buffer with the rise delay 3 and the fall delay 7. The
// input a is 1 and falls at 10, which schedules a fall of y at 17, and rises
// at 12, which schedules a rise at 15, before the fall: the negative pulse is
// detected at 12. y_plain (no declaration) and y_no (noshowcancelled) stay 1.
// y_event (showcancelled) is x from 15 to 17, and y_detect (showcancelled and
// pulsestyle_ondetect) is x from 12 to 17; both are 1 again at 17. The
// changes of each output from time 10 on are printed at the end.
//
// Icarus Verilog 13.0 ignores showcancelled and the pulse style declarations
// and leaves all four outputs at 1.

`timescale 1ns/1ns

module scx_plain_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = (3, 7);
  endspecify
endmodule

module scx_no_cell (input a, output y);
  buf (y, a);
  specify
    noshowcancelled y;
    (a => y) = (3, 7);
  endspecify
endmodule

module scx_event_cell (input a, output y);
  buf (y, a);
  specify
    showcancelled y;
    (a => y) = (3, 7);
  endspecify
endmodule

module scx_detect_cell (input a, output y);
  buf (y, a);
  specify
    showcancelled y;
    pulsestyle_ondetect y;
    (a => y) = (3, 7);
  endspecify
endmodule

module test_showcancelled_negative_pulse_x;
  reg a = 1;
  wire y_plain, y_no, y_event, y_detect;
  string lp = "", ln = "", le = "", ld = "";

  scx_plain_cell up (a, y_plain);
  scx_no_cell un (a, y_no);
  scx_event_cell ue (a, y_event);
  scx_detect_cell ud (a, y_detect);

  always @(y_plain) if ($time >= 10) lp = {lp, $sformatf(" %0d:%b", $time, y_plain)};
  always @(y_no) if ($time >= 10) ln = {ln, $sformatf(" %0d:%b", $time, y_no)};
  always @(y_event) if ($time >= 10) le = {le, $sformatf(" %0d:%b", $time, y_event)};
  always @(y_detect) if ($time >= 10) ld = {ld, $sformatf(" %0d:%b", $time, y_detect)};

  initial begin
    #10 a = 0;     // fall of y scheduled at 17
    #2 a = 1;      // 12: rise of y scheduled at 15, before the fall
    #18 $display("plain:%s end %b", lp, y_plain);
    $display("noshowcancelled:%s end %b", ln, y_no);
    $display("showcancelled on-event:%s end %b", le, y_event);
    $display("showcancelled on-detect:%s end %b", ld, y_detect);
  end
endmodule
