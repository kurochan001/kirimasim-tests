/*
:name: test_vpi_udp_table_primitive
:description: A UDP definition gives vpiProtected FALSE, its primitive type, its table entries and their string decompilation, and a UDP instance gives its delay expression, each primitive terminal leads to the primitive and to its expression, and the terminal extent is the number of inputs (IEEE 1800-2023 Sections 37.35, 37.36)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.35 37.36 29.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_udp_table_primitive.c
:expected_stdout: @test_vpi_udp_table_primitive.expected
*/
// IEEE 1800-2023 §37.35: a primitive gives its delay expression with the tag
// vpiDelay (diagram), a primitive terminal leads to its primitive with the
// untagged primitive access type and to its expression with the untagged
// expression access type (diagram), and vpiSize of a primitive is its number
// of inputs (detail 1). §37.36: a UDP definition gives vpiProtected, which is
// FALSE for source that is not encrypted (37.3.6), its vpiPrimType, which is
// vpiCombPrim for a combinational UDP (detail 2), and its table entries; only
// the string (decompilation) and vector (ASCII) formats are available for a
// table entry (detail 1), and the test reads the string form of each entry.
// The entries are sorted because their iteration order is not fixed, and the
// terminals are printed by term index, whose order is fixed (37.35 detail 3).

primitive upd_and (o, a, b);
  output o;
  input a, b;
  table
    0 ? : 0;
    1 0 : 0;
    1 1 : 1;
  endtable
endprimitive

module test_vpi_udp_table_primitive;
  logic a = 1'b1, b = 1'b1, o;
  logic [1:0] unused;

  upd_and #3 g (o, a, b);

  initial #1 $vt_udp;
endmodule
