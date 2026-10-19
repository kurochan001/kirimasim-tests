/*
:name: test_sequence_goto_nonconsecutive
:description: Goto repetition b[->2] ends at the second b and needs c right after it, while nonconsecutive repetition b[=2] lets c come later as long as no third b comes first (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_goto_nonconsecutive.expected
*/
// IEEE 1800-2023 §16.9.2: in s ##1 b[->2] ##1 c the goto repetition matches
// at the second tick where b is true, so c has to be true on the tick right
// after it. In s ##1 b[=2] ##1 c the nonconsecutive repetition can also end
// on later ticks where b is false, so c may come later, but no third b may
// come in between. Each cover property counts its matches in its pass
// statement (16.14.3). Each phase starts with s and ends with c on its fifth
// tick: in the first, b is true on ticks 2 and 4, so both match; in the
// second, on ticks 2 and 3, so only the nonconsecutive form matches; in the
// third, on ticks 2, 3 and 4, so neither does.

`timescale 1ns/1ns

module test_sequence_goto_nonconsecutive;
  logic clk = 0, s = 0, b = 0, c = 0;
  int n_goto = 0, n_nonconsecutive = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_goto: cover property (@(posedge clk) s ##1 b[->2] ##1 c) n_goto++;
  c_nonconsecutive: cover property (@(posedge clk) s ##1 b[=2] ##1 c) n_nonconsecutive++;

  // Drives one tick: values are set between ticks.
  task automatic tick(logic vs, logic vb, logic vc);
    s = vs; b = vb; c = vc;
    #10;
  endtask

  task automatic report(string phase);
    #1 $display("%s: goto %0d, nonconsecutive %0d", phase, n_goto, n_nonconsecutive);
    #9;
  endtask

  initial begin
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 0, 0); tick(0, 1, 0); tick(0, 0, 1);
    tick(0, 0, 0); report("b on ticks 2 and 4");
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 1, 0); tick(0, 0, 0); tick(0, 0, 1);
    tick(0, 0, 0); report("b on ticks 2 and 3");
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 1, 0); tick(0, 1, 0); tick(0, 0, 1);
    tick(0, 0, 0); report("b on ticks 2, 3 and 4");
    $finish;
  end
endmodule
