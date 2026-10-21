/*
:name: test_vpi_intermod_path_levels
:description: vpi_handle_multi with vpiInterModPath returns the intermodule path between an output port of a nested instance and an input port at another level of the hierarchy, and the ports of the path include those two ports (IEEE 1800-2023 Section 38.22)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.22 37.37 37.14 38.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_intermod_path_levels.c
:expected_stdout: @test_vpi_intermod_path_levels.expected
*/
// IEEE 1800-2023 §38.22: vpi_handle_multi(vpiInterModPath, ...) returns the
// intermodule path between an output port and an input port of the same size,
// which can be at different levels of the hierarchy. §37.37: an intermodule
// path leads to ports, among them the two it was obtained from; which other
// ports the iteration returns is not fixed, so only those two are looked for.
// The 4-bit output port of m.leaf drives, through the port of m and the net w,
// the 4-bit input port of s, one level higher in the hierarchy. The ports are
// found by iterating vpiPort of each instance (37.14), and the ports of the
// path are compared with them by vpi_compare_objects (38.3). Icarus Verilog
// 13.0 reports that it cannot insert the path and returns NULL.

module test_vpi_intermod_path_levels_leaf(output wire [3:0] o);
  assign o = 4'd9;
endmodule

module test_vpi_intermod_path_levels_mid(output wire [3:0] q);
  test_vpi_intermod_path_levels_leaf leaf(.o(q));
endmodule

module test_vpi_intermod_path_levels_sink(input wire [3:0] i);
endmodule

module test_vpi_intermod_path_levels;
  wire [3:0] w;

  test_vpi_intermod_path_levels_mid m(.q(w));
  test_vpi_intermod_path_levels_sink s(.i(w));

  initial #1 $vt_path;
endmodule
