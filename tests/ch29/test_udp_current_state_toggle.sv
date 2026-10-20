/*
:name: test_udp_current_state_toggle
:description: A sequential UDP selects its next state by its current state, so a toggle flip-flop alternates on each rising clock, and a level-sensitive reset entry applies whatever the clock does (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.10 29.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_current_state_toggle.expected
*/
// IEEE 1800-2023 §29.6, §29.3.4: an entry of a sequential UDP lists the
// inputs, the current state and the next state, so r 0 : 0 : 1 and r 0 : 1 : 0
// make the output toggle at each rising clock. The output starts at x; while
// rst is 1 the level-sensitive entry gives 0, also for the rising clock at 15
// (29.10), and the falling rst keeps the state. Then each rising clock toggles
// the output, and falling clocks keep it.

primitive udp_tff (q, clk, rst);
  output q;
  reg q;
  input clk, rst;
  table
  // clk rst  : q : q+
     ?    1   : ? : 0;
     ?   (10) : ? : -;
     r    0   : 0 : 1;
     r    0   : 1 : 0;
     n    0   : ? : -;
  endtable
endprimitive

module test_udp_current_state_toggle;
  reg clk, rst;
  wire q;

  udp_tff u (q, clk, rst);

  initial begin
    clk = 0;
    #5 $display("t=%0d: q=%b", $time, q);
    rst = 1;
    #5 $display("t=%0d: q=%b", $time, q);
    #5 clk = 1;
    #1 $display("t=%0d: q=%b", $time, q);
    #4 clk = 0;
    #5 rst = 0;
    #1 $display("t=%0d: q=%b", $time, q);
    repeat (3) begin
      #4 clk = 1;
      #1 $display("t=%0d: q=%b", $time, q);
      #4 clk = 0;
      #1 $display("t=%0d: q=%b", $time, q);
    end
  end
endmodule
