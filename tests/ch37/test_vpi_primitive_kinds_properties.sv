/*
:name: test_vpi_primitive_kinds_properties
:description: a module iterates its gates, switches and UDP instances as primitives, each with its name, full name, number of inputs, drive strengths, module and array membership; a UDP instance gives its definition name, and a gate array gives its elements, which lead back to it (IEEE 1800-2023 Section 37.35)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.35 37.10 37.11 28.3.2 28.3.5 28.5 29.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_primitive_kinds_properties.c
:expected_stdout: @test_vpi_primitive_kinds_properties.expected
*/
// IEEE 1800-2023 §37.35: gates, switches and UDP instances are the members of
// the primitive group, so the vpiPrimitive iteration of a module (§37.10)
// returns all three kinds, here with vpiType vpiGate, vpiSwitch and vpiUdp,
// and every member has the properties and relations of the group. vpiName is
// the instance name and vpiFullName the hierarchical one; vpiSize is the number
// of inputs (detail 1): 3 for the and gate, 1 for the buf with two outputs
// (28.5), 2 for the nand and nor gates and for the two-input UDPs (29.8);
// vpiStrength0 and vpiStrength1 are the drive strengths written in the
// instantiation (28.3.2), as the strength constants of Annex K;
// vpiDefName of a UDP instance is the name of its UDP; vpiModule gives the
// module instance that holds the primitive, the top module or the instance
// sub. The gate array ga of the instance arr (28.3.5, 37.11) is a
// vpiGateArray, which iterates its two elements with vpiPrimitive;
// vpiPrimitiveArray of an element gives ga again, and vpiArrayMember and the
// deprecated vpiArray are TRUE for an element and FALSE for a primitive
// outside an array. The elements are told apart by their vpiIndex (detail 4).
// Strengths are printed only for the primitives that are given drive
// strengths, and the switch has no inputs printed. Lists are sorted by name.

primitive test_vpi_primitive_kinds_properties_or2 (output y, input a, input b);
  table
    1 ? : 1;
    ? 1 : 1;
    0 0 : 0;
  endtable
endprimitive

primitive test_vpi_primitive_kinds_properties_and2 (output y, input a, input b);
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive

module test_vpi_primitive_kinds_properties_cell (input wire i1, i2, output wire o);
  nand n1 (o, i1, i2);
endmodule

module test_vpi_primitive_kinds_properties_arr (input wire [1:0] p, q, output wire [1:0] r);
  nor (pull0, strong1) ga [1:0] (r, p, q);
endmodule

module test_vpi_primitive_kinds_properties;
  reg a = 1'b1, b = 1'b0, c = 1'b1;
  wire y1, y2, y3, y4, y5, y6, y7;
  wire [1:0] r;

  and (strong0, weak1) g_and (y1, a, b, c);
  buf (supply0, pull1) g_buf (y2, y3, a);
  nmos s_nmos (y4, a, c);
  test_vpi_primitive_kinds_properties_or2 u_or (y5, a, b);
  test_vpi_primitive_kinds_properties_and2 u_and (y6, b, c);

  test_vpi_primitive_kinds_properties_cell sub (.i1(a), .i2(b), .o(y7));
  test_vpi_primitive_kinds_properties_arr arr (.p({a, b}), .q({b, c}), .r(r));

  initial #1 $vt_prims;
endmodule
