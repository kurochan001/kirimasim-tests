/*
:name: test_timing_controls_forms
:description: delay, event and level-sensitive wait controls defer a statement, with repeat, edge, named-event, or/comma and parenthesized forms, and each resumes at the time the clause fixes (IEEE 1800-2023 9.4, 9.4.2, 9.4.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4 9.4.2 9.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_controls_forms.expected
*/
// IEEE 1800-2023 §9.4: a procedural delay advances time by the value of its
// expression, an event control waits for a change or a named event, and a
// wait waits for a level. §9.4.2: an event expression may use edges, named
// events and the or and comma lists. §9.4.3: wait takes an expression and a
// statement. One observer waits for a posedge, a negedge, a named event,
// two posedges under repeat, a low level under wait, and a delay of an
// expression, then a delay whose value is in the variable d. Another observer
// waits with or and comma lists on a later signal. Each print is at a distinct
// time fixed by the stimulus at 2, 4, 5, 8, 9, 12, 15, 20 and 22 ns, so an
// event that fires at another time or a delay that does not advance by its
// expression prints a different line.

`timescale 1ns/1ps

module test_timing_controls_forms;
  logic sig = 0;
  logic s2 = 0;
  int d;
  event ev;
  event dummy;

  initial begin
    #2 sig = 1;
    #2 sig = 0;
    #1 -> ev;
    #1 sig = 1;
    #1 sig = 0;
    #1 sig = 1;
    #1 sig = 0;
    #11 s2 = 1;
    #2 s2 = 0;
    #2 s2 = 1;
    #6 $finish;
  end

  initial begin
    @(posedge sig) $display("pos %0d", $time);
    @(negedge sig) $display("neg %0d", $time);
    @ev $display("ev %0d", $time);
    repeat (2) @(posedge sig);
    $display("repeat %0d", $time);
    wait (sig == 1'b0) $display("wait %0d", $time);
    #(1 + 2) $display("delay %0d", $time);
    d = 3;
    #d $display("vardelay %0d", $time);
  end

  initial begin
    @(s2 or dummy) $display("or %0d", $time);
    @(s2, dummy) $display("comma %0d", $time);
  end
endmodule
