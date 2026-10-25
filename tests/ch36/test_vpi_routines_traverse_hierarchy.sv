/*
:name: test_vpi_routines_traverse_hierarchy
:description: the routines of Table 36-3 do what it lists: vpi_handle follows a one-to-one relation from a net to its module, vpi_iterate and vpi_scan give each object of a one-to-many relation once, and vpi_handle_multi gives the intermodule path of an output port and an input port (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.18 38.23 38.40 38.22 37.37 37.10 37.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_traverse_hierarchy.c
:expected_stdout: @test_vpi_routines_traverse_hierarchy.expected
*/
// IEEE 1800-2023 §36.11, Table 36-3: vpi_handle obtains the handle of an
// object in a one-to-one relationship, vpi_iterate and vpi_scan the handles
// of the objects in a one-to-many relationship, and vpi_handle_multi the
// handle of an object in a many-to-one relationship. §38.18: vpi_handle(type,
// ref) returns the object of that type related to ref; a net is related to
// the module that contains it (37.16). §38.23, §38.40: vpi_iterate creates an
// iterator and vpi_scan returns each object once and then NULL; the vpiModule
// relation of a module gives its instances (37.10), and vpiNet its nets.
// §38.22, §37.37: vpi_handle_multi(vpiInterModPath, port1, port2) gives the
// intermodule path from an output port to an input port.
// At the start of simulation the application lists the instances of the top
// module and the nets of d1, sorted, gets the module of d1.inner, and the
// intermodule path from the port o of s to the port i of d1, both joined by w.
// Under Verilator 5.052 the vpiNet iteration of d1 is empty, and vpi_handle
// of a net and vpi_handle_multi return NULL.

module test_vpi_routines_traverse_hierarchy_src(output wire o);
  assign o = 1'b1;
endmodule

module test_vpi_routines_traverse_hierarchy_dst(input wire i);
  wire inner;
  assign inner = i;
endmodule

module test_vpi_routines_traverse_hierarchy;
  wire w;

  test_vpi_routines_traverse_hierarchy_src s(.o(w));
  test_vpi_routines_traverse_hierarchy_dst d1(.i(w));
  test_vpi_routines_traverse_hierarchy_dst d2(.i(w));

  initial #1 $display("design: w=%b d1.inner=%b", w, d1.inner);
endmodule
