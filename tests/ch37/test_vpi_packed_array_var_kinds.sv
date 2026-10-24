/*
:name: test_vpi_packed_array_var_kinds
:description: Packed arrays of packed structs, packed unions and enums are packed array vars for which vpiVector and vpiPacked are TRUE, as they are for every subelement down to the struct, union or enum elements; vpiSize is the number of bits and the number of leaf elements is the product of the sizes of the packed ranges; vpiConstantSelect of a subelement is TRUE in a static variable and FALSE in an element of a dynamic array (IEEE 1800-2023 Section 37.18)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.18 37.17 37.22 7.4.1 7.2.1 7.3.1 6.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_packed_array_var_kinds.c
:expected_stdout: @test_vpi_packed_array_var_kinds.expected
*/
// IEEE 1800-2023 §37.18 detail 1: a vpiPackedArrayVar represents a packed
// array of packed struct, union or enum vars, and vpiVector and vpiPacked are
// TRUE for it and for its underlying elements. Detail 2: its vpiSize is its
// number of bits (24, 16 and 12 here), and the number of struct, union or enum
// elements is the product of the vpiSize of its packed ranges (37.22): 3 x 2,
// 4 and 2 x 3. vpiElement (detail 3) gives one dimension level at a time, so
// the application walks it down to the leaves and counts them: as many as the
// product, each of the element kind and with both flags TRUE, and the
// intermediate levels are packed array vars with both flags TRUE as well.
// vpiConstantSelect of a subelement (diagram of 37.18; rule in 37.17 detail
// 27) is TRUE for pae[1] and pae[1][2], selected with constants from a static
// variable, and FALSE for the subelements of dpe[0], an element of a dynamic
// array.

typedef struct packed { logic [2:0] a; bit b; } test_vpi_packed_array_var_kinds_s;
typedef union packed { logic [3:0] w; test_vpi_packed_array_var_kinds_s s; }
  test_vpi_packed_array_var_kinds_u;
typedef enum logic [1:0] {PK0, PK1, PK2} test_vpi_packed_array_var_kinds_e;

module test_vpi_packed_array_var_kinds;
  test_vpi_packed_array_var_kinds_s [2:0][1:0] pas;
  test_vpi_packed_array_var_kinds_u [3:0] pau;
  test_vpi_packed_array_var_kinds_e [1:0][2:0] pae;
  test_vpi_packed_array_var_kinds_e [1:0] dpe [];

  initial begin
    dpe = new[1];
    #1 $vt_packed;
  end
endmodule
