/*
:name: test_vpi_packed_array_typespec_ranges
:description: A packed array typespec iterates its packed range with vpi_iterate(vpiRange), and each range gives the declared left and right bounds, for named and unnamed packed arrays of packed structures with descending and ascending dimensions (IEEE 1800-2023 Section 37.25)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_packed_array_typespec_ranges.c
:expected_stdout: @test_vpi_packed_array_typespec_ranges.expected
*/
// IEEE 1800-2023 §37.25: in the typespec diagram, the bit, logic and packed
// array typespecs have a one-to-many relation to range, which an application
// walks with vpi_iterate(vpiRange) and vpi_scan. Detail 8 says that a packed
// array whose elements are packed structures is a packed array typespec, and
// detail 1 that its vpiName is the typedef name when there is one and NULL
// otherwise. Each packed array here has a single packed dimension, declared
// on a packed struct element (7.4.1), so the iteration gives exactly that one
// range: row_t is [5:2] of pr_s, col_t is [0:3] of pr_t, and the variable
// vanon has an unnamed [1:3] of pr_s. A struct typespec has no range relation
// of its own. The application gets each variable's typespec with
// vpiTypespec, checks its type, and prints the bounds of every range from
// vpiLeftRange and vpiRightRange, read as integers.

module test_vpi_packed_array_typespec_ranges;
  typedef struct packed { logic [1:0] f; bit g; } pr_s;
  typedef struct packed { bit [3:0] k; } pr_t;
  typedef pr_s [5:2] row_t;
  typedef pr_t [0:3] col_t;

  row_t vrow;
  col_t vcol;
  pr_s [1:3] vanon;

  initial #1 $vt_ranges;
endmodule
