/*
:name: test_min_typ_max_unordered_delay_values
:description: the rise, fall and turn-off delays of a gate and of a continuous assignment, and a procedural delay, can each be min:typ:max expressions in any numeric order, and the change comes after one of the three values (IEEE 1800-2023 Section 28.16.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16.1 10.3.3 9.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_min_typ_max_unordered_delay_values.expected
*/
// IEEE 1800-2023 §28.16.1: each of the rise, fall and turn-off delays of a
// gate or a continuous assignment (10.3.3) can be given as minimum, typical
// and maximum expressions separated by colons, with no required relation
// between the three values, and a procedural delay control can be written
// the same way (9.4.1). Which of the three a run uses is left to the tool,
// so the test checks only times outside all three: the values are at least
// 2 and at most 9, each list is in no order, and every change of the
// inputs is checked 1 and 10 time units later. The bufif1 and the
// continuous assignment drive z while c is 0, so that their turn-off delays
// are used too. The procedural delay is checked in the same way, and the
// time it took is printed as one of its three values.

`timescale 1ns/1ns
module test_min_typ_max_unordered_delay_values;
  logic d, c;
  wire o_g, o_a;
  bufif1 #(9:3:6, 8:4:6, 7:2:5) g(o_g, d, c);
  assign #(9:3:6, 8:4:6, 7:2:5) o_a = c ? d : 1'bz;

  logic flag;
  time t0;

  task automatic show(string what);
    #1 $display("%s +1: gate=%b assign=%b", what, o_g, o_a);
    #9 $display("%s +10: gate=%b assign=%b", what, o_g, o_a);
  endtask

  initial begin
    d = 1'b0;
    c = 1'b1;
    #20;
    d = 1'b1;
    show("rise");
    d = 1'b0;
    show("fall");
    c = 1'b0;
    show("turn-off");
    flag = 1'b0;
    t0 = $time;
    fork
      #(6:2:4) flag = 1'b1;
      begin
        #1 $display("procedural +1: flag=%b", flag);
        #9 $display("procedural +10: flag=%b", flag);
      end
    join
  end

  always @(posedge flag)
    $display("procedural delay is one of 2, 4, 6: %b",
             $time - t0 == 2 || $time - t0 == 4 || $time - t0 == 6);
endmodule
