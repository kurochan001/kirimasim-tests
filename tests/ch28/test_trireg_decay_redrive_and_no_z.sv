/*
:name: test_trireg_decay_redrive_and_no_z
:description: a trireg net with three delays uses the first two as rise and fall delays and the third as its charge decay time, keeps its 1, 0 or x when its driver turns off instead of becoming z, ends a decay when the driver turns on again, and holds z only when forced (IEEE 1800-2023 Section 28.16.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16.2 28.16.2.1 6.6.4 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_decay_redrive_and_no_z.expected
*/
// IEEE 1800-2023 §28.16.2: of the three delays of a trireg net, the first two
// are the delays of a change to 1 and to 0 that a driver puts on the net,
// and the third is the charge decay time, not a delay of a change to z: when
// the drivers turn off, the net keeps its last driven 1, 0 or x (6.6.4), and
// z from a driver never reaches it; it holds z only as its initial value or
// when it is forced (10.6.2). §28.16.2.1: the decay starts when the drivers
// turn off and ends when the time has passed, where a 1 or 0 becomes x, or
// when a driver turns on again and drives 1, 0 or x into the net. The net t
// has #(2, 3, 20) and a bufif1 driver. The value is printed one time unit
// or more away from each change: the rise at 12 and the fall at 23; the
// driver turns off at 40, so t is x from 60; it drives 1 again from 70, off
// at 80, on at 90 and off at 95, so the decay that started at 80 ends at 90
// and the one from 95 ends at 115; the driver puts an x on t at 132 and
// turns off at 140, and t keeps the x; at 170 t is forced to z.
// Icarus Verilog 13.0 and Verilator 5.052 do not support trireg nets.

`timescale 1ns/1ns
module test_trireg_decay_redrive_and_no_z;
  logic d, en;
  trireg #(2, 3, 20) t;
  bufif1 b(t, d, en);

  task show;
    $display("t=%0d %b", $time, t);
  endtask

  initial begin
    d = 1'b0;
    en = 1'b1;
    #10 d = 1'b1;
    #1 show;   // 11
    #2 show;   // 13
    #7 d = 1'b0;
    #2 show;   // 22
    #2 show;   // 24
    #6 d = 1'b1;
    #10 en = 1'b0;
    #5 show;   // 45
    #14 show;  // 59
    #2 show;   // 61
    #9 en = 1'b1;
    #10 en = 1'b0;
    #10 en = 1'b1;
    #5 en = 1'b0;
    #6 show;   // 101
    #13 show;  // 114
    #2 show;   // 116
    #4 d = 1'b0; en = 1'b1;
    #10 d = 1'bx;
    #10 en = 1'b0;
    #5 show;   // 145
    #20 show;  // 165
    #5 force t = 1'bz;
    #1 show;   // 171
  end
endmodule
