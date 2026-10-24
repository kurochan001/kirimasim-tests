/*
:name: test_udp_level_sequential_next_state_by_current
:description: a level-sensitive sequential UDP with output reg chooses its next state from the input levels and its current state field, so the same inputs give different outputs for different current states (IEEE 1800-2023 Section 29.5)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.5 29.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_level_sequential_next_state_by_current.expected
*/
// IEEE 1800-2023 §29.5: a level-sensitive sequential UDP is written like a
// combinational one, but its output is declared reg and each row has a
// field for the current state between the inputs and the output, which is
// then the next state (29.3.4). In srt the input levels 1 0 set the output
// and 0 1 reset it; with 0 0 the rows give the current state back, and with
// 1 1 they give its inverse, so 1 1 gives 1 from state 0 and 0 from state
// 1. After the start with s 0 and r 1, which gives 0 whatever the order in
// which the two inputs take their first values, the inputs change one at a
// time, and after each change the output is printed.

primitive srt(q, s, r);
  output q;
  reg q;
  input s, r;
  table
  // s r : q : q+
     1 0 : ? : 1;
     0 1 : ? : 0;
     0 0 : 0 : 0;
     0 0 : 1 : 1;
     1 1 : 0 : 1;
     1 1 : 1 : 0;
  endtable
endprimitive

module test_udp_level_sequential_next_state_by_current;
  logic s, r;
  wire q;
  srt u(q, s, r);

  initial begin
    s = 1'b0;
    r = 1'b1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 s = 1'b1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 r = 1'b0;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 s = 1'b0;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 s = 1'b1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 r = 1'b1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 s = 1'b0;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    #1 r = 1'b0;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
  end
endmodule
