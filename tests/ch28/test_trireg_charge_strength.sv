/*
:name: test_trireg_charge_strength
:description: A trireg net that a driver charged and then left holds its value with the charge strength of its declaration, medium when none is given (IEEE 1800-2023 Section 28.15.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.15.2 28.15.1 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_charge_strength.expected
*/
// IEEE 1800-2023 §28.15.2: a trireg net in the charge storage state, after a
// driver charged it and turned to high impedance, drives with the charge
// strength of its declaration, large, medium or small, and medium by default
// (28.15.1). Each net is driven by a bufif1 whose enable goes low at 10; %v
// (21.2.1.4) then shows the stored value with the capacitor strength.

`timescale 1ns/1ns

module test_trireg_charge_strength;
  logic en = 1;
  trireg t_def;
  trireg (small) t_small;
  trireg (large) t_large;

  bufif1 (t_def, 1'b1, en);
  bufif1 (t_small, 1'b0, en);
  bufif1 (t_large, 1'b1, en);

  initial begin
    #5 $display("driven: %v %v %v", t_def, t_small, t_large);
    #5 en = 0;
    #5 $display("stored: %v %v %v", t_def, t_small, t_large);
  end
endmodule
