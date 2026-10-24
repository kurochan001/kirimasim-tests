/*
:name: test_trireg_declared_charge_strength_kept
:description: A trireg net stores its charge at the strength of its declaration, medium by default or small or large when declared, whatever the strength of the driver that charged it (IEEE 1800-2023 Section 28.15)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.15
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_declared_charge_strength_kept.expected
*/
// IEEE 1800-2023 §28.15: a trireg declaration can specify one of two signal
// strength levels other than its default one; 28.15.2 gives them as small and
// large, with medium as the default, and a trireg whose drivers all turn off
// keeps its value at that charge strength. Each of the four nets is driven
// through a bufif1 of a different drive strength. While the enable is 1, %v
// shows the drive strength; after the enable goes to 0 at 10, it shows the
// declared charge strength, which does not depend on the driver. No net has a
// charge decay time, so the charge does not decay.
// Icarus Verilog 13.0 does not support trireg nets ("sorry"), and the 5.052
// release of Verilator does not model strengths.

`timescale 1ns/1ns

module test_trireg_declared_charge_strength_kept;
  logic en = 1'b1;
  trireg t_def;
  trireg (medium) t_med;
  trireg (small) t_sm;
  trireg (large) t_lg;
  bufif1 (supply0, supply1) b0 (t_def, 1'b1, en);
  bufif1 (weak0, weak1) b1 (t_med, 1'b0, en);
  bufif1 (supply0, supply1) b2 (t_sm, 1'b1, en);
  bufif1 (weak0, weak1) b3 (t_lg, 1'b0, en);
  initial begin
    #5 $display("driven: %v %v %v %v", t_def, t_med, t_sm, t_lg);
    #5 en = 1'b0;
    #5 $display("stored: %v %v %v %v", t_def, t_med, t_sm, t_lg);
  end
endmodule
