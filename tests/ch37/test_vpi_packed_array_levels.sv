/*
:name: test_vpi_packed_array_levels
:description: vpiElement unwinds a two-dimensional packed array of packed structs one dimension at a time; every subelement has the whole array as vpiParent, is a packed array member and iterates its indices from the element outward; a packed array that is a struct member is a struct member while its elements are not (IEEE 1800-2023 Section 37.18)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.18 37.17 37.26 37.22 7.4.1 7.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_packed_array_levels.c
:expected_stdout: @test_vpi_packed_array_levels.expected
*/
// IEEE 1800-2023 §37.18: pav, a packed array (§7.4.1) of packed structs
// (§7.2.1) with two packed dimensions, is a vpiPackedArrayVar whose vpiSize
// is its number of bits, 2 x 3 x 8 (detail 2), as it is for its packed array
// subelements; vpiRange gives its ranges from the leftmost (37.17 detail 4).
// vpiElement returns one dimension level at a time
// (detail 3): first the packed array vars pav[0] and pav[1], whose own
// elements are the struct vars pav[1][0] to pav[1][2], of 8 bits (37.17
// detail 9). Their names carry their indices (37.17 detail 28); vpiParent
// of each is pav, the largest containing packed array (detail 3);
// vpiPackedArrayMember is TRUE for them (detail 4); vpi_iterate(vpiIndex)
// gives the indices from the element outward, 2 then 1 for pav[1][2]
// (detail 6). vpiStructUnionMember is TRUE only for a packed array var that
// is a direct member of a struct (detail 5): FALSE for pav[1], TRUE for the
// member pp of the struct rv (37.26), whose parent is rv, and FALSE for the
// elements of pp, whose parent is pp (37.17 detail 26). Values are read in
// hex, every one with a nonzero top digit. Element lists are sorted by name.

module test_vpi_packed_array_levels;
  typedef struct packed {
    logic [3:0] hi, lo;
  } pair_t;

  typedef struct packed {
    pair_t [1:0] pp;
    logic [7:0] tag;
  } rec_t;

  pair_t [1:0][2:0] pav = {8'h92, 8'h91, 8'h90, 8'h82, 8'h81, 8'h80};
  rec_t rv = {8'h97, 8'h96, 8'h95};

  initial #1 $vt_levels;
endmodule
