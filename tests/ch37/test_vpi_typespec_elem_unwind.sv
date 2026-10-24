/*
:name: test_vpi_typespec_elem_unwind
:description: vpiElemTypespec unwinds array, packed array, bit and logic typespecs one leftmost dimension at a time, keeping the typedef names of the intermediate levels, down to a struct, union or enum typespec or a bit or logic typespec without range, for which it is NULL; vpiLeftRange and vpiRightRange give the leftmost packed dimension and vpiVector tells whether a bit, logic or packed array typespec has a packed dimension (IEEE 1800-2023 Section 37.25)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25 7.4 7.2.1 7.3.1 6.19 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_typespec_elem_unwind.c
:expected_stdout: @test_vpi_typespec_elem_unwind.expected
*/
// IEEE 1800-2023 §37.25 detail 8: vpi_handle(vpiElemTypespec) applied to an
// array typespec gives the typespec with the leftmost unpacked range removed,
// and applied to a packed array, bit or logic typespec with packed ranges the
// one with the leftmost packed range removed, until no range is left; for a
// struct, union or enum typespec and for a bit or logic typespec without range
// it gives NULL. Typedef names are kept at each level: the typespec of va
// (arr_t [1:0], no name) gives arr_t, which gives nib_t, which gives a logic
// typespec without range; the typespec of vpa (eu_row [1:0], no name) gives
// eu_row and then the struct eu_s; vpu and vpe end at the union eu_u and the
// enum eu_e. Detail 9: vpiLeftRange and vpiRightRange of a bit, logic or
// packed array typespec give its leftmost packed dimension (3 and 0 for vb, 1
// and 0 for vpa). Detail 10: a bit typespec iterates its packed ranges from
// the leftmost. vpiVector is TRUE for a bit, logic or packed array typespec
// with a packed dimension and FALSE for one without (diagram of 37.25 and
// 37.17 detail 20).

typedef struct packed { logic [1:0] p; } test_vpi_typespec_elem_unwind_s;
typedef union packed { logic [1:0] w; bit [1:0] b; } test_vpi_typespec_elem_unwind_u;
typedef enum logic [1:0] {EU0, EU1} test_vpi_typespec_elem_unwind_e;

module test_vpi_typespec_elem_unwind;
  typedef test_vpi_typespec_elem_unwind_s [2:0] eu_row;
  typedef logic [3:0] nib_t;
  typedef nib_t arr_t [0:2];

  bit [3:0][1:0] vb;
  logic [5:2] vl;
  logic vs;
  eu_row [1:0] vpa;
  test_vpi_typespec_elem_unwind_u [3:1] vpu;
  test_vpi_typespec_elem_unwind_e [0:1] vpe;
  arr_t va [1:0];

  initial #1 $vt_unwind;
endmodule
