/*
:name: test_vpi_instance_array_relations
:description: Module, interface and program arrays give their elements through vpiInstance and each element gives its array through vpiInstanceArray; a module array also through vpiModule and vpiModuleArray; gate, switch and UDP arrays are primitive arrays whose primitives give their array through vpiPrimitiveArray; arrays have a local name, a full name and a size, and vpiExpr of a module array is a list operation of its connections (IEEE 1800-2023 Section 37.11)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.11 23.3.3.5 28.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_array_relations.c
:expected_stdout: @test_vpi_instance_array_relations.expected
*/
// IEEE 1800-2023 §37.11: interface, program and module arrays are instance
// arrays; vpi_iterate(vpiInstance) of one gives its element instances and
// vpi_handle(vpiInstanceArray) of an element gives the array back. A module
// array has the same pair of relations with vpiModule and vpiModuleArray. Gate,
// switch and UDP arrays are primitive arrays (vpiGateArray, vpiSwitchArray and
// vpiUdpArray), which give their primitives through vpiPrimitive, and each
// primitive gives its array through vpiPrimitiveArray. An instance array has
// vpiName, its own name, vpiFullName and vpiSize, the number of elements.
// vpiExpr of an instance array is an operation of type vpiListOp (detail 1)
// that holds the connections written in the source: for ma those are ia and
// iy, in that order. Elements are named by their index (23.3.3.5, 28.3.6);
// the application sorts them by full name, since the order of an iteration is
// not fixed, and prints the names of the arrays that the elements give back.

primitive iar_udp (y, a);
  output y;
  input a;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

interface iar_if;
  logic s;
endinterface

program iar_prog;
  int pv;
endprogram

module iar_leaf (input wire a, output wire y);
  assign y = a;
endmodule

module test_vpi_instance_array_relations;
  wire [2:0] ia, iy;
  wire [1:0] ga, gy, ua, uy, sa, sb;
  wire sc = 1'b1;

  iar_leaf ma [2:0] (ia, iy);
  iar_if ifa [1:0] ();
  iar_prog pga [0:1] ();
  buf gb [1:0] (gy, ga);
  tranif1 sw [1:0] (sa, sb, sc);
  iar_udp uda [1:0] (uy, ua);

  initial #1 $vt_arrays;
endmodule
