/*
:name: test_vpi_handle_multi_intermod_path
:description: vpi_handle_multi with vpiInterModPath and two ports joined by a net returns the intermodule path between them (IEEE 1800-2023 Section 38.22)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.22 37.37 37.14
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_multi_intermod_path.c
:expected_stdout: @test_vpi_handle_multi_intermod_path.expected
*/
// IEEE 1800-2023 §38.22: vpi_handle_multi gives the object in a many-to-one
// relationship with two or more reference objects; §37.37: the intermodule
// path between two ports is reached with vpi_handle_multi(vpiInterModPath,
// port1, port2). The output port of s and the input port of d are joined by
// the net w; the ports are found by iterating vpiPort of each instance
// (37.14).

module test_vpi_handle_multi_intermod_path_src(output wire o);
  assign o = 1'b1;
endmodule

module test_vpi_handle_multi_intermod_path_dst(input wire i);
endmodule

module test_vpi_handle_multi_intermod_path;
  wire w;

  test_vpi_handle_multi_intermod_path_src s(.o(w));
  test_vpi_handle_multi_intermod_path_dst d(.i(w));

  initial #1 $vt_path;
endmodule
