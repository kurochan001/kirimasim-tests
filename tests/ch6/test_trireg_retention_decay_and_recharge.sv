/*
:name: test_trireg_retention_decay_and_recharge
:description: A trireg retains charge after disconnection decays to unknown and can be recharged (IEEE 1800-2023 Section 6.3.2.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.2.1 6.6.4.1 6.6.4.2 28.15.2 28.16.2.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_retention_decay_and_recharge.expected
*/
// IEEE 1800-2023 6.3.2.1 6.6.4.1 6.6.4.2 28.15.2 28.16.2.2: The third delay
// measures charge decay after turnoff, not a transition to high impedance.
// Stored values use the declared charge strength and a later driver restores a
// known strong value.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release is a two-state engine and is not used as the oracle here.

`timescale 1ns/1ns
module test_trireg_retention_decay_and_recharge;
  logic data = 0, enabled = 1;
  trireg (medium) #(1, 2, 5) node;
  trireg (large) unused;
  bufif1 gate(node, data, enabled);
  initial begin
    #3 $display("driven=%v unused=%v", node, unused);
    enabled = 0;
    #1 $display("retained=%v", node);
    #3 $display("before_decay=%v", node);
    #2 $display("decayed=%v", node);
    data = 1; enabled = 1;
    #2 $display("recharged=%v", node);
    enabled = 0;
    #1 $display("stored_one=%v", node);
    #5 $display("decayed_again=%v", node);
  end
endmodule
