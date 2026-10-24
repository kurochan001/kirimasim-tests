/*
:name: test_trireg_capacitive_network_sharing
:description: Connecting triregs in the capacitive state through a tranif1 lets the larger charge set the smaller trireg's value and strength, makes equal-size triregs with different values x, and a disconnected smaller trireg keeps the shared value at its own charge strength (IEEE 1800-2023 Section 6.6.4.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.4.1 6.3.2.1 6.6.4 28.13 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_capacitive_network_sharing.expected
*/
// IEEE 1800-2023 §6.6.4.1: triregs connected to each other form a capacitive
// network, and while they are in the capacitive state (6.6.4) values and
// charge strengths propagate between them: the charge of a larger trireg sets
// the value of a smaller one and gives it its own larger strength, while two
// triregs of the same size that store different values both become x. The
// charge strength models the relative size of the capacitance (6.3.2.1):
// large is above medium, which is above small (28.11). When the connection
// opens, each trireg keeps its last value with its own charge strength.
// big (large) and little (small) are charged to 1 and 0, and m1 and m2 (both
// medium) to 0 and 1, by bufif1 gates that then turn off; tranif1 switches,
// which do not change the strength of what they pass (28.13), then connect
// big with little and m1 with m2, and open again. %v (21.2.1.4) shows each
// value with its strength.
// Oracle checks: neither Icarus Verilog 13.0 nor the 5.052 release supports
// trireg nets, so the expected output follows the cited clauses alone.

module test_trireg_capacitive_network_sharing;
  logic d_big = 1'b1, d_little = 1'b0, d_m1 = 1'b0, d_m2 = 1'b1;
  logic en = 1'b1, link = 1'b0;
  trireg (large) big;
  trireg (small) little;
  trireg (medium) m1, m2;

  bufif1 g_big(big, d_big, en);
  bufif1 g_little(little, d_little, en);
  bufif1 g_m1(m1, d_m1, en);
  bufif1 g_m2(m2, d_m2, en);
  tranif1 s_size(big, little, link);
  tranif1 s_same(m1, m2, link);

  task automatic show(string what);
    $display("%s: big=%v little=%v m1=%v m2=%v", what, big, little, m1, m2);
  endtask

  initial begin
    #1 show("driven, apart");
    en = 1'b0;
    #1 show("stored, apart");
    link = 1'b1;
    #1 show("connected");
    link = 1'b0;
    #1 show("apart again");
  end
endmodule
