/*
:name: test_vpi_module_process_assign_primitive_relations
:description: a module iterates its processes, its continuous assignments and its primitives, each of which, like a primitive array, leads back to its instance through vpiModule; a module without them iterates none (IEEE 1800-2023 Section 37.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.35 37.47 37.63
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_process_assign_primitive_relations.c
:expected_stdout: @test_vpi_module_process_assign_primitive_relations.expected
*/
// IEEE 1800-2023 §37.5: a module has one-to-many relations to its processes
// (vpiProcess), its continuous assignments (vpiContAssign) and its
// primitives (vpiPrimitive), and each of them, as well as a primitive array,
// has a one-to-one relation back to the module, vpi_handle(vpiModule). u1
// and u2 are instances of a module with an initial, an always and a final
// procedure (§37.63), two continuous assignments to y1 and y2 (§37.47), a
// gate g1 and an instance p1 of a UDP (§37.35). The application prints, for
// u1 and u2, each object, sorted, with the instance that vpiModule gives for
// it; the top module has none of these objects. The gate array ga is in the
// instance pa, and vpiModule of the array gives pa. The output is printed
// from a cbStartOfSimulation callback, before any procedure runs. The VPI
// headers of Icarus Verilog 13.0 lack vpiProcess and other constants used
// here, and in Verilator 5.052 the iterations give no object.

primitive test_vpi_module_process_assign_primitive_relations_udp(output o, input i);
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module test_vpi_module_process_assign_primitive_relations_leaf(input wire a, input wire b,
                                                               output wire y1, output wire y2,
                                                               output wire y3, output wire y4);
  logic r;

  assign y1 = a & b;
  assign y2 = a | b;
  and g1 (y3, a, b);
  test_vpi_module_process_assign_primitive_relations_udp p1 (y4, a);

  initial r = 1'b0;
  always @(a) r = a;
  final r = 1'b1;
endmodule

module test_vpi_module_process_assign_primitive_relations_arr(input wire [1:0] i,
                                                              output wire [1:0] o);
  not ga [1:0] (o, i);
endmodule

module test_vpi_module_process_assign_primitive_relations;
  logic a, b;
  logic [1:0] i;
  wire y1, y2, y3, y4, z1, z2, z3, z4;
  wire [1:0] o;

  test_vpi_module_process_assign_primitive_relations_leaf u1(a, b, y1, y2, y3, y4);
  test_vpi_module_process_assign_primitive_relations_leaf u2(b, a, z1, z2, z3, z4);
  test_vpi_module_process_assign_primitive_relations_arr pa(i, o);
endmodule
