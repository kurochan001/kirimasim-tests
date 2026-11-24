/*
:name: test_udp_initial_states_drive_separately_delayed_fanout
:description: Sequential primitive initial states appear before the instance delays and propagate through independently delayed fanout
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.7 29.8 29.6 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_initial_states_drive_separately_delayed_fanout.expected
*/
`timescale 1ns/1ns
primitive udp_left_one(q, clock);
  output q;
  reg q;
  input clock;
  initial q = 1;
  table
       r : 0 : 1;
       r : 1 : 0;
       f : ? : -;
    (x0) : ? : -;
  endtable
endprimitive

primitive udp_right_zero(q, clock);
  output q;
  reg q;
  input clock;
  initial q = 0;
  table
       r : 0 : 1;
       r : 1 : 0;
       f : ? : -;
    (x0) : ? : -;
  endtable
endprimitive

module test_udp_initial_states_drive_separately_delayed_fanout;
  logic clock = 0;
  wire left, right, left_fanout, right_fanout;
  udp_left_one #(4, 7) seeded_one(left, clock);
  udp_right_zero #(3, 5) seeded_zero(right, clock);
  buf #(2, 3) delayed_left(left_fanout, left);
  not #(5, 1) delayed_right(right_fanout, right);

  task automatic sample;
    $display("t=%0d source=%b%b fanout=%b%b", $time, left, right, left_fanout, right_fanout);
  endtask

  initial begin
    #1 sample();
    #2 sample();
    #3 sample();
    clock = 1;
    #2 sample();
    #3 sample();
    #3 sample();
    #3 sample();
    $finish(0);
  end
endmodule
