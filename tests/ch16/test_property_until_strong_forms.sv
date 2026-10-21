/*
:name: test_property_until_strong_forms
:description: s_until and s_until_with hold when the second operand comes, needing the first before it or also at it; until with a sequence as second operand ends at the start tick of its match, and until with a property of two ticks as first operand needs it to hold from every tick before the second one (IEEE 1800-2023 Section 16.12.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.12 16.12.15 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_until_strong_forms.expected
*/
// IEEE 1800-2023 §16.12.12: p1 s_until p2 holds if p2 holds at some tick and p1
// at every tick from the start before it; p1 s_until_with p2 also needs p1 at
// that tick. Being strong, they need the tick of p2 to come (§16.12.15), which
// it does in every phase; in the last one b holds at the start tick. p1 and p2
// are properties evaluated from each tick: with p2 = b ##1 c, the tick where p2
// holds is a tick of b followed by c, and with p1 = ##1 d, p1 holds at a tick
// if d holds at the next one. The assertions start at a tick with start
// (§16.12.7); the fail actions count the failures of each phase (§16.14.1).
// Each line shows a, b, c and d at T to T+4. In the second phase b at T+2 is
// not followed by c and a is low there, so a until (b ##1 c) fails, and d is
// low at T+2, so (##1 d) until b fails.

`timescale 1ns/1ns

module test_property_until_strong_forms;
  logic clk = 0, start = 0, a = 0, b = 0, c = 0, d = 0;
  int f_su = 0, f_suw = 0, f_useq = 0, f_uprop = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_su: assert property (@(posedge clk) start |-> a s_until b) else f_su++;
  a_suw: assert property (@(posedge clk) start |-> a s_until_with b) else f_suw++;
  a_useq: assert property (@(posedge clk) start |-> a until (b ##1 c)) else f_useq++;
  a_uprop: assert property (@(posedge clk) start |-> (##1 d) until b) else f_uprop++;

  // Runs one phase of 5 ticks; start is high at the first.
  task automatic phase(logic [4:0] as, logic [4:0] bs, logic [4:0] cs, logic [4:0] ds);
    for (int i = 0; i < 5; i++) begin
      start = (i == 0);
      a = as[4 - i];
      b = bs[4 - i];
      c = cs[4 - i];
      d = ds[4 - i];
      #10;
    end
    $display("a %b, b %b, c %b, d %b: a_su %0d, a_suw %0d, a_useq %0d, a_uprop %0d",
             as, bs, cs, ds, f_su, f_suw, f_useq, f_uprop);
    f_su = 0;
    f_suw = 0;
    f_useq = 0;
    f_uprop = 0;
  endtask

  initial begin
    phase(5'b11000, 5'b00100, 5'b00010, 5'b01100);
    phase(5'b11000, 5'b00100, 5'b00000, 5'b01000);
    phase(5'b11100, 5'b00100, 5'b00010, 5'b01100);
    phase(5'b00000, 5'b10000, 5'b01000, 5'b00000);
    $finish;
  end
endmodule
