/*
:name: test_vpi_udp_definitions
:description: a UDP instance gives its UDP definition, with the definition name, the number of inputs, whether it is combinational or sequential, its io declarations, its table entries with the number of symbols in each, and the initial statement of a sequential UDP (IEEE 1800-2023 Section 37.36)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.36 37.35 29.3 29.4 29.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_udp_definitions.c
:expected_stdout: @test_vpi_udp_definitions.expected
*/
// IEEE 1800-2023 §37.36: vpi_handle(vpiUdpDefn, udp) gives the definition of
// a UDP instance (§37.35); it has vpiDefName, vpiSize, the number of inputs,
// and vpiPrimType, vpiCombPrim for a combinational and vpiSeqPrim for a
// sequential UDP (detail 2). It iterates its io declarations (§29.3) with
// vpiIODecl and its table entries (§29.4) with vpiTableEntry, each with
// vpiSize, its number of symbol entries: the inputs and the output, plus the
// current state for a sequential UDP. The initial statement of a sequential
// UDP (§29.7) is reached with vpiInitial.

primitive maj3(output y, input a, b, c);
  table
    1 1 ? : 1;
    1 ? 1 : 1;
    ? 1 1 : 1;
    0 0 ? : 0;
    0 ? 0 : 0;
    ? 0 0 : 0;
  endtable
endprimitive

primitive latch_udp(output reg q, input en, d);
  initial q = 1'b0;
  table
    1 1 : ? : 1;
    1 0 : ? : 0;
    0 ? : ? : -;
  endtable
endprimitive

module test_vpi_udp_definitions;
  reg a = 1, b = 0, c = 1, en = 1, d = 1;
  wire y, q;

  maj3 m(y, a, b, c);
  latch_udp l(q, en, d);

  initial #1 $vt_udps;
endmodule
