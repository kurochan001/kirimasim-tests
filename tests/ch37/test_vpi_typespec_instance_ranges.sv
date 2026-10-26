/*
:name: test_vpi_typespec_instance_ranges
:description: An instance iterates the named typespecs it declares with vpiTypespec, and a packed array typespec iterates its packed ranges from the leftmost and gives the leftmost bounds, with the typedef name of the element typespec (IEEE 1800-2023 Section 37.25)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25 6.18 7.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_typespec_instance_ranges.c
:expected_stdout: @test_vpi_typespec_instance_ranges.expected
*/
// IEEE 1800-2023 §37.25: an instance gives its typespecs with the untagged
// typespec access relation, traversed with vpi_iterate (diagram). For a
// packed array typespec, vpi_iterate(vpiRange) gives the packed ranges
// beginning with the leftmost and continuing to the rightmost (detail 10),
// and vpiLeftRange and vpiRightRange give the bounds of the leftmost packed
// dimension (detail 9). The name of a typespec is the name of its typedef
// (detail 1): word_t is a four-state logic type with the packed range [1:0],
// arr_t is a packed array type with the ranges [2:1] and [4:3], and pst_t is
// a struct type. Only named typespecs are printed, sorted, because built-in
// type objects have no name (detail 1) and the order of the iteration is not
// fixed. An inline typedef field may have the empty name (detail 5); the
// standard allows either the empty name or no name there, so it is not
// printed.

module tsp_child;
endmodule

module test_vpi_typespec_instance_ranges;
  typedef logic [1:0] word_t;
  typedef word_t [2:1][4:3] arr_t;
  typedef struct { logic [3:0] f; } pst_t;

  word_t w;
  arr_t a;
  pst_t p;
  tsp_child u ();

  initial #1 $vt_ts;
endmodule
