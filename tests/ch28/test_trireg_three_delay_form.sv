/*
:name: test_trireg_three_delay_form
:description: In a trireg declaration with three delays the first two are the rise and fall delays for values that drivers put on the net and the third is the charge decay time, counted from when the drivers turn off (IEEE 1800-2023 Section 28.16.2.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16.2.2 28.16.2 28.16.2.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_three_delay_form.expected
*/
// IEEE 1800-2023 §28.16.2.2: a three-valued delay of a trireg net is
// (rise_delay, fall_delay, charge_decay_time), and the decay time has to
// follow a rise and a fall delay. §28.16.2: the first two apply when a driver
// sets the net to 1 or 0; the third replaces the delay to z, as a trireg net
// keeps its value when its drivers turn off. §28.16.2.1: the decay starts when
// the drivers turn off. t has #(2, 3, 15): d falls at 10, so t falls at 13;
// the driver turns off at 20, so t becomes x at 35. Values are printed one
// time unit before and after each change.

`timescale 1ns/1ns

module test_trireg_three_delay_form;
  logic d = 1, en = 1;
  trireg (small) #(2, 3, 15) t;

  bufif1 (t, d, en);

  initial begin
    #10 d = 0;
    #2 $display("t=%0t: %b", $time, t);
    #2 $display("t=%0t: %b", $time, t);
    #6 en = 0;
    #14 $display("t=%0t: %b", $time, t);
    #2 $display("t=%0t: %b", $time, t);
  end
endmodule
