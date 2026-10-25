/*
:name: test_property_binary_operator_forms
:description: not, or, and, implies, iff, until, s_until, until_with and s_until_with give the truth values their definitions require over a sequence of clock ticks, shown by per-phase failure counts (IEEE 1800-2023 Sections 16.12.3 to 16.12.8 and 16.12.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.3 16.12.4 16.12.5 16.12.8 16.12.12 16.12.7 16.14.1 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_binary_operator_forms.expected
*/
// IEEE 1800-2023 §16.12.3: not p is true when p is false. §16.12.4: p or q
// needs one of them true. §16.12.5: p and q needs both. §16.12.8: p implies q
// is false only when p is true and q false, and p iff q needs both false or
// both true. §16.12.12: a until b needs b at some tick with a at every earlier
// tick, s_until is the strong form whose b must occur, and the until_with
// forms also need a at the tick where b holds.
//
// Each assertion checks start |-> operator (§16.12.7), so an evaluation
// begins only at the first tick of a phase, and the fail actions count the
// failures (§16.14.1). Every phase lasts five ticks, and the printed counts
// are for that phase. In the first phase p and q are both 1 at the start
// tick; in the second p is 1 at the start and q at the next tick; in the
// third p is 1 only at the start and q never; in the fourth neither is 1 at
// the start and q comes at the next tick; in the fifth p is 1 at the start
// and at the next tick, where q also comes.

`timescale 1ns/1ns

module test_property_binary_operator_forms;
  logic clk = 0, start = 0, p = 0, q = 0;
  int f_not = 0, f_or = 0, f_and = 0, f_imp = 0, f_iff = 0;
  int f_unt = 0, f_sunt = 0, f_untw = 0, f_suntw = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_not: assert property (@(posedge clk) start |-> not p) else f_not++;
  a_or: assert property (@(posedge clk) start |-> (p or q)) else f_or++;
  a_and: assert property (@(posedge clk) start |-> (p and q)) else f_and++;
  a_imp: assert property (@(posedge clk) start |-> (p implies q)) else f_imp++;
  a_iff: assert property (@(posedge clk) start |-> (p iff q)) else f_iff++;
  a_unt: assert property (@(posedge clk) start |-> (p until q)) else f_unt++;
  a_sunt: assert property (@(posedge clk) start |-> (p s_until q)) else f_sunt++;
  a_untw: assert property (@(posedge clk) start |-> (p until_with q)) else f_untw++;
  a_suntw: assert property (@(posedge clk) start |-> (p s_until_with q)) else f_suntw++;

  // Runs one phase of five ticks with the p and q bits given from the start.
  task automatic phase(logic [4:0] ps, logic [4:0] qs);
    for (int i = 0; i < 5; i++) begin
      start = (i == 0);
      p = ps[4 - i];
      q = qs[4 - i];
      #10;
    end
    $display("p %b q %b: not %0d, or %0d, and %0d, implies %0d, iff %0d", ps, qs,
             f_not, f_or, f_and, f_imp, f_iff);
    $display("  until %0d, s_until %0d, until_with %0d, s_until_with %0d", f_unt,
             f_sunt, f_untw, f_suntw);
    f_not = 0;
    f_or = 0;
    f_and = 0;
    f_imp = 0;
    f_iff = 0;
    f_unt = 0;
    f_sunt = 0;
    f_untw = 0;
    f_suntw = 0;
  endtask

  initial begin
    phase(5'b10000, 5'b10000);
    phase(5'b10000, 5'b01000);
    phase(5'b10000, 5'b00000);
    phase(5'b00000, 5'b01000);
    phase(5'b11000, 5'b01000);
    $finish;
  end
endmodule
