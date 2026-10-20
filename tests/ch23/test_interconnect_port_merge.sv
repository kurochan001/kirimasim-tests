/*
:name: test_interconnect_port_merge
:description: An interconnect net takes on the net type of the ports it connects, here merging a wire and a wor driver into a wor (IEEE 1800-2023 Section 23.3.3.7.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7.1 23.3.3.7 6.6.8 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_port_merge.expected
*/
// IEEE 1800-2023 §6.6.8: an interconnect net is typeless and only expresses
// connections. §23.3.3.7.1: every port connection with an interconnect net
// merges the nets into one, which takes the type of the net on the other
// side. n connects an inout wire driven with 0 and an inout wor driven with
// 1; by Table 23-1 the wor dominates the wire, so the merged net resolves as
// a wor to 1 where a wire would give x.

module test_interconnect_port_merge_wire_drv(inout wire w);
  assign w = 1'b0;
endmodule

module test_interconnect_port_merge_wor_drv(inout wor w);
  assign w = 1'b1;
endmodule

module test_interconnect_port_merge_reader(input wire logic i);
  initial #1 $display("%m sees %b", i);
endmodule

module test_interconnect_port_merge;
  interconnect n;

  test_interconnect_port_merge_wire_drv d1(n);
  test_interconnect_port_merge_wor_drv d2(n);
  test_interconnect_port_merge_reader r(n);
endmodule
