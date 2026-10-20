/*
:name: test_trireg_charge_decay
:description: A trireg net with a charge decay time keeps its value for that long after its driver turns off, then becomes x, and a driver turning on again ends the decay (IEEE 1800-2023 Section 28.16.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16.2 28.16.2.1 6.6.4.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_charge_decay.expected
*/
// IEEE 1800-2023 §28.16.2: the third delay of a trireg net is its charge decay
// time. When the drivers turn off, the net keeps its value, and after the
// decay time it becomes x (28.16.2.1); a driver that turns on before then
// ends the decay. The decay time here is 20: off at 10, still 1 at 25, x at
// 35; on again at 40 and off at 45, so still 0 at 60 and x at 70.

`timescale 1ns/1ns

module test_trireg_charge_decay;
  logic d, en;
  trireg #(0, 0, 20) t;

  bufif1 b(t, d, en);

  initial begin
    d = 1; en = 1;
    #10 en = 0;
    #15 $display("t=%0d %b", $time, t);
    #10 $display("t=%0d %b", $time, t);
    #5 d = 0; en = 1;
    #5 en = 0;
    #15 $display("t=%0d %b", $time, t);
    #10 $display("t=%0d %b", $time, t);
  end
endmodule
