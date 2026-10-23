/*
:name: test_vpi_interconnect_net_type_size
:description: An interconnect net and an interconnect array have vpiNetType vpiInterconnect; the net merged with a wand port has vpiResolvedNetType vpiWand and the size of that net; the array has the number of its elements as vpiSize and no typespec (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 6.6.8 23.3.3.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interconnect_net_type_size.c
:expected_stdout: @test_vpi_interconnect_net_type_size.expected
*/
// IEEE 1800-2023 §37.16: interconnect net and interconnect array are members
// of the nets group. Their vpiNetType is vpiInterconnect, and the
// vpiResolvedNetType of an interconnect net is the type of the simulated net
// (detail 12). vpiTypespec is NULL for an interconnect array (detail 13).
// vpiSize of an interconnect array is its number of elements, and that of an
// interconnect net that is not an array is the size of the net it is
// connected to (detail 24). §6.6.8, §23.3.3.7.1: a port connection merges an
// interconnect net with the net of the port into a net of the type of that
// net: iw is merged with the 4-bit wand port w, and each element of ia with a
// tri1 port, so no simulated net stays an interconnect.

module icts_wand (inout wand [3:0] w);
endmodule

module icts_tri1 (inout tri1 t);
endmodule

module test_vpi_interconnect_net_type_size;
  interconnect [3:0] iw;
  interconnect ia [0:2];

  icts_wand cw (.w(iw));
  icts_tri1 c0 (.t(ia[0]));
  icts_tri1 c1 (.t(ia[1]));
  icts_tri1 c2 (.t(ia[2]));

  initial #1 $vt_ic;
endmodule
