/*
:name: test_vpi_attribute_ports_params
:description: An attribute on an ANSI port declaration is iterated with vpiAttribute from the port of the instance, one on a parameter declaration from each param assign of that declaration, each leads back with vpiParent, and vpiDefFile and vpiDefLineNo of an attribute give the file and line where it is written (IEEE 1800-2023 Section 37.83)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.83 5.12 37.14 37.28 A.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_attribute_ports_params.c
:expected_stdout: @test_vpi_attribute_ports_params.expected
*/
// IEEE 1800-2023 §37.83: a port and a param assign iterate their attributes
// with vpiAttribute, and vpiParent of each attribute leads back to the object
// it belongs to. An attribute has vpiName, a value read with vpi_get_value(),
// and a definition location: vpiDefFile, the source file in which it is
// written, and vpiDefLineNo, the line. §5.12: an attribute instance written
// before a declaration is attached to it; a declaration that declares several
// items gives the attribute to each of them, and items declared without it do
// not have it. A.1.3: an attribute instance can precede each ANSI port
// declaration. §37.28: an instance iterates the param assigns of its
// parameters with vpiParamAssign, and vpiLhs of a param assign is the
// parameter. §37.14: an instance iterates its ports with vpiPort.
//
// In atp_leaf, the port p has the attribute a_port and the port q none; the
// one parameter declaration with a_param declares P and Q, and R is declared
// without an attribute; the net w has a_net. Each attribute is written on the
// same line as what it is attached to, so its definition line is that line,
// and none is on the line of the module header. From a start-of-simulation
// callback the application prints, for each port and param assign of the
// instance u, the name and value of its attributes and whether their
// vpiParent is that object, and for each attribute found, and the one of w,
// the base name of vpiDefFile and vpiDefLineNo; the lines are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiAttribute, vpiParamAssign and vpiLhs,
// and a run with Verilator 5.052 prints nothing, as it gives no ports, no
// param assigns and no attributes.

module atp_leaf (
  (* a_port = 1 *) input logic p,
  input logic q
);
  (* a_param = 2 *) parameter int P = 4, Q = 5;
  parameter int R = 6;
  (* a_net = 3 *) wire w;
endmodule

module test_vpi_attribute_ports_params;
  logic x, y;

  atp_leaf u (.p(x), .q(y));
endmodule
