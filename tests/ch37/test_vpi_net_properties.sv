/*
:name: test_vpi_net_properties
:description: Nets give their net type, size, sign, scalar or vector and range; a net bit is a scalar of size 1 with its index and its vector as parent; an implicit net is marked as implicitly declared, with line 0 (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 37.22 6.7 6.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_properties.c
:expected_stdout: @test_vpi_net_properties.expected
*/
// IEEE 1800-2023 §37.16: vpiNetType gives the kind of each net (6.7), vpiSize
// its width (detail 24), vpiSigned its sign, and vpiScalar and vpiVector
// whether it has a packed dimension (detail 28); vpiLeftRange and
// vpiRightRange give the bounds of a vector (detail 26), as written. The bit
// v[2] from vpi_handle_by_index is a vpiNetBit of size 1, a scalar, with index
// 2 (detail 10) and v as its vpiParent (detail 31). imp is declared implicitly
// by the continuous assignment to it (6.10), so vpiImplicitDecl is true,
// vpiLineNo is 0, and vpiFile is the file where it first appears (detail 9).

module test_vpi_net_properties;
  wire w;
  wire [7:0] v;
  wire signed [3:0] sv;
  wire [0:3] asc;
  tri t;
  wand wa;
  wor wo;
  triand ta;
  trior tor;
  tri0 t0;
  tri1 t1;
  supply0 s0;
  supply1 s1;
  uwire uw;
  trireg tr;
  logic [7:0] src = 8'h0f;

  assign v = src;
  assign imp = src[0];

  initial #1 $vt_nets;
endmodule
