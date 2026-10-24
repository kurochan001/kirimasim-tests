/*
:name: test_net_types_pull_and_supply_strength_levels
:description: tri0 and tri1 nets give their value at pull strength and supply0 and supply1 nets at supply strength, which %v shows when they are undriven and decides how a pull, weak or strong driver of the other value combines with them (IEEE 1800-2023 Section 28.15)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_types_pull_and_supply_strength_levels.expected
*/
// IEEE 1800-2023 §28.15: the tri0, tri1, supply0 and supply1 net types
// generate signals with specific strength levels: pull strength for tri0 and
// tri1 (28.15.1) and supply strength for supply0 and supply1 (28.15.3). The
// first line shows the four nets undriven. Each net of the second line has one
// driver of the other value: a pull driver on the tri0 net gives an equal
// strength of both values, PuX (28.12.1), a weak driver loses to the pull of
// the tri1 net, and neither a pull nor a strong driver changes a supply net.

`timescale 1ns/1ns

module test_net_types_pull_and_supply_strength_levels;
  tri0 t0_free, t0_drv;
  tri1 t1_free, t1_drv;
  supply0 s0_free, s0_drv;
  supply1 s1_free, s1_drv;
  assign (pull1, pull0) t0_drv = 1'b1;
  assign (weak1, weak0) t1_drv = 1'b0;
  assign (pull1, pull0) s0_drv = 1'b1;
  assign (strong1, strong0) s1_drv = 1'b0;
  initial begin
    #1 $display("free: %v %v %v %v", t0_free, t1_free, s0_free, s1_free);
    $display("driven: %v %v %v %v", t0_drv, t1_drv, s0_drv, s1_drv);
  end
endmodule
