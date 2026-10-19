/*
:name: test_pull_supply_net_strength
:description: tri0 and tri1 nets are pulled to 0 or 1 at pull strength, and supply0 and supply1 nets have supply strength that other drivers cannot override (IEEE 1800-2023 Section 28.15.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.15.1 28.15.3 28.12.1 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pull_supply_net_strength.expected
*/
// IEEE 1800-2023 §28.15.1: a tri0 net behaves as if a pulldown were connected
// to it, and a tri1 net as if a pullup were: with no stronger driver it is 0 or
// 1 at pull strength. A z driver does not change that, a weak driver loses to
// it and a strong driver wins (28.12.1). §28.15.3: supply0 and supply1 nets
// have supply strength, so a strong driver cannot change them, and a supply
// driver of the other value makes them X. %v shows strength and value
// (21.2.1.4).

module test_pull_supply_net_strength;
  tri0 t0;
  tri1 t1;
  tri0 t0w; assign (weak0, weak1) t0w = 1'b1;
  tri1 t1s; assign t1s = 1'b0;
  tri0 t0z; assign t0z = 1'bz;
  supply1 vdd; assign vdd = 1'b0;
  supply0 gnd; assign (supply0, supply1) gnd = 1'b1;

  initial begin
    #1;
    $display("t0=%v t1=%v", t0, t1);
    $display("t0w=%v t1s=%v t0z=%v", t0w, t1s, t0z);
    $display("vdd=%v gnd=%v", vdd, gnd);
  end
endmodule
