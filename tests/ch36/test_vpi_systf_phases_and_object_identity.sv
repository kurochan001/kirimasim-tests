/*
:name: test_vpi_systf_phases_and_object_identity
:description: A linked-in VPI application reads elaborated objects at run time, its compiletf runs while the design is built and its calltf on each call, and equal declarations in two instances are distinct objects while a simulation object is reachable (IEEE 1800-2023 Section 36.2, 36.6, 36.8, 36.10)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.2 36.6 36.8 36.10 38.37
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_phases_and_object_identity.c
:expected_stdout: @test_vpi_systf_phases_and_object_identity.expected
*/
// IEEE 1800-2023 §36.2: the PLI is a procedural interface through which C
// functions access the instantiated design. §36.6: a user-supplied PLI
// application is a C function linked into the tool and called when its
// $name is executed. §36.8: the sizetf, compiletf and calltf routines run in
// their own phases; compiletf runs while the design is built (before the
// cbEndOfCompile callback) and calltf on each call. §36.10: each instance of an
// object is uniquely accessible, so u1.w and u2.w are distinct objects with
// their own values, and VPI also exposes simulation objects, here the
// intermodule path between s.o and d.i.
//
// The system function $vt_value is registered with a compiletf and a calltf;
// its calltf prints a line and puts 31 as the call's return value (38.34).
// $vt_report reads u1.w and u2.w through vpi_get_value and asks for the
// intermodule path with vpi_handle_multi (38.22). The 13.0 release of Icarus
// Verilog does not call sizetf here, so the test observes the compiletf and
// calltf phases of 36.8 and leaves sizetf to the existing sized-function test.

module vsi_unit(input wire w, output wire o);
  assign o = w;
endmodule

module vsi_src(output wire o);
  assign o = 1'b1;
endmodule

module vsi_dst(input wire i);
endmodule

module test_vpi_systf_phases_and_object_identity;
  reg a = 1'b1, b = 1'b0;
  wire o1, o2, n1;

  vsi_unit u1(.w(a), .o(o1));
  vsi_unit u2(.w(b), .o(o2));
  vsi_src s(.o(n1));
  vsi_dst d(.i(n1));

  initial begin
    $display("value=%0d", $vt_value());
    $vt_report;
  end
endmodule
