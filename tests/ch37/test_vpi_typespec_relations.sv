/*
:name: test_vpi_typespec_relations
:description: vpiElemTypespec unwinds an array declared through several typedefs one dimension at a time and keeps their names; a dynamic or associative dimension of an array typespec is an empty range; an associative array typespec gives its index typespec, none for a wildcard index; a typedef of time aliases the predefined time typespec; an unpacked struct member gives its default value; an interconnect net has the typespec of the nets it connects and their members (IEEE 1800-2023 Sections 37.25, 37.22 and 37.24)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25 37.22 37.24 37.17 6.6.8 7.2.2 7.5 7.8 7.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_typespec_relations.c
:expected_stdout: @test_vpi_typespec_relations.expected
*/
// IEEE 1800-2023 §37.25 detail 8: vpiElemTypespec removes one dimension at a
// time and keeps the names of the typedefs: the typespec of grid, an unnamed
// array typespec with the ranges [4:1] and [0:2] (detail 10), gives row_t,
// then the logic typespec byte_t with two packed dimensions, then nib_t, then
// a logic typespec without a range, whose vpiElemTypespec is NULL. vpiLeftRange
// and vpiRightRange give the bounds of the leftmost dimension (detail 9), and
// a built-in type has no name (detail 1). §37.22: the range of a dynamic
// (§7.5) or associative (§7.8) dimension of an array typespec is empty, with
// vpiSize 0 and NULL bounds, and so are the bounds of the typespec when that
// dimension is the leftmost. Detail 2: vpiIndexTypespec of int aa [int] is an
// int typespec and NULL for the wildcard index of aw (§7.8.1). Detail 6:
// stamp_t is a time typespec whose vpiTypedefAlias is the predefined time
// typespec. Detail 7: the member a of the unpacked struct dflt_t gives its
// default value (§7.2.2) through vpiExpr. §37.24 detail 1: the
// interconnect net ic (§6.6.8) has the typespec of the port nets it connects,
// the packed struct bus_t, and vpiMember gives its members. Lists are sorted.

typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} test_vpi_typespec_relations_bus_t;

module test_vpi_typespec_relations_drv(output wire test_vpi_typespec_relations_bus_t o);
  assign o = 8'h5a;
endmodule

module test_vpi_typespec_relations_rcv(input wire test_vpi_typespec_relations_bus_t i);
endmodule

module test_vpi_typespec_relations;
  typedef logic [3:0] nib_t;
  typedef nib_t [1:0] byte_t;
  typedef byte_t row_t [0:2];
  typedef time stamp_t;
  typedef struct {
    int a = 5;
    int b;
  } dflt_t;

  row_t grid [4:1];
  int da [][0:1];
  int aa [int];
  int aw [*];
  stamp_t when;
  dflt_t ds;
  interconnect ic;

  test_vpi_typespec_relations_drv u1(ic);
  test_vpi_typespec_relations_rcv u2(ic);

  initial #1 $vt_typespecs;
endmodule
