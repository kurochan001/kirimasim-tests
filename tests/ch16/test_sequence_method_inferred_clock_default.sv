/*
:name: test_sequence_method_inferred_clock_default
:description: when a sequence with an event formal that defaults to $inferred_clock is given no clock and its triggered method is used, the clock is inferred as for a sampled value function: the clock of the assertion where the instance is, the leading clock of the assertion whose action block reads it, the clock inferred for the procedure that reads it, and the default clocking elsewhere (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_method_inferred_clock_default.expected
*/
// IEEE 1800-2023 §16.13.6: if a formal of a sequence defaults to
// $inferred_clock and the instance to which triggered is applied gives no
// actual for it, the clock bound to the formal is inferred with the rules of
// 16.9.3 for sampled value functions. Those rules take, in an assertion, the
// clock that flows to the place of the call; in the action block of an
// assertion, the leading clock of that assertion; in a procedure, the clock
// inferred for it (16.14.6), if any; and otherwise the default clocking
// (14.12). s_inf has the formal ck = $inferred_clock and is p ##1 q on
// @(ck); it is used four times without ck:
// - in the cover property on posedge clk_a, so it is clocked by clk_a;
// - in the pass action of the assertion on posedge clk_b, so by clk_b;
// - in the initial procedure of the program p_inf, whose only timing
//   control is the event control @(posedge clk_e) and which uses clk_e
//   nowhere else, so posedge clk_e is the clock inferred for it (16.14.6)
//   and s_inf is clocked by clk_e there;
// - in a wait statement of a module initial procedure that also has a
//   delay, so that no clock is inferred for it: by the default clocking on
//   posedge clk_d.
// The four clocks have period 10 and rise at 10 * k + 2, + 5, + 4 and + 8.
// x is 1 from 10 to 20 and from 40 to 50, y from 20 to 30 and from 50 to 60,
// so with each clock x ##1 y ends at its tick in 20..30 and in 50..60: at
// 22 and 52 on clk_a, 25 and 55 on clk_b, 24 and 54 on clk_e, 28 and 58 on
// clk_d. triggered is true only in the time step of an end point (16.13.6),
// so each use sees the end points of its own clock and none of the others,
// and each list shows which clock its instance has. The program procedure
// resumes after each rising edge of clk_e in the Reactive region (24.3.1),
// after the Observed region of that time step in which triggered is set, so
// it sees an end point at that edge.
// Icarus Verilog 13.0 does not support these assertions, and the 5.054
// release of the Verilator simulator does not implement $inferred_clock (nor
// triggered, an event actual of a sequence or a program declared in a
// module), so the expected output comes from the standard alone.

`timescale 1ns/1ns

module test_sequence_method_inferred_clock_default;
  logic clk_a = 0, clk_b = 0, clk_d = 0, clk_e = 0;
  logic x = 0, y = 0;
  string in_assertion = "", in_action = "", in_proc = "", in_wait = "";

  default clocking cb_d @(posedge clk_d); endclocking

  sequence s_inf(p, q, event ck = $inferred_clock);
    @(ck) p ##1 q;
  endsequence

  initial begin
    #2 forever begin clk_a = 1; #5 clk_a = 0; #5; end
  end
  initial begin
    #5 forever begin clk_b = 1; #5 clk_b = 0; #5; end
  end
  initial begin
    #4 forever begin clk_e = 1; #5 clk_e = 0; #5; end
  end
  initial begin
    #8 forever begin clk_d = 1; #5 clk_d = 0; #5; end
  end

  c_a: cover property (@(posedge clk_a) s_inf(x, y).triggered)
    in_assertion = {in_assertion, $sformatf(" %0t", $time)};

  a_b: assert property (@(posedge clk_b) 1)
    if (s_inf(x, y).triggered) in_action = {in_action, $sformatf(" %0t", $time)};

  program p_inf;
    initial forever begin
      @(posedge clk_e);
      if (s_inf(x, y).triggered) in_proc = {in_proc, $sformatf(" %0t", $time)};
    end
  endprogram

  initial forever begin
    wait (s_inf(x, y).triggered);
    in_wait = {in_wait, $sformatf(" %0t", $time)};
    #1;
  end

  initial begin
    #10 x = 1;
    #10 x = 0; y = 1;
    #10 y = 0;
    #10 x = 1;
    #10 x = 0; y = 1;
    #10 y = 0;
    #13;
    $display("in the cover on clk_a: [%s ]", in_assertion);
    $display("in the action block of the assertion on clk_b: [%s ]", in_action);
    $display("in a program initial procedure on posedge clk_e: [%s ]", in_proc);
    $display("in a wait, default clocking on clk_d: [%s ]", in_wait);
    $finish;
  end
endmodule
