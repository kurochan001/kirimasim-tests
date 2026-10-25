/*
:name: test_array_query_dimension_numbering_typedefs
:description: array query functions number dimensions from the slowest varying one, unpacked before packed, after expanding the typedefs that a declaration uses (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_dimension_numbering_typedefs.expected
*/
// IEEE 1800-2023 §20.7: the slowest varying dimension of an array, packed or
// unpacked, is dimension 1, and faster varying dimensions get the next
// numbers; typedefs used in the declaration are expanded before the
// dimensions are numbered. The unpacked dimensions of a variable vary more
// slowly than those of its element type, and unpacked dimensions more slowly
// than packed ones.
// z is declared with an unpacked range [6:7] and the type up_t, a typedef of
// an unpacked array [2:3] of pk_t, which is a packed [7:4][0:2] array. So the
// dimensions of z are 1 [6:7], 2 [2:3], 3 [7:4] and 4 [0:2]. w is written
// out with the same dimensions and gives the same numbers. Each line shows
// $left, $right and $size of one dimension of z and w.
// Icarus Verilog 13.0 numbers the unpacked dimension of the typedef up_t
// before that of z, so it shows [2:3] as dimension 1 and [6:7] as 2.

module test_array_query_dimension_numbering_typedefs;
  typedef bit [7:4][0:2] pk_t;
  typedef pk_t up_t [2:3];
  up_t z [6:7];
  bit [7:4][0:2] w [6:7][2:3];

  initial begin
    $display("dim 1: z %0d %0d %0d w %0d %0d %0d", $left(z, 1), $right(z, 1), $size(z, 1),
             $left(w, 1), $right(w, 1), $size(w, 1));
    $display("dim 2: z %0d %0d %0d w %0d %0d %0d", $left(z, 2), $right(z, 2), $size(z, 2),
             $left(w, 2), $right(w, 2), $size(w, 2));
    $display("dim 3: z %0d %0d %0d w %0d %0d %0d", $left(z, 3), $right(z, 3), $size(z, 3),
             $left(w, 3), $right(w, 3), $size(w, 3));
    $display("dim 4: z %0d %0d %0d w %0d %0d %0d", $left(z, 4), $right(z, 4), $size(z, 4),
             $left(w, 4), $right(w, 4), $size(w, 4));
    $display("dimensions z=%0d w=%0d unpacked z=%0d w=%0d", $dimensions(z), $dimensions(w),
             $unpacked_dimensions(z), $unpacked_dimensions(w));
  end
endmodule
