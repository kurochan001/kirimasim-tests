/*
:name: test_vpi_module_port_io_decl_relations
:description: a module iterates its ports and its IO declarations, and vpiModule of each port and each IO declaration leads back to the instance that has it; a module without ports has neither (IEEE 1800-2023 Section 37.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.13 37.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_port_io_decl_relations.c
:expected_stdout: @test_vpi_module_port_io_decl_relations.expected
*/
// IEEE 1800-2023 §37.5: a module has one-to-many relations to its ports and
// to its IO declarations, traversed with vpi_iterate(vpiPort) and
// vpi_iterate(vpiIODecl), and each port and each IO declaration has a
// one-to-one relation back to its module, vpi_handle(vpiModule). u1 and u2
// are two instances of the same module with the ports a, y and z; the
// application prints, in the order of vpiPortIndex (§37.14), the ports of
// each instance with the full name of the module that vpiModule gives for
// each, and the IO declarations of u1 with their direction (§37.13). The top
// module has no ports, so both of its iterations give no object. The output
// is printed from a cbStartOfSimulation callback. The VPI headers of Icarus
// Verilog 13.0 do not define vpiIODecl, so the application does not build
// there, and in Verilator 5.052 vpi_iterate(vpiPort) gives no port.

module test_vpi_module_port_io_decl_relations_leaf(input wire a, output wire y, inout wire z);
  assign y = a;
endmodule

module test_vpi_module_port_io_decl_relations;
  logic a1 = 1'b0, a2 = 1'b1;
  wire y1, y2, z1, z2;

  test_vpi_module_port_io_decl_relations_leaf u1(.a(a1), .y(y1), .z(z1));
  test_vpi_module_port_io_decl_relations_leaf u2(.a(a2), .y(y2), .z(z2));
endmodule
